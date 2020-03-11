pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--core

vec2mt={
	__add=function(v1,v2)
		return vec2(v1.x+v2.x,v1.y+v2.y)
	end,
	__sub=function(v1,v2)
		return vec2(v1.x-v2.x,v1.y-v2.y)
	end,
	__mul=function(s,v)
		return vec2(s*v.x,s*v.y)
	end,
	__len=function(self)
		return sqrt(self.x*self.x+self.y*self.y)
	end,
	__eq=function(v1,v2)
		return v1.x==v2.x and v1.y==v2.y
	end,
	floored = function(self)
		return vec2(flr(self.x),flr(self.y))
	end,
	tostring=function(v)
		return "vec2("..v.x..","..v.y..")"
	end,
}
vec2mt.__index=vec2mt

function vec2(x,y)
	return setmetatable({x=x,y=y},vec2mt)
end

node={position=vec2(0,0),global_position=vec2(0,0)}
node.__index=node
function node:new(t)
	t=t or {}
	setmetatable(t,self)
	t.__index=t
	t.children={}
	return t
end

function node:add_child(n)
	add(self.children,n)
	n.parent=self
	if self.readied then
		n:ready()
	end
	n:set_position()
end

function node:remove_child(n)
	del(self.children,n)
	n.parent=nil
	if self.readied then
		n:unready()
	end
end

function node:set_position(p)
	p=p or self.position
	self.position=p
	self.global_position=self.parent and (self.parent.global_position+self.position) or self.position
	for i=1,#self.children do
		self.children[i]:set_position()
	end
end

function node:ready()
	self:readycb()
	self.readied=true
	for child in all(self.children) do
		child:ready()
	end
end
function node:readycb()
end

function node:unready()
	self:unreadycb()
	self.readied=false
	for child in all(self.children) do
		child:unready()
	end
end
function node:unreadycb()
end

function node:update()
	self:updatecb()
	for i=1,#self.children do
		self.children[i]:update()
	end
end
function node:updatecb() end

function node:draw()
	self:drawcb()
	for i=1,#self.children do
		self.children[i]:draw()
	end
end
function node:drawcb() end

function _init()
	root:set_position()
	root:ready()
end

function _update()
	root:update()
end

function _draw()
	cls(12)
	root:draw()
	print(stat(1),0,0,1)
end

-->8
--physics

colliders={}

function add_collider(t,pos,size)
	colliders[t]={pos=pos,size=size}
end

function remove_collider(t)
	colliders[t]=nil
end

function check_against_colliders(exc,x,y,w,h)
	local x1=x-w
	local x2=x+w-1
	local y1=y-h
	local y2=y+h-1
	for t,c in pairs(colliders) do
		local xx1=c.pos.x-c.size.x
		local xx2=c.pos.x+c.size.x-1
		local yy1=c.pos.y-c.size.y
		local yy2=c.pos.y+c.size.y-1
		if t!=exc then
			if ((x1>=xx1 and x1<=xx2) or (x2>=xx1 and x2<=xx2) or (x1<=xx1 and x2>=xx2)) and
			   ((y1>=yy1 and y1<=yy2) or (y2>=yy1 and y2<=yy2) or (y1<=yy1 and y2>=yy2)) then
				return true
			end
		end
	end
	return false
end

function add_contact(contacts,c)
	for cc=1,#contacts do
		if (contacts[cc]==c) return
	end
	add(contacts,c)
end

function check_against_map(contacts,x,y,w,h)
	local tile_x1=flr((x-w)/8)
	local tile_x2=flr((x+w-1)/8)
	local tile_y1=flr((y-h)/8)
	local tile_y2=flr((y+h-1)/8)
	for tx=tile_x1,tile_x2 do
		for ty=tile_y1,tile_y2 do
			local flags=fget(mget(tx,ty))
			if flags!=0 then
				add_contact(contacts,vec2(tx,ty))
			end
			if (band(flags,1)!=0) return true
		end
	end
end

function move_collider(t,new_pos)
	local hit=false
	local hit_normal=vec2(0,0)
	local col=colliders[t]
	local tile_x=flr(col.pos.x/8)
	local vec=new_pos-col.pos
	local contacts={}
	for y=col.pos.y,new_pos.y,sgn(vec.y) do
		local tile_y=flr((y-col.size.y)/8)
		local tile_y2=flr((y+col.size.y-1)/8)
		if check_against_map(contacts,col.pos.x,y,col.size.x,col.size.y) or check_against_colliders(t,col.pos.x,y,col.size.x,col.size.y) then
			hit=true
			hit_normal.y=-sgn(vec.y)
			break
		end
		col.pos.y=y
	end
	local tile_y=flr(col.pos.y/8)
	for x=col.pos.x,new_pos.x,sgn(vec.x) do
		local tile_x=flr((x-col.size.y)/8)
		local tile_x2=flr((x+col.size.x-1)/8)
		if check_against_map(contacts,x,col.pos.y,col.size.x,col.size.y) or check_against_colliders(t,x,col.pos.y,col.size.x,col.size.y) then
			hit=true
			hit_normal.x=-sgn(vec.x)
			break
		end
		col.pos.x=x
	end
	return col.pos,hit,hit_normal,contacts
end

-->8
--nodes

sprite=node:new()
function sprite:drawcb()
	local pos=self.global_position:floored()-vec2(4,4)-camera_pos
	spr(self.s,pos.x,pos.y)
end

kinematicbody=node:new{size=vec2(4,4)}
function kinematicbody:readycb()
	add_collider(self,self.position,self.size)
end
function kinematicbody:unreadycb()
	remove_collider(self)
end

faller=kinematicbody:new{position=vec2(100,5),direction=vec2(0,1)}
function faller:updatecb()
	if btn(4) then
		self.direction=vec2(0,-1)
	else
		self.direction+=vec2(0,0.5)
	end
	if (btn(0)) self.direction.x=-1
	if (btn(1)) self.direction.x=1
	local new_pos=self.position+self.direction
	local pos,hit,hit_normal,contacts=move_collider(self,new_pos:floored())
	if (not hit) pos=new_pos
	if hit and hit_normal.y!=0 then
		self.direction=vec2(0,0)
	end
	self:set_position(pos)
	for c=1,#contacts do
		if band(fget(mget(contacts[c].x,contacts[c].y)),2)!=0 then
			mset(contacts[c].x,contacts[c].y,0)
		end
	end
end


maprender=node:new{}
function maprender:drawcb()
	local pos=self.global_position:floored()-camera_pos
	map(0,0,pos.x,pos.y,128,32)
end

camera_pos=vec2(0,0)
camerafollow=node:new{}
function camerafollow:updatecb()
	camera_pos=self.global_position:floored()-vec2(64,64)
end

block=kinematicbody:new{position=vec2(100,30)}
block:add_child(sprite:new{s=17})

root=node:new()
root:add_child(maprender)
root:add_child(block)
-->8
--scenes

function instance(scene)
	local newn = scene[1]:new()
	for name,value in pairs(scene) do
		if type(name)!="number" then
			newn[name]=value
		end
	end
	for i=2,#scene do
		newn:add_child(instance(scene[i]))
	end
	return newn
end

function scene(t)
	t.instance=instance
	return t
end

player_scene=scene{
	faller,
	{sprite,s=1},
	{camerafollow},
}

root:add_child(player_scene:instance())

__gfx__
00000000ffffffff3333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fbbbbbbf444444444444444400aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700fbbbbbbf44444444444444440a9999a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000fbbbbbbf44444444445644440a9999a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000fbbbbbbf44444444445544440a9999a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700fbbbbbbf44444444444444440a9999a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000fbbbbbbf444444444444444400aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff4444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff2222222244444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f888888f2222222244444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f888888f2222222244444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f888888f2222222224242424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f888888f2222222242424242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f888888f2222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000f888888f2222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ffffffff2222222222222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010102000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000012120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000012120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202030302020202020202030202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1313131313131313131313131313131300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1212121212121212121212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
