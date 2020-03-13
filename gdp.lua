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
	n:set_position()
	if self.readied then
		n:ready()
	end
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
	for child in all(self.children) do
		child:set_position()
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
	for child in all(self.children) do
		child:update()
	end
end
function node:updatecb() end

function node:draw()
	self:drawcb()
	for child in all(self.children) do
		child:draw()
	end
end
function node:drawcb() end

function _init()
	palt(0,false)
	palt(14,true)
	root:set_position()
	root:ready()
end

function _update()
	root:update()
end

function _draw()
	cls(1)
	root:draw()
	print(stat(0),0,0,7)
end

--physics

colliders={}

function add_collider(t,pos,size)
	colliders[t]={pos=pos,size=size}
end

function remove_collider(t)
	colliders[t]=nil
end

function check_against_colliders(contacts,exc,x,y,w,h)
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
				add_contact(contacts,t)
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
		if check_against_map(contacts,col.pos.x,y,col.size.x,col.size.y) or check_against_colliders(contacts,t,col.pos.x,y,col.size.x,col.size.y) then
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
		if check_against_map(contacts,x,col.pos.y,col.size.x,col.size.y) or check_against_colliders(contacts,t,x,col.pos.y,col.size.x,col.size.y) then
			hit=true
			hit_normal.x=-sgn(vec.x)
			break
		end
		col.pos.x=x
	end
	return col.pos,hit,hit_normal,contacts
end

--nodes

sprite=node:new()
function sprite:drawcb()
	local pos=self.global_position:floored()-vec2(4,4)-camera_pos
	spr(self.s,pos.x,pos.y,1,1,self.hflip)
end

kinematicbody=node:new{size=vec2(4,4)}
function kinematicbody:readycb()
	add_collider(self,self.global_position,self.size)
end
function kinematicbody:unreadycb()
	remove_collider(self)
end
function kinematicbody:move(new_pos)
	local pos,hit,hit_normal,contacts=move_collider(self,new_pos:floored())
	for c in all(contacts) do
		self:contactcb(c)
	end
	if not hit then
		pos=new_pos
	end
	self:set_position(pos)
	return hit,hit_normal
end
function kinematicbody:contactcb(c)
end
function kinematicbody:collide(c)
end

faller=kinematicbody:new{position=vec2(100,50),direction=vec2(0,1),state="walking",can_grapple=false}
function faller:updatecb()
	self[self.state](self)
end

function find_target(pos)
	local tx=flr(pos.x/8)
	local ty=flr(pos.y/8)
	while not fget(mget(tx,ty),0) do
		ty-=1
	end
	return vec2(pos.x,ty*8+7)
end

grapple_acquired=false

function faller:walking()
	self.direction.x=0
	if btn(4) and self.can_grapple then
		self.state="grappling"
		self.grapple_target=find_target(self.global_position)
		self.children[1].s=50
		self.can_grapple=false
	else
		self.direction+=vec2(0,0.5)
		if btn(0) then
			self.direction.x=-1
			self.children[1].hflip=true
		end
		if btn(1) then
			self.direction.x=1
			self.children[1].hflip=false
		end
		local new_pos=self.position+self.direction
		local hit,hit_normal=self:move(new_pos)
		if hit and hit_normal.y!=0 then
			self.direction=vec2(0,0)
		end
		if hit and hit_normal.y<0 then
			self.can_grapple=grapple_acquired
		end
	end
end

function faller:contactcb(c)
	if getmetatable(c)==vec2mt then
		if band(fget(mget(c.x,c.y)),2)!=0 then
			mset(c.x,c.y,0)
		end
	else
		self:collide(c)
		c:collide(self)
	end
end

function faller:grappling()
	self.direction+=vec2(0,-0.5)
	self.direction.y=max(self.direction.y,-5)
	local new_pos=self.position+self.direction
	local hit,hit_normal=self:move(new_pos)
	if hit and hit_normal.y>0 then
		self.state="walking"
		self.children[1].s=49
	end
	if hit and hit_normal.y<0 then
		self.direction.y=0
	end
end

function faller:drawcb()
	if self.state=="grappling" then
		local p=self.global_position-camera_pos
		local t=self.grapple_target-camera_pos
		line(p.x,p.y,t.x,t.y,4)
	end
end

maprender=node:new{last_camera=vec2(-64,-64)}
function maprender:updatecb()
--maybe a little smelly
--maprender also tracks camera pos
--and spawns entites from tiles when they appear
	local last_t=vec2(self.last_camera.x/8,self.last_camera.y/8):floored()
	local now_t=vec2(camera_pos.x/8,camera_pos.y/8):floored()
	if now_t.x<last_t.x then
		for x=last_t.x-1,now_t.x,-1 do
			for y=last_t.y,last_t.y+16 do
				local m=mget(x,y)
				if fget(m,2) then
					local e=tile_spawn_scenes[m]:instance()
					e:set_position(vec2(x*8+4,y*8+4))
					root:add_child(e)
				end
			end
		end
	end
	if now_t.x>last_t.x then
		for x=last_t.x+1,now_t.x do
			for y=last_t.y,last_t.y+16 do
				local xx=x+16
				local m=mget(xx,y)
				if fget(m,2) then
					local e=tile_spawn_scenes[m]:instance()
					e:set_position(vec2(xx*8+4,y*8+4))
					root:add_child(e)
				end
			end
		end
	end
	if now_t.y<last_t.y then
		for y=last_t.y-1,now_t.y,-1 do
			for x=last_t.x,last_t.x+16 do
				local m=mget(x,y)
				if fget(m,2) then
					local e=enemy_scene:instance()
					e:set_position(vec2(x*8+4,y*8+4))
					root:add_child(e)
				end
			end
		end
	end
	if now_t.y>last_t.y then
		for y=last_t.y+1,now_t.y do
			for x=last_t.x,last_t.x+16 do
				local yy=y+16
				local m=mget(x,yy)
				if fget(m,2) then
					local e=tile_spawn_scenes[m]:instance()
					e:set_position(vec2(x*8+4,yy*8+4))
					root:add_child(e)
				end
			end
		end
	end
	self.last_camera=camera_pos
end
function maprender:drawcb()
	local pos=self.global_position:floored()-camera_pos
	if (pos.y>0) rectfill(0,0,128,pos.y,5)
	if (pos.x>0) rectfill(0,0,pos.x,128,5)
	map(0,0,pos.x,pos.y,128,64,0x80)
end

camera_pos=vec2(0,0)
camerafollow=node:new{}
function camerafollow:updatecb()
	camera_pos=self.global_position:floored()-vec2(64,64)
end

powerup=kinematicbody:new()
function powerup:updatecb()
	if grapple_acquired then
		self.parent:remove_child(self)
	end
end
function powerup:collide()
	grapple_acquired=true
end

remove_if_offscreen=node:new()
function remove_if_offscreen:updatecb()
	if self.global_position.x<camera_pos.x-8 or self.global_position.x>camera_pos.x+136 or
	   self.global_position.y<camera_pos.y-8 or self.global_position.y>camera_pos.y+136 then
		self.parent.parent:remove_child(self.parent)
	end
end

block=kinematicbody:new{position=vec2(100,30)}
block:add_child(sprite:new{s=17})

root=node:new()
root:add_child(maprender)
root:add_child(block)
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
	{sprite,s=33},
	{camerafollow},
	position=vec2(72*8,60*8),
}

enemy_scene=scene{
	kinematicbody,
	{sprite,s=6}
}

hook_powerup_scene=scene{
	powerup,
	{sprite,s=20},
	{remove_if_offscreen},
}

tile_spawn_scenes={
	[5]=enemy_scene,
	[20]=hook_powerup_scene,
}

root:add_child(player_scene:instance())