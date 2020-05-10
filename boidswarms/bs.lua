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
	local tx=(pos.x-3)\8+level*16
	local ty=(pos.y-3)\8
	local tx2=(pos.x+3)\8+level*16
	local ty2=(pos.y+3)\8
	return fget(mget(tx,ty),0) or fget(mget(tx2,ty),0) or fget(mget(tx,ty2),0) or fget(mget(tx2,ty2),0)
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
	if abs(self.pos.x - player.pos.x) < 7 and abs(self.pos.y - player.pos.y) < 7 then
		spawn_bees()
		score+=10
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
	t-=1
	if gameplay_state=="spawning" then
		if t<=0 then
			gameplay_state="normal"
		end
	elseif gameplay_state=="dead" then
		if t<=0 then
			gameplay_state="spawning"
			t=45
			player.spr=3
			swarm={}
			spawn_bees()
			if lives<0 then
				change_mode("gameover")
			end
		end
	else
		--normal
		for obj in all(objects) do
			obj:update()
		end
		update_swarm()
		for i=1,#swarm do
			if #(swarm[i].pos-player.pos)<2  then
				player.spr=2
				gameplay_state="dead"
				t=45
				lives-=1
			end
		end
		local potcount=0
		for obj in all(objects) do
			if obj.update==update_honeypot then
				potcount+=1
			end
		end
		if potcount==0 then
			level+=1
			if level>=8 then
				level=0
				difficulty+=1
			end
			score+=100
			score+=#swarm
			gameplay_state="spawning"
			t=45
			load_level()
		end
	end
end

function draw_gameplay()
	cls(3)
	map(level*16,0,0,0,16,16,1)
	draw_swarm()
	for obj in all(objects) do
		obj:draw()
	end
	aprint("score "..tostr(score),2,120)
	if gameplay_state=="spawning" then
		if t>30 then
			aprint("3",60,30)
		elseif t>15 and t<=30 then
			aprint("2",60,30)
		elseif t>0 and t<=15 then
			aprint("1",60,30)
		end
	end
	if gameplay_state=="dead" then
		aprint("ouch...",36,30)
	end
	if gameplay_state=="normal" and t>-30 then
		aprint("go",56,30)
	end
end

score_name={ord("_"),ord("_"),ord("_")}
function init_gameover()
	selected=1
end

function update_gameover()
	t+=1
	update_swarm()

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

	if btnp(4) or btnp(5) then
		if selected<3 then
			selected+=1
		else
			name=chr(score_name[1])..chr(score_name[2])..chr(score_name[3])
			change_mode("attract")
			add_highscore(name,score)
		end
	end
end

function add_highscore(name,score)
	for i=1,#highscores do
		if score>highscores[i][2] then
			local next=highscores[i]
			for j=i,#highscores do
				local temp=highscores[j]
				highscores[j]=next
				next=temp
			end
			highscores[#highscores+1]=next
			highscores[i]={name,score}
			break
		end
	end
	highscores[11]=nil

	--save highscores
	for i=0,9 do
		local s=highscores[i+1]
		dset(i*4,ord(sub(s[1],1,1)))
		dset(i*4+1,ord(sub(s[1],2,2)))
		dset(i*4+2,ord(sub(s[1],3,3)))
		dset(i*4+3,s[2])
	end
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

function spawn_bees()
	for v in all(bee_spawn_points) do
		for i=1,difficulty do
			add(swarm,{pos=vec2(v.x*8+3+i,v.y*8+4),vel=vec2(0,0)})
		end
	end
end

function init_gameplay()
	lives=3
	level=0
	difficulty=1
	score=0
	load_level()
	gameplay_state="spawning"
	t=45
end

function load_level()
	init_swarm()
	player={pos=vec2(64,64),update=update_player,draw=draw_sprite,spr=3}
	objects={player}
	bee_spawn_points={}
	for y=0,15 do
		for x=0,15 do
			local xx=x+level*16
			if fget(mget(xx,y),2) then
				local honey_pot={pos=vec2(x*8+4,y*8+4),update=update_honeypot,draw=draw_sprite,spr=16}
				add(objects,honey_pot)
			end
			if fget(mget(xx,y),1) then
				add(bee_spawn_points,vec2(x,y))
			end
			if fget(mget(xx,y),3) then
				player.pos=vec2(x*8+4,y*8+4)
			end
		end
	end
	spawn_bees()
end

function init_title()
	t=0
end

function update_title()
	t+=1
	if t>30*30 then
		change_mode("attract")
	end
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

function init_attract()
	t=0
end

function update_attract()
	t+=1
	if t>30*30 or btnp(4) or btnp(5) then
		change_mode("title")
	end
end

function draw_attract()
	cls(3)
	aprint("high scores",20,8)
	for i=1,#highscores do
		aprint(highscores[i][1],30,16+i*10)
		aprint(tostr(highscores[i][2]),80,16+i*10)
	end
end

modes={
	intro={update=update_intro,draw=draw_intro},
	attract={init=init_attract,update=update_attract,draw=draw_attract},
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

function load_highscores()
	highscores={}
	for i=0,9 do
		name=chr(dget(i*4))..chr(dget(i*4+1))..chr(dget(i*4+2))
		score=dget(i*4+3)
		add(highscores,{name,score})
	end
end

function _init()
	local loaded=cartdata("bear_necessities_maximilian_hunt")
	if loaded then
		load_highscores()
	else
		highscores={
			{"___",0},
			{"___",0},
			{"___",0},
			{"___",0},
			{"___",0},
			{"___",0},
			{"___",0},
			{"___",0},
			{"___",0},
			{"___",0},
		}
	end
	change_mode("attract")
end
