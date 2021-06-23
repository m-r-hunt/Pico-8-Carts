local function new(class,...)
	local n=setmetatable({},{__index=class})
	if class.construct then
		n:construct(...)
	end
	return n
end
local function Class(table)
	return setmetatable(table,{__call=new})
end

local Entity=Class{
	construct=function(self,x,y,sprite)
		self.x=x
		self.y=y
		self.sprite=sprite
	end,

	move=function(self,dx,dy)
		self.x+=dx
		self.y+=dy
	end,

	draw=function(self)
		spr(self.sprite,self.x*8,self.y*8)
	end
}

local Tile=Class{
	construct=function(self,blocked,block_sight)
		self.blocked=blocked
		if block_sight==nil then
			block_sight=blocked
		end
		self.block_sight=block_sight
	end
}

local function initializeTiles(width,height)
	local tiles={}
	for x=0,width-1 do
		tiles[x]={}
		for y=0,height-1 do
			tiles[x][y]=Tile(false)
		end
	end

	tiles[4][2].blocked=true
	tiles[4][2].block_sight=true
	tiles[5][2].blocked=true
	tiles[5][2].block_sight=true
	tiles[6][2].blocked=true
	tiles[6][2].block_sight=true

	return tiles
end

local GameMap=Class{
	construct=function(self,width,height)
		self.width=width
		self.height=height
		self.tiles=initializeTiles(width,height)
	end,

	isBlocked=function(self,x,y)
		return self.tiles[x][y].blocked
	end,

	draw=function(self)
		for x,row in pairs(self.tiles) do
			for y,t in pairs(row) do
				local wall=t.block_sight

				if wall then
					spr(64,x*8,y*8)
				else
					spr(65,x*8,y*8)
				end
			end
		end
	end
}

local main_thread=nil
game_map=GameMap(16,16)
local player=Entity(8,8,1)
local npc=Entity(6,8,2)
local entities={npc,player}

local function handleKeys()
	if (btnp(0)) return {move={-1,0}}
	if (btnp(1)) return {move={1,0}}
	if (btnp(2)) return {move={0,-1}}
	if (btnp(3)) return {move={0,1}}

	return {}
end

local function main()
	while true do
		local dt=yield()
		local action=handleKeys()
		if action.move then
			local dx,dy=unpack(action.move)
			if (not game_map:isBlocked(player.x+dx,player.y+dy)) player:move(dx,dy)
		end
	end
end

local function _init()
	main_thread=cocreate(main)
end

local function _update(dt)
	assert(coresume(main_thread,dt))
end

local function _draw()
	cls()

	game_map:draw()

	for e in all(entities) do
		e:draw()
	end
end