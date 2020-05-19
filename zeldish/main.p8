pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
#include px9-3.p8:1
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
}
vec2mt.__index=vec2mt
function vec2(x,y)
	return setmetatable({x=x,y=y},vec2mt)
end

overworldgfx=0
overworldflags=%0x30fe
overworldmap=%0x30fc
underworldgfx=%0x30fa
underworldflags=%0x30f8
underworldmap=%0x30f6

world=""

function load_overworld()
	reload(0x4300,overworldgfx,0x1b00)
	px9_decomp(0,0,0x4300,sget,sset)
	reload(0x3000,overworldflags,0x50)
	reload(0x4300,overworldmap,0x1b00)
	px9_decomp(0,0,0x4300,mget,mset)
	pal(overworld,1)
	world="overworld"
end
function load_underworld()
	reload(0x4300,underworldgfx,0x1b00)
	px9_decomp(0,0,0x4300,sget,sset)
	reload(0x3000,underworldflags,0x50)
	reload(0x4300,underworldmap,0x1b00)
	px9_decomp(0,0,0x4300,mget,mset)
	pal(underworld,1)
	world="underworld"
end

function _init()
	load_overworld()
	pl = make_actor(64,2,2)
	screen=vec2(0,0)
end

actor={}
function make_actor(k, x, y)
	a={
		k = k,
		pos=vec2(x,y),
		dx =vec2(0,0),
		frame = 0,
		t = 0,
		friction = 0.15,
		bounce  = 0.3,
		frames = 2,
		dim=vec2(0.4,0.4),
	}
	add(actor,a)
	return a
end

function solid(x, y)
	val=mget(x, y)
	return fget(val, 1)
end


function solid_area(x,y,w,h)
	return 
		solid(x-w,y-h) or
		solid(x+w,y-h) or
		solid(x-w,y+h) or
		solid(x+w,y+h)
end

function solid_actor(a, dx, dy)
	for a2 in all(actor) do
		if a2 != a then
		
			local x=(a.pos.x+dx) - a2.pos.x
			local y=(a.pos.y+dy) - a2.pos.y
			
			if ((abs(x) < (a.dim.x+a2.dim.x)) and (abs(y) < (a.dim.h+a2.dim.h))) then
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

function solid_a(a,dx,dy)
	if solid_area(a.pos.x+dx,a.pos.y+dy,a.dim.x,a.dim.y) then
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
	a.frame += abs(a.dx.x) * 4
	a.frame += abs(a.dx.y) * 4
	a.frame %= a.frames

	a.t += 1
end

function control_player(pl)
	accel = 0.05
	if (btn(0)) pl.dx.x -= accel 
	if (btn(1)) pl.dx.x += accel 
	if (btn(2)) pl.dx.y -= accel 
	if (btn(3)) pl.dx.y += accel 
end

function _update()
	control_player(pl)
	foreach(actor, move_actor)
	local screenp=vec2(screen.x*16,screen.y*15)

	--todo: Nice transition
	if pl.pos.x<screenp.x-2/8 then
		screen.x-=1
	end
	if pl.pos.x>screenp.x+16+2/8 then
		screen.x+=1
	end
	if pl.pos.y<screenp.y-2/8 then
		screen.y-=1
	end
	if pl.pos.y>screenp.y+15+2/8 then
		screen.y+=1
	end
end

function draw_actor(a)
	local sx = (a.pos.x * 8) - 4
	local sy = (a.pos.y * 8) - 4
	spr(a.k + a.frame, sx, sy)
end

function _draw()
	camera()
	cls(15)

	clip(0,0,128,120)
	--game world
	local bg=world=="overworld" and 13 or 5
	rectfill(0,0,128,128,bg)
	camera(screen.x*16*8,screen.y*15*8)
	map(0,0,0,0,128,64)
	foreach(actor,draw_actor)

	clip(0,120,128,128)
	camera()
	--ui
end

__gfx__
ffffff0fff73af31c6703ac4aad1db7dd51163d9c2783c312c1c9bbe264efee77e7fd813659555ad1bacafa3b1d6ed7ae4437edb1f3c3c5bfec7e06e8f786cd6
94e852934eb4278c19b909cb7104c226fe3a9742f0ef8d2f74c085e1121e9c37ff4c01c06113854e9060b8c19d31697ea529d037c0d342327cf110293204206d
3cb7377390978c3608d081f50c87836ea401b4005e10223fb45e78acf0718854e0e007069e53127088fa94010f5e85856ff0f744c228dcf1f12999f7461ef143
559571840c611c619363f44ffa29809d4e0ebdbf3425e1616985d4299c8f70980a11987a0070080f48f1346080fb48d7694e01bc97f16f1f8c9c084219c42229
94e29f11144239cf3cc3c7c17ce63219c2c667c8fc3cdfcedf3e6e24c92c1e11e7b1a4919d3cbdf32fb08d790019fff3d28a44b2ff8dff78710e6eff3e876946
19f9ce2ef56c743c9cfff6d9f39b8b9b8b8b917171f1ff38cc8fb97939fd8fd879fb3f938f9939b1cff68ffb182fff7fde1effffffffffbcfea052cfff3fa720
140cffffe23b0f0fff7bd8cfffff287fffffb1093d31efffd3ca1efff978fffffffffffff4cf1c5cb27c1ffffe3e1e71ef0cffff70808cffff7182f1fdffff71
818dffff7183978dffff71808cffff718f78f18f3e5f3c5e9bc979be2ffc5e79bc579f1e2fe5edbcd79f5e2fbc5ef9b2f7c8702df5e2e2e2e2bbce2e2e2e2bbc
e2e2e2e2effffffff132005520002020000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000ffffff0fff71e8f5520494912e4cb2b85bd5726b4f8efffff80ef00f708f30cf10ef00f708f30cf10e7a4676abffffad30c31e8c5fd9
ecffffa980f6e83e47cfff5ecbe9cdf3c9ef8fffff0fcf2ffc3ef9fb4ef0efffdde7afbe7bfffff485ffbc168f38fff3adfebf61f0f3e8fffff207d79f4042cf
ffff93fff7edbfffffb42ffffa8f98f30cf11efff61f70fffffffff192f7e57c21f78cfffd5fbdfffff307c4cfff97effffffff300fff0efff61fff0ef1efff5
1f3174ce1efff72f70fffffffffff714e71efff62fffffd2cf10ef00f708f30cf10ef00f708f30cfffffffffff409fffff50ffffff0fff73af3148cc1255ab96
3feff90eb746d3e88e5e1ead02e351d81efff45eb33c5787ec3fc9f486fb7fd0c387f612b08fff709b80f3464e78f30f437d3f6b94479bc80afb0e80fff71274
2cdb40fb01c1dcbea62d72848061f78979c40cfff30bf369ed2fc1c11a707ff27c4a147631b9f521e90ffff02b483b9fe310361e1bd20bf674ec832ebfffb12f
3d7fbcf39ef2cf0fce79f3e788f78c872390c11780c1fff7a02f8d3bf542e4c584294216cffffae1f97f84ec7674f882dbc5c3ffff2b93ff9a8f7effff30ac48
fffbf9c1f830ffffdbb3edfae8fff7f597f78a0efffb7619f5e1b7abfffbf07e4ffffe769ffffffffffffffff3088bc5793f2fd5ebbcd79fe2fe5edbcf079f7e
2ffc5ef9bcf379f7e2ffc5c5c5c5a7179d5279c5e9b4e2e2e2e2e2effffffff12200000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000ffffff0fff716d2cffb9fff3b2fffffd03390fffffff3058fffffffffff40b
cffffffffffffffffb05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002105a10472038a020a02
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
