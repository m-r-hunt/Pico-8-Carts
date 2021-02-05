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

current_state="start"
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
	states[current_state]:enter()
end

state{
	name="start",
	enter=function(self)
		self.t=0
	end,
	update=function(self)
		self.t+=1
		if btnp(4) then
			emit("switch")
		end
	end,
	draw=function(self)
		cls()
		print(self.t)
		sspr(8,0,8,8,0,0,128,128)
	end,
	transitions={switch="start"},
}

poke(0x5f2e,1)
pal(1,140,1)
pal(2,12,1)
pal(3,7,1)
pal(4,10,1)

actor=interface{
	x="number",
	y="number",
	dx="number",
	dy="number",
	w="number",
	h="number",
}

player=class{
	x=0,
	y=0,
	dx=0,
	dy=0,
	w=6,
	h=12,
}
actor(player)
