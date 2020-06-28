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
--flag 3: enemy spawn

function load_overworld()
	init_tileobjs()
	reload(0x4300,overworldgfx,0x1b00)
	px9_decomp(0,0,0x4300,sget,sset)
	reload(0x3000,overworldflags,0x80)
	reload(0x4300,overworldmap,0x1b00)
	px9_decomp(0,0,0x4300,mget,mset)
	pal(overworld,1)
	world="overworld"
end
function load_south()
	init_tileobjs()
	reload(0x4300,overworldgfx,0x1b00)
	px9_decomp(0,0,0x4300,sget,sset)
	reload(0x3000,overworldflags,0x80)
	reload(0x4300,overworldsouthmap,0x1b00)
	px9_decomp(0,0,0x4300,mget,mset)
	pal(overworld,1)
	world="overworld"
end
function load_underworld()
	init_tileobjs()
	reload(0x4300,underworldgfx,0x1b00)
	px9_decomp(0,0,0x4300,sget,sset)
	reload(0x3000,underworldflags,0x80)
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
	for a in all(actor) do
		if a ~= pl then
			del(actor, a)
		end
	end
	--todo clear out old objects that may have moved
	for x=pos.x*16,pos.x*16+15 do
		for y=pos.y*15,pos.y*15+14 do
			local tile=mget(x,y)
			if not fget(tile,0) then
				if fget(tile,3) then
					local e=make_actor(tile,x,y)
					e.update=slime_update
					e.friction=0
				else
					tileobjs[y][x]={spr=tile,flammable=fget(tile,1),lightable=fget(tile,2),frames=1,frame=0}
				end
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
	items={}
	equipped_item=1
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
	return (tileobjs[y][x]!=nil) and (not tileobjs[y][x].unsolid) and vec2(x, y)
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
					collide_event(a,a2)
					collide_event(a2,a)
					return true
				end
				
				-- along y
				if (dy != 0 and abs(y) <
					   abs(a.pos.y-a2.pos.y)) then
					v=abs(a.dx.y)>abs(a2.dx.y) and 
					  a.dx.y or a2.dx.y
					a.dx.y,a2.dx.y = v,v
					collide_event(a,a2)
					collide_event(a2,a)
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

function collide_event(a1,a2)
	if a1.k==96 and a2.projectile then
		--todo fix enemy collision
		del(actor,a1)
	end
	if a1.projectile then
		del(actor,a1)
	end
	if a1.k==96 and a2 == pl then
		hp -= 1
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

	if a==pl and tileobjs[to.y][to.x].spr==80 then
		add(items,{mp_cost=30,use=use_firerod,spr=80})
		tileobjs[to.y][to.x]=nil
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

function use_firerod()
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

		if items[equipped_item] and btnp(❎) and mp>=items[equipped_item].mp_cost then
			mp-=items[equipped_item].mp_cost
			items[equipped_item].use()
		end
	elseif pl.state=="firerod" then
		pl.firet-=1
		if pl.firet<=0 then
			pl.state="normal"
			pl.k=64
		end
	end
end

function slime_update(sl)
	if not sl.timer or sl.timer<0 then
		sl.dx=0.1*rnd{vec2(1,0),vec2(-1,0),vec2(0,1),vec2(0,-1)}
		sl.timer=rnd(30)+15
	end
	sl.timer-=1
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
						tileobjs[y][x].unsolid=true
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

	--equipped item
	if items[equipped_item] then
		spr(items[equipped_item].spr,0,120)
	end
	print("❎",8,122,2)

	--mp bar
	pal(6,7)
	pal(12,7)
	spr(93,104,120,3,1)
	pal(6,6)
	pal(12,12)
	spr(93,104,120,mp/100*3,1)

	--hearts
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
b4f8e35bfe0ff0ffb5e2ef9c5426480c173898d33fff7f296cb01e74e0f0dfffb7031b1fb29c178ccfffd39f4e7ea761cffff3e2df7d7674cfff1c3631c0ffe2
9b0fff717205ef3c2cffff728cff6c6c81ff132161eff61f278ef3ffc5985803efb8f52e68010f75cf3d071ff3bc3f70f305299bfdc18731efabc3ed3e787259
408f76e916b70e7942eff6248eaeaf0f0140cf44c11b30cf81d5fef3298cffe2ef02cf098580f08f7a4229660cf72a75467d52e6ef7617c46926c111221f7577
e1ff8c97c280fb98edf9f32810ff7b8f8f38b2374878721e7d0f49b268f9ae7860381eff7648c23ffff221ff7e8f380f493cdc178c5ef8bcf2c178f32a5fbc5e
abc9c178b9f1e0fe5ef8bcf379f5e2fbc59f7ac5097f79bce27d5c5279e5a7179e5279c5c567179cffffffff3640100030000020102030303030303030303030
30101010101010101010101010301010202020003030301830303030303020002020200030302020200000301818000000000000000000000000000018180000
00000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000ffffff0fff71eaffdb480004424160780a7f
05da8558503a1633d9258ad45830d906c271ac1443225d4633a1c0211058430e79ba47b6d723e17e3fffff32227748cf10ef00f708f30cf10ef00f7022ff46d3
37cae042f880efffb53021e8c5fd3931fefc9848fff73c87bfc1f8bc3f5eef129f36fff723fb876ffcf4f3d7efa7eafdcf7f3ef9e751e9c3effff363ffefcf8f
9ffffe6efed143fb3bff1cff1ef71ffff93fff8ff9cf2b7693c0f708f30cf10ef00f708f30c19decef2fbcf2baffbc8baffb9fffcff86fb4e70f7c8ff358ffff
4e78f216ffbaff7dffc4fff62e0f328402862effffb32cfff31915648fff7d1f7effffffb18cf10ef00ffb40f708f30cf10699f32c11effffb32cf51e790fff7
46ffbbfff5eff199f92cfff3907ccff0fff8868585e74fffff1e9ff5ef678cf49832f3df4ff39cf4b34ef1ef1e3edeff3d54eff3ef771efd0ffff30cf13fa424
98f8f2c73cfa28ffb9fb6cff12ff3ddf342ff7dd1cfff58cc1cb9ffd29858f1c9ff9525fff768f2cfd1e9cfdf772f7fefffe7effb2121e78c1ef7debff9c443c
ff5c5f8cf90ef7e1efff42f708f38f721f758f38f30cf10ef0efffb48ff17e78f14e78df09abcdf1fffff9bdf5f7df57fb4e74f4e7cf133276298c7c59fc31ac
b1effecfff5f81e84db45e2ed01efe4cffd8ff31f358f92cfff580be57d5bb278767d5f38623fd291bfd3f9fb40f708fffb498fd2cfffb8c1ef17e5cf01ecccf
ff780ff6878f72cffc2cfff71ef7b1ef7faff31eccff8feb3774e785cff9fb8c5affffa838ffff7cf10ef0ec0b074832cf7cf10ef00f70bc1efff248fb2cf11e
a0d0758f924d51eff01efc4cfe1ef782ff4872cf51e80ff4f78f1e785257cadab65d67fce78f12de17c1b32f86e7471ff5290f38cf71ef6f7261e66cffff784c
f978cfffbddffa938b8fffbdeffdd4dbc10ef00ffb40f708f30cf5b3fc4846e79ef38fff52ec074874e4eb4427bffb80e7c0f58f93cbcf21efe0f385842efff0
482f7509948ff162efffc9f1e8cffcfffeff719fff37ffffff0fff71e9752ff7062a4ba03bea94efffdbd19e1f08f30cf10ef00f708f30cf10ef089066bc0fff
ff700efffd370fffff301e02cfff570b2cfff77a97e2ea68ffffc2f5eb3fffff71275e8d2ef00f708f30cf10ef00f708f59fffffffff00cf90ef00f708f30cf1
0ef00f708f329ef2cffff5ef00f708f30cf10ef00f708f30cf1cffffffff362efff53fffffd20ef00f708f30cf10ef00f708ffffffff7c0c10ef00f708f30cf1
0ef00f708f30cf1cffff700f708f30cf10ef00f708f30cf10ef0effffffff131ffffa9fffff610f708f30cf10ef00f708f30cffffffff360e00f708f30cf10ef
00f708f30cf10ef0effff308f30cf10ef00f708f30cf10ef00f70fffffffff898fff7dcffff7b08f30cf10ef00f708f30cf10effffffff130fffffb0ffffff0f
ff73af314605bede49cb1b3efff31019fce0ef2e007c4c1cff65bcdbe10c175e0f87486161978b26712f01eff79748f3671f275ebf0708ff74a2cff05f0eb5d7
0cf56ffb3bff522487d590f79fa148d0fb7690ffb4b1fd297e74fdfff14eff4230708ffff9c7c3c46a507172fff6e2e5e0e2e00f8e38d854e39ff774f0e7a8cf
3bec31a59423cffff07efacf30b30c1291efff94e9842fff1bf7802cffff5d5876840cfff3103ef732f7140ffff302f72ff840c106461efff74e9cf996e7b4c9
320b0fff734e769ff98effffffff7e6fe8070c370c9c50202024e0070ffbce579cfc97e95fa461fc679778e59293339127d55b87e1dfff5f9b28cfbb7e035962
ec583e26b8b084088c42c3cffd6b9acfd1b4eb0f6cb3e22d0900c2bcffa32748f97f2129e619732821e0f06e9ff72ddbfafb7bc534ad38f67a8c129842194ceb
5901b41bffb561bccfed769f6595e8c3d7afe37e7f3c8175742cffec466cfdbc678e5c32ffcea5ef7d1fe1cc51a0e005ef0fc5aff3ac1a1ea0748f539b648136
cfff585832cff969e967f890e68010ffff04426dd5432811e7c4e70678df01effba8e111619080b101efadef870cf298f308408dbf8ffd6678c59c1d80801040
81b1e7acec5e9739be40212bf1afcff6d8a4744290bc80603c03cf5b37c5fbcf2f3072c188f5ef7c9b8a981e7851ba44224e7b74391757e8343f008ff13d4db2
b48052cf7d5f97caf8ffff3cfbed87e72e07898fffb99cf1f327c6bdfffd48ef94e8be9ccfffdc46f37df3d0efff7acfbef1bdbeffff70e84ed9fffba97bff16
17cffff728cfffffffffff80c179e56797e27f5ef8bc979fe27e5eebcf079f5e2f7c5ef9bcf379f7e2db8b8b4e29b8bc3717179d527179c56797effffffff122
10000000000010003030303030303030000000000000100000303030303000000000000000000000000000000000000000000020204000002000000000000018
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffff0fff71e9f3595004c8f91b0f7c944bca1e6b9b6bb3cf10ef00f708f30cf10ef00f708f302746efffeb4d076833c39af53c728fffb01a982758f72c31ef
291fff71098f1278ff52121effe63ae9323ff73e72e790fb48f58501717ddeaffdc1bf467b8070fff566ff35e79848fff31c1e4c12836b5e03c1bd2f3ac993df
21e790f36e81e0bff368fffb21e7e0f48f5defffb0f58b2cff2243cfffbbcc91effff3521fff7c2fed5f342f74a9f5c12942d0784290772cf21e790fb48f52cf
23fcf25ff4cf478efffd69f8f25ffff9de72acf3cf09afff3b1e790fb48fff731a1e2f7d7cfffdecf639ff22f8381b4dbcb16cff58f52cf2c9ed381f72ff0fff
2ef7c17480766efff82d3e7b6ffbe2e7b9cde0c1b6378dffd2faf52cff18070fffffb0670f46e7d0fff762cf23278fe790768fffb61effffbe3bbaec4ec433fb
4834294a1e0942968f52cf21e790fb0ffffff02ffffff06ff5aa1effffb52c51efff768b3cfffd5bf78f7858f68ffb0fb48f583d57072ff07ad1c8fff0ffffff
5c1bd2772a126836b5eff99bcf21ef4bb31ff30dff92fff7c2cfffdc0d0f5868f32cffff7048fffff0dca5f42f4a99f52c12112b0fb48f52cf21e790fb0fffff
f02ffffff06f35e5768f7c11efff858ffb01efff768ff74872c31efffd683def1eff2cf21e71e7801e71e47d10e84cffc8fff487df8f5e670ffffa5ff5eac6ff
3dc7e790f7ac5b1ff56e780f48ffffffc0ff7a0768fff761e8c1ec0d4cffff717afcf19af52cf21e790fb48f52cf21e710000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ae042e0516083c09c00b400c00000000
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

