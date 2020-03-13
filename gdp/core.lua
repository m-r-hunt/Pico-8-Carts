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

	--globals

	--core
	camera_pos=vec2(0,0)

	--physics
	colliders={}

	--nodes/gameplay
	grapple_acquired=false

	--initialise node tree/root
	root=initial_scene:instance()
	root:set_position()
	root:ready()
end

function _update()
	root:update()
end

function _draw()
	cls(1)
	camera(camera_pos.x,camera_pos.y)
	root:draw()
	camera()
	print(stat(0),0,0,7)
end
