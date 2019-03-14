pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
  cls()
  levels[leveln][1]()
  copy_to_memory()
  poke(0x5f34, 1)
end

pang=0
pang2=0
pspeed=0.01
rad=60
cutn=0

cakex=24
cakey=24
cakesize=80

levels={
 --{function() circfill(64,64,30,7) end,1,2,{5,15,15,15,15,15,8,15,15,15,15,15}},
 {function() rectfill(0,0,128,128,7) end,4,5,{5,15,15,15,15,15,10,10,15,15,15,15,15,10}},
}
leveln=1

function copy_to_screen(y)
 if (not y) y=0
 spr(0,cakex,cakey+y,cakesize/8,cakesize/8)
end

function copy_to_memory()
 for row=0,63 do
  memcpy(row*64,0x6000+cakey*64+cakex/2+row*64,cakesize/2)
 end
end

function _update()
 if btn(0) then pang-=pspeed end
 if btn(1) then pang+=pspeed end
 if btn(2) then pang2-=pspeed end
 if btn(3) then pang2+=pspeed end
 if btnp(4) then
  local x=64+rad*sin(pang)
  local y=64+rad*cos(pang)
  local x2=64+rad*sin(pang2)
  local y2=64+rad*cos(pang2)
  cls()
  copy_to_screen()
  line(x,y,x2,y2,0)
  copy_to_memory()
  calculate_slices()
  cutn+=1
  local level=levels[leveln]
  if cutn>=level[2] then
   if #slices==level[3] and slices_equal() then
    _draw=victory
   else
    _draw=failure
   end
  end
 end
end

function draw_cake()
 local cake=levels[leveln][4]
 for c=1,#cake do
  pal(7,cake[c])
  copy_to_screen(#cake-c+1)
 end
 pal()
 copy_to_screen(0)

end

function _draw()
 cls()
 draw_cake()
 local level=levels[leveln]
 print("cut the cake into "..level[3].." slices ",0,0)
 print("using "..level[2].." cuts",0,8)
 local x=64+rad*sin(pang)
 local y=64+rad*cos(pang)
 pset(x,y,8)
 local x2=64+rad*sin(pang2)
 local y2=64+rad*cos(pang2)
 pset(x2,y2,9)
 local col=8
 line(x,y,x2,y2,col)
 color(7)
 fillp(0)
end

function victory()
 cls()
 draw_cake()
 print("you did it")
end

function failure()
 cls()
 draw_cake()
 print("oops. now ken will eat you.")
end

-->8
slices={}

function calculate_slices()
 for x=0,127 do
  for y=0,127 do
   if pget(x,y)~=0 then
    pset(x,y,7)
   end
  end
 end
 local nextc=8
 slices={}
 for x=0,127 do
  for y=0,127 do
   if pget(x,y)==7 then
    local area=1
   	local q={{x,y}}
   	pset(x,y,nextc)
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
   	  end
   	 end
   	end
   	nextc+=1
   	if (nextc==0 or next==7) nextc+=1
   	add(slices,area)
   end
  end
 end
end

function slices_equal()
	local total=0
	for i=1,#slices do
	 total+=slices[i]
	end
	local allowed_variance=total/10
	for i=1,#slices do
	 for j=i+1,#slices do
	  if abs(slices[i] - slices[j]) > allowed_variance then
	   return false
	  end
	 end
	end
	return true
end

__gfx__
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888888888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888887788888888888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888887888888888877778888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888878888888887778888878888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888788888888878888888878777788888877888888888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888788888888778888888878788778887787888777888888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888877777888788888888877888888778887877888788888888888888888888000000000000000000000000000000000000000000000000
88888888888888888888888878888788888888878888888788887878887888787777888888888888000000000000000000000000000000000000000000000000
88888888888888888888888877888788888888778888887888887788887888787888778888888888000000000000000000000000000000000000000000000000
88888888888888888888888877887788888888778888878877778788778887878888878888888888000000000000000000000000000000000000000000000000
88888888888888888888888877888788888888778888887888888788888887788888878888888888000000000000000000000000000000000000000000000000
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
88888888888888808888888878888777888888888888888888888888888888888888888888888888000000000000000000000000000000000000000000000000
88888000000000088888888878888887788888888888888788888888888888888888888888888888000000000000000000000000000000000000000000000000
00000888888888888888888878888887788888888888888788888888888888888888888888888888000000000000000000000000000000000000000000000000
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
