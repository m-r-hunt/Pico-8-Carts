local function class(tab)
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

local function interface(tab)
	local check=function(tab,check)
		for k,v in pairs(tab) do
			if type(check[k])!=v then
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

current_state="mainmenu"
states={}

state_interface=interface{
	name="string",
	enter="function",
	update="function",
	draw="function",
	transitions="table"
}

local function state(tab)
	state_interface(tab)
	states[tab.name]=tab
end

local function emit(signal)
	current_state=states[current_state].transitions[signal]
	states[current_state]:enter()
end

particles={}
local function tick_particles()
	for p in all(particles) do
		p.x+=p.dx
		p.dy+=1
		p.y+=p.dy
		if p.y>64*8 then
			del(particles,p)
		end
	end
end
local function draw_particles()
	for p in all(particles) do
		pset(p.x,p.y,p.c)
	end
end
local function add_particle(x,y,dx,dy,c)
	add(particles,{x=x,y=y,dx=dx,dy=dy,c=c})
end

tf=0
ts=0
tm=0

function _update()
	tf+=1
	if tf>=30 then
		tf=0
		ts+=1
		if ts>=60 then
			ts=0
			tm+=1
		end
	end
	states[current_state]:update()
	tick_particles()
end

local function setup_palette()
	pal()
	poke(0x5f2e,1)
	pal(1,140,1)
	pal(2,12,1)
	pal(3,7,1)
	pal(4,10,1)
end

function _draw()
	setup_palette()
	states[current_state]:draw()
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
	draw="function"
}

local function simulate_actor(a)
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
	acc=0,
	w=1,
	h=1,
	tick=function(self,dx)
		self.acc+=dx
	end,
	draw=function(self,x,y,flipx)
		spr(self.base+self.acc%self.frames,flr(x*8),flr(y*8),self.w,self.h,flipx)
	end
}

coin_count=0
to_reset={}

local function reset_doors()
	for pos in all(to_reset) do
		mset(pos[1],pos[2],mget(pos[1],pos[2])-1)
	end
	to_reset={}
end

local function collect_coin(x,y)
	mset(x,y,0)
	sfx(5)
	coin_count+=1
	for n=1,16 do
		add_particle(x*8,y*8,rnd(2)-1,rnd(5)-10,2)
	end
end

player=class{
	x=11,
	y=56,
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

	construct=function(self)
		self.anim=sprite_anim()
		self.anim.h=2
		self.anim.base=4
		self.anim.frames=4

		self.reset_point_x=self.x
		self.reset_point_y=self.y
	end,

	update=function(self)
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
			sfx(6)
		end
		self.anim:tick(self.dx)
		self.dx=mid(-3/8,self.dx,3/8)
		self.dy=mid(-1,self.dy,1)
		self.on_ground=simulate_actor(self)
		local below_tile=mget(self.x+self.w/2,flr(self.y+self.h)+1)
		if self.on_ground and fget(below_tile,1) then
			self.energy+=0.2
			self.energy=min(self.energy,self.max_energy)
			self.reset_point_x=flr(self.x+self.w/2)
			self.reset_point_y=flr(self.y)
			if stat(19)!=2 then
				sfx(2,3)
			end
			reset_doors()
			add_particle((self.x+self.w/2)*8,(self.y+self.h)*8,rnd(2)-1,rnd(2)-1,4)
		elseif self.on_ground and fget(below_tile,4) then
			emit"died"
		elseif self.on_ground and below_tile==85 then
			sfx(8)
			self.energy-=4
			mset(self.x+self.w/2,flr(self.y+self.h)+1,86)
			add(to_reset,{self.x+self.w/2,flr(self.y+self.h)+1})
			for dx=-2,2,1 do
				for dy=-3,3,1 do
					local t=mget(self.x+self.w/2+dx,flr(self.y+self.h)+1+dy)
					if t==87 or t==103 then
						mset(self.x+self.w/2+dx,flr(self.y+self.h)+1+dy,t+1)
						add(to_reset,{self.x+self.w/2+dx,flr(self.y+self.h)+1+dy})
					end
				end
			end
		else
			sfx(2,-2)
			self.energy-=energy_used
			if stat(19)!=3 and self.energy<4 then
				sfx(3,3)
			end
		end

		local t1=mget(self.x,self.y)
		if (fget(t1,5)) collect_coin(self.x,self.y)
		local t2=mget(self.x+self.w,self.y)
		if (fget(t2,5)) collect_coin(self.x+self.w,self.y)
		local t3=mget(self.x,self.y+self.h)
		if (fget(t3,5)) collect_coin(self.x,self.y+self.h)
		local t4=mget(self.x+self.w,self.y+self.h)
		if (fget(t4,5)) collect_coin(self.x+self.w,self.y+self.h)
	end,

	reset=function(self)
		self.x=self.reset_point_x
		self.y=self.reset_point_y
		self.dx=0
		self.dy=0
		self.energy=self.max_energy
	end,

	draw=function(self)
		self.anim:draw(self.x+self.ox,self.y+self.oy,self.flipx)
	end



}
actor(player)






local function draw_power_bar()
	rectfill(8,121,8+the_player.energy,126,4)
	local middle_segments=(the_player.max_energy-16)/8
	local x=8
	spr(16,x,120)
	x+=8
	for i=0,middle_segments do
		spr(17,x,120)
		x+=8
	end
	spr(18,x,120)
end

local function draw_coin_count()
	spr(37,120,120)
	local s=tostr(coin_count)
	if (#s==1) s="0"..s
	print(s,112,121,3)
end

local function draw_ui()
	rectfill(0,119,128,128,0)
	draw_power_bar()
	draw_coin_count()
end

local function draw_world()
	cls()
	camera(the_player.x*8-64,the_player.y*8-64)
	map(0,0,0,0,128,64)
	for actor in all(actors) do
		actor:draw()
	end
	draw_particles()
	camera()
end

max_coins=0

state{
	name="newgame",
	enter=function(self)
		reload()
		music(0)
		tf=0
		ts=0
		tm=0
		coin_count=0
		to_reset={}
		the_player=player()
		actors={the_player}
		emit"finished"
		batteries={}
		game_enders={}
		max_coins=0
		for x=0,127 do
			for y=0,63 do
				if fget(mget(x,y),2) then
					add(batteries,{x=x,y=y})
				elseif fget(mget(x,y),3) then
					add(game_enders,{x=x,y=y})
				elseif fget(mget(x,y),7) then
					the_player.x=x
					the_player.y=y
					the_player.reset_point_x=x
					the_player.reset_point_y=y
				elseif (fget(mget(x,y),5)) then
					max_coins+=1
				end
			end
		end
	end,
	update=function(self)
		
	end,draw=function(self)
		
	end,transitions={finished="playing"}}
state{
	name="playing",
	enter=function(self)
		
	end,update=function(self)
		for actor in all(actors) do
			actor:update()
		end
		for b in all(batteries) do
			if abs(b.x-the_player.x)+abs(b.y-the_player.y-4/8)<1 then
				the_player.max_energy+=8
				the_player.energy+=8
				mset(b.x,b.y,0)
				mset(b.x,b.y-1,0)
				del(batteries,b)
				emit"batteryget"
				break
			end
		end
		for e in all(game_enders) do
			if abs(e.x-the_player.x)+abs(e.y-the_player.y-4/8)<1 then
				emit"gamewon"
				return
			end
		end
		if the_player.energy<0 then
			the_player.energy=0
			emit"died"
		end
	end,draw=function(self)
		draw_world()
		draw_ui()
	end,
	transitions={
		batteryget="batteryget",
		died="dying",
		gamewon="outro"
	}
}

state{
	name="batteryget",
	enter=function(self)
		sfx(7)
		sfx(3,-2)
		self.t=0
	end,
	update=function(self)
		add_particle(the_player.x*8,the_player.y*8,rnd(2)-1,rnd(5)-5,4)
		self.t+=1
		if self.t>30 then
			emit"finished"
		end
	end,
	draw=function(self)
		pal(4,self.t%16)
		draw_world()
		draw_ui()
	end,

	transitions={finished="playing"}
}

state{
	name="dying",
	enter=function(self)
		music(-1)
		self.t=0
		sfx(3,-2)
		sfx(1)
	end,
	update=function(self)
		self.t+=1
		if self.t>=60 then
			the_player:reset()
			reset_doors()
			emit"finished"
			music(0)
		end
	end,
	draw=function(self)
		pal(4,8)
		draw_world()
		draw_ui()
	end,
	transitions={finished="playing"}
}

state{
	name="outro",
	enter=function(self)
		self.t=0
		sfx(3,-2)
		sfx(4)
		for e in all(game_enders) do
			mset(e.x,e.y,mget(e.x,e.y)+2)
		end
		the_player.dx=0
	end,
	update=function(self)
		self.t+=1
		if self.t>60 then
			emit"finished"
		end
		simulate_actor(the_player)
	end,
	draw=function(self)
		draw_world()
		draw_ui()
	end,
	transitions={finished="gamewon"}
}

state{
	name="gamewon",
	enter=function(self)
		music(-1)
		self.s=ts
		self.m=tm
	end,
	update=function(self)
		if btnp(4) or btnp(5) then
			emit"finished"
		end
	end,
	draw=function(self)
		cls(1)
		print("game complete!",35,40,3)
		print("time: "..self.m.."m"..self.s.."s",30,64,3)
		print("coins found: "..coin_count.."/"..max_coins,30,72,3)
		print("press key to exit",30,80,3)
	end,
	transitions={finished="mainmenu"}
}

state{
	name="mainmenu",
	enter=function(self)
		music(16)
	end,
	update=function(self)
		if btnp(4) or btnp(5) then
			emit"newgame"
		end
	end,
	draw=function(self)
		cls(1)
		print("chargin' chuck",35,34,3)
		print("by maximilian hunt",25,42,3)
		print("press key to start",25,74,3)
	end,
	transitions={newgame="newgame"}
}