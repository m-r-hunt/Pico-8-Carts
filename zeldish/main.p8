pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
#include px9-5.p8:1
#include palettes.p8:0

vec2mt={
	__add=function(v1,v2)
		return vec2(v1.x+v2.x,v1.y+v2.y)
	end,
	__sub=function(v1,v2)
		return vec2(v1.x-v2.x,v1.y-v2.y)
	end,
	__mul=function(s,v)
		return vec2(s*v.x,s*v.y)
	end,
	__div=function(v,s)
		return vec2(v.x/s, v.y/s)
	end,
	__len=function(self)
		return sqrt(self.x*self.x+self.y*self.y)
	end,
	__eq=function(v1,v2)
		return v1.x==v2.x and v1.y==v2.y
	end,
	floored = function(self)
		return vec2(flr(self.x),flr(self.y))
	end,
	tostring=function(v)
		return "vec2("..v.x..","..v.y..")"
	end,
	copy=function(v)
		return vec2(v.x,v.y)
	end,
}
vec2mt.__index=vec2mt
function vec2(x,y)
	return setmetatable({x=x,y=y},vec2mt)
end

--this order needs to match
--compression order
overworldgfx=0
overworldflags=%0x30f0
overworldmap=%0x30f2
overworldsouthmap=%0x30f4
underworldgfx=%0x30f6
underworldflags=%0x30f8
underworldmap=%0x30fa

--flag documentation
--flag 0: visible map tile(vs object)

--on visible tiles
--flag 1: solid/collider
--flag 7: zone transition

--on object tiles
--flag 1: flammable
--flag 2: lightable

function load_overworld()
	init_tileobjs()
	reload(0x4300,overworldgfx,0x1b00)
	px9_decomp(0,0,0x4300,sget,sset)
	reload(0x3000,overworldflags,0x50)
	reload(0x4300,overworldmap,0x1b00)
	px9_decomp(0,0,0x4300,mget,mset)
	pal(overworld,1)
	world="overworld"
end
function load_south()
	init_tileobjs()
	reload(0x4300,overworldgfx,0x1b00)
	px9_decomp(0,0,0x4300,sget,sset)
	reload(0x3000,overworldflags,0x50)
	reload(0x4300,overworldsouthmap,0x1b00)
	px9_decomp(0,0,0x4300,mget,mset)
	pal(overworld,1)
	world="overworld"
end
function load_underworld()
	init_tileobjs()
	reload(0x4300,underworldgfx,0x1b00)
	px9_decomp(0,0,0x4300,sget,sset)
	reload(0x3000,underworldflags,0x50)
	reload(0x4300,underworldmap,0x1b00)
	px9_decomp(0,0,0x4300,mget,mset)
	pal(underworld,1)
	world="underworld"
end

world=""
loaders={
	underworld=load_underworld,
	overworld=load_overworld,
	overworld_south=load_south,
}
overworld_transitions={
	[02]={0,0,3,3,"underworld"},
	[13]={4,0,3,3,"underworld"},

	[30]={0,0,2,2,"overworld_south"},

	[00]={0,3,2,2,"overworld"},

	[01]={2,0,8.5,7,"overworld"},
	[04]={3,1,8.5,14.5,"overworld"},
}

function load_screen(pos)
	--todo clear out old objects that may have moved
	for x=pos.x*16,pos.x*16+15 do
		for y=pos.y*15,pos.y*15+14 do
			local tile=mget(x,y)
			if not fget(tile,0) then
				tileobjs[y][x]={spr=tile,flammable=fget(tile,1),lightable=fget(tile,2),frames=1,frame=0}
			end
		end
	end
end

function init_tileobjs()
	tileobjs={}
	for y=0,63 do
		tileobjs[y]={}
	end
end

function new_game()
	actor={}
	load_overworld()
	pl=make_actor(64,3,3)
	pl.state="normal"
	screen=vec2(0,0)
	pl.update=control_player
	pl.lastdir=vec2(1,0)
	load_screen(screen)
	particles={}
	mp=100
	hp=3
end

function init_gameplay()
end

function make_actor(k, x, y)
	a={
		k = k,
		pos=vec2(x,y),
		dx =vec2(0,0),
		frame = 0,
		t = 0,
		friction = 0.2,
		bounce  = 0.1,
		frames = 2,
		dim=vec2(0.4,0.4),
	}
	add(actor,a)
	return a
end

function solid(x, y)
	val=mget(x, y)
	return fget(val,0) and fget(val, 1)
end

function solid_area(x,y,w,h)
	return 
		solid(x-w,y-h) or
		solid(x+w,y-h) or
		solid(x-w,y+h) or
		solid(x+w,y+h)
end

function solid_tileobj1(x,y)
	local x=flr(x)
	local y=flr(y)
	if y<0 or y>=60 then
		return false
	end
	return (tileobjs[y][x]!=nil) and vec2(x, y)
end

function solid_tileobj(x,y,w,h)
	return solid_tileobj1(x-w,y-h) or
		solid_tileobj1(x+w,y-h) or
		solid_tileobj1(x-w,y+h) or
		solid_tileobj1(x+w,y+h)
end

function solid_actor(a, dx, dy)
	for a2 in all(actor) do
		if a2 != a then
		
			local x=(a.pos.x+dx) - a2.pos.x
			local y=(a.pos.y+dy) - a2.pos.y
			
			if ((abs(x) < (a.dim.x+a2.dim.x)) and (abs(y) < (a.dim.y+a2.dim.y))) then
				-- moving together?
				-- this allows actors to
				-- overlap initially 
				-- without sticking together    

				-- process each axis separately

				-- along x
				if (dx != 0 and abs(x) < abs(a.pos.x-a2.pos.x)) then
					v=abs(a.dx.x)>abs(a2.dx.x) and a.dx.x or a2.dx.x
					a.dx.x,a2.dx.x = v,v
					--local ca=
					-- collide_event(a,a2) or
					-- collide_event(a2,a)
					return true
				end
				
				-- along y
				if (dy != 0 and abs(y) <
					   abs(a.pos.y-a2.pos.y)) then
					v=abs(a.dx.y)>abs(a2.dx.y) and 
					  a.dx.y or a2.dx.y
					a.dx.y,a2.dx.y = v,v
					--local ca=
					-- collide_event(a,a2) or
					-- collide_event(a2,a)
					return true
				end
				
			end
		end
	end
	return false
end

function collide_terrain_event(a)
	if a.projectile then
		del(actor,a)
	end
end

function flammable(to)
	return tileobjs[to.y][to.x].flammable
end

function lightable(to)
	return tileobjs[to.y][to.x].lightable
end

function collide_tileobj_event(a,to)
	if a.projectile then
		del(actor,a)

		--todo check it's actually a fireball
		if flammable(to) then
			tileobjs[to.y][to.x].fire=0
		elseif lightable(to) then
			tileobjs[to.y][to.x].spr+=1
			tileobjs[to.y][to.x].lightable=false
			tileobjs[to.y][to.x].frames=2
		end
	end

	if a==pl and tileobjs[to.y][to.x].fire then
		hp-=1
	end
end

function solid_a(a,dx,dy)
	if solid_area(a.pos.x+dx,a.pos.y+dy,a.dim.x,a.dim.y) then
		collide_terrain_event(a)
		return true
	end
	local to=solid_tileobj(a.pos.x+dx,a.pos.y+dy,a.dim.x,a.dim.y)
	if to then
		collide_tileobj_event(a,to)--todo get tileobj
		return true
	end
	return solid_actor(a,dx,dy)
end

function move_actor(a)
	-- only move actor along x
	-- if the resulting position
	-- will not overlap with a wall
	if not solid_a(a,a.dx.x,0) then
		a.pos.x += a.dx.x
	else
		a.dx.x *= -a.bounce
	end

	-- ditto for y
	if not solid_a(a,0,a.dx.y) then
		a.pos.y += a.dx.y
	else
		a.dx.y *= -a.bounce
	end

	-- apply friction
	-- (comment for no inertia)
	a.dx.x *= (1-a.friction)
	a.dx.y *= (1-a.friction)

	-- advance one frame every
	-- time actor moves 1/4 of
	-- a tile
	a.frame += abs(a.dx.x) * 1
	a.frame += abs(a.dx.y) * 1
	a.frame %= a.frames

	a.t += 1
end

function update_fireball(fb)
	add(particles,{x=fb.pos.x*8,y=fb.pos.y*8,c=0,lifetime=4+rnd(7),dy=-1,dx=rnd(0.2)-0.1})
end

function control_player(pl)
	if pl.state=="normal" then
		mp=min(mp+1,100)
		accel = 0.05
		local pdir=vec2(0,0)
		if (btn(0)) pdir.x-=1
		if (btn(1)) pdir.x+=1
		if (btn(2)) pdir.y-=1
		if (btn(3)) pdir.y+=1
		pl.dx+=accel*pdir
		if pdir.x!=0 or pdir.y!=0 then
			pl.lastdir=pdir
		end

		if btnp(❎) and mp>=30 then
			mp-=30
			pl.state="firerod"
			pl.firet=15
			pl.k=66
			pl.frame=0
			if (dx==0 and dy==0) dx=1
			local fb=make_actor(76,pl.pos.x+pl.lastdir.x,pl.pos.y+pl.lastdir.y)
			fb.dx=0.5*pl.lastdir
			fb.projectile=true
			fb.update=update_fireball
			fb.friction=0

			pl.dx=vec2(sgn(pl.dx.x)*0.0001,0)
		end
	elseif pl.state=="firerod" then
		pl.firet-=1
		if pl.firet<=0 then
			pl.state="normal"
			pl.k=64
		end
	end
end

function update_gameplay()
	for a in all(actor) do
		a:update()
	end
	foreach(actor, move_actor)

	local base_x=flr(screen.x*16)
	local base_y=flr(screen.y*15)
	for y=base_y,base_y+15 do
		for x=base_x,base_x+16 do
			if tileobjs[y][x] then 
				if tileobjs[y][x].fire then
					if tileobjs[y][x].fire%4==0 then
						add(particles,{x=x*8+4,y=y*8,c=0,lifetime=4+rnd(7),dy=-1,dx=rnd(0.4)-0.2})
					end
					tileobjs[y][x].fire+=1
					if tileobjs[y][x].fire==10 then
						for d in all({vec2(-1,0),vec2(1,0),vec2(0,-1),vec2(0,1)}) do
							if tileobjs[y+d.y][x+d.x] and tileobjs[y+d.y][x+d.x].flammable then
								tileobjs[y+d.y][x+d.x].fire=max(0,tileobjs[y+d.y][x+d.x].fire)
							end
						end
					elseif tileobjs[y][x].fire>=60 then
						tileobjs[y][x].spr=73
						tileobjs[y][x].flammable=false
						tileobjs[y][x].fire=nil
					end
				end
				tileobjs[y][x].frame+=0.2
				tileobjs[y][x].frame=tileobjs[y][x].frame%tileobjs[y][x].frames
			end
		end
	end

	for p in all(particles) do
		p.lifetime-=1
		if p.lifetime<=0 then
			del(particles,p)
		end
		p.x+=p.dx
		p.y+=p.dy
	end

	local screenp=vec2(screen.x*16,screen.y*15)
	if pl.pos.x<screenp.x-2/8 then
		trans_start=screen:copy()
		screen.x-=1
		change_mode("screentrans")
		load_screen(screen)
	end
	if pl.pos.x>screenp.x+16+2/8 then
		trans_start=screen:copy()
		screen.x+=1
		change_mode("screentrans")
		load_screen(screen)
	end
	if pl.pos.y<screenp.y-2/8 then
		trans_start=screen:copy()
		screen.y-=1
		change_mode("screentrans")
		load_screen(screen)
	end
	if pl.pos.y>screenp.y+15+2/8 then
		trans_start=screen:copy()
		screen.y+=1
		change_mode("screentrans")
		load_screen(screen)
	end

	local ptile=mget(pl.pos.x,pl.pos.y)
	if fget(ptile,0) and fget(ptile,7) then
		change_mode("dungeontrans")
	end
end

function draw_actor(a)
	local sx=(a.pos.x*8)-4
	local sy=(a.pos.y*8)-4
	local flipx=a.dx.x<0
	spr(a.k+a.frame,sx,sy,1,1,flipx)
end

function draw_world(screen_pos)
	clip(0,0,128,120)
	--game world
	local bg=world=="overworld" and 13 or 5
	rectfill(0,0,128,128,bg)
	camera(screen_pos.x*16*8,screen_pos.y*15*8)
	map(0,0,0,0,128,64,1)

	local base_x=flr(screen_pos.x*16)
	local base_y=flr(screen_pos.y*15)
	for y=base_y,base_y+15 do
		for x=base_x,base_x+16 do
			if tileobjs[y][x] then
				spr(tileobjs[y][x].spr+tileobjs[y][x].frame,x*8,y*8)
				if tileobjs[y][x].fire then
					local t=globalt+y*x
					local s=(t%15>=7) and 74 or 75
					spr(s,x*8,y*8)
				end
			end
		end
	end

	foreach(actor,draw_actor)

	for p in all(particles) do
		pset(p.x,p.y,p.c)
	end
end

function draw_gameplay()
	camera()
	cls(7)

	draw_world(screen)

	clip(0,120,128,128)
	camera()
	--ui
	--print(mget(pl.pos.x,pl.pos.y),1,121,0)
	spr(80,0,120)
	print("❎",8,122,2)

	pal(6,7)
	pal(12,7)
	spr(93,104,120,3,1)
	pal(6,6)
	pal(12,12)
	spr(93,104,120,mp/100*3,1)

	for i=1,hp do
		print("♥",104-7*i,122,2)
	end
end

trans_duration=15

function init_screentrans()
	transt=0
end

function update_screentrans()
	transt+=1
	if transt>trans_duration then
		change_mode("gameplay")
	end
end

--quadratic easing in/out
function ease(t,b,c,d)
	t/=d/2
	if (t < 1) return c/2*t*t + b
	t-=1
	return -c/2 * (t*(t-2) - 1) + b
end

function draw_screentrans()
	camera_pos=trans_start+ease(transt,0,1,trans_duration)*(screen-trans_start)

	camera()
	cls(15)

	draw_world(camera_pos)

	clip(0,120,128,128)
	camera()
	print(ease(transt,0,1,15),0,121,2)
end

function init_dungeontrans()
	transt=0
end

function update_dungeontrans()
	transt+=1
	if transt==trans_duration then
		local index=screen.y*10+screen.x
		local target_data=overworld_transitions[index]
		loaders[target_data[5]]()
		screen=vec2(target_data[1],target_data[2])
		pl.pos=vec2(screen.x*16+target_data[3],screen.y*15+target_data[4])
		pl.dx=vec2(0,0)
		load_screen(screen)
	end
	if transt>2*trans_duration then
		change_mode("gameplay")
	end
end

function draw_dungeontrans()
	local t=0
	local pos=screen
	if transt<=trans_duration then
		t=ease(transt,0,1,trans_duration)
	else
		t=ease(transt-trans_duration,1,-1,trans_duration)
	end

	camera()
	cls(15)

	draw_world(pos)
	camera()
	rectfill(0,0,128,64*t,0)
	rectfill(0,0,64*t,128,0)
	rectfill(128-64*t,0,128,128,0)
	rectfill(0,128-64*t,128,128,0)

	clip(0,120,128,128)
	camera()
end

modes={}
mode=""
function mode(name,u,d,i)
	modes[name]={u,d,i}
end
function change_mode(new)
	mode=new
	if modes[mode][3] then
		modes[mode][3]()
	end
end
function _init()
	globalt=0
	new_game()
	change_mode("gameplay")
end
function _update()
	globalt+=1
	modes[mode][1]()
end
function _draw()
	modes[mode][2]()
end
mode("gameplay",update_gameplay,draw_gameplay,init_gameplay)
mode("screentrans",update_screentrans,draw_screentrans,init_screentrans)
mode("dungeontrans",update_dungeontrans,draw_dungeontrans,init_dungeontrans)

__gfx__
ffffff0fff73af318501ffde8367986ef4c5cfffd866def3595556dba2bef4afb934e944f0ed3eae79d1e9f78ec1fdffb2f01ef709369421f81e8c167d17c9fe
d9c27c1f313eff6943cfed32224e830a96197a7e977e8daebfb8409af38f8f58ff58942f8c5c137448c0c7f703c1958f58631ef8471e7fc698549f10dcc189b3
512ff07cc2f3e0fb8cff44c276a9bfa6c078529cff12cf81ef7aa878f54ff73cf8cf8a3e01ea1bd8b686291f35f93ebb681e2784cf634158c77c3f4fcbebcc8b
e0ab7a3026ffff1f87afce911b835e03261acf3e8fff0f20cdcf628b2bc407c69c22f3171ff23e3a1e4e7b58f2279f163faf39b8b9b8b8b917171f1fb071d4c8
fb97939fd8fd879f1443229b2bcbe0e76e4e60ffb1efdc203400b082fff76bc315f706ed029cdc7c717db978ce98f1c429c9d3c17ec51c52b4e2816802b4c5b3
e83fb6ff93e8d9997cb29838e68ffe1f7cf1b5ccf13b7eddf6c72c18fb8767ce9f9a7474eb541a9ce871cbe2bd2624e1f71fe195c3f318e8cf9dc28f4887e56c
9a2311016f794df184094ef2e919f984df147b7c1c5e4cb80d66cf21018f36022ff1f90e6a96e98c88cf54aa019a52a1487609a240f7583bd4c90e7242e7329c
2b0970002501ac380fb17a3d4c50efa8f0ffd322194b19f80d78c839fb227661c9c1e70cb9f1c763ed9fe1cc06300312df3e89d132db99eb270e0cc1f58be83e
8e1f7cd84e78076278e9784275b4a99c2785694ec78301c3ea7c5293ea48989b1f306e858882c9e22f742fdc18fc85196f1a0f1587e8f2f9202b34299fceefec
ce274c596ae94814763a06cf34ded1bf372904c6f348cd2278e8042f1e3142952c6a54497ff98ef00f90f748011c1c5f4e0fc5163529550bc523d5246c93188f
e2ef9c5ef89a09acf2e0246f5cc79581e178c459c0d02b4ec344c6a520dc0f3acd1196e0e7046940109d3f95f7890168c1fc3910798c1a1acce2b82e7a8df02f
f64e84cf21f09f14404288c4ef091f35f8fe5509878f0bce9f7834ff72a3743bf103d4e707488304ef94ef9116c81fff7161e80ff7a4eeceb131cf10120efff3
426d4864032cf8945c5f75ef1fff5f70a66858088f56302cf5beb30772e602106fbcf2ef7b9d7294e89f7ef1012080f706c688df1995ed42751c212bd99ffd66
2976e88d91ce8b403ff4c03c0cf2c9f7ceaf385fef3290c188f32cff537743c7a94a77e19d5944224809f5e0742dc593c71f4e100ffb532dd3ef9356901a482f
b4f8e35bfe0ff0ffb5e2ef5754207cd0626fccfffdc4af327878efffd48df9427c123fff7332f37d3b0efff7aefbe3b32effff7069c58fff7ab4aff161effff3
14ef73636c8ff8190b0ff7b839aef3ffc5985811efb8f52e58010f75cf3d071ff3bc3f70f3052997ff80808fbe2787f8f1e845210ef99368de08f5298ffb901a
ba3e3c3f08f942e88d10e7c8eafef1944ef771f701e784424870cf352194330ef31db22bbe21f2ff3b836c25c83609ffab3f8f74ec36148fd44fefcf11c40eff
61f1f70756e82f0fc5cf61e9275c0f35df0d0603cfffc80956efff542effc1f701e9278b93e09bcf179f583e0f744be79bc579393e0737f1edbcf179f7e2fbc5
e79b2ff49b02fef279d5eab8b4e2dbce2e2db4e29b8bce2e29ffffffff7c80100030000020102030303030303030303030301010101010101010101010103010
10202020003030301830303030303020002020200030302020200000301818000000000000000000000000000018180000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000ffffff0fff71eaff9b480004424160780a7f05da8558503a1633d9258ad458331c
85e249388644aa9c6643814220a096e5ea2dda5f9c87c9fcfffff888cd112f708f30cf10ef00f708f30cf188cf395fcc1ba309c3228ffff6d0848327d7f4e4cb
f37221efffd03ede37c3e2fc79bf784ef8dfff9ccf2e9df3f3df4f9fbe9be73ffdf8f7af55872f8fffff8dcfbf3f3e7efffbb9fb7707de7fff1cff1efff37ef7
1fff8f56fc2781ef00f708f30cf10ef00f70832bd9df3ef8f365ff39175fff2ffb9fffce79cdef81ff3a0ffff9cf0f52ceff4ffbaff79effc4c1ef309040d4cf
fff7748fff7223ac80ffffa3e7cffffff7309f30cf10ef790ef00f708f30c23f74832cffff7748fb2cf21efff8ceff6ffbbcff323f358fff721e89fffdff01d0
b0bcf7effff3c3ff7cfbe09f92174e7af9ef729f9678cf3cf3c7cf0978cff6cffe2cfb1efff708f36e494821f1f58f68f550ff73f3d8ff34ef79bf784eff9b38
fffb0993873ff3521b0f383ff3b4aefffc0f58fb3c39f7ffd4efddfffdfcff55242cf093cffad7ff399868ffb8be19f31cffc3cfff94ef00f70ff42efa0f70f7
08f30cf1cfff790ff3ecd7bcdbf12579bf3effff37bf7ef9f7ee79cf7e9cf7ff564ec4219f8b2f9724973cffd9fffbe13c19a79ac5cb12cfd98ffb1ff72e7a0f
358fffb016dbeab675e0fceabe70d46eb5236fb7e3f790ef00fff7921fb58fff7193cf3ecb8f12c999ffff01efd0f0ff48ff958ffff2cff63cffe5ff72c99ffd
ed77ee8cf0b8fffe719b4ffff5170fffff8f30cf1c9161e80748ff8f30cf10ef0693cfff580f758f32c51a1ea0f358ab2cff12cf998fd3cff05ef90f48fb2c11
ef9ef0f3cf0b4ae85b57daadee9df0f34ad3e83674e1dcf7e2efb421e709ff2cfde74c2cdc8fffff098f1f09fff7bbff137071fff7bdff9b9a7930cf10ef790e
f00f708fb67e9909ccf2df70fffb4c91e80f8c9c7984e6ff711cf81eb0f37879f52cfd1e70b094cfff1805efa02390ff3c4cfff93f3c19ff5fffbfff22fff7e0
ffffff0fff71e9752ff7062a4ba03bea94efffdbd19e1f08f30cf10ef00f708f30cf10ef089066bc0fffff700efffd370fffff301e02cfff570b2cfff77a97e2
ea68ffffc2f5eb3fffff71275e8d2ef00f708f30cf10ef00f708f59fffffffff00cf90ef00f708f30cf10ef00f708f329ef2cffff5ef00f708f30cf10ef00f70
8f30cf1cffffffff362efff53fffffd20ef00f708f30cf10ef00f708ffffffff7c0c10ef00f708f30cf10ef00f708f30cf1cffff700f708f30cf10ef00f708f3
0cf10ef0effffffff131ffffa9fffff610f708f30cf10ef00f708f30cffffffff360e00f708f30cf10ef00f708f30cf10ef0effff308f30cf10ef00f708f30cf
10ef00f70fffffffff898fff7dcffff7b08f30cf10ef00f708f30cf10effffffff130fffffb0ffffff0fff73af314605bede49cb1b3efff31019fce0ef2e007c
4c1cff65bcdbe10c175e0f87486161978b26712f01eff79748f3671f275ebf0708ff74a2cff05f0eb5d70cf56ffb3bff522487d590f79fa148d0fb7690ffb4b1
fd297e74fdfff14eff4230708ffff9c7c3c46a507172fff6e2e5e0e2e00f8e38d854e39ff774f0e7a8cf3bec31a59423cffff07efacf30b30c1291efff94e984
2fff1bf7802cffff5d5876840cfff3103ef732f7140ffff302f72ff840c106461efff74e9cf996e7b4c9320b0fff734e769ff98effffffff7e6fe8070c370c9c
50202024e0070ffbce579cfc97e95fa461fc679778e59293339127d55b87e1dfff5f9b28cfbb7e035962ec583e26b8b084088c42c3cffd6b9acfd1b4eb0f6cb3
e22d0900c2bcffa32748f97f2129e619732821e0f06e9ff72ddbfafb7bc534ad38f67a8c129842194ceb5901b41bffb561bccfed769f6595e8c3d7afe37e7f3c
8175742cffec466cfdbc678e5c32ffcea5ef7d1fe1cc51a0e005ef0fc5aff3ac1a1ea0748f539b648136cfff585832cff969e967f890e68010ffff04426dd543
2811e7c4e70678df01effba8e111619080b101efadef870cf298f308408dbf8ffd6678c59c1d8080104081b1e7acec5e9739be40212bf1afcff6d8a4744290bc
80603c03cf5b37c5fbcf2f3072c188f5ef7c9b8a981e7851ba44224e7b74391757e8343f008ff13d4db2b48052cf7d5f97caf8ffff3cfbed87e72e07898fffb9
9cf1f327c6bdfffd48ef94e8be9ccfffdc46f37df3d0efff7acfbef1bdbeffff70e84ed9fffba97bff1617cffff728cfffffffffff80c179e56797e27f5ef8bc
979fe27e5eebcf079f5e2f7c5ef9bcf379f7e2db8b8b4e29b8bc3717179d527179c56797effffffff12210000000000010003030303030303030000000000000
10000030303030300000000000000000000000000000000000000000002020400000200000000000001800000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffff0fff71e9f3595004c8f91b0f7c944bca1e6b9b
6bb3cf10ef00f708f30cf10ef00f708f302746efffeb4d076833c39af53c728fffb01a982758f72c31ef291fff71098f1278ff52121effe63ae9323ff73e72e7
90fb48f58501717ddeaffdc1bf467b8070fff566ff35e79848fff31c1e4c12836b5e03c1bd2f3ac993df21e790f36e81e0bff368fffb21e7e0f48f5defffb0f5
8b2cff2243cfffbbcc91effff3521fff7c2fed5f342f74a9f5c12942d0784290772cf21e790fb48f52cf23fcf25ff4cf478efffd69f8f25ffff9de72acf3cf09
afff3b1e790fb48fff731a1e2f7d7cfffdecf639ff22f8381b4dbcb16cff58f52cf2c9ed381f72ff0fff2ef7c17480766efff82d3e7b6ffbe2e7b9cde0c1b637
8dffd2faf52cff18070fffffb0670f46e7d0fff762cf23278fe790768fffb61effffbe3bbaec4ec433fb4834294a1e0942968f52cf21e790fb0ffffff02fffff
f06ff5aa1effffb52c51efff768b3cfffd5bf78f7858f68ffb0fb48f583d57072ff07ad1c8fff0ffffff5c1bd2772a126836b5eff99bcf21ef4bb31ff30dff92
fff7c2cfffdc0d0f5868f32cffff7048fffff0dca5f42f4a99f52c12112b0fb48f52cf21e790fb0ffffff02ffffff06f35e5768f7c11efff858ffb01efff768f
f74872c31efffd683def1eff2cf21e71e7801e71e47d10e84cffc8fff487df8f5e670ffffa5ff5eac6ff3dc7e790f7ac5b1ff56e780f48ffffffc0ff7a0768ff
f761e8c1ec0d4cffff717afcf19af52cf21e790fb48f52cf21e71000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
rrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrr
rbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbr
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr3
3rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr3
33rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr33
j333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333jj333333j
rjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjr
rrbbbbrrrrrgggrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgggrrrrbbbbrr
rbbrrbbrrrgfffgrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgfffgrrbbrrbbr
bbbbbbbbrgffvvfgrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgffvvfgbbbbbbbb
3rbbbbr3gffvvvvgrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgffvvvvg3rbbbbr3
3rrrrrr3gfvvvfugrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgfvvvfug3rrrrrr3
33rrrr33gfvvf4ugrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgfvvf4ug33rrrr33
j333333jgvvu44grrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgvvu44grj333333j
rjj33jjrrgggggrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgggggrrrjj33jjr
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr33rrrr33
j333333jrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrj333333j
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33jjr
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgggrrrrrgggrrrrrgggrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgfffgrrrgfffgrrrgfffgrrrrrrrrrrrrrrrrrrrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrrrrrrrgffvvfgrgffvvfgrgffvvfgrrrrrrrrrrrrrrrrrrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrrrrrrrrrrrrrrrrrrrr3r3rrrrrrrrrrrrr3r3rrrrrrrrrrrrrrrrrrgffvvvvggffvvvvggffvvvvgrrrrrrrrrrrrrrrrrrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgfvvvfuggfvvvfuggfvvvfugrrrrrrrrrrrrrrrrrrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrrrrrrrrgfvvf4uggfvvf4uggfvvf4ugrrrrrrrrrrrrrrrrrrrrrrrr33rrrr33
j333333jrrrrrrrrrrrrrrrrrrrrrrrrr3r3rrrrrrrrrrrrr3r3rrrrrrrrrrrrrrrrrrrrgvvu44grgvvu44grgvvu44grrrrrrrrrrrrrrrrrrrrrrrrrj333333j
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgggggrrrgggggrrrgggggrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33jjr
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrrrrrrrrrrrr3r3rrrrrrrrrrrrr3r3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrrrrrrrrrrr3rrrrrrrrrrrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr33rrrr33
j333333jrrrrrrrrrrrrrrrrr3r3rrrrrrrrrrrrr3r3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrj333333j
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33jjr
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrggggggrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrg444444grrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrg4ff4f4grrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrg44ff44grrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrg444444grrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrggkkggrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr33rrrr33
j333333jrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgk4grrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrj333333j
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgk4grrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33jjr
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr33rrrr33
j333333jrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrj333333j
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33jjr
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
rbbrrbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
bbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
3rbbbbr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
3rrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
33rrrr33rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
j333333jrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrfffffffffffffffffffffffffffffffffffffffffffffffffggggfffffffffffffff
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffffffffffffffffffffffffffffffffffffffffffgcffcgffffffffffffff
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrfffffffffffffffffffffffffffffffffffffffffffffffgfcffcvgfffffffffffff
rbbrrbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrfffffffffffffffffffffffffffffffffffffffffffffffgssssssgfffffffffffff
bbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrfffffffffffffffffffffffffffffffffffffffffffffffgcsggcsgfffffffffffff
3rbbbbr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrfffffffffffffffffffffffffffffffffffffffffffffffgcsggcsgfffffffffffff
3rrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrggrrggrrrrrrrrrrrrrr
33rrrr33rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
j333333jrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr33rrrr33
j333333jrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrj333333j
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrjj33jjr
rrbbbbrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrr3r33r3rr3r33r3rr3r33r3rr3r33r3rrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrrrrr9999999999999999rrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3b3bb3b33b3bb3b33b3bb3b33b3bb3b3rrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrrrr9aaaaaaaaaaaaaaaa9rrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3r3br3r33r3br3r33r3br3r33r3br3r3rrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrrr9asccjjjjjsccjjjjja9rrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr333br333333br333333br333333br333rrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrr9accccjjccccccjjcccca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3br33bb33br33bb33br33bb33br33bb3rrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrr9acssccccjcssccccjcsa9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrb33brr3bb33brr3bb33brr3bb33brr3brrrrrrrr33rrrr33
j333333jrrrrrrrrr9accjsccssccjsccsscca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3br3r3r33br3r3r33br3r3r33br3r3r3rrrrrrrrj333333j
rjj33jjrrrrrrrrrr9ajcjssssjjcjssssjjca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrr33r3r3rr33r3r3rr33r3r3rr33r3r3rrrrrrrrrrjj33jjr
rrbbbbrrrrrrrrrrr9ajccccjjjjccccjjjjca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrr3r33r3rr3r33r3rr3r33r3rr3r33r3rrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrr9accsjjcccccsjjccccca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3b3bb3b33b3bb3b33b3bb3b33b3bb3b3rrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrr9asccsjssjsccsjssjsca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3r3br3r33r3br3r33r3br3r33r3br3r3rrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrr9ajsccjjjjjsccjjjjjsa9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr333br333333br333333br333333br333rrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrr9accccjjccccccjjcccca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3br33bb33br33bb33br33bb33br33bb3rrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrr9acssccccjcssccccjcsa9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrb33brr3bb33brr3bb33brr3bb33brr3brrrrrrrr33rrrr33
j333333jrrrrrrrrr9accjsccssccjsccsscca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3br3r3r33br3r3r33br3r3r33br3r3r3rrrrrrrrj333333j
rjj33jjrrrrrrrrrr9ajcjssssjjcjssssjjca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrr33r3r3rr33r3r3rr33r3r3rr33r3r3rrrrrrrrrrjj33jjr
rrbbbbrrrrrrrrrrr9ajccccjjjjccccjjjjca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrr3r33r3rr3r33r3rr3r33r3rr3r33r3rrrrrrrrrrrbbbbrr
rbbrrbbrrrrrrrrrr9accsjjcccccsjjccccca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3b3bb3b33b3bb3b33b3bb3b33b3bb3b3rrrrrrrrrbbrrbbr
bbbbbbbbrrrrrrrrr9asccsjssjsccsjssjsca9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3r3br3r33r3br3r33r3br3r33r3br3r3rrrrrrrrbbbbbbbb
3rbbbbr3rrrrrrrrr9ajsccjjjjjsccjjjjjsa9rrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr333br333333br333333br333333br333rrrrrrrr3rbbbbr3
3rrrrrr3rrrrrrrrrr9acccjjccccccjjccca9rrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3br33bb33br33bb33br33bb33br33bb3rrrrrrrr3rrrrrr3
33rrrr33rrrrrrrrrrr9aaaaaaaaaaaaaaaa9rrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrb33brr3bb33brr3bb33brr3bb33brr3brrrrrrrr33rrrr33
j333333jrrrrrrrrrrrr9999999999999999rrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrr3br3r3r33br3r3r33br3r3r33br3r3r3rrrrrrrrj333333j
rjj33jjrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrr33r3r3rr33r3r3rr33r3r3rr33r3r3rrrrrrrrrrjj33jjr
rrbbbbrrrrrgggrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgggrrrrbbbbrr
rbbrrbbrrrgfffgrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgfffgrrbbrrbbr
bbbbbbbbrgffvvfgrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgffvvfgbbbbbbbb
3rbbbbr3gffvvvvgrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgffvvvvg3rbbbbr3
3rrrrrr3gfvvvfugrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgfvvvfug3rrrrrr3
33rrrr33gfvvf4ugrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgfvvf4ug33rrrr33
j333333jgvvu44grrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgvvu44grj333333j
rjj33jjrrgggggrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrfrffffffffrfrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrgggggrrrjj33jjr
rrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrfrffffffffrfrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrrrrbbbbrr
rbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrrfrffffffffrfrrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbrrbbr
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbrrfrffffffffrfrrbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
3rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr3rrfrffffffffrfrr3rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr33rbbbbr3
3rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr3rrfrffffffffrfrr3rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr33rrrrrr3
33rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr33rrfrffffffffrfrr33rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr3333rrrr33
j333333jj333333jj333333jj333333jj333333jj333333jj333333jrrfrffffffffrfrrj333333jj333333jj333333jj333333jj333333jj333333jj333333j
rjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrrfrffffffffrfrrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjrrjj33jjr
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
v000v000vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvv0vvv0vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
v000v000vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
v0vvv0vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
v000v000vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009f041f0500082609aa0b2a0c00000000
__map__
0000000000b0bd001111cccc000008000020220020222202dddddddd3d3dd3d300000000000000000000000000000000000000000000000000000000000000000000000000bbbb0bcccc6c11008008000072770242444424ddddddddb3b33b3b0000000000000000000000000000000000000000000000000000000000000000
00077000d0ddbbdd6661cc16008088002077ff2742777424dddddbddd3b33d3d00000000000000000000000000000000000000000000000000000000000000000070070030d1dd3d1111c61c0088880072f7ff2f42744724ddbdbddd33b33d330000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c802cc014201
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a00200055000540005400053000530005300052000510005500055000540005300055000550005400053002550025500254002530045500455004540045400453004530045300452004510045100451004510
010a00200c053000000000000000000030000000000000000c0530000000000000000000000000000000000027633000000000000000000000000000000000002763300000000000000000000000000000000000
010a00200055000540005400053000530005300052000510005500055000540005300055000550005400053004550045500454004530025500255002540025400253002530025300252002510025100251002510
010a00201c7521c7521c7421c7421c7321c7321c7221c7121c7121c7121c7121c7121c7121c7121c7121c7121d7521d7421d7321d722217522174221732217222172221722217122171221712217122171221712
010a0000247522474224742247322375223742237422373221742217422174221732217322172221722217121f7501f7511e7511e7511d7511d7511c7511c7421c7421c7321c7321c7221c7121c7121c7121c712
010a00001c0501c0551f0501f055230502305524050240551c0501c0551f0501f055230502305524050240552505025055230502305521050210551d0501d0552405024055230502305521050210551d0501d055
010a00002305023055260502605528050280552305023055230502305526050260552805028055230502305524050240552805028055290502905524050240552405024055290502905528050280552405024055
__music__
01 20214344
00 22214344
00 20212344
00 22212444
00 20212544
02 22212644

