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

function simulate_actor(a)
	actor(a)
	struck=false
	if (a.dy>0) then
		local target_y=a.y+a.h+a.dy
		if fget(mget(a.x,target_y),0) or fget(mget(a.x+a.w,target_y),0) then
			a.y=flr(target_y)-a.h-1/8
			a.dy=0
		else
			a.y+=a.dy
		end
	end
	if (a.dy<0) then
		local target_y=a.y+a.dy
		if fget(mget(a.x,target_y),0) or fget(mget(a.x+a.w,target_y),0) then
			a.y=ceil(target_y)+1/8
			a.dy=0
		else
			a.y+=a.dy
		end
	end
	if (a.dx>0) then
		local target_x=a.x+a.w+a.dx
		if fget(mget(target_x,a.y),0) or fget(mget(target_x,a.y+a.h),0) then
			a.x=flr(target_x)-a.w-1/8
			a.dx=0
		else
			a.x+=a.dx
		end
	end
	if (a.dx<0) then
		local target_x=a.x+a.dx
		if fget(mget(target_x,a.y),0) or fget(mget(target_x,a.y+a.h),0) then
			a.x=ceil(target_x)
			a.dx=0
		else
			a.x+=a.dx
		end
	end
end

sprite_anim=class{
	base=0,
	frames=0,
	w=1,
	h=1,
}
function sprite_anim:draw(x,y,flipx)
	spr(self.base,flr(x*8),flr(y*8),self.w,self.h,flipx)
end

player=class{
	x=1,
	y=0,
	dx=0,
	dy=0,
	w=5/8,
	h=12/8,
	oy=-2/8,
	ox=-1/8,
	flipx=false
}
function player:construct()
	self.anim=sprite_anim()
	self.anim.h=2
	self.anim.base=4
	self.anim.frames=4
end
function player:update()
	self.dy+=1/8
	if btn(0) then
		self.dx+=-0.1
		self.flipx=true
	elseif btn(1) then
		self.dx+=0.1
		self.flipx=false
	else
		if abs(self.dx)<=0.05 then
			self.dx=0
		else
			self.dx+=-0.05*sgn(self.dx)
		end
	end
	if (btnp(2)) self.dy=-1
	self.dx=mid(-3/8,self.dx,3/8)
	self.dy=mid(-1,self.dy,1)
	simulate_actor(self)
end
function player:draw()
	self.anim:draw(self.x+self.ox,self.y+self.oy,self.flipx)
	--rectfill((self.x)*8,(self.y)*8,(self.x+self.w)*8,(self.y+self.h)*8,8)
	--print(self.x)
	--print(self.y)
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

