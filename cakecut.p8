pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
  cls()
  circfill(64,64,30,7)
  copy_to_memory()
end

pang=0
pang2=0
pspeed=0.01
slices={}
rad=60
cutn=0

levels={
 {function() circfill(64,64,30,7) end,1,2},
}
leveln=1

function copy_to_screen()
 spr(0,0,0,16,16)
end

function copy_to_memory()
 memcpy(0x0000,0x6000,0x2000)
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
 pal(7,5)
 spr(0,0,10,16,16)
 pal(7,15)
 for y=9,6,-1 do
 spr(0,0,y,16,16)
 end
 pal(7,8)
 spr(0,0,5,16,16)
 pal(7,15)
 for y=4,1,-1 do
 spr(0,0,y,16,16)
 end
 pal()
 spr(0,0,0,16,16)

end

function _draw()
 cls()
 draw_cake()
 local level=levels[leveln]
 print("cut the cake into "..level[3].." slices ",0,0)
 print("using "..level[2].." cuts",0,8)
 for s=1,#slices do
  print(slices[s],0,s*8)
 end	
 local x=64+rad*sin(pang)
 local y=64+rad*cos(pang)
 pset(x,y,8)
 local x2=64+rad*sin(pang2)
 local y2=64+rad*cos(pang2)
 pset(x2,y2,9)
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

