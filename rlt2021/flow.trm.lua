





local function handleKeys()
	if btnp(0) then
		return {move=V2(-1,0)}
	end
	if btnp(1) then
		return {move=V2(1,0)}
	end
	if btnp(2) then
		return {move=V2(0,-1)}
	end
	if btnp(3) then
		return {move=V2(0,1)}
	end

	return {}
end

local function blocks_fov(pos)
	return fget(mget(pos:unpack()),1)
end

local function main()
	while true do
		local dt=yield()
		local action=handleKeys()
		if action.move then
			local dx=player.pos+action.move
			if not game_map:isBlocked(dx) then
				local target=getBlockingEntitiesAt(dx)

				if target then
					message="you kick the "..target.name.." in the nuts"
				else
					message=""
					player:move(dx)
					fov_map=calculateFOV(blocks_fov,player.pos,10)
					memory:unionWith(fov_map)
				end

				foreach(entities,function(e)
					if e.ai then
						e.ai:takeTurn()
					end
				end)
			end
		end
	end
end

local main_thread=nil
local function _init()
	main_thread=cocreate(main)

	player=Entity(V2(8,8),1,"player",true,Fighter(30,2,5))
	entities={player}
	player.pos=makeMap(entities)
	fov_map=calculateFOV(blocks_fov,player.pos,10)
	memory=Grid()
	memory:unionWith(fov_map)
	message=""
end

local function _update(dt)
	assert(coresume(main_thread,dt))
end

local function _draw()
	cls()

	camera((player.pos*8-V2(64,64)):unpack())

	game_map:draw(player.pos,memory,fov_map)

	foreach(entities,function(e)
		if fov_map:get(e.pos) then
			e:draw()
		end
	end)

	camera()
	print(message,0,0,7)
end
