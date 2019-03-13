pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
  cls()
  circfill(64, 64, 30)
  memcpy(0,0x6000,0x2000)
end

pang=0
pang2=0

function _update()
 if btn(0) then pang -= .1 end
 if btn(1) then pang += .1 end
 if btn(2) then pang2 -= .1 end
 if btn(3) then pang2 += .1 end
 if btnp(4) then
  local x=64+40*sin(pang)
  local y=64+40*cos(pang)
  local x2=64+40*sin(pang2)
  local y2=64+40*cos(pang2)
  cls()
  memcpy(0x6000,0,0x2000)
  line(x,y,x2,y2,0)
  memcpy(0,0x6000,0x2000)
 end
end

function _draw()
 cls()
 memcpy(0x6000,0,0x2000)
 local x=64+40*sin(pang)
 local y=64+40*cos(pang)
 pset(x,y,8)
 local x2=64+40*sin(pang2)
 local y2=64+40*cos(pang2)
 pset(x2,y2,9)
end
