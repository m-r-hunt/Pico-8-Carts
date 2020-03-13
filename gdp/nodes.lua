sprite=node:new()
function sprite:drawcb()
	local pos=self.global_position:floored()-vec2(4,4)
	spr(self.s,pos.x,pos.y,1,1,self.hflip)
end

faller=kinematicbody:new{
	position=vec2(100,50),
	direction=vec2(0,1),
	state="walking",
	can_grapple=false
}
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
		local p=self.global_position
		local t=self.grapple_target
		line(p.x,p.y,t.x,t.y,4)
	end
end

function lt(a,b)
	return a<b
end
function gt(a,b)
	return a>b
end
hacky_table={
	{
		"x",
		lt,
		"y",
		-1,
		0,
	},
	{
		"x",
		gt,
		"y",
		1,
		16,
	},
	{
		"y",
		lt,
		"x",
		-1,
		0,
	},
	{
		"y",
		gt,
		"x",
		1,
		16,
	},
}
maprender=node:new{last_camera=vec2(-64,-64)}
function maprender:updatecb()
--maybe a little smelly
--maprender also tracks camera pos
--and spawns entites from tiles when they appear
	local last_t=vec2(self.last_camera.x/8,self.last_camera.y/8):floored()
	local now_t=vec2(camera_pos.x/8,camera_pos.y/8):floored()
	for t in all(hacky_table) do
		c1=t[1]
		fn=t[2]
		c2=t[3]
		step=t[4]
		offset=t[5]
		if fn(now_t[c1],last_t[c1]) then
			for x=last_t[c1]+step,now_t[c1],step do
				for y=last_t[c2],last_t[c2]+16 do
					local cc=x+offset
					local tt={[c1]=cc,[c2]=y}
					local m=mget(tt.x,tt.y)
					if fget(m,2) then
						local e=tile_spawn_scenes[m]:instance()
						e:set_position(vec2(tt.x*8+4,tt.y*8+4))
						root:add_child(e)
					end
				end
			end
		end
	end
	self.last_camera=camera_pos
end
function maprender:drawcb()
	local pos=self.global_position:floored()
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
