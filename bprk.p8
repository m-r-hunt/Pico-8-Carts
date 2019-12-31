pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
piece_pool={}

piece_defs={
	{{0,0},spriten=9,previewc=6},
	{{0,0},{1,0},spriten=5,previewc=10},

	{{0,0},{1,0},{2,0},spriten=3,previewc=3},
	{{0,0},{1,0},{1,1},spriten=3,previewc=3},

	{{0,0},{1,0},{1,1},{2,1},spriten=7,previewc=12},
	{{0,0},{1,0},{0,1},{1,1},spriten=7,previewc=12},
	{{0,1},{1,1},{1,0},{2,0},spriten=7,previewc=12},
	{{0,0},{1,0},{2,0},{2,-1},spriten=11,previewc=14},
	{{0,0},{1,0},{2,0},{2,1},spriten=11,previewc=14},
	{{0,0},{1,0},{2,0},{3,0},spriten=11,previewc=14},

	{{0,0},{0,1},{1,1},{1,2},{2,1},spriten=3,previewc=3},
	{{0,0},{0,1},{0,2},{1,2},{1,3},spriten=3,previewc=3},
}

--powerup option defs
shorts={1,2}
mids={3,4}
longs={5,6,7,8,9,10}
regpend=10 --regular piece end
vlongs={11,12}
available_vlongs={11,12}

mode="piece select"
selected_piece=1
px=1
py=1
pr=0
cancel_selected=false
grid={
	{0,0,0,0},
	{0,0,0,0},
	{0,0,0,0},
	{0,0,0,0},
}
grid_powerups={
	{0,0,0,ocean},
	{0,mountain,0,0},
	{0,0,sand,0},
	{0,forest,0,0},
}
gridx=30
gridy=20

choices={}
choicen=1
choice_select=1

function reset_vlongs()
 for i=1,#vlongs do
  available_vlongs[i]=vlongs[i]
 end
end

function rotate(x,y,r)
	if r==0 then
		return x,y
	elseif r==1 then
		return y,-x
	elseif r==2 then
		return -x,-y
	elseif r==3 then
		return -y,x
	end
end

function _init()
	for i=1,regpend do
		piece_pool[i]=1
	end
	for i=regpend+1,#piece_defs do
	 piece_pool[i]=0
	end
	new_board()
end

function _update()
 if mode~="make choices" then
 	for y=1,4 do
  	for x=1,4 do
   	if grid[y][x]~=0 and grid[y][x]<67 then
    	grid[y][x]+=32
   	end
  	end
 	end
 end
	if mode=="piece select" then
		update_piece_select()
	elseif mode=="piece place" then
		update_piece_place()
	elseif mode=="make choices" then
		update_make_choices()
	elseif mode=="select piece to burn" then
	 update_select_burn()
	elseif mode=="delete square" then
	 update_delete_square()
	end
end

function update_piece_select()
	if btnp(2) then
		selected_piece-=1
 	if selected_piece<0 then
  	selected_piece+=#piece_pool+1
  end
	 while selected_piece>9 and piece_pool[selected_piece]==0 do
	  selected_piece-=1
	 end
 elseif btnp(3) then
  selected_piece+=1
  while selected_piece<=#piece_pool and piece_pool[selected_piece]==0 do
   selected_piece+=1
  end
 end
 if selected_piece<0 then
  selected_piece+=#piece_pool+1
 elseif selected_piece>#piece_pool then
  selected_piece-=#piece_pool+1
 end
 
 if btnp(4) then
  if selected_piece==0 then
   mode="select piece to burn"
  elseif piece_pool[selected_piece]>=1 then
  	mode="piece place"
	 	px=1
	 	py=1
	 	pr=0
	 	cancel_selected=false
  else
   --feedback?
  end
 end
end

function update_select_burn()
	if btnp(2) then
		selected_piece-=1
 	if selected_piece<0 then
  	selected_piece+=#piece_pool+1
  end
	 while selected_piece>9 and piece_pool[selected_piece]==0 do
	  selected_piece-=1
	 end
 elseif btnp(3) then
  selected_piece+=1
  while selected_piece<=#piece_pool and piece_pool[selected_piece]==0 do
   selected_piece+=1
  end
 end
 if selected_piece<0 then
  selected_piece+=#piece_pool+1
 elseif selected_piece>#piece_pool then
  selected_piece-=#piece_pool+1
 end
 
 if btnp(4) then
  if selected_piece==0 then
   mode="piece select"
  elseif piece_pool[selected_piece]>=1 then
  	mode="delete square"
	 	px=1
	 	py=1
	 	pr=0
	 	cancel_selected=false
  else
   --feedback?
  end
 end
end

function board_is_full()
 local any_empty=false
 for y=1,4 do
  for x=1,4 do
   any_empty=any_empty or (grid[y][x]==0)
  end
 end
 return not any_empty
end

function rand_swap(t)
 local t1=flr(rnd(#t))+1
 local t2=flr(rnd(#t))+1
 local tmp=t[t1]
 t[t1]=t[t2]
 t[t2]=tmp
end

function new_board()
 for y=1,4 do
  for x=1,4 do
   grid[y][x]=0
   grid_powerups[y][x]=0
  end
 end
 xs={1,2,3,4}
 ys={1,2,3,4}
 powerups={
  shorts,
  mids,
  longs,
  available_vlongs,
 }
 for shufs=1,20 do
  rand_swap(xs)
  rand_swap(ys)
  rand_swap(powerups)
 end
 
 for i=1,4 do
  x=xs[i]
  y=ys[i]
  grid_powerups[y][x]=powerups[i]
 end
 
 x=flr(rnd(4))+1
 y=flr(rnd(4))+1
 while grid_powerups[y][x]~=0 do
 	x=flr(rnd(4))+1
	 y=flr(rnd(4))+1
 end
 grid[y][x]=13
end

function check_stuck()
-- for p=1,#piece_pool do
--  if piece_pool[p]~=0 then
--   local def=piece_defs[p]
--   for y=1,4 do
--    for x=1,4 do
--     for r=0,3 do
--      found_block=false
--      for loc=1,#def do
--       px,py=rotate(x+def[loc][1],y+def[loc][2],r)
--       if py<1 or py>4 or px<1 or px>4 or grid[py][px]~=0 then
--       	found_block=true
--        break
--       end
--      end
--      if not found_block then
--       return false
--      end
--     end
--    end
--   end
--  end
-- end
-- return true
 return false
end

function update_piece_place()
 if not cancel_selected then
	if (btnp(0)) px-=1
	if (btnp(1)) px+=1
	if (btnp(2)) py-=1
	if py==4 and btnp(3) then
	 cancel_selected=true
	elseif btnp(3) then
  py+=1
 end
	px=mid(1,px,4)
	py=mid(1,py,4)
	
	if btnp(5) then
	 pr-=1
	 if pr<0 then
	  pr+=4
	 end
	end
	
	if btnp(4) then
	 can_place=check_placement()
	 if can_place then
	  choices={}
	 	choices=stamp_piece(selected_piece,px,py)
	 	if #choices>0 then
				choicen=1
				choice_select=1
	 		mode="make choices"
	 	else
	 		mode="piece select"
	 	end
	 	selected_piece=1
	 	if board_is_full() then
	 	 new_board()
	 	 add(choices,mids)
	 	 mode="make choices"
				choicen=1
				choice_select=1
	 	end
	 	stuck=check_stuck()
	 	if stuck then
	 	 mode="game over"
	 	end
	 else
	 	--feedback?
	 end
	end
	else
	 if btnp(2) then
	  cancel_selected=false
	 end
	 if btnp(4) then
	  mode="piece select"
	 end
	end
end

function update_delete_square()
	if not cancel_selected then
		if (btnp(0)) px-=1
		if (btnp(1)) px+=1
		if (btnp(2)) py-=1
		if py==4 and btnp(3) then
	 	cancel_selected=true
		elseif btnp(3) then
  	py+=1
 	end
		px=mid(1,px,4)
		py=mid(1,py,4)
		
		if btnp(4) and grid[py][px]~=0 then
		 grid[py][px]=0
		 piece_pool[selected_piece]-=1
		 mode="piece select"
		end
	else
	 if btnp(2) then
	  cancel_selected=false
	 end
	 if btnp(4) then
	  mode="piece select"
	 end
	end
end

function update_make_choices()
 if (btnp(0)) choice_select-=1
 if (btnp(1)) choice_select+=1
 if (choice_select<1) choice_select+=#choices[choicen]
 if (choice_select>#choices[choicen]) choice_select-=#choices[choicen]
 if btnp(4) then
  piece_pool[choices[choicen][choice_select]]+=1
  if choices[choicen]==available_vlongs then
   del(available_vlongs,available_vlongs[choice_select])
   if #available_vlongs==0 then
    reset_vlongs()
   end
  end
  choicen+=1
  if choicen>#choices then
   mode="piece select"
  end
 end
end

function check_placement()
 local any_bad=false
 local i=selected_piece
 for sq=1,#piece_defs[i] do
  rx,ry=rotate(piece_defs[i][sq][1],piece_defs[i][sq][2],pr)
  local x=px+rx
  local y=py+ry
  if x<1 or x>4 or y<1 or y>4 or grid[y][x]~=0 then
   any_bad=true
  end
 end
 return not any_bad
end

function stamp_piece(i,x,y)
 piece_pool[i]-=1
 local choices={}
	for sq=1,#piece_defs[i] do
	 rx,ry=rotate(piece_defs[i][sq][1],piece_defs[i][sq][2],pr)
 	local px=x+rx
 	local py=y+ry
 	if px>=1 and px<=4 and py>=1 and py<=4 then
 		grid[py][px]=piece_defs[i].spriten
	 	if grid_powerups[py][px]~=0 then
	 	 if #grid_powerups[py][px]==1 and grid_powerups[py][px]~=available_vlongs then
	 			piece_pool[grid_powerups[py][px][1]]+=1
	 		else
	 		 add(choices,grid_powerups[py][px])
	 		end
	 	end
 	end
 end
 return choices
end

preview_size=4

function draw_piece_preview(i,xbase,ybase)
 for sq=1,#piece_defs[i] do
	 local px=piece_defs[i][sq][1]
 	local py=piece_defs[i][sq][2]
 	local x=xbase+px*preview_size
 	local y=ybase+py*preview_size
 	rectfill(x,y,x+preview_size,y+preview_size,piece_defs[i].previewc)
 	rect(x,y,x+preview_size,y+preview_size,1)
 end
end

function draw_piece(i,bx,by)
 local transformed={}
 for sq=1,#piece_defs[i] do
  local rx,ry=rotate(piece_defs[i][sq][1],piece_defs[i][sq][2],pr)
  add(transformed, {rx,ry})
 end
 --crappy n^2 sort but it's at most like 6 things
 for i=1,#transformed do
  for j=i,#transformed do
   if transformed[i][2]>transformed[j][2] or (transformed[i][2]==transformed[j][2] and transformed[i][1]>transformed[j][1]) then
   	local tmp=transformed[i]
   	transformed[i]=transformed[j]
   	transformed[j]=tmp
   end
  end
 end
	for sq=1,#transformed do
	 local rx=transformed[sq][1]
	 local ry=transformed[sq][2]
	 col=piece_defs[i].previewc
	 if px+rx<1 or px+rx>4 or py+ry<1 or py+ry>4 or grid[py+ry][px+rx]~=0 then
	  col=8
	 end
 	local x=bx+rx*16
 	local y=by+ry*16
 	rectfill(x+1,y+1,x+17,y+17,0)
 	rectfill(x,y,x+16,y+16,col)
 	rect(x,y,x+16,y+16,1)
 end
end

function _draw()
 cls(15)
 print(mode..selected_piece,2,2,2)
 for i=1,regpend do
  local ybase=10*(i)+4
 	draw_piece_preview(i,5,ybase)
 	print(piece_pool[i],1,ybase)
 	if i==selected_piece and (mode=="piece select" or mode=="select piece to burn") then
 		spr(2,20,ybase)
 	end
 end
 if mode~="select piece to burn" then
  spr(18,4,4)
 else
  print("cancel",4,4)
 end
 if selected_piece==0 then
  spr(2,12,4)
 end
 local ybase=10*(regpend+1)+4
 for i=regpend+1,#piece_pool do
  if piece_pool[i]>0 then
 		draw_piece_preview(i,5,ybase)
 		print(piece_pool[i],1,ybase)
 		if i==selected_piece and mode=="piece select" then
 			spr(2,20,ybase)
 		end
 		ybase+=10
  end
 end
 for y=1,4 do
 	for x=1,4 do
 	 sn=grid[y][x]
 	 if (sn==0) sn=32
 		spr(sn,gridx+x*16,gridy+y*16,2,2)
 		if sn==32 and grid_powerups[y][x]~=0 then
 		 draw_piece_preview(grid_powerups[y][x][1],gridx+x*16+6,gridy+y*16+6)
 		end
 	end
 end
 line(gridx+16,gridy+5*16,gridx+5*16,gridy+5*16,4)
 line(gridx+5*16,gridy+16,gridx+5*16,gridy+5*16,4)
 if mode=="piece place" then
 	draw_piece(selected_piece,gridx+px*16-2,gridy+py*16-2)
 	rect(gridx+px*16,gridy+py*16,gridx+px*16+2,gridy+py*16+2,4)
 	rectfill(48,108,74,115,7)
 	print("cancel",50,110,5)
 	if cancel_selected then
 	 spr(2,74,108)
 	end
 elseif mode=="delete square" then
  spr(18,gridx+px*16,gridy+py*16)
  rectfill(48,108,74,115,7)
 	print("cancel",50,110,5)
 	if cancel_selected then
 	 spr(2,74,108)
 	end
 end
 
 if mode=="make choices" then
 	rect(5,30,128-5,60,12)
 	rectfill(6,31,128-6,59,6)
 	for n=1,#choices[choicen] do
 	 draw_piece_preview(choices[choicen][n],n*32,45)
 	 if n==choice_select then
 	  spr(2,n*32+8,40)
 	 end
 	end
 end
 
 if mode=="game over" then
  print("game over!")
 end
end

-->8
--notes

--allow reflections
--allow removing one tile at cost of a piece

--compute score, larger pieces=more pts

--slow down growth anims

__gfx__
00000000333bb3330002000044444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444400000000
0000000033bbbb3300282000433333333333333349999999999999994ccccccccccccccc46666666666666664556666665555565455555555555555500000000
0070070033bbbb3302882220433333333333333349999999999999994cc7cccccccccccc46666666666666664556555565555565455555555555555500000000
0007700033bbbb332888888243333333333333334999f99999999f994ccccccccccc7ccc46666666666666664556555565555566455555555555555500000000
000770003334433302882220433333333333333349999999999999994ccccccccccccccc4666666666666666455655556555556545555555ddddd55500000000
007007003334433300282000433333333333333349999999999999994ccccccccccccccc46666666666666664556555566666665455555dd1d11d55500000000
000000003344443300020000433333333333333349999999999999994cccccddcccccccc4666666676666766455655556555556545555d1d1d11dd5500000000
0000000033333333000000004333333333333333499999999ff999994ccccccccccccccc4666766677666776466655556555556545555d1d1d111d5500000000
400000004444444406566650433333333333333349999999999999994ccccccccccccccc466676655556677645565555655555654555dd1d1111115500000000
400000000000000065044056433333333343333349999999999999994ccccccccccccccc46677765665577764556555565555565455d1d111d11115500000000
400000000000000050042005433333333333333349999999999999994ccccccccccccccc46677766766775574556666665555565455d1d1d1111155500000000
400000000000000000042000433333333333333349999999999999994ccccccccccccccc46775776776755554556555565555565455d11111111155500000000
400000000000000000042000433333333333333349999999999999994ccccccccddccccc4555555777755555455655556555556645551d111d11555500000000
400000000000000000042000433343333333333349999999ff9999994ccccccccccccccc455666777777655545565555655555654555511d1115555500000000
400000000000000000042000433333333333333349999999999999994ccccccccccccccc45666775557766664666555565555565455555111155555500000000
400000000000000000044000433333333333333349999999999999994ccccccccccccccc46655555555556664556555566666665455555555555555500000000
44444444444444440000000044444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444400000000
42ddddddddddddd200000000433333333333333349999999999999994ccccccccccccccc46666666666666664846666664888465455555555555555500000000
4ddddddddddddddd00000000433333333333333349999999999999994cc77ccccccccccc46666666666666664246488464222465455555555555555500000000
4ddddddddddddddd000000004333333333333333499fff999999fff94cccccccccc77ccc46666666666666664846422469999966455555555555555500000000
4ddddddddddddddd00000000433333333333333349999999999999994ccccccccccccccc4666666676666766424648846999996545555555ddddd55500000000
4ddddddddddddddd00000000433333333333333349999999999999994ccccdcccccccccc46667666776667764946422466666665455555dd1d11d55500000000
4ddddddddddddddd0000000043333333333b333349999999fffff9994cccdddddccccccc4666766555566776494648846488846545555d1d1d11dd5500000000
4ddddddddddddddd000000004333333333b4b333499999ffffffff994ccccccccccccccc4667775566557776466642246422246545555d1d1d111d5500000000
4ddddddddddddddd000000004333333333b4533349999999999999994ccccccccccccccc466777667667755748469999648884654555dd1d1111115500000000
4ddddddddddddddd000000004333333333445333499f9999999999994ccccccccccccccc467777767767755542469999642ee465455d1d111d11115500000000
4ddddddddddddddd00000000433333333333333349999999999999f94ccc7ccccccccccc45555557777556654846666664888465455d1d1d1111155500000000
4ddddddddddddddd000000004333b3333333333349999999999999994ccccccccdddcccc455655777777666642464884642ee465455d11111111155500000000
4ddddddddddddddd00000000433b4b333333333349999fffff9999994ccccccddddddccc4555677555776566494642246488846645551d111d11555500000000
4ddddddddddddddd0000000043344533333333334999fffffff999994ccccccccccccccc466555555555556649464884699999654555511d1115555500000000
4ddddddddddddddd00000000433333333333333349999999999999994c7ccccccccccccc46555555555555564666999969999965455555111155555500000000
42ddddddddddddd200000000433333333333333349999999999999994ccccccccccccccc46555555555556554846999966666665455555555555555500000000
00000000000000000000000044444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444400000000
000000000000000000000000433333333333333349999999999999994ccccccccccccccc46666666666666664e566666652ee265455555555555555500000000
0000000000000000000000004333333333333333499fff999999fff94c777ccccccccccc46666666766667664256eeee65222265455555555555555500000000
0000000000000000000000004333333333bbb33349fffff999ffffff4cccccccccc777cc46667666776667764256222265221266455555555555555500000000
000000000000000000000000433333333bbbbb3349999999999999994ccccccccccccccc466676655556677642562ee26522126545555555ddddd55500000000
00000000000000000000000043333333bbb2bbb349999999fffff9994ccccddddccccccc46677755665577764256222266666665455555dd1d11d55500000000
00000000000000000000000043333333bb22bbb3499999ffffffff994cccddddddcccccc466777667667755742562ee265eeee6545555d1d1d11dd5500000000
00000000000000000000000043333333bb44bb5349999ffffffffff94ccddddddccccccc4677577677675555466622226522226545555d1d1d111d5500000000
000000000000000000000000433bbb335544553349999999999999994ccccccccccc7ccc46555557777555554e562212652222654555dd1d1111115500000000
00000000000000000000000043bbbbb33544533349fff999999999994ccccccccccccccc455555777777655542562212652ee265455d1d111d11115500000000
00000000000000000000000043bb2bb3333333334999999999999fff4cc77cccdddddccc45566775557766654256666665222265455d1d1d1111155500000000
00000000000000000000000043b24b533333333349999ffffff999994cccccdddddddddc45665555555556664256eeee652ee265455d11111111155500000000
00000000000000000000000043544553333333334999ffffffff99994cccddddddddddcc4665555555555566425622226522226645551d111d11555500000000
0000000000000000000000004354453333333333499ffffffffff9994cccccdddddddccc466555555555556642562222652122654555511d1115555500000000
000000000000000000000000433333333333333349999999999999994c77cccccccccccc46555566666655564666212265212265455555111155555500000000
000000000000000000000000433333333333333349999999999999994ccccccccccccccc46556666666666554e56212266666665455555555555555500000000
__label__
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff222f222f222ff22f222ffffff22f222f2fff222ff22f222fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff2f2ff2ff2fff2fff2fffffff2fff2fff2fff2fff2ffff2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff222ff2ff22ff2fff22ffffff222f22ff2fff22ff2ffff2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff2ffff2ff2fff2fff2fffffffff2f2fff2fff2fff2ffff2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff2fff222f222ff22f222fffff22ff222f222f222ff22ff2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f11ff11111fffffffffffff2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff16661ffffffffffff282fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff16661fffffffffff288222fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff16661ffffffffff28888882ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f111f11111fffffffffff288222fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffff282fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffff2ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f11ff111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff1aaa1aaa1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff1aaa1aaa1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff1aaa1aaa1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f111f111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f11ff1111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff1333133313331ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff1333133313331ffffffffffffffffffffffffffff44444444444444444444444444444444444444444444444444444444444444444fffffffffffffffff
ff1ff1333133313331ffffffffffffffffffffffffffff42ddddddddddddd242ddddddddddddd2455555555555555542ddddddddddddd24fffffffffffffffff
f111f1111111111111ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd45555555555555554ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd45555555555555554ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd45555555ddddd5554ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd455555dd1d11d5554ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd45555d1d1d11dd554ddddd1111111111411fffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd45555d1d1d111d554ddddd1333133313431fffffffffffffff
f11ff111111111ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4555dd1d111111554ddddd1333133313431fffffffffffffff
ff1ff133313331ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd455d1d111d1111554ddddd1333133313431fffffffffffffff
ff1ff133313331ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd455d1d1d111115554ddddd1111111111411fffffffffffffff
ff1ff133313331ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd455d1111111115554ddddddddddddddd4fffffffffffffffff
f111f111111111ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd45551d111d1155554ddddddddddddddd4fffffffffffffffff
fffffffff13331ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4555511d111555554ddddddddddddddd4fffffffffffffffff
fffffffff13331ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd45555511115555554ddddddddddddddd4fffffffffffffffff
fffffffff13331ffffffffffffffffffffffffffffffff42ddddddddddddd242ddddddddddddd2455555555555555542ddddddddddddd24fffffffffffffffff
fffffffff11111ffffffffffffffffffffffffffffffff44444444444444444444444444444444444444444444444444444444444444444fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff42ddddddddddddd242ddddddddddddd242ddddddddddddd242ddddddddddddd24fffffffffffffffff
f11ff111111111ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1ccc1ccc1ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1ccc1ccc1ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1ccc1ccc1ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
f111f1111111111111ffffffffffffffffffffffffffff4ddddd11111ddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffffffff1ccc1ccc1ffffffffffffffffffffffffffff4ddddd13331ddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffffffff1ccc1ccc1ffffffffffffffffffffffffffff4ddddd13331ddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffffffff1ccc1ccc1ffffffffffffffffffffffffffff4ddddd13331ddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffffffff111111111ffffffffffffffffffffffffffff4ddddd11111111114ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddd13331333134ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
f11ff111111111ffffffffffffffffffffffffffffffff4ddddd13331333134ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1ccc1ccc1ffffffffffffffffffffffffffffffff4ddddd13331333134ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1ccc1ccc1ffffffffffffffffffffffffffffffff4ddddd11111111114ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1ccc1ccc1ffffffffffffffffffffffffffffffff42dddddddd13331242ddddddddddddd242ddddddddddddd242ddddddddddddd24fffffffffffffffff
f111f111111111ffffffffffffffffffffffffffffffff44444444444444444444444444444444444444444444444444444444444444444fffffffffffffffff
fffff1ccc1ccc1ffffffffffffffffffffffffffffffff42ddddddddddddd242ddddddddddddd242ddddddddddddd242ddddddddddddd24fffffffffffffffff
fffff1ccc1ccc1ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffff1ccc1ccc1ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffff111111111ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
f11ffffff111111111ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddd11111ddddd4ddddddddddddddd4fffffffffffffffff
ff1ffffff1ccc1ccc1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddd16661ddddd4ddddddddddddddd4fffffffffffffffff
ff1ffffff1ccc1ccc1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddd16661ddddd4ddddddddddddddd4fffffffffffffffff
ff1ffffff1ccc1ccc1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddd16661ddddd4ddddddddddddddd4fffffffffffffffff
f111f1111111111111ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddd11111ddddd4ddddddddddddddd4fffffffffffffffff
fffff1ccc1ccc1ffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffff1ccc1ccc11111ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffff1ccc1ccc1eee1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffff111111111eee1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffffffffffff1eee1ffffffffffffffffffffffffffff42ddddddddddddd242ddddddddddddd242ddddddddddddd242ddddddddddddd24fffffffffffffffff
f11ff1111111111111ffffffffffffffffffffffffffff44444444444444444444444444444444444444444444444444444444444444444fffffffffffffffff
ff1ff1eee1eee1eee1ffffffffffffffffffffffffffff42ddddddddddddd242ddddddddddddd242ddddddddddddd242ddddddddddddd24fffffffffffffffff
ff1ff1eee1eee1eee1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1eee1eee1eee1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
f111f1111111111111ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddd111111111d4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddd1ccc1ccc1d4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddd1ccc1ccc1d4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff4ddddddddddddddd4ddddd1ccc1ccc1d4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
f11ff1111111111111ffffffffffffffffffffffffffff4ddddddddddddddd4ddddd11111111114ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1eee1eee1eee1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddd1ccc1c4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1eee1eee1eee1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddd1ccc1c4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
ff1ff1eee1eee1eee1ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddd1ccc1c4ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
f111f1111111111111ffffffffffffffffffffffffffff4ddddddddddddddd4ddddddddd1111114ddddddddddddddd4ddddddddddddddd4fffffffffffffffff
fffffffffffff1eee1ffffffffffffffffffffffffffff42ddddddddddddd242ddddddddddddd242ddddddddddddd242ddddddddddddd24fffffffffffffffff
fffffffffffff1eee1ffffffffffffffffffffffffffff44444444444444444444444444444444444444444444444444444444444444444fffffffffffffffff
fffffffffffff1eee1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffff11111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f11ff11111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff1eee1eee1eee1eee1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff1eee1eee1eee1eee1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ff1ff1eee1eee1eee1eee1ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
f111f11111111111111111ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff

__map__
03040304090a090a100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
13141314191a191a100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07080304090a090a100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
17181314191a191a100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0708070807080506100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1718171817181516100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0506050605060506100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1516151615161516100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
