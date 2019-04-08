pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- super cake cutter v1.0
--(c) 2019 max hunt (cc by-sa)
--music credit: autumn wind by gruber (cc4-by-nc-sa)

function _init()
 poke(0x5f34, 1)
 --[[menuitem(5,"toggle debug", function() 
  debug=not debug
  poke(0x5f2d,1-peek(0x5f2d))
 end)--]]
 change_mode("title")
 
 music(10)
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
 if modes[mode] and modes[mode].leave then
  modes[mode].leave()
 end
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
  calculate_slices()
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

function level_init()
 menuitem(1,"quit to menu",function()
  change_mode("title")
 end)
 menuitem(2,"restart",function()
  leveln-=1
  change_mode("level_intro")
 end)
end

function level_leave()
 menuitem(1)
 menuitem(2)
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
  particle_cut_line(x,y,x2,y2)
  copy_to_memory()
  cutn+=1
  calculate_slices()
  local level=levels[leveln]
  if cutn>=level[2] then
   copy_to_memory()
   change_mode("end_transition")
   if #slices==level[3] and slices_equal() then
    end_trans_next="victory"
    sfx(4)
   else
    end_trans_next="failure"
    sfx(5)
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
 print_bolded(#slices.."/"..level[3],12,4)
 spr(27,2,11)
 print_bolded(cutn.."/"..level[2],12,13)
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
 print_bolded("⬆️⬇️⬅️➡️:move cursor",25,110)
 print_bolded("🅾️:cut ❎:swap",37,120)
 
 debug_print_slices()
 if debug then
  -- temp level design mouse
  print("\n"..stat(32)..","..stat(33))
  spr(11,stat(32)-3,stat(33)-3)
 end
end

--debug=true

function debug_print_slices()
 if (not debug) return
 cursor(0,30)
 for s=1,#slices do
  print(slices[s])
 end
 print(stat(0))
 print(stat(1))
 print(stat(2))
end

function draw_result_table()
 color(7)
 for s=1,#slices do
  local y=(s+2)*8
  col=slices[s][4]
  pal(13,col)
  spr(12,10,y)
  local desc=slices[s][1]
  local percent=flr((slices[s][3]/slice_total)*100)
  if (slices[s][2]>0) desc=desc.."+"..slices[s][2]
  print("slice "..s..".."..desc.."("..percent.."%)",20,y+1)
  pal()
  palt(0,false)
  palt(8,true)
  spr(slices[s][5] and 28 or 29,10,y)
  palt()
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
 print_bolded_centered("you did it",6)
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
 print_bolded_centered("oops. now ken will eat you.",6)
 print_bolded_centered(fail_reason,14)
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
 print_bolded_centered("congratulations",10)
 print_bolded_centered("you cut all the cakes",20)
 print_bolded_centered("❎ or 🅾️ to return to title",120)
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

function text_centered_x(s)
 return 128/2-#s*2
end

function print_bolded_centered(s,y)
 print_bolded(s,text_centered_x(s),y)
end

function title_draw()
 draw_cake()
 print_bolded_centered("super cake cutter",10)
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
 if c==0 or c==7 or c==8 or c==11 or c==13 or c==14 then
  c=(c+1)%16
 end
 return c
end

slices={}

strawb_weight=150

function has_strawb(x,y)
 local strawbs=levels[leveln][5]
 return strawbs.rev[x] and strawbs.rev[x][y]
end

function calculate_slices()
 --[[for x=0,127 do
  for y=0,127 do
   if pget(x,y)~=0 then
    pset(x,y,7)
   end
  end
 end--]]
 local nextc=9
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
 local target=slice_total/#slices
	local allowed_variance=slice_total/20
	local all_ok=true
	for i=1,#slices do
	 if abs(slices[i][3]-target)>allowed_variance then
	  all_ok=false
	  slices[i][5]=false
	 else
	  slices[i][5]=true
	 end
	end
	return all_ok
end

-->8
-- levels

function strawbs(strawbs)
 local rev_strawbs={}
 for s=1,#strawbs do
  if not rev_strawbs[strawbs[s][1]] then
   rev_strawbs[strawbs[s][1]]={}
  end
  rev_strawbs[strawbs[s][1]][strawbs[s][2]]=true
 end
 strawbs.rev=rev_strawbs
 return strawbs
end

l1_strawbs={}
for i=1,5 do
 local ang=i*1/8-1/16
 add(l1_strawbs,{54+23*cos(ang),54+23*sin(ang)})
end
for i=6,8 do
 local ang=i*1/8-1/16
 add(l1_strawbs,{64+23*cos(ang),64+23*sin(ang)})
 l1_strawbs=strawbs(l1_strawbs)
end

levels={
 --title screen "level"
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
 
 --basic levels
 {
  function() circfill(64,64,30,7) end,
  1,
  2,
  {5,15,15,15,15,15,8,15,15,15,15,15},
  strawbs{},
 },
 {
  function() circfill(64,64,30,7) end,
  5,
  5,
  {5,4,4,4,5,5,4,4,4,4},
  strawbs{},
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
  strawbs{},
 },
 {
  function()
   rectfill(54,34,74,94,7)
   rectfill(34,54,94,74,7)
   pset(54,34,0)
   pset(54,94,0)
   pset(74,34,0)
   pset(74,94,0)
   pset(34,54,0)
   pset(94,54,0)
   pset(34,74,0)
   pset(94,74,0)
  end,
  3,
  6,
  {5,8,8,8,8,6,6,6,8,8,8,8},
  strawbs{},
 },
 {
  function()
   local xmin=24
   local xmax=104
   for x=xmin,xmax do
    yoff=10*sin((x-xmin)/(xmax-xmin))
    for y=54,74 do
     pset(x,y+yoff,7)
    end
   end
  end,
  3,
  6,
  {5,9,9,9,9,9,15,15,9,9,9,9,9,9},
  strawbs{},
 },
 
 --strawberry levels
 {
  function() rectfill(32,50,96,70,7) end,
  2,
  3,
  {5,15,15,15,15,15,10,10,15,15,15,15,15,10},
  strawbs{{40,60}},
 },
 {
  function() 
   for y=1,40 do
    local yy=40+y
    for x=-y,y do
     local xx=64+x
     pset(xx,yy,7)
    end
   end
  end,
  3,
  4,
  {5,4,4,4,4,4,4,4,3,11,11},
  strawbs{{64,45},{34,75},{94,75}},
 },
 {
  function() circfill(64,64,30,7) end,
  5,
  5,
  {5,4,4,4,5,5,4,4,4,4},
  strawbs{{64,40},{64,88},{40,64},{88,64}},
 },
 {
  function()
   rectfill(30,30,50,98,7)
   rectfill(50,50,78,78,7)
   rectfill(78,30,98,98,7)
  end,
  2,
  3,
  {5,4,4,4,5,5,4,4,4,4},
  strawbs{{64,64},{40,64},{88,64}},
 },
 {
  function()
   camera(-24,-24)
   line(40,1,51,30,7)
   line(51,30,80,31,7)
   line(79,31,56,50,7)
   line(56,50,65,80,7)
   line(65,79,40,64,7)
   
   line(40,1,29,30,7)
   line(29,30,1,31,7)
   line(1,31,24,50,7)
   line(24,50,15,80,7)
   line(15,79,40,64,7)
   
   camera()
   local q={{64,64}}
   pset(64,64,7)
   while #q>0 do
    local c=q[1]
    del(q,c)
    if pget(c[1]-1,c[2])~=7 then
     pset(c[1]-1,c[2],7)
     add(q,{c[1]-1,c[2]})
    end
    if pget(c[1]+1,c[2])~=7 then
     pset(c[1]+1,c[2],7)
     add(q,{c[1]+1,c[2]})
    end
    if pget(c[1],c[2]-1)~=7 then
     pset(c[1],c[2]-1,7)
     add(q,{c[1],c[2]-1})
    end
    if pget(c[1],c[2]+1)~=7 then
     pset(c[1],c[2]+1,7)
     add(q,{c[1],c[2]+1})
    end
   end
  end,
  1,
  2,
  {5,8,8,9,9,10,10,3,3,12,12,1,1,2,2},
  strawbs{{64,64}}
 },
 
 --end screen "level"
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
  strawbs{{47,50},{82,50}},
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
  init=level_init,
  update=update,
  draw=draw,
  leave=level_leave,
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

function particle_cut_line(x,y,x2,y2)
 local num=10+rnd(10)
 for n=1,num do
  local t=rnd(1)
  local x=x+(x2-x)*t
  local y=y+(y2-y)*t
  add(particles,{x=x,y=y,dx=0,dy=0,c=4})
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
88888888888888888888878888888887778888878888888888888888888888888888888888888888000077000000000488888888808888080000000000000000
88888888888888888888788888888878888888878777788888877888888888888888888888888888007788700000004488888808070880700000000000000000
88888888888888888888788888888778888888878788778887787888777888888888888888888888077788770000044088888070807007080000000000000000
88888888888888888888877777888788888888877888888778887877888788888888888888888888777777770000540080880708880770880000000000000000
88888888888888888888888878888788888888878888888788887878887888787777888888888888ffffffff0005600007007088880770880000000000000000
88888888888888888888888877888788888888778888887888887788887888787888778888888888888888880056000080770888807007080000000000000000
88888888888888888888888877887788888888778888878877778788778887878888878888888888ffffffff0560000088008888070880700000000000000000
88888888888888888888888877888788888888778888887888888788888887788888878888888888555555555600000088888888808888080000000000000000
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
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddd777777777777777eeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeedddddd777777777777777777777eeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
ddddddddddddddddddddddddddddddddddddddddd777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddd77788887777777777777888877777ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddd777788882877777777777888828777777ddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddd77777288888777777777772888887777777dddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddd777777888288287777777778882882877777777dddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddd77777778888888277777777788888882777777777ddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddd7777777728288288777777777282882887777777777dddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddd777777777388888837777777773888888377777777777ddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddd77777777777333333777777777773333337777777777777dddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddd77777777777777777777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddd7777777777777777777777777777777777777777777777777ddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddd777777777777777777777777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddd777777777777777777777777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddd77777777777777777777777777777777777777777777777777777ddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddd7778888777777777777777777777777777777777777777888877777dddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddd7788882877777777777777777777777777777777777778888287777dddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddd7728888877777777777777777777777777777777777772888887777dddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddd778882882877777777777777777777777777777777777888288287777ddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddd778888888277777777777777777777777777777777777888888827777ddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddd772828828877777777777777777777777777777777777282882887777ddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd77738888883777777777777777777777777777777777773888888377777dddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd77773333337777777777777777777777777777777777777333333777777dddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd77777777777777777777777777777777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd77777777777777777777777777777777777777777777777777777777777dddddddddddddddddddddddddddddddddddddddddddd
eeeeeeddddddddddddddddddd77777777777777777777777777777777777777777777777777777777777ddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddd77777777777777777777777777777777777777777777777777777777777ddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddd77777777777777777777777777777777777777777777777777777777777ddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddd77777777777777777777777777777777777777777777777777777777777ddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddd77777777777777777777777777772222222222222222222222222222222ddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddd77777777777777777777777777722222222222222222222222222222222ddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddd77777777777777777777777777221111111111111111111111111111111ddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddd77777888877777777777777772211111111111111111111111111111111ddddddddddeeeeeeeeddddddddddddddddddddddddee
ddddddddddddddddddddddddd7777888828777777777777772211cccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd777728888877777777777772211ccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd77788828828777777777772211cc3333333333333333333333333333333dddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd2778888888277777777772211cc33333333333333333333333333333333dddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd277282882887777777772211cc33aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd17738888883777777772211cc33aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaadddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd1277333333777777772211cc33aa99999999999777777777777777777777777777777dddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddc27777777777777772211cc33aa999999999997777777777777777777777777777777dddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddc1777777777777772211cc33aa9988888888877777777777777777777777777777777dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd3127777777777772211cc33aa99888888888777777777777777777777788887777777dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd3c2277777777772211cc33aa998855555557777777777777777777777888828777777dddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddac127777777772211cc33aa99885dddddd77777777777777777777777288888777777dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddda311277777772211cc33aa99885dddddd777777777777777777777778882882877777dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd93c122777772211cc33aa99885dddddd7777777777777777777777778888888277772dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd9acc1277772211cc33aa99885dddddd77777777777777777777777772828828877772dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd8a3c112772211cc33aa99885dddddd777777777777777777777777773888888377771dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd8933c1222211cc33aa99885dddddd7777777777777777777777777777333333777721dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddd59a3cc12211cc33aa99885dddddd7777777777777777777777777777777777777772cdddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddd8aa3c1111cc33aa99885dddddd77777777777777777777777777777777777777771cdddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddd89a33c11cc33aa99885dddddd7777777777777777777777777777777777777777213dddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddd599a3cccc33aa99885dddddd777777777777777777777777777777777777777722c3dddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddd89aa3cc33aa99885dddddd7777777777777777777777777777777777777777721cadddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddd889a3333aa99885dddddd777778888777777777777788887777777777777772113adddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddd5899a33aa99885dddddd77777888828777777777778888287777777777777221c39dddddddddddddddddddddddddddddddddd
eeeeeedddddddddddddddddddddd589aaaa99885dddddd77777728888877777777777288888777777777777721cca9eeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddd889aa99885dddddd777777888288287777777778882882877777777777211c3a8eeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddd589999885dddddd777777788888882777777777888888827777777777221c3398eeeeeeeeddddddddddddddddddddddddee
eeeeeedddddddddddddddddddddddd5899885edddddd77777772828828877777777728288288777777777221cc3a95eeeeeeeeddddddddddddddddddddddddee
eeeeeedddddddddddddddddddddddde88885eedddddd27777773888888377777777738888883777777772211c3aa8deeeeeeeeddddddddddddddddddddddddee
eeeeeedddddddddddddddddddddddde5885eeedddddd2227777733333377777777777333333777777722211c33a98deeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddee55eeeedddddd122277777777777777777777777777777777722211cc3a995deeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeedddddd11122277777777777777777777777777777222111cc3aa98ddeeeeeeeeddddddddddddddddddddddddee
ddddddddddddddddddddddddddddddddddddddddddddc111222777777777777777777777777777222111cc33a988dddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddccc11122227777777777777777777772222111ccc33a9985dddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddd3ccc111222222777777777777777222222111ccc33aa985ddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddd333ccc11112222222222222222222221111ccc333aa988dddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddda333ccc111111222222222222222111111ccc333aa9985dddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddaaa333cccc111111111111111111111cccc333aaa9985ddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddd9aaa333cccccc111111111111111cccccc333aaa9988dddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddd999aaa3333ccccccccccccccccccccc3333aaa999885dddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddd8999aaa333333ccccccccccccccc333333aaa999885ddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddd888999aaaa333333333333333333333aaaa9998885dddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddd5888999aaaaaa333333333333333aaaaaa9998885ddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddd558889999aaaaaaaaaaaaaaaaaaaaa999988855dddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddd5888999999aaaaaaaaaaaaaaa9999998885dddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddd558888999999999999999999999888855ddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddd58888889999999999999998888885ddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddd555888888888888888888888555dddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddd555888888888888888555ddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddddddddddddddddd555555555555555dddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
eeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddeeeeeeeeddddddddddddddddddddddddee
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd

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
__sfx__
013d00200a6100f611156111c6112c6113161131611236111b6110d6110d6110c6110b6110a621096110861107611096110b6110161106611076110f611186111c61125611256111c61116611126110d61109611
0108080a1307014070180701806018050180401803018020180141801500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010b0809245701d5701c5701c5601c5501c5401c5301c5201c5100050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
011000001c5141c5101c5101c5101c5101c5150000000000000000000000000000000000000000000000000021514215102151021510215102151500000000001f5141f5101f5101f5101f5101f5150000000000
0110000018564000000000000000000000000000000000001a5641c5641d5641f5641856400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000018564000000000000000000000000000000000001d5641c5641a5641b5641856400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01780000269542694026930185351870007525075240752507534000002495424940249301d5241d7000c5250c5242952500000000002b525000001d5241d5250a5440a5450a5440a5201a7341a7350a0350a024
017800000072400735007440075500744007350072400715007340072500000057440575505744057350572405735057440575503744037350372403735037440375503744037350372403735037440373503704
017800000a0041f734219442194224a5424a5224a45265351a5341a5350000026934269421ba541ba501ba550c5340c5450c5540c555000001f9541f9501f955225251f5341f52522a2022a3222a452b7342b725
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
017800000c8410c8410c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c8400c84018841188401884018840188401884018840188402483124830248302483024830248302483024830
01780000269542694026930185351870007525075240752507534000002495424940249301d5241d7000c5250c5242952500000000002b525000001d5241d5250a5440a5450a5440a5201a7341a7350a0350a024
017800000072400735007440075500744007350072400715007340072500000057440575505744057350572405735057440575503744037350372403735037440375503744037350372403735037440373503704
017800000a0041f734219442194224a5424a5224a45265351a5341a5350000026934269421ba541ba501ba550c5340c5450c5540c555000001f9541f9501f955225251f5341f52522a2022a3222a452b7342b725
__music__
02 01024344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
03 0a0b0c0d

