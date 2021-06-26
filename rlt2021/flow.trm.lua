






local function handleKeys()
	if (btnp(0)) return {move={-1,0}}
	if (btnp(1)) return {move={1,0}}
	if (btnp(2)) return {move={0,-1}}
	if (btnp(3)) return {move={0,1}}

	return {}
end

local function blocks_fov(pos)
	return fget(mget(pos[1],pos[2]),1)
end

local function main()
	while true do
		local dt=yield()
		local action=handleKeys()
		if action.move then
			local dx,dy=unpack(action.move)
			if not game_map:isBlocked(player.x+dx,player.y+dy) then
				player:move(dx,dy)
				fov_map=calculateFOV(blocks_fov,{player.x,player.y},10)
				memory:unionWith(fov_map)
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
end