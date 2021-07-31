







local draw=nil

local function drawGameplay()
	cls()

	camera((player.pos*8-V2(64,64)):unpack())

	game_map:draw(player.pos,memory,fov_map)

	for z=0,3 do
		foreach(entities,function(e)
			if e.z==z and (fov_map:get(e.pos:floored()) or (e.stairs and memory:get(e.pos:floored()))) then
				e:draw()
			end
		end)
	end

	drawParticles()

	camera()
	print("lv"..current_level,0,121,7)
	print("hp",16,121,7)
	rect(24,120,24+player.fighter.max_hp+10,127,7)
	rectfill(25,121,24+player.fighter.hp+9,126,8)
	print("floor "..dungeon_level,100,121)
end

local options={"pickup","use item"}
local selected=1

local function drawMenu()
	drawGameplay()
	for i=1,#options do
		print(options[i],20,20+i*8,8)
		if i==selected then
			print(">",17,20+i*8,8)
		end
	end
end

local function actionMenu()
	draw=drawMenu
	selected=1
	options={"pickup","use item"}
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
			draw=drawGameplay
			if options[selected]=="pickup" then
				return {pickup=true}
			elseif options[selected]=="use item" then
				return {use_item=true}
			end
		end
		if btnp(5) then
			draw=drawGameplay
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
		for e in all(entities) do
			if e.stairs and e.pos==player.pos then
				return {take_stairs=true}
			end
		end
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
	print("game over",40,34,7)
	print("press (x) or (o) to quit",22,60,7)
end

local function gameOver()
	draw=drawGameOver
	while true do
		yield()

		if btnp(4) or btnp(5) then
			return
		end
	end
end

local function new_floor()
	entities={player}
	player.pos=makeMap(entities)
	fov_map=calculateFOV(blocks_fov,player.pos,10)
	memory=Grid()
	memory:unionWith(fov_map)
end

local function levelUp()
	draw=drawMenu
	selected=1
	options={"+20 hp","+1 str","+1 def"}
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
			draw=drawGameplay
			if options[selected]=="+20 hp" then
				player.fighter.max_hp+=20
				player.fighter.hp+=20
			elseif options[selected]=="+1 str" then
				player.fighter.power+=1
			elseif options[selected]=="+1 def" then
				player.fighter.defence+=1
			end
			return
		end
	end
end


local function gameplay()
	dungeon_level=1

	player=Entity(V2(8,8),1,"player",true,Fighter(30,2,5),nil,nil,Inventory(26))
	current_level=1
	current_xp=0
	new_floor()

	draw=drawGameplay
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
						local xp=player.fighter:attack(target)
						local levelled=addXp(xp)
						if levelled then
							levelUp()
						end
					else
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
			elseif action.take_stairs then
				new_floor()
				turn_taken=true
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

local function drawMain()
	cls()
	print("roguelike tutorial project",14,20,7)
	print("by maximilian hunt",24,26,7)
	print("press (x) or (o) to start",22,60,7)
end

local function main()
	while true do
		draw=drawMain
		yield()
		if btnp(4) or btnp(5) then
			gameplay()
		end
	end
end

local main_thread=nil
local function _init()
	main_thread=cocreate(main)
end

local function _update60()
	tickParticles()
	assert(coresume(main_thread))
end

local function _draw()
	draw()
end
