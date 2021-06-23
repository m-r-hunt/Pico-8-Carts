local main_thread=nil
local player_x=1
local player_y=1

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
			player_x+=action.move[1]
			player_y+=action.move[2]
		end
	end
end

local function _init()
	main_thread=cocreate(main)
end

local function _update(dt)
	assert(coresume(main_thread,dt))
end

local function _draw()
	cls()
	spr(1,player_x*8,player_y*8)
end