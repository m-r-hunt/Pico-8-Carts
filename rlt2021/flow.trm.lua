






local draw=nil

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
	if btnp(4) then
		return {wait=true}
	end

	return {}
end

local function blocks_fov(pos)
	return fget(mget(pos:unpack()),1)
end

local function drawGameOver()
	cls()
	print("game over",40,64,7)
end

local function gameOver()
	draw=drawGameOver
	while true do
		yield()
	end
end

local function drawMain()
	cls()

	camera((player.pos*8-V2(64,64)):unpack())

	game_map:draw(player.pos,memory,fov_map)

	for z=1,3 do
		foreach(entities,function(e)
			if e.z==z and fov_map:get(e.pos:floored()) then
				e:draw()
			end
		end)
	end

	drawParticles()

	camera()
	print(message,0,0,7)
	print("HP",0,121,7)
	rect(8,120,player.fighter.max_hp+10,127,7)
	rectfill(9,121,player.fighter.hp+9,126,8)
end

local function main()
	draw=drawMain
	while true do
		yield()
		local action=handleKeys()
		local turn_taken=false
		if action.move then
			turn_taken=true
			local dx=player.pos+action.move
			if not game_map:isBlocked(dx) then
				local target=getBlockingEntitiesAt(dx)

				if target then
					player.fighter:attack(target)
				else
					message=""
					player:move(dx)
					fov_map=calculateFOV(blocks_fov,player.pos,10)
					memory:unionWith(fov_map)
				end
			end
		elseif action.wait then
			turn_taken=true
			addNumber("z",6,player.pos*8,V2(0,-0.5),180)
		end

		if turn_taken then
			foreach(entities,function(e)
				if e.ai then
					e.ai:takeTurn()
				end
			end)

			if player.fighter.hp<=0 then
				return gameOver()
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

local function _update60()
	tickParticles()
	assert(coresume(main_thread))
end

local function _draw()
	draw()
end
