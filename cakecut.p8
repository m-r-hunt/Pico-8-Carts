pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- todo
-- * particle effects on cut

function _init()
 poke(0x5f34, 1)
 menuitem(1,"toggle debug", function() debug=not debug end)
 change_mode("title")
 
 --temp level design mouse
 poke(0x5f2d,1)
end

function _update()
 update_bg()
 update_particles()
 modes[mode].update()
end

function _draw()
 cls()
 draw_bg()
 modes[mode].draw()
 draw_particles()
end

-- change mode should be reentrant if called from init
-- i may need to rethink this
-- this works as long as init is called last
function change_mode(m)
 mode=m
 if modes[mode].init then
  modes[mode].init()
 end
end

function next_level()
 fail_reason=nil
 cutn=0
	leveln+=1
	if leveln>=#levels then
	 change_mode("final")
	else
  cls()
  levels[leveln][1]()
  copy_to_memory()
 end
end

ps={{32,32},{96,96}}
pselected=1
pspeed=1
rad=60
cutn=0

cakex=24
cakey=24
cakesize=80

bg={0,0}
bgdx={2,1}

function copy_to_screen(y)
 if (not y) y=0
 spr(0,cakex,cakey+y,cakesize/8,cakesize/8)
end

function copy_to_memory()
 for row=0,cakesize-1 do
  memcpy(row*64,0x6000+cakey*64+cakex/2+row*64,cakesize/2)
 end
end

function click_for_next()
	if btnp(4) or btnp(5) then
	 if (fail_reason) leveln-=1
	 change_mode("level_intro")
	end
end

function update_bg()
 bg[1]+=bgdx[1]
 bg[2]+=bgdx[2]
 bg[1]=bg[1]%128
 bg[2]=bg[2]%128
end

function update()
 local p=ps[pselected]
 if (btn(0)) p[1]-=pspeed
 if (btn(1)) p[1]+=pspeed
 if (btn(2)) p[2]-=pspeed
 if (btn(3)) p[2]+=pspeed
 if btnp(5) then
  pselected=(pselected%#ps)+1
 end
 if btnp(4) then
  local x=ps[1][1]
  local y=ps[1][2]
  local x2=ps[2][1]
  local y2=ps[2][2]
  cls()
  copy_to_screen()
  line(x,y,x2,y2,0)
  copy_to_memory()
  cutn+=1
  local level=levels[leveln]
  if cutn>=level[2] then
   calculate_slices()
   copy_to_memory()
   change_mode("end_transition")
   if #slices==level[3] and slices_equal() then
    end_trans_next="victory"
   else
    end_trans_next="failure"
    if #slices==level[3] then
     fail_reason="slices weren't even enough!"
    else
     fail_reason="wrong number of slices"
    end
   end
  end
 end
end

function draw_cake()
 local cake=levels[leveln][4]
 for c=1,#cake do
  for col=1,15 do
   pal(col,cake[c])
  end
  copy_to_screen(#cake-c+1)
 end
 for col=1,15 do
  pal(col,7)
 end
 copy_to_screen(0)
 pal()
 local strawbs=levels[leveln][5]
 for s=1,#strawbs do
  if not debug then
 		spr(14,strawbs[s][1]-4,strawbs[s][2]-4)
 	else
 	 pset(strawbs[s][1],strawbs[s][2],8)
 	end
 end
end

function draw_bg()
 map(0,0,bg[1]-128,bg[2]-128,32,32)
end

function draw()
 color(7)
 draw_cake()
 local level=levels[leveln]
 spr(26,2,2)
 print(#slices.."/"..level[3],11,4)
 spr(27,2,11)
 print(cutn.."/"..level[2],11,13)
 local x=ps[pselected][1]
 local y=ps[pselected][2]
 local x2=ps[pselected%#ps+1][1]
 local y2=ps[pselected%#ps+1][2]
 line(x,y,x2,y2,6)
 spr(11,x-3,y-3)
 spr(10,x2-2,y2-2)
 local col=8
 color(7)
 fillp(0)
 debug_print_slices()
 -- temp level design mouse
 print("\n"..stat(32)..","..stat(33))
 spr(11,stat(32)-3,stat(33)-3)
end

--debug=true

function debug_print_slices()
 if (not debug) return
 cursor(0,30)
 for s=1,#slices do
  print(slices[s])
 end
end

function draw_result_table()
 color(7)
 for s=1,#slices do
  local y=(s+2)*8
  col=slices[s][4]
  pal(13,col)
  spr(12,0,y)
  local desc=slices[s][1]
  local percent=flr((slices[s][3]/slice_total)*100)
  if (slices[s][2]>0) desc=desc.."+"..slices[s][2]
  print("slice "..s..".."..desc.."("..percent.."%)",8,y)
 end
 pal()
end

function victory()
 copy_to_screen(23)
 local strawbs=levels[leveln][5]
 for s=1,#strawbs do
  pset(strawbs[s][1],strawbs[s][2]+23,3)
 end
 color(7)
 cursor()
 print("you did it")
 draw_result_table()
 debug_print_slices()
end

function failure()
 copy_to_screen(23)
 local strawbs=levels[leveln][5]
 for s=1,#strawbs do
  pset(strawbs[s][1],strawbs[s][2]+23,3)
 end
 color(7)
 print("oops. now ken will eat you.")
 print(fail_reason)
 draw_result_table()
 debug_print_slices()
end

function final_init()
 leveln=#levels
 cls()
 levels[leveln][1]()
 copy_to_memory()
 final_timer=31
end

function final_update()
 final_timer+=1
 if final_timer>30 then
  particle_burst(30,10)
  particle_burst(98,10)
  final_timer=0
 end
 if btnp(4) or btnp(5) then
  change_mode("title")
 end
end

function final_draw()
 draw_cake()
 print_bolded("congratulations",35,10)
 print_bolded("you cut all the cakes",25,20)
 print_bolded("❎ or 🅾️ to return to title",10,120)
end

end_trans_timer=0
end_trans_next=nil

function end_transition_init()
 end_trans_timer=0
end

function end_transition_update()
 end_trans_timer+=1
 if end_trans_timer>=60 or btnp(4) or btnp(5) then
  change_mode(end_trans_next)
 end
end

function end_transition_draw()
 color(7)
 if end_trans_timer<=15 then
  draw_cake()
 elseif end_trans_timer<=30 then
  copy_to_screen()
  local strawbs=levels[leveln][5]
  for s=1,#strawbs do
   pset(strawbs[s][1],strawbs[s][2],3)
  end
 else
  local prop=(end_trans_timer-30)/30
  local y=23*prop
  copy_to_screen(y)
  local strawbs=levels[leveln][5]
  for s=1,#strawbs do
   pset(strawbs[s][1],strawbs[s][2]+y,3)
  end
 end
end

function title_init()
 leveln=0
 next_level()
end

function print_bolded(s,x,y)
 print(s,x-1,y,0)
 print(s,x+1,y,0)
 print(s,x,y-1,0)
 print(s,x,y+1,0)
 print(s,x,y,7)
end

function title_draw()
 draw_cake()
 print_bolded("super cake cutter",30,10)
 print_bolded("press ❎ or 🅾️ to start",20,115)
end

function title_update()
 if btnp(4) or btnp(5) then
  change_mode("level_intro")
 end
end

level_intro_timer=0

function level_intro_init()
 next_level()
 level_intro_timer=0
end

function level_intro_update()
 level_intro_timer+=1
 if level_intro_timer>=150 or btnp(4) or btnp(5) then
  change_mode("level")
 end
end

function level_intro_draw()
 draw_cake()
 rectfill(0,50,level_intro_timer*3,78,12)
 local x=max(128-level_intro_timer*2,15)
 print_bolded("level "..leveln-1,x+35,55)
 local level=levels[leveln]
 print_bolded("divide into "..level[3].." with "..level[2].." cuts",x,70)
end

-->8
-- slice stuff

function next_colour(c)
 c=(c+1)%16
 if c==0 or c==7 or c==13 or c==14 then
  c=(c+1)%16
 end
 return c
end

slices={}

strawb_weight=150

function has_strawb(x,y)
 return rev_strawbs[x] and rev_strawbs[x][y]
end

function calculate_slices()
 --[[for x=0,127 do
  for y=0,127 do
   if pget(x,y)~=0 then
    pset(x,y,7)
   end
  end
 end--]]
 rev_strawbs={}
 local strawbs=levels[leveln][5]
 for s=1,#strawbs do
  if not rev_strawbs[strawbs[s][1]] then
   rev_strawbs[strawbs[s][1]]={}
  end
  rev_strawbs[strawbs[s][1]][strawbs[s][2]]=true
 end
 local nextc=8
 slices={}
 for x=cakex,cakex+cakesize do
  for y=cakey,cakey+cakesize do
   if pget(x,y)==7 then
    local area=1
    local strawbs=0
   	local q={{x,y}}
   	pset(x,y,nextc)
   	if (has_strawb(x,y)) strawbs+=1
   	while #q>0 do
   	 local c=q[1]
   	 del(q,c)
   	 local neigh={{-1,0},{1,0},{0,-1},{0,1}}
   	 for n=1,#neigh do
   	  local nn=neigh[n]
   	  local cc={c[1]+nn[1],c[2]+nn[2]}
   	  if pget(cc[1],cc[2])==7 then
   	   pset(cc[1],cc[2],nextc)
   	   add(q,cc)
   	   area+=1
   				if (has_strawb(cc[1],cc[2])) strawbs+=1
   	  end
   	 end
   	end
   	add(slices,{area,strawbs,area+strawbs*strawb_weight,nextc})
   	nextc=next_colour(nextc)
   end
  end
 end
 local to_rem={}
 for s=1,#slices do
  if slices[s][1]<=10 then
   add(to_rem,slices[s])
  end
 end
 for r=1,#to_rem do
  del(slices,to_rem[r])
 end
 
 slice_total=0
 for s=1,#slices do
  slice_total+=slices[s][3]
 end
 
end

function slices_equal()
	local allowed_variance=slice_total/10
	for i=1,#slices do
	 for j=i+1,#slices do
	  if abs(slices[i][3] - slices[j][3]) > allowed_variance then
	   return false
	  end
	 end
	end
	return true
end

-->8
-- levels

leveln=0

l1_strawbs={}
for i=1,5 do
 local ang=i*1/8-1/16
 add(l1_strawbs,{54+23*cos(ang),54+23*sin(ang)})
end
for i=6,8 do
 local ang=i*1/8-1/16
 add(l1_strawbs,{64+23*cos(ang),64+23*sin(ang)})
end

levels={
 {
  function() 
   for x=cakex,cakex+cakesize do
    for y=cakey,cakey+cakesize do
     if abs(x-54)^2+abs(y-54)^2<30^2 and atan2(x-54,y-54)<0.625 then
      pset(x,y,7)
     end
     
     if abs(x-64)^2+abs(y-64)^2<30^2 and atan2(x-65,y-64)>=0.625 then
      pset(x,y,7)
     end
    end
   end
  end,
  1,
  2,
  {5,8,8,9,9,10,10,3,3,12,12,1,1,2,2},
  l1_strawbs,
 },
 {
  function() circfill(64,64,30,7) end,
  1,
  2,
  {5,15,15,15,15,15,8,15,15,15,15,15},
  {},
 },
 {
  function()
   circfill(50,64,20,7)
   circfill(78,64,20,7)
   rectfill(50,44,78,84,7)
  end,
  2,
  3,
  {5,15,15,15,14,14,14,4,4,4},
  {},
 },
 {
  function() rectfill(32,50,96,70,7) end,
  2,
  3,
  {5,15,15,15,15,15,10,10,15,15,15,15,15,10},
  {{40,60}},
 },
 {
  function()
   circfill(64,74,30,7)
   circfill(64,74,20,0)
   rectfill(34,44,94,74,0)
   circfill(47,50,10,7)
   circfill(82,50,10,7)
  end,
  0,
  0,
  {1,1,1,1,3,3,3,3,11,11,11,11},
  {{47,50},{82,50}},
 },
}

-->8
-- mode definitions

modes={
 title={
  init=title_init,
  update=title_update,
  draw=title_draw,
 },
 level_intro={
  init=level_intro_init,
  update=level_intro_update,
  draw=level_intro_draw,
 },
 level={
  update=update,
  draw=draw
 },
 victory={
  update=click_for_next,
  draw=victory
 },
 failure={
  update=click_for_next,
  draw=failure
 },
 end_transition={
  init=end_transition_init,
  update=end_transition_update,
  draw=end_transition_draw
 },
 final={
  init=final_init,
  update=final_update,
  draw=final_draw
 },
}

-->8
-- particles

particles={}

gravity=0.5

function update_particles()
 local rem={}
 for p=1,#particles do
  local p=particles[p]
  p.dy+=gravity
  p.x+=p.dx
  p.y+=p.dy
  if p.x<0 or p.x>128 or p.y>128 then
   add(rem,p)
  end
 end
 for r=1,#rem do
  del(particles,rem[r])
 end
end

function draw_particles()
 for p=1,#particles do
  local p=particles[p]
  pset(p.x,p.y,p.c)
 end
end

function particle_burst(x,y)
 local num=10+rnd(40)
 for n=1,num do
  add(particles,{x=x,y=y,dx=rnd(2)-1,dy=rnd(6)-6,c=6+rnd(7)})
 end
end

__gfx__
888888888888888888888888888888888888888888888888888888888888888888888888888888880010000000080000ddddddddeeeeeeee0088880000000000
888888888888888888888888888888888888888888888888888888888888888888888888888888880010000000888000ddddddddeeeeeeee0888828000000000
888888888888888888888888888888888888888888888888888888888888888888888888888888881101100008080800ddddddddeeeeeeee0288888000000000
888888888888888888888888888888888888888888888888888888888888888888888888888888880010000088808880ddddddddeeeeeeee8882882800000000
888888888888888888888888888888888888888888888888888888888888888888888888888888880010000008080800ddddddddeeeeeeee8888888200000000
888888888888888888888888888888888888888888888888888888888888888888888888888888880000000000888000ddddddddeeeeeeee2828828800000000
888888888888888888888877888888888888888888888888888888888888888888888888888888880000000000080000ddddddddeeeeeeee3888888300000000
888888888888888888888878888888888777788888888888888888888888888888888888888888880000000000000000ddddddddeeeeeeee0333333000000000
88888888888888888888878888888887778888878888888888888888888888888888888888888888000077000000000400000000000000000000000000000000
88888888888888888888788888888878888888878777788888877888888888888888888888888888007788700000004400000000000000000000000000000000
88888888888888888888788888888778888888878788778887787888777888888888888888888888077788770000044000000000000000000000000000000000
88888888888888888888877777888788888888877888888778887877888788888888888888888888777777770000540000000000000000000000000000000000
88888888888888888888888878888788888888878888888788887878887888787777888888888888ffffffff0005600000000000000000000000000000000000
88888888888888888888888877888788888888778888887888887788887888787888778888888888888888880056000000000000000000000000000000000000
88888888888888888888888877887788888888778888878877778788778887878888878888888888ffffffff0560000000000000000000000000000000000000
88888888888888888888888877888788888888778888887888888788888887788888878888888888555555555600000000000000000000000000000000000000
88888888888888888888888877888778888788788888887888888878888887788888877888888888000000000000000000000000000000000000000000000000
88888888888888888888788878888878877788788888888788888887888887888888887888888888000000000000000000000000000000000000000000000000
88888888888888888887887788888887788888788888888878788888777788888888887888888888000000000000000000000000000000000000000000000000
88888888888888888888778888888888888888888888888887888888888888888888887888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888887888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888887777888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878888777888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878888887788888888888888788888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878888887788888888888888788888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878888878888888888888888788888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878888788888888888888887888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878877888888888888888887888887888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888877778888888888888788887888887888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878887888888888888788877788878888888887788888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878888778888788888788878888878888887778878888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878887788887788888788878888878877778888878888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878778888888788887888878888777788878888778888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888777888888888788887888878887878888788777888888777788888888000000000000000000000000000000000000000000000000
88888888888888888888888788888888888878878888878888878888788888888887888877888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888887778888878888878888788888888778888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888878888887888788888888788888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888878888887888877788888788888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888878888887888888878888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888878888887888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888878887778888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888887788888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888778888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
__map__
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c0c0d0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
