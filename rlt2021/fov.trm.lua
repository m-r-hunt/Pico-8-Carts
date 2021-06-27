

local Line=Class{
	construct=function(self,xi,yi,xf,yf)
		self.i={xi,yi}
		self.f={xf,yf}
	end,

	relativeSlope=function(self,p)
		return (self.f[2]-self.i[2])*(self.f[1]-p[1])-(self.f[1]-self.i[1])*(self.f[2]-p[2])
	end,

	pointBelow=function(self,p)
		return self:relativeSlope(p)>0
	end,

	pointBelowOrCollinear=function(self,p)
		return self:relativeSlope(p)>=0
	end,

	pointAbove=function(self,p)
		return self:relativeSlope(p)<0
	end,

	pointAboveOrCollinear=function(self,p)
		return self:relativeSlope(p)<=0
	end,

	pointCollinear=function(self,p)
		return self:relativeSlope(p)==0
	end,

	lineCollinear=function(self,line)
		return self:pointCollinear(line.i) and self:pointCollinear(line.f)
	end
}

function Line:clone()
	return Line(self.i[1],self.i[2],self.f[1],self.f[2])
end

local ViewBump=Class{
	construct=function(self,pos,parent)
		self.pos=pos
		self.parent=parent
	end
}

local View=Class{
	construct=function(self,shallow,steep)
		if steep then
			self.shallow_line=shallow
			self.steep_line=steep
		else
			local other=shallow
			self.shallow_line=other.shallow_line:clone()
			self.steep_line=other.steep_line:clone()
			self.shallow_bump=other.shallow_bump
			self.steep_bump=other.steep_bump
		end
	end
}

local function addShallowBump(bump_pos,active_view)
	active_view.shallow_line.f=bump_pos

	active_view.shallow_bump=ViewBump(bump_pos,active_view.shallow_bump)

	local cur_bump=active_view.steep_bump

	while cur_bump do
		if active_view.shallow_line:pointAbove(cur_bump.pos) then
			active_view.shallow_line.i=cur_bump.pos
		end

		cur_bump=cur_bump.parent
	end
end

local function addSteepBump(bump_pos,active_view)
	active_view.steep_line.f=bump_pos

	active_view.steep_bump=ViewBump(bump_pos,active_view.steep_bump)

	local cur_bump=active_view.shallow_bump

	while cur_bump!=nil do
		if active_view.steep_line:pointBelow(cur_bump.pos) then
			active_view.steep_line.i=cur_bump.pos
		end

		cur_bump=cur_bump.parent
	end
end

local function checkView(active_views,view_index)
	local shallow_line=active_views[view_index].shallow_line
	local steep_line=active_views[view_index].steep_line

	if shallow_line:lineCollinear(steep_line) and (shallow_line:pointCollinear({0,1}) or shallow_line:pointCollinear({1,0})) then
		deli(active_views,view_index)
		return false
	else
		return true
	end
end

local function visitCoord(pos,x,y,dx,dy,active_views,fov,blocksFOV)
	local view_index=1

	local top_left={x,y+1}
	local bottom_right={x+1,y}

	while view_index<=#active_views and active_views[view_index].steep_line:pointBelowOrCollinear(bottom_right) do
		view_index+=1
	end

	if view_index>#active_views or active_views[view_index].shallow_line:pointAboveOrCollinear(top_left) then
		return
	end

	local real_x=x*dx
	local real_y=y*dy
	local real_pos=V2(pos[1]+real_x,pos[2]+real_y)

	fov:add(real_pos,true)

	local is_blocked=blocksFOV(real_pos)

	if not is_blocked then
		return nil
	end

	local active_view=active_views[view_index]
	if active_view.shallow_line:pointAbove(bottom_right) and active_view.steep_line:pointBelow(top_left) then
		deli(active_views,view_index)
	elseif active_view.shallow_line:pointAbove(bottom_right) then
		addShallowBump(top_left,active_view)
		checkView(active_views,view_index)
	elseif active_view.steep_line:pointBelow(top_left) then
		addSteepBump(bottom_right,active_view)
		checkView(active_views,view_index)
	else
		local shallow_view_index=view_index
		local steep_view_index=view_index+1

		add(active_views,View(active_views[shallow_view_index]),shallow_view_index)

		addSteepBump(bottom_right,active_views[shallow_view_index])

		if not checkView(active_views,shallow_view_index) then
			steep_view_index-=1
		end

		addShallowBump(top_left,active_views[steep_view_index])
		checkView(active_views,steep_view_index)
	end
end

local function checkQuadrant(pos,dx,dy,radius,fov,blocksFOV)
	local active_views={}
	local shallow_line=Line(0,1,radius,0)
	local steep_line=Line(1,0,0,radius)

	add(active_views,View(shallow_line,steep_line))

	local max_i=radius+radius
	local i=1
	while i<=max_i and #active_views>=1 do
		local start_j=max(0,i-radius)
		local max_j=min(i,radius)
		local j=start_j
		while j<=max_j and #active_views>=1 do
			local x=i-j
			local y=j
			visitCoord(pos,x,y,dx,dy,active_views,fov,blocksFOV)

			j+=1
		end

		i+=1
	end
end

function calculateFOV(blocksFOV,pos,radius)
	local fov=Grid()
	fov:add(pos,true)

	checkQuadrant(pos,1,1,radius,fov,blocksFOV)
	checkQuadrant(pos,1,-1,radius,fov,blocksFOV)
	checkQuadrant(pos,-1,-1,radius,fov,blocksFOV)
	checkQuadrant(pos,-1,1,radius,fov,blocksFOV)

	return fov
end
