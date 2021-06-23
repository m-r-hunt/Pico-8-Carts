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

local GameMap=Class{
	isBlocked=function(self,x,y)
		return fget(mget(x,y),0)
	end,

	draw=function(self)
		map(0,0,0,0,128,64)
	end
}

local game_map=GameMap()
local player=Entity(8,8,1)
local npc=Entity(6,8,2)
local entities={npc,player}

local Rect=Class{
	construct=function(self,x,y,w,h)
		self.x1=x
		self.y1=y
		self.x2=x+w
		self.y2=y+h
	end,

	create=function(self)
		for x=self.x1+1,self.x2-1 do
			for y=self.y1+1,self.y2-1 do
				mset(x,y,65)
			end
		end
	end,

	center=function(self)
		local cx=flr((self.x1+self.x2)/2)
		local cy=flr((self.y1+self.y2)/2)
		return cx,cy
	end,

	intersects=function(self,other)
		return self.x1<=other.x2 and self.x2>=other.x1 and self.y1<=other.y2 and self.y2>=other.y1
	end
}

local function createHTunnel(x1,x2,y)
	for x=min(x1,x2),max(x1,x2) do
		mset(x,y,65)
	end
end

local function createVTunnel(y1,y2,x)
	for y=min(y1,y2),max(y1,y2) do
		mset(x,y,65)
	end
end

local room_max_size=10
local room_min_size=6
local max_rooms=30
local map_width=128
local map_height=64
local function makeMap()
	local rooms={}
	for r=1,max_rooms do
		local w=room_min_size+flr(rnd(room_max_size))
		local h=room_min_size+flr(rnd(room_max_size))
		local x=rnd(map_width-w)
		local y=rnd(map_height-h)
		local new_room=Rect(x,y,w,h)
		local any_clash=false
		for other in all(rooms) do
			if new_room:intersects(other) then
				any_clash=true
				break
			end
		end
		if not any_clash then
			new_room:create()
			local nx,ny=new_room:center()
			if #rooms==0 then
				player.x=nx
				player.y=ny
			else
				local px,py=rooms[#rooms]:center()
				if rnd(1)<0.5 then
					createHTunnel(px,nx,py)
					createVTunnel(py,ny,nx)
				else
					createVTunnel(py,ny,px)
					createHTunnel(px,nx,ny)
				end
			end
			add(rooms,new_room)
		end
	end
	foreach(rooms,Rect.create)
end

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

local main_thread=nil
local function _init()
	main_thread=cocreate(main)
	makeMap()
end

local function _update(dt)
	assert(coresume(main_thread,dt))
end

local function _draw()
	cls()

	camera(player.x*8-64,player.y*8-64)

	game_map:draw()

	for e in all(entities) do
		e:draw()
	end
end