

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

	draw=function(self,fov)

		for x,y in fov:iter() do
			spr(mget(x,y),x*8,y*8)
		end
	end
}

local game_map=GameMap()

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
	local start_x=0
	local start_y=0
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
				start_x=nx
				start_y=ny
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
	return start_x,start_y
end