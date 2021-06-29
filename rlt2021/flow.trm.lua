






local draw=nil

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

local options={"pickup","use item"}
local selected=1

local function drawActionMenu()
	drawMain()
	for i=1,#options do
		print(options[i],20,20+i*8,8)
		if i==selected then
			print(">",17,20+i*8,8)
		end
	end
end

local function actionMenu()
	draw=drawActionMenu
	selected=1
	while true do
		yield()
		if btnp(2) then
			selected-=1
			if selected<=0 then
				selected=#options
			end
		end
		if btnp(3) then
			selected+=1
			if selected>#options then
				selected=1
			end
		end
		if btnp(4) then
			draw=drawMain
			if options[selected]=="pickup" then
				return {pickup=true}
			elseif options[selected]=="use item" then
				return {use_item=true}
			end
		end
		if btnp(5) then
			draw=drawMain
			return nil
		end
	end
end

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
	if btnp(5) then
		return actionMenu()
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

local function main()
	draw=drawMain
	while true do
		yield()
		local action=handleKeys()
		if action then
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
			elseif action.pickup then
				for e in all(entities) do
					if e.item and e.x==player.x and e.y==player.y then
						turn_taken=true
						player.inventory:addItem(e)
						break
					end
				end
			elseif action.use_item then

				if player.inventory:hasItem() then
					turn_taken=true
					player.inventory:useItem()
				end
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
end

local main_thread=nil
local function _init()
	main_thread=cocreate(main)

	player=Entity(V2(8,8),1,"player",true,Fighter(30,2,5),nil,nil,Inventory(26))
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
