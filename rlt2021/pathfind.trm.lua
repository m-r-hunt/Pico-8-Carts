

local Grid=Class{
	construct=function(self)
		self.set={}
	end,

	add=function(self,pos,val)
		self.set[pos[1]]=self.set[pos[1]] or {}
		self.set[pos[1]][pos[2]]=val
	end,

	get=function(self,pos)
		return self.set[pos[1]] and self.set[pos[1]][pos[2]]
	end
}

function pathfind(s,t,blocks)
	local frontier={s}
	local came_from=Grid()

	local i=0
	while #frontier>0 do
		i+=1
		printh(i)
		local current=frontier[1]
		deli(frontier,1)

		if current==t then
			break
		end

		local n=current-V2(1,0)
		if not came_from:get(n) and not blocks(n) then
			add(frontier,n)
			came_from:add(n,current)
		end
		n=current+V2(1,0)
		if not came_from:get(n) and not blocks(n) then
			add(frontier,n)
			came_from:add(n,current)
		end
		n=current-V2(0,1)
		if not came_from:get(n) and not blocks(n) then
			add(frontier,n)
			came_from:add(n,current)
		end
		n=current+V2(0,1)
		if not came_from:get(n) and not blocks(n) then
			add(frontier,n)
			came_from:add(n,current)
		end
	end

	if not came_from:get(t) then
		printh("Failed pathfinding")
		return nil
	end

	printh("Found path")
	local path={t}
	while path[1]!=s do
		add(path,came_from:get(path[1]),1)
	end
	return path
end
