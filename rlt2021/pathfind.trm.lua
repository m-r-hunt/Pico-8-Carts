

local neighbours={V2(-1,0),V2(1,0),V2(0,-1),V2(0,1)}

function pathfind(s,t,blocks)
	local frontier={s}
	local came_from=Grid()

	local i=0
	while #frontier>0 do
		i+=1
		local current=frontier[1]
		deli(frontier,1)

		if current==t then
			break
		end

		foreach(neighbours,function(v)
			local n=current+v
			if not came_from:get(n) and not blocks(n) then
				add(frontier,n)
				came_from:add(n,current)
			end
		end)
	end


	if not came_from:get(t) then
		return nil
	end

	local path={t}
	while path[1]!=s do
		add(path,came_from:get(path[1]),1)
	end
	return path
end
