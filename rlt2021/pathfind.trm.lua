

local Grid=Class{
	construct=function(self)
		self.set={}
	end,

	add=function(self,x,y,val)
		self.set[x]=self.set[x] or {}
		self.set[x][y]=val
	end,

	get=function(self,x,y)
		printh("get")
		return self.set[x] and self.set[x][y]
	end
}

function pathfind(sx,sy,tx,ty,blocks)
	local frontier={{sx,sy}}
	local came_from=Grid()

	while #frontier>0 do
		local current=frontier[1]
		deli(frontier,1)
		printh(current[1].." "..current[2])

		if current[1]==tx and current[2]==ty then
			break
		end

		if not came_from:get(current[1]-1,current[2]) and not blocks(current[1]-1,current[2]) then
			add(frontier,{current[1]-1,current[2]})
			came_from:add(current[1]-1,current[2],current)
		end
		if not came_from:get(current[1]+1,current[2]) and not blocks(current[1]+1,current[2]) then
			add(frontier,{current[1]+1,current[2]})
			came_from:add(current[1]+1,current[2],current)
		end
		if not came_from:get(current[1],current[2]-1) and not blocks(current[1],current[2]-1) then
			add(frontier,{current[1],current[2]-1})
			came_from:add(current[1],current[2]-1,current)
		end
		if not came_from:get(current[1],current[2]+1) and not blocks(current[1],current[2]+1) then
			add(frontier,{current[1],current[2]+1})
			came_from:add(current[1],current[2]+1,current)
		end
	end

	if not came_from:get(tx,ty) then
		return nil
	end

	local path={{tx,ty}}
	while path[1][1]!=sx or path[1][2]!=sy do
		add(path,came_from:get(path[1][1],path[1][2]),1)
	end
	printh(#path)
	return path
end
