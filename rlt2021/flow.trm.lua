


local function handleKeys()
	if (btnp(0)) return {move={-1,0}}
	if (btnp(1)) return {move={1,0}}
	if (btnp(2)) return {move={0,-1}}
	if (btnp(3)) return {move={0,1}}

	return {}
end

local function main()
	while true do
		local dt=yield()
		local action=handleKeys()
		if action.move then
			local dx,dy=unpack(action.move)
			if (not game_map:isBlocked(player.x+dx,player.y+dy)) player:move(dx,dy)
		end
	end
end

local main_thread=nil
local function _init()
	main_thread=cocreate(main)
	player.x,player.y=makeMap()
end

local function _update(dt)
	assert(coresume(main_thread,dt))
end

local function _draw()
	cls()

	camera(player.x*8-64,player.y*8-64)

	game_map:draw()

	for e in all(entities) do
		e:draw()
	end
end