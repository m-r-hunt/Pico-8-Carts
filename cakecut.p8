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

function copy_to_screen()
 memcpy(0x6000,0x0000,0x2000)
end

function copy_to_memory()
 memcpy(0x0000,0x6000,0x2000)
end

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
   	add(slices,area)
   end
  end
 end
end

function _update()
 if btn(0) then pang-=pspeed end
 if btn(1) then pang+=pspeed end
 if btn(2) then pang2-=pspeed end
 if btn(3) then pang2+=pspeed end
 if btnp(4) then
  local x=64+40*sin(pang)
  local y=64+40*cos(pang)
  local x2=64+40*sin(pang2)
  local y2=64+40*cos(pang2)
  cls()
  copy_to_screen()
  line(x,y,x2,y2,0)
  calculate_slices()
  copy_to_memory()
 end
end

function _draw()
 cls()
 copy_to_screen()
 for s=1,#slices do
  print(slices[s],0,s*8)
 end	
 local x=64+40*sin(pang)
 local y=64+40*cos(pang)
 pset(x,y,8)
 local x2=64+40*sin(pang2)
 local y2=64+40*cos(pang2)
 pset(x2,y2,9)
end
