pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
cur_frame=0
frame_size=64
frame_line=frame_size/2
frame_total_size=64*64/2


screen_line=128/2
screen_frame_base=0x6000+32*screen_line+32/2

curs_x=32
curs_y=32

max_frames=8

function _init()
 memset(0,0x0,max_frames*frame_total_size)
 save=""
 for i=0,0x5000 do
  save=save.."x"
 end
end

function copy_frame_to_screen()
 for i=0,frame_size-1 do
  memcpy(screen_frame_base+i*screen_line,cur_frame*frame_total_size+i*frame_line,frame_line)
 end
end

function copy_frame_from_screen()
 for i=0,frame_size-1 do
  memcpy(cur_frame*frame_total_size+i*frame_line,screen_frame_base+i*screen_line,frame_line)
 end
end

function _update()
 if (btn(0)) curs_x-=1
 if (btn(1)) curs_x+=1
 if (btn(2)) curs_y-=1
 if (btn(3)) curs_y+=1
 if (btn(4)) click()
end

function click()
 if curs_x>=32 and curs_x<96 and curs_y>=32 and curs_y<96 then
  copy_frame_to_screen()
  circfill(curs_x,curs_y,5,12)
  copy_frame_from_screen()
 end
 
 if curs_x<8 then
  cur_frame=flr(curs_y/8)
 end
 
end

function _draw()
 cls()
 rect(31,31,96,96,7)
 copy_frame_to_screen()
 
 for i=0,max_frames-1 do
  if (i==cur_frame) then col=11 else col=7 end
  rect(0,i*8,8,i*8+8,col)
  print(i+1,2,i*8+2,col)
 end
 
 pset(curs_x,curs_y,15)
 
 print("mem:"..stat(0),0,104,7)
 print("cpu:"..stat(1),0,112,7)
 print(stat(7).."fps",0,120,7)
end
