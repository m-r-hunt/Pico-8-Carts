pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
function clw(c)
	rectfill(0,0,128,128,c or 7)
end

debug_window={}
function debug_window:init()
	debug_log={}
end
function debug_window:draw()
	rectfill(0,0,100,100,7)
	cursor(1,1,5)
	for i=1,#debug_log do
		print(debug_log[i])
	end
	debug_log={}
end

function log(s)
	add(debug_log,s)
end

blank_window={}
function blank_window.get_dimensions()
	return 50, 60
end
function blank_window:init()
	self.c=11
end
function blank_window:draw()
	rectfill(0,0,100,100,self.c)
end
function blank_window:onclick(x,y)
	self.c+=1
end

calculator={}
function calculator.get_dimensions()
	return 27, 42
end
function calculator:init()
	self.value=0
end
function draw_calc_button(x,y,s)
	rect(x*7,y*9+7,x*7+6,y*9+15,5)
	print(s,x*7+2,y*9+9,5)
end
function calculator:draw()
	clw()
	print(self.value,1,1,5)

	draw_calc_button(0,0,"7")
	draw_calc_button(1,0,"8")
	draw_calc_button(2,0,"9")

	draw_calc_button(0,1,"4")
	draw_calc_button(1,1,"5")
	draw_calc_button(2,1,"6")

	draw_calc_button(0,2,"1")
	draw_calc_button(1,2,"2")
	draw_calc_button(2,2,"3")

	draw_calc_button(0,3,"0")

	draw_calc_button(3,0,"+")
	draw_calc_button(3,1,"-")
	draw_calc_button(3,2,"*")
	draw_calc_button(3,3,"/")
	draw_calc_button(1,3,"C")
	draw_calc_button(2,3,"=")
end

default_width=22
default_height=19
window_left_size=1
window_extra_w=2
window_extra_h=5
close_button_w=4
titlebar_h=4

function create_window(class,x,y)
	local w,h=default_width,default_height
	if class.get_dimensions then
		w,h=class.get_dimensions()
	end
	w=mid(5,w,128)
	h=mid(1,h,120)
	local x=mid(0,x,128-w-window_extra_w)
	local y=mid(0,y,128-h-window_extra_h)
	local newwin={x=x,y=y,w=w,h=h,class=class,data={}}
	add(windows,newwin)
	newwin.class.init(newwin.data)
end

function _init()
	poke(0x5f2d,1)
	windows={}
	create_window(debug_window,10,10)
	create_window(blank_window,50,16)
	create_window(blank_window,60,26)
	create_window(calculator,70,26)
end

function get_mouse_target()
	for i=#windows,1,-1 do
		local w=windows[i]
		local inx=mousex>=w.x and mousex<w.x+w.w+window_extra_w
		local iny=mousey>=w.y and mousey<w.y+w.h+window_extra_h
		if iny and inx then
			return i
		end
	end
	return -1
end

function _update()
	mousex=stat(32)
	mousey=stat(33)
	local new_mousebtns=stat(34)
	local ldown=band(new_mousebtns,1)
	local ldown_last=band(mousebtns,1)
	local lpressed=ldown~=0 and ldown_last==0
	local lreleased=ldown==0 and ldown_last~=0
	mousebtns=new_mousebtns
	
	local mouse_target=get_mouse_target()
	
	if lpressed and mouse_target~=-1 then
		local w=windows[mouse_target]
		del(windows,w)
		add(windows,w)
		
		if mousey-w.y<titlebar_h and mousex-w.x<w.w+window_extra_w-close_button_w then
			dragging=true
			dragx=mousex
			dragy=mousey
			origx=w.x
			origy=w.y
			dragw=#windows
		end
	end
	
	if dragging then
		local w=windows[dragw]
		w.x=mid(0,origx+mousex-dragx,128-w.w-window_extra_w)
		w.y=mid(0,origy+mousey-dragy,128-w.h-window_extra_h-8)
	end
	
	if not dragging and lreleased and mouse_target~=-1 then
		local w=windows[mouse_target]
		local lx=mousex-w.x
		local ly=mousey-w.y
		if lx>=w.w+window_extra_w-close_button_w and ly<titlebar_h then
			--close button
			del(windows,w)
		end
		if w.class.onclick and lx>0 and lx<w.w+window_left_size and ly>=titlebar_h and ly<titlebar_h+w.h then
			w.class.onclick(w.data,lx-window_left_size,ly-titlebar_h)
		end
	end
	
	if lreleased then
		dragging=false
	end
end

function draw_windows()
	for i=1,#windows do
		window=windows[i]
		camera()
		clip()
		
		sspr(48,0,4,4,window.x+window_left_size,window.y,window.w+window_extra_w-close_button_w-1,titlebar_h)
		sspr(52,0,4,4,window.x+window.w-window_extra_w,window.y)
		line(window.x,window.y+1,window.x,window.y+window.h+window_extra_h-2,5)
		line(window.x+1,window.y+window.h+window_extra_h-1,window.x+window.w,window.y+window.h+window_extra_h-1,5)
		line(window.x+window.w+1,window.y+1,window.x+window.w+1,window.y+window.h+window_extra_h-2,5)
		
		clip(window.x+window_left_size,window.y+titlebar_h,window.w,window.h)
		camera(-window.x-window_left_size,-window.y-titlebar_h)
		window.class.draw(window.data)
	end
	camera()
	clip()
end

function draw_os_chrome()
	sspr(16,0,8,8,0,120,128,8)
	spr(1,0,121)
	local h=""..stat(93)
	if (#h==1) h="0"..h
	local m=""..stat(94)
	if (#m==1) m="0"..m
	print(h..":"..m,108,122,5)
end

function draw_mouse()
	spr(3,mousex,mousey)
end

function _draw()
	cls()
	draw_windows()
	draw_os_chrome()
	draw_mouse()
end
__gfx__
000000000005000088888888c5555000055555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000
000000000058500077777777577775005eeeeeeeeeeeeeeeeeee8e85000000000000000000000000000000000000000000000000000000000000000000000000
007007000597f500eeeeeeee567777505eeeeeeeeeeeeeeeeeeee8e5000000000000000000000000000000000000000000000000000000000000000000000000
000770005a777e50eeeeeeee567777505eeeeeeeeeeeeeeeeeee8e85000000000000000000000000000000000000000000000000000000000000000000000000
0007700005b7d500eeeeeeee56677750500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00700700005c5000eeeeeeee05667775500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
0000000000050000eeeeeeee00555675500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000008888888800000550500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000055555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000
