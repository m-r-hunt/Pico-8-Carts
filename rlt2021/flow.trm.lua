






local function handleKeys()
	if btnp(0) then
		return {move={-1,0}}
	end
	if btnp(1) then
		return {move={1,0}}
	end
	if btnp(2) then
		return {move={0,-1}}
	end
	if btnp(3) then
		return {move={0,1}}
	end

	return {}
end

local function blocks_fov(pos)
	return fget(mget(pos[1],pos[2]),1)
end

local message=""
local function main()
	while true do
		local dt=yield()
		local action=handleKeys()
		if action.move then
			local dx=player.x+action.move[1]
			local dy=player.y+action.move[2]
			if not game_map:isBlocked(dx,dy) then
				local target=getBlockingEntitiesAt(dx,dy)

				if target then
					message="you kick the "..target.name.." in the nuts"
				else
					message=""
					player:move(dx,dy)
					fov_map=calculateFOV(blocks_fov,{player.x,player.y},10)
					memory:unionWith(fov_map)
				end

				for e in all(entities) do

					
				end
			end
		end
	end
end
local main_thread=nil
local function _init()
	main_thread=cocreate(main)
	player.x,player.y=makeMap(entities)
	fov_map=calculateFOV(blocks_fov,{player.x,player.y},10)
	memory=PosSet()
	memory:unionWith(fov_map)
end

local function _update(dt)
	assert(coresume(main_thread,dt))
end

local function _draw()
	cls()

	camera(player.x*8-64,player.y*8-64)

	game_map:draw(player.x,player.y,memory,fov_map)

	for e in all(entities) do
		if fov_map:contains(e.x,e.y) then
			e:draw()
		end
	end

	camera()
	print(message,0,0,7)
end
