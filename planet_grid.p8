pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--planet grid v1.0
--(c) 2020 max hunt (cc by-sa)

ibase=192
isfx=0
function intro()
	pal(14,0)
	local i=0
	sfx(isfx)
	while(btn()==0)do
		cls()
		spr(ibase+0,52,40,2,2)
		spr(ibase+18,68,48,1,1,false,i>10)
		spr(ibase+32,54,57,3,2)
		if(i>10)spr(ibase+2,60,40)
		flip()
		i+=1
		if(i>90)break
	end
	flip()
	pal()
end
--intro()

menu_options={
	{display="start",mode="piece select"},
	{display="instructions",mode="instructions"},
}
menu_select=1

piece_pool={}

piece_defs={
	{{0,0},spriten=9,previewc=6},
	{{0,0},{1,0},spriten=5,previewc=10},

	{{0,0},{1,0},{2,0},spriten=3,previewc=3},
	{{0,0},{1,0},{1,1},spriten=3,previewc=3},

	{{0,0},{1,0},{0,1},{1,1},spriten=7,previewc=12},
	{{0,0},{1,0},{1,1},{2,1},spriten=7,previewc=12},
	{{0,0},{1,0},{2,0},{2,1},spriten=7,previewc=12},
	{{0,0},{1,0},{2,0},{3,0},spriten=7,previewc=12},

	{{0,0},{1,0},{0,1},{1,1},{2,0},spriten=11,previewc=14},
	{{0,0},{0,1},{1,1},{1,2},{2,1},spriten=11,previewc=14},
	{{0,0},{1,0},{2,0},{2,1},{3,1},spriten=11,previewc=14},
	{{0,0},{1,0},{2,0},{3,0},{3,1},spriten=11,previewc=14},
	{{0,0},{0,1},{0,2},{1,1},{2,1},spriten=11,previewc=14},
	{{0,0},{0,1},{1,1},{2,1},{2,0},spriten=11,previewc=14},
	{{0,0},{1,0},{2,0},{2,1},{2,2},spriten=11,previewc=14},
	{{0,0},{1,0},{1,1},{2,1},{2,2},spriten=11,previewc=14},
	{{0,0},{1,0},{1,1},{2,0},{3,0},spriten=11,previewc=14},
	{{0,0},{0,1},{1,1},{2,1},{2,2},spriten=11,previewc=14},
}

--powerup option defs
shorts={1,2}
mids={3,4}
longs={5,6,7,8}
regpend=8 --regular piece end
vlongs={9,10,11,12,13,14,15,16,17,18}
available_vlongs={}

mode="main menu"
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
	{0,0,0,0},
	{0,0,0,0},
	{0,0,0,0},
	{0,0,0,0},
}
gridx=30
gridy=-10

choices={}
choicen=1
choice_select=1

play_modes={
	"piece select",
	"piece place",
	"make choices",
	"select piece to burn",
	"delete square",
	"game over",
}

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
	elseif r==4 then
		return x,-y
	elseif r==5 then
		return y,x
	elseif r==6 then
		return -x,y
	elseif r==7 then
		return -y,-x
	end
end

function _init()
end

function new_game()
	for i=1,regpend do
		piece_pool[i]=0
	end
	for i=regpend+1,#piece_defs do
		piece_pool[i]=0
	end
	piece_pool[1]=1
	piece_pool[2]=1
	piece_pool[3]=1
	piece_pool[4]=1
	reset_vlongs()
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
	if mode=="main menu" then
		update_main_menu()
	elseif mode=="instructions" then
		update_instructions()
	elseif mode=="piece select" then
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

function update_main_menu()
	if (btnp(2)) menu_select-=1
	if (btnp(3)) menu_select+=1
	if (menu_select<1) menu_select+=#menu_options
	if (menu_select>#menu_options) menu_select-=#menu_options

	if btnp(4) then
	 new_game()
		mode=menu_options[menu_select].mode
	end
end

function update_instructions()
	if btnp(4) or btnp(5) then
		mode="main menu"
	end
end

function update_piece_select()
	if btnp(2) then
		selected_piece-=1
		if selected_piece<0 then
			selected_piece+=#piece_pool+1
		end
		while selected_piece>regpend and piece_pool[selected_piece]==0 do
			selected_piece-=1
		end
	elseif btnp(3) then
		selected_piece+=1
		while selected_piece<=#piece_pool and selected_piece>regpend and piece_pool[selected_piece]==0 do
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
		while selected_piece>regpend and piece_pool[selected_piece]==0 do
			selected_piece-=1
		end
	elseif btnp(3) then
		selected_piece+=1
		while selected_piece<=#piece_pool and selected_piece>regpend and piece_pool[selected_piece]==0 do
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
	for i=1,#piece_pool do
		if piece_pool[i]>0 then
			return false
		end
	end
	return true
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
			pr+=1
			if pr>=8 then
				pr-=8
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
					piece_pool[1]+=1
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
		
		if btnp(4) and grid[py][px]~=0 and grid[py][px]~=77 then
			grid[py][px]=0
			piece_pool[selected_piece]-=1
			mode="piece select"
			stuck=check_stuck()
			if stuck then
				mode="game over"
			end
		end
	else
		if btnp(2) then
			cancel_selected=false
		end
		if btnp(4) then
			mode="select piece to burn"
		end
	end
end

function update_make_choices()
	if (btnp(0)) choice_select-=1
	if (btnp(1)) choice_select+=1
	if (btnp(2)) choice_select-=5
	if (btnp(3)) choice_select+=5
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

choicebox={x=25,y=75,maxx=128-5,maxy=126}

function draw_choice_box()
	rect(choicebox.x,choicebox.y,choicebox.maxx,choicebox.maxy,12)
	rectfill(choicebox.x+1,choicebox.y+1,choicebox.maxx-1,choicebox.maxy-1,6)
	--have at most 5 in a row, then break to a second line.
	--only needed for the vlongs
	local maxi=#choices[choicen]
	local div=2
	if maxi>5 then
		maxi=5
		div=3
	end
	increment=(choicebox.maxx-choicebox.x)/maxi
	for n=1,maxi do
		local x=choicebox.x+increment/2+(n-1)*increment-5
		local y=choicebox.y+(choicebox.maxy-choicebox.y)/div
		draw_piece_preview(choices[choicen][n],x,y)
		if n==choice_select then
			spr(2,x+8,y-5)
		end
	end
	if maxi<#choices[choicen] then
		increment=(choicebox.maxx-choicebox.x)/(#choices[choicen]-maxi)
		for n=1,#choices[choicen]-maxi do
			local x=choicebox.x+increment/2+(n-1)*increment-5
			local y=choicebox.y+2*(choicebox.maxy-choicebox.y)/3
			draw_piece_preview(choices[choicen][maxi+n],x,y)
			if n+maxi==choice_select then
				spr(2,x+8,y-5)
			end
		end
	end
	local str="choose a new piece"
	local sx=12
	if #choices>1 then
		str=str.."("..choicen.."/"..#choices..")"
		sx=4
	end
	print(str,choicebox.x+sx,choicebox.y+4)
end

function _draw()
	for m=1,#play_modes do
		if play_modes[m]==mode then
			draw_play_mode()
			return
		end
	end
	if mode=="main menu" then
		draw_main_menu()
	elseif mode=="instructions" then
		draw_instructions()
	end
end

function draw_main_menu()
	cls(15)
	spr(99,32,10,8,8)
	textxbase=40
	textybase=80
	for m=1,#menu_options do
		print(menu_options[m].display,textxbase-1,textybase+m*10,4)
		print(menu_options[m].display,textxbase+1,textybase+m*10,4)
		print(menu_options[m].display,textxbase,textybase-1+m*10,4)
		print(menu_options[m].display,textxbase,textybase+1+m*10,4)

		print(menu_options[m].display,textxbase,textybase+m*10,9)
		if m==menu_select then
			spr(34,textxbase-10,textybase-1+m*10)
		end
	end
end

function draw_instructions()
	cls(15)
	for i=1,#instrs do
	 print(instrs[i],2,(i-1)*6+2,1)
	end
	print("🅾️ or ❎ to return to menu",2,120,1)
end

function draw_help_text()
	str=""
	if mode=="piece select" then
		str="choose a piece or delete"
	elseif mode=="piece place" then
		str="place piece or cancel"
	elseif mode=="select piece to burn" then
		str="select piece to sacrifice\nor cancel"
	elseif mode=="delete square" then
		str="select square to delete\nor cancel"
	end
	print(str,choicebox.x,choicebox.y+4,1)
end

function draw_play_mode()
	cls(15)

	--debug
	--print(mode..pr,2,2,2)

	--draw piece pool
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
			if i==selected_piece and (mode=="piece select" or mode=="select piece to burn") then
				spr(2,20,ybase)
			end
			ybase+=10
		end
	end

	--draw main grid
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

	--draw cursors for placing piece/deleting square
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
		draw_choice_box()
	end

	if mode=="game over" then
		print("game over!")
	end

	draw_help_text()
end

-->8
--notes

--compute score, larger pieces=more pts

--slow down growth anims

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

-->8
instrs={
	"in planet grid, your goal is",
	"to keep building planets by",
	"filling up their grids.",
	"each turn, select a piece and",
	"then place it on the grid.",
	"any extra piece icons you",
	"cover will give you more",
	"pieces to use in subsequent",
	"turns.",
	"if you're stuck, select the",
	"hammer to delete a single tile",
	"at the cost of one piece. the",
	"starting holes cannot be deleted",
	"filling up a grid awards you",
	"a bonus piece and a new grid.",
	"go for a high score!",
}
__gfx__
00000000333bb3330002000044444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444400000000
0000000033bbbb3300282000433333333333333349999999999999994ccccccccccccccc46666666666666664556666665555565455555555555555500000000
0070070033bbbb3302882220433333333333333349999999999999994cc7cccccccccccc46666666666666664556555565555565455555555555555500000000
0007700033bbbb332888888243333333333333334999f99999999f994ccccccccccc7ccc46666666666666664556555565555566455555555555555500000000
000770003334433302882220433333333333333349999999999999994ccccccccccccccc4666666666666666455655556555556545555555ddddd55500000000
007007003334433300282000433333333333333349999999999999994ccccccccccccccc46666666666666664556555566666665455555dd1d11d55500000000
000000003344443300020000433333333333333349999999999999994cccccddcccccccc4666666676666766455655556555556545555d1d1d11dd5500000000
0000000033333333000000004333333333333333499999999ff999994ccccccccccccccc4666766677666776466655556555556545555d1d1d111d5500000000
400000004444444400111110433333333333333349999999999999994ccccccccccccccc466676655556677645565555655555654555dd1d1111115500000000
400000000000000001666661433333333343333349999999999999994ccccccccccccccc46677765665577764556555565555565455d1d111d11115500000000
400000000000000001644561433333333333333349999999999999994ccccccccccccccc46677766766775574556666665555565455d1d1d1111155500000000
400000000000000000144151433333333333333349999999999999994ccccccccccccccc46775776776755554556555565555565455d11111111155500000000
400000000000000000144110433333333333333349999999999999994ccccccccddccccc4555555777755555455655556555556645551d111d11555500000000
400000000000000000144100433343333333333349999999ff9999994ccccccccccccccc455666777777655545565555655555654555511d1115555500000000
400000000000000000144100433333333333333349999999999999994ccccccccccccccc45666775557766664666555565555565455555111155555500000000
400000000000000000011000433333333333333349999999999999994ccccccccccccccc46655555555556664556555566666665455555555555555500000000
44444444444444440000200044444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444400000000
42ddddddddddddd200028200433333333333333349999999999999994ccccccccccccccc46666666666666664846666664888465455555555555555500000000
4ddddddddddddddd02228820433333333333333349999999999999994cc77ccccccccccc46666666666666664246488464222465455555555555555500000000
4ddddddddddddddd288888824333333333333333499fff999999fff94cccccccccc77ccc46666666666666664846422469999966455555555555555500000000
4ddddddddddddddd02228820433333333333333349999999999999994ccccccccccccccc4666666676666766424648846999996545555555ddddd55500000000
4ddddddddddddddd00028200433333333333333349999999999999994ccccdcccccccccc46667666776667764946422466666665455555dd1d11d55500000000
4ddddddddddddddd0000200043333333333b333349999999fffff9994cccdddddccccccc4666766555566776494648846488846545555d1d1d11dd5500000000
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
00000000000000000000000000000000000000000000000000333333166666000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000003333333333316666666600000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000333333333333316666666666000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000033333333333333331666666666660000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000003333333333333333331666666666666600000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000333333333333333333331666666666666666000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000003333333333333333333333166666666666666600000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000033333333333333333333333166666666666666660000000000000000000000000000000000000000000000000000
00000000000000000000000000000000003333333333333333333333333166666666666666666600000000000000000000000000000000000000000000000000
00000000000000000000000000000000033333333333333333333333333166666666666666666660000000000000000000000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333166666666666666666666000000000000000000000000000000000000000000000000
00000000000000000000000000000000333333333333333333333333333316666666666666666666000000000000000000000000000000000000000000000000
00000000000000000000000000000003333333333333333333333333333316666666666666666666600000000000000000000000000000000000000000000000
00000000000000000000000000000033333333333333333333333333333316666666666666666666660000000000000000000000000000000000000000000000
00000000000000000000000000000333333333333333333333333333333316666666666666666666666000000000000000000000000000000000000000000000
00000000000000000000000000000333333333333333333333333333333316666666666666666666666000000000000000000000000000000000000000000000
00000000000000000000000000003333333333333333333333333333333316666666666666666666666600000000000000000000000000000000000000000000
00000000000000000000000000003333333333333333333333333333333316666666666666666666666600000000000000000000000000000000000000000000
00000000000000000000000000033333333333333333333333333333333316666666666666666666666660000000000000000000000000000000000000000000
00000000000000000000000000033333333333333333333333333333333331666666666666666666666660000000000000000000000000000000000000000000
00000000000000000000000000334444443344443333444443344443444444444444444444444666666666000000000000000000000000000000000000000000
00000000000000000000000000334999944349943334499944349944499449999999449999994666666666000000000000000000000000000000000000000000
00000000000000000000000003334999994449943344999994449994499449999999449999994666666666600000000000000000000000000000000000000000
00000000000000000000000003334994499449943349994999449999499449944444444499444666666666600000000000000000000000000000000000000000
00000000000000000000000003334994499449943349994999449999499449944446666499466666666666600000000000000000000000000000000000000000
00000000000000000000000003334999994449943349999999449999999449999946666499466666666666600000000000000000000000000000000000000000
00000000000000000000000033334999944349943349994999449949999449999946666499466666666666660000000000000000000000000000000000000000
00000000000000000000000033334994443349944449944499449949999449944444466499466666666666660000000000000000000000000000000000000000
00000000000000000000000033334994333349999449943499449944999449999999466499466666666666660000000000000000000000000000000000000000
00000000000000000000000033334994333349999449943499449944499449999999466499466666666666660000000000000000000000000000000000000000
00000000000000000000000033334444333344444444443444444443444444444444466444466666666666660000000000000000000000000000000000000000
00000000000000000000000033333333333333333333333333333333333331666666666666666666666666660000000000000000000000000000000000000000
00000000000000000000000013333333333333333333333333333333333331666666666666666666666666610000000000000000000000000000000000000000
000000000000000000000000c1333333333333333333333333344444443444444446444444444444446666120000000000000000000000000000000000000000
000000000000000000000000cc133333333333333333333333449999944499999944499999944999944461220000000000000000000000000000000000000000
000000000000000000000000ccc11113333333333333333334499999994499999994499999944999999442220000000000000000000000000000000000000000
000000000000000000000000ccccccc1111333333333333334999444994499449994444994444994499942220000000000000000000000000000000000000000
000000000000000000000000ccccccccccc111111111333334994444444499449994114994114994449942220000000000000000000000000000000000000000
0000000000000000000000000ccccccccccccccccccc111114994499994499999944224994224994249942200000000000000000000000000000000000000000
0000000000000000000000000cccccccccccccccccccccccc4994499994499999442224994224994449942200000000000000000000000000000000000000000
0000000000000000000000000cccccccccccccccccccccccc4999444994499499944444994444994499942200000000000000000000000000000000000000000
0000000000000000000000000cccccccccccccccccccccccc4499999994499449994499999944999999442200000000000000000000000000000000000000000
00000000000000000000000000cccccccccccccccccccccccc449999944499444994499999944999944422000000000000000000000000000000000000000000
00000000000000000000000000ccccccccccccccccccccccccc4444444c444424444444444444444442222000000000000000000000000000000000000000000
000000000000000000000000000cccccccccccccccccccccccccccccccccc1222222222222222222222220000000000000000000000000000000000000000000
000000000000000000000000000ccccccccccccccccccccccccccccccccc12222222222222222222222220000000000000000000000000000000000000000000
0000000000000000000000000000cccccccccccccccccccccccccccccccc12222222222222222222222200000000000000000000000000000000000000000000
0000000000000000000000000000cccccccccccccccccccccccccccccccc12222222222222222222222200000000000000000000000000000000000000000000
00000000000000000444444000000ccccccccccccccccccccccccccccccc12222222222222222222222000000000000000000000000000000000000000000000
00000000000000004ffffff400000ccccccccccccccccccccccccccccccc12222222222222222222222000000000000000000000000000000000000000000000
00000000000000004f4ff4f4000000cccccccccccccccccccccccccccccc12222222222222222222220000000000000000000000000000000000000000000000
00000000000000004ffffff40000000ccccccccccccccccccccccccccccc12222222222222222222200000000000000000000000000000000000000000000000
00000000000000004f4ff4f400000000cccccccccccccccccccccccccccc12222222222222222222000000000000000000000000000000000000000000000000
00000000044444404ff44ff400000000ccccccccccccccccccccccccccc122222222222222222222000000000000000000000000000000000000000000000000
000000004ffffff4e4ffff4e000000000cccccccccccccccccccccccccc122222222222222222220000000000000000000000000000000000000000000000000
0000000054ffff4554ffff450000000000ccccccccccccccccccccccccc122222222222222222200000000000000000000000000000000000000000000000000
000000055555555550000000000000000000ccccccccccccccccccccccc122222222222222220000000000000000000000000000000000000000000000000000
0000005666666666650000000000000000000cccccccccccccccccccccc122222222222222200000000000000000000000000000000000000000000000000000
00000566776666666650000000000000000000cccccccccccccccccccc1222222222222222000000000000000000000000000000000000000000000000000000
0000056677766666665000000000000000000000cccccccccccccccccc1222222222222200000000000000000000000000000000000000000000000000000000
000005766776666666500000000000000000000000cccccccccccccccc1222222222220000000000000000000000000000000000000000000000000000000000
00000576666666666755000000000000000000000000ccccccccccccc12222222222000000000000000000000000000000000000000000000000000000000000
0000005766666667750000000000000000000000000000ccccccccccc12222222200000000000000000000000000000000000000000000000000000000000000
00000005555555555000000000000000000000000000000000cccccc122222000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06606606660666060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06060606000600060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000606600600066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000606000600060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000606660666060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660060006606660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06006060606060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06006060666006000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06006060606000600600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06006660606066000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
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
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff333333166666ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffff33333333333166666666ffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffff333333333333316666666666ffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffff3333333333333333166666666666ffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffff33333333333333333316666666666666ffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffff333333333333333333331666666666666666ffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffff33333333333333333333331666666666666666fffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffff3333333333333333333333316666666666666666ffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffff33333333333333333333333331666666666666666666ffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffff3333333333333333333333333316666666666666666666fffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff333333333333333333333333333166666666666666666666ffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff333333333333333333333333333316666666666666666666ffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffff33333333333333333333333333333166666666666666666666fffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffff3333333333333333333333333333331666666666666666666666ffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffff333333333333333333333333333333316666666666666666666666fffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffff333333333333333333333333333333316666666666666666666666fffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffff33333333333333333333333333333333166666666666666666666666ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffff33333333333333333333333333333333166666666666666666666666ffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffff3333333333333333333333333333333331666666666666666666666666fffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffff3333333333333333333333333333333333166666666666666666666666fffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffff334444443344443333444443344443444444444444444444444666666666ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffff334999944349943334499944349944499449999999449999994666666666ffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffff33349999944499433449999944499944994499999994499999946666666666fffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffff33349944994499433499949994499994994499444444444994446666666666fffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffff33349944994499433499949994499994994499444466664994666666666666fffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffff33349999944499433499999994499999994499999466664994666666666666fffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff3333499994434994334999499944994999944999994666649946666666666666ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff3333499444334994444994449944994999944994444446649946666666666666ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff3333499433334999944994349944994499944999999946649946666666666666ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff3333499433334999944994349944994449944999999946649946666666666666ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff3333444433334444444444344444444344444444444446644446666666666666ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff3333333333333333333333333333333333333166666666666666666666666666ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffff1333333333333333333333333333333333333166666666666666666666666661ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffc133333333333333333333333334444444344444444644444444444444666612ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffcc13333333333333333333333344999994449999994449999994499994446122ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffccc1111333333333333333333449999999449999999449999994499999944222ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffccccccc111133333333333333499944499449944999444499444499449994222ffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffccccccccccc11111111133333499444444449944999411499411499444994222ffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffccccccccccccccccccc1111149944999944999999442249942249942499422fffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffcccccccccccccccccccccccc49944999944999994422249942249944499422fffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffcccccccccccccccccccccccc49994449944994999444449944449944999422fffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffcccccccccccccccccccccccc44999999944994499944999999449999994422fffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffcccccccccccccccccccccccc449999944499444994499999944999944422ffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffccccccccccccccccccccccccc4444444c444424444444444444444442222ffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffcccccccccccccccccccccccccccccccccc122222222222222222222222fffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffccccccccccccccccccccccccccccccccc1222222222222222222222222fffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffcccccccccccccccccccccccccccccccc122222222222222222222222ffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffcccccccccccccccccccccccccccccccc122222222222222222222222ffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffccccccccccccccccccccccccccccccc12222222222222222222222fffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffccccccccccccccccccccccccccccccc12222222222222222222222fffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffcccccccccccccccccccccccccccccc1222222222222222222222ffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffccccccccccccccccccccccccccccc122222222222222222222fffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffcccccccccccccccccccccccccccc12222222222222222222ffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffccccccccccccccccccccccccccc122222222222222222222ffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffcccccccccccccccccccccccccc12222222222222222222fffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffccccccccccccccccccccccccc1222222222222222222ffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffccccccccccccccccccccccc12222222222222222ffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffffffffffcccccccccccccccccccccc1222222222222222fffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffcccccccccccccccccccc1222222222222222ffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffcccccccccccccccccc12222222222222ffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffcccccccccccccccc122222222222ffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffccccccccccccc12222222222ffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffccccccccccc122222222ffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffcccccc122222ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
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
ffffffffffffffffffffffffffffffffff2ffffff44f444f444f444f444fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffff282ffff49949994999499949994ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffff222882ff4944f494494949494494fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffff28888882f4999449449994994f494fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffff222882fff4494494494949494494fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffff282fff4994f494494949494494fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffff2fffff44fff4ff4f4f4f4ff4ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff444f44fff44f444f444f4f4ff44f444f444ff44f44fff44fffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffff49994994f49949994999494944994999499944994994f4994ffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff49449494944f494494949494944f494f494494949494944fffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff49449494999449449944949494ff494f4944949494949994ffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff494494944494494494949494944f494f4944949494944494ffffffffffffffffffffffffffffffffffffffff
fffffffffffffffffffffffffffffffffffffff499949494994f49449494499449944944999499449494994fffffffffffffffffffffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffff444f4f4f44fff4ff4f4ff44ff44ff4ff444f44ff4f4f44ffffffffffffffffffffffffffffffffffffffffff
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
__sfx__
0001000006770057700577008700097001b1001c1001d1001e10020100211000b7000b7000b7000b7000b7000b700097000b7000b7000b7000c7000c7000e170131701517017170191701a1701c1700a7000a700
