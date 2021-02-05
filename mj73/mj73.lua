function class(tab)
	local new=function(tab,...)
		local n={}
		setmetatable(n,{__index=tab})
		if tab.construct then
			tab.construct(n,...)
		end
		return n
	end
	setmetatable(tab,{__call=new})
	return tab
end

function interface(tab)
	local check=function(tab,check)
		for k,v in pairs(tab) do
			if type(check[k])~=v then
				cls()
				print("interface err: "..tostr(check))
				print("expected "..k.." type "..v)
				print("got "..type(check[k]))
				assert(false)
			end
		end
	end
	setmetatable(tab,{__call=check})
	return tab
end

current_state="newgame"
states={}

state_interface=interface{
	name="string",
	enter="function",
	update="function",
	draw="function",
	transitions="table",
}

function state(tab)
	state_interface(tab)
	states[tab.name]=tab
end

function emit(signal)
	current_state=states[current_state].transitions[signal]
	states[current_state]:enter()
end

function _update()
	states[current_state]:update()
end

function _draw()
	states[current_state]:draw()
end

function _init()
	--palette setup (persistence enabled)
	poke(0x5f2e,1)
	pal(1,140,1)
	pal(2,12,1)
	pal(3,7,1)
	pal(4,10,1)

	states[current_state]:enter()
end

actor=interface{
	x="number",
	y="number",
	dx="number",
	dy="number",
	w="number",
	h="number",
	update="function",
	draw="function",
}

sprite_anim=class{
	base=0,
	frames=0,
	w=1,
	h=1,
}
function sprite_anim:draw(x,y)
	spr(self.base,x*8,y*8,self.w,self.h)
end

player=class{
	x=0,
	y=0,
	dx=0,
	dy=0,
	w=6,
	h=12,
}
function player:construct()
	self.anim=sprite_anim()
	self.anim.h=2
	self.anim.base=4
	self.anim.frames=4
end
function player:update()
end
function player:draw()
	self.anim:draw(self.x,self.y)
end
actor(player)

state{
	name="newgame",
	enter=function(self)
		actors={player()}
		emit"finished"
	end,
	update=function(self)end,
	draw=function(self)end,
	transitions={finished="playing"},
}

state{
	name="playing",
	enter=function(self)end,
	update=function(self)
		for actor in all(actors) do
			actor:update()
		end
	end,
	draw=function(self)
		draw_world()
	end,
	transitions={}
}

function draw_world()
	cls()
	map()
	for actor in all(actors) do
		actor:draw()
	end
end

