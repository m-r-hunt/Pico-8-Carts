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
