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

function aprint(str,x,y)
	for i=1,#str do
		s=sub(str,i,i)
		c=ord(s)
		if c>=ord("a") and c<=ord("z") then
			spr(32+c-ord("a"),x,y)
		elseif s=="." then
			spr(58,x,y)
		elseif c>=ord("0") and c<=ord("9") then
			spr(59+c-ord("0"),x,y)
		elseif s=="_" then
			spr(69,x,y)
		elseif s==" " then
			--do nothing
		else
			assert(false)
		end
		x+=8
	end
end

function vec2(x,y)
	return setmetatable({x=x,y=y},vec2mt)
end

swarm_size=2
swarm={}

system_scale=1
max_vel=1.5
com_factor=200
repulsion_dist=2
repulsion_factor=1
coordination_factor=32
target_factor=100

function intersects_map(pos)
	local tx=(pos.x-4)\8
	local ty=(pos.y-4)\8
	return fget(mget(tx,ty),0) or fget(mget(tx+1,ty),0) or fget(mget(tx,ty+1),0) or fget(mget(tx+1,ty+1),0)
end

function update_player(self)
	local pos=vec2(self.pos.x,self.pos.y)
	if (btn(0)) pos.x-=1
	if (btn(1)) pos.x+=1
	if not intersects_map(pos) then
		self.pos=pos
	end

	pos=vec2(self.pos.x,self.pos.y)
	if (btn(2)) pos.y-=1
	if (btn(3)) pos.y+=1
	if not intersects_map(pos) then
		self.pos=pos
	end

	self.spr+=0.5
	if self.spr>6 then
		self.spr=3
	end
end

function update_honeypot(self)
	if #(self.pos-player.pos)<4 then
		for i=1,4 do
			a=rnd(1.0)
			add(swarm,{pos=vec2(64+sin(a)*64,64+cos(a)*64),vel=vec2(0,0)})
		end
		del(objects,self)
	end
end

function draw_sprite(self)
	spr(self.spr,self.pos.x-4,self.pos.y-4)
end

player={}
objects={}
high_scores={}

function init_swarm()
	swarm={}
	for i=1,swarm_size do
		add(swarm,{pos=vec2(rnd(128),rnd(128)),vel=vec2(0,0)})
	end
end

function draw_swarm()
	for i=1,#swarm do
		local s=swarm[i]
		pset(s.pos.x/system_scale,s.pos.y/system_scale,9)
	end
end

target=system_scale*vec2(64,64)

function update_swarm()
	local target=system_scale*player.pos

	local com=vec2(0,0)
	for j=1,#swarm do
		com+=swarm[j].pos
	end
	com/=#swarm

	local pv=vec2(0,0)
	for j=1,#swarm do
		pv+=swarm[j].vel
	end
	pv/=#swarm

	for i=1,#swarm do
		local s=swarm[i]

		local v1=(com-s.pos)/com_factor

		local c=vec2(0,0)
		for j=1,#swarm do
			if (i!=j) then
				if #(s.pos-swarm[j].pos)<repulsion_dist then
					c-=(swarm[j].pos-s.pos)
				end
			end
		end
		local v2=c/repulsion_factor

		local v3=(pv-s.vel)/coordination_factor

		local v4=(target-s.pos)/target_factor

		s.vel+=v1+v2+v3+v4
		assert(#s.vel>=0)
		if (#s.vel)>max_vel then
			s.vel=max_vel*s.vel/#s.vel
		end
		s.pos+=s.vel
	end
end

function update_gameplay()
	for obj in all(objects) do
		obj:update()
	end
	update_swarm()
	for i=1,#swarm do
		if #(swarm[i].pos-player.pos)<2  then
			player.spr=2
			change_mode("gameover")
		end
	end
end

function draw_gameplay()
	cls(3)
	map(0,0,0,0,16,16,1)
	draw_swarm()
	for obj in all(objects) do
		obj:draw()
	end
end

score_name={ord("_"),ord("_"),ord("_")}
function init_gameover()
	selected=1
end

function update_gameover()
	t+=1

	if btnp(4) or btnp(5) then
		if selected<3 then
			selected+=1
		else
			change_mode("title")
		end
	end

	if btnp(0) then
		selected-=1
	end
	if btnp(1) then
		selected+=1
	end
	if selected<=0 then
		selected=3
	end
	if selected>3 then
		selected=1
	end

	if btnp(2) then
		local c=score_name[selected]-1
		if c<ord(".") then
			c=ord("z")
		elseif c>ord(".") and c<ord("0") then
			c=ord(".")
		elseif c>ord("9") and c<ord("_") then
			c=ord("9")
		elseif c>ord("_") and c<ord("a") then
			c=ord("_")
		end
		score_name[selected]=c
	end
	if btnp(3) then
		local c=score_name[selected]+1
		if c>ord(".") and c<ord("0") then
			c=ord("0")
		elseif c>ord("9") and c<ord("_") then
			c=ord("_")
		elseif c>ord("_") and c<ord("a") then
			c=ord("a")
		elseif c>ord("z") then
			c=ord(".")
		end
		score_name[selected]=c
	end



	update_swarm()
end

function draw_gameover()
	draw_gameplay()
	aprint("game over",64-4.5*8,32,7)
	for i=1,3 do
		aprint(chr(score_name[i]),44+i*8,80)
	end
	if (t \ 20) % 2 == 0 then
		spr(70,44+selected*8,72)
		spr(71,44+selected*8,88)
	end
end

function init_gameplay()
	init_swarm()
	player={pos=vec2(64,64),update=update_player,draw=draw_sprite,spr=3}
	objects={player}
	for y=0,15 do
		for x=0,15 do
			if fget(mget(x,y),2) then
				local honey_pot={pos=vec2(x*8+4,y*8+4),update=update_honeypot,draw=draw_sprite,spr=16}
				add(objects,honey_pot)
			end
		end
	end
end

function init_title()
	t=0
end

function update_title()
	t+=1
	if btnp(4) or btnp(5) then
		change_mode("gameplay")
	end
end

function draw_title()
	cls(3)
	aprint("bear necessities", 0, 20)
	spr(76,64-16,40,4,4)
	if (t \ 20) % 2 == 0 then
		aprint("press start", 20, 80)
	end
end

modes={
	intro={update=update_intro,draw=draw_intro},
	attract={update=update_attract,draw=draw_attract},
	title={init=init_title,update=update_title,draw=draw_title},
	gameplay={init=init_gameplay,update=update_gameplay,draw=draw_gameplay},
	gameover={init=init_gameover,update=update_gameover,draw=draw_gameover},
}
mode=""

function change_mode(m)
	mode=m
	if modes[m].init then
		modes[m].init()
	end
end

function _update()
	modes[mode].update()
end

function _draw()
	modes[mode].draw()
end

function _init()
	cartdata("bear_necessities_maximilian_hunt")
	change_mode("title")
end
