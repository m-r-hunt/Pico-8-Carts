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

function setup_palette()
	pal()
	poke(0x5f2e,1)
	pal(1,140,1)
	pal(2,12,1)
	pal(3,7,1)
	pal(4,10,1)
end

function _init()
	setup_palette()
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
	local on_ground=false
	if (a.dy>0) then
		local target_y=a.y+a.h+a.dy
		if fget(mget(a.x,target_y),0) or fget(mget(a.x+a.w,target_y),0) then
			a.y=flr(target_y)-a.h-1/8
			a.dy=0
			on_ground=true
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
	return on_ground
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
	flipx=false,
	on_ground=false,

	reset_point_x=1,
	reset_point_y=0,

	energy=15,
	max_energy=15,
}
function player:construct()
	self.anim=sprite_anim()
	self.anim.h=2
	self.anim.base=4
	self.anim.frames=4
end
function player:update()
	self.dy+=1/8
	local energy_used=0.05
	if btn(0) then
		self.dx+=-0.1
		self.flipx=true
		energy_used=0.1
	elseif btn(1) then
		self.dx+=0.1
		self.flipx=false
		energy_used=0.1
	else
		if abs(self.dx)<=0.05 then
			self.dx=0
		else
			self.dx+=-0.05*sgn(self.dx)
		end
	end
	if self.on_ground and btnp(2) then
		self.dy=-1
		energy_used=0.5
	end
	self.dx=mid(-3/8,self.dx,3/8)
	self.dy=mid(-1,self.dy,1)
	self.on_ground=simulate_actor(self)
	local below_tile=mget(self.x+self.w/2,flr(self.y+self.h)+1)
	if self.on_ground and fget(below_tile,1) then
		self.energy+=0.2
		self.energy=min(self.energy,self.max_energy)
		self.reset_point_x=flr(self.x+self.w/2)
		self.reset_point_y=flr(self.y)
		if stat(19)~=2 then
			sfx(2,3)
		end
	else
		sfx(2,-2)
		self.energy-=energy_used
		if stat(19)~=3 and self.energy<4 then
			sfx(3,3)
		end
	end
end

function player:reset()
	self.x=self.reset_point_x
	self.y=self.reset_point_y
	self.dx=0
	self.dy=0
	self.energy=self.max_energy
end

function player:draw()
	self.anim:draw(self.x+self.ox,self.y+self.oy,self.flipx)
	--rectfill((self.x)*8,(self.y)*8,(self.x+self.w)*8,(self.y+self.h)*8,8)
	--print(self.x)
	--print(self.y)
end
actor(player)

function draw_power_bar()
	rectfill(8,121,8+the_player.energy,126,4)
	middle_segments=(the_player.max_energy-16)/8
	local x=8
	spr(16,x,120)
	x+=8
	for i=1,middle_segments do
		spr(17,x,120)
		x+=8
	end
	spr(18,x,120)
end

state{
	name="newgame",
	enter=function(self)
		the_player=player()
		actors={the_player}
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
		if the_player.energy<0 then
			the_player.energy=0
			emit("died")
		end
	end,
	draw=function(self)
		draw_world()
		draw_power_bar()
	end,
	transitions={
		died="dying",
		gamewon="gamewon",
	}
}

state{
	name="dying",
	enter=function(self)
		self.t=0
		pal(4,8)
		sfx(3,-2)
		sfx(1)
	end,
	update=function(self)
		self.t+=1
		if self.t>=60 then
			the_player:reset()
			setup_palette()
			emit("finished")
		end
	end,
	draw=function(self)
		draw_world()
		draw_power_bar()
	end,
	transitions={finished="playing"}
}

function draw_world()
	cls()
	map(0,0,0,0,128,64)
	for actor in all(actors) do
		actor:draw()
	end
end

