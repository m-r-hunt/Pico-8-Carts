pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
piece_pool={}

piece_defs={
 {{0,0},spriten=1},
 {{0,0},{1,0},spriten=1},
 {{0,0},{1,0},{2,0},spriten=1},
 {{0,0},{1,0},{1,1},spriten=1},
 {{0,0},{1,0},{1,1},{2,1},spriten=1},
}

mode="piece select"
selected_piece=1
px=1
py=1
pr=0
grid={
 {0,0,0,0},
 {0,0,0,0},
 {0,0,0,0},
 {0,0,0,0},
}
gridx=40
gridy=40

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
 for i=1,#piece_defs do
  piece_pool[i]=1
 end
end

function _update()
 if mode=="piece select" then
  update_piece_select()
 elseif mode=="piece place" then
  update_piece_place()
 end
end

function update_piece_select()
 if btnp(2) then
  selected_piece-=1
 elseif btnp(3) then
  selected_piece+=1
 end
 if selected_piece<=0 then
  selected_piece+=#piece_pool
 elseif selected_piece>#piece_pool then
  selected_piece-=#piece_pool
 end
 
 if btnp(4) then
  mode="piece place"
 end
end

function update_piece_place()
	if (btnp(0)) px-=1
	if (btnp(1)) px+=1
	if (btnp(2)) py-=1
	if (btnp(3)) py+=1
	px=mid(1,px,4)
	py=mid(1,py,4)
	
	if btnp(5) then
	 pr-=1
	 if pr<0 then
	  pr+=4
	 end
	end
	
	if btnp(4) then
	 stamp_piece(selected_piece,px,py)
	 mode="piece select"
	 selected_piece=1
	 px=1
	 py=1
	end
end

function stamp_piece(i,x,y)
	for sq=1,#piece_defs[i] do
	 rx,ry=rotate(piece_defs[i][sq][1],piece_defs[i][sq][2],pr)
 	local px=x+rx
 	local py=y+ry
 	if px>=1 and px<=4 and py>=1 and py<=4 then
 		grid[py][px]=piece_defs[i].spriten
 	end
 end
end

preview_size=4

function draw_piece_preview(i,ybase)
 for sq=1,#piece_defs[i] do
	 local px=piece_defs[i][sq][1]
 	local py=piece_defs[i][sq][2]
 	local x=5+px*preview_size
 	local y=ybase+py*preview_size
 	rectfill(x,y,x+preview_size,y+preview_size,3)
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
	 col=3
	 if px+rx<1 or px+rx>4 or py+ry<1 or py+ry>4 then
	  col=8
	 end
 	local x=bx+rx*8
 	local y=by+ry*8
 	rectfill(x+1,y+1,x+9,y+9,0)
 	rectfill(x,y,x+8,y+8,col)
 	rect(x,y,x+8,y+8,1)
 end
end

function _draw()
 cls(15)
 print(mode,2,2,2)
 for i=1,#piece_pool do
  local ybase=10*(i)+4
 	draw_piece_preview(i,ybase)
 	print(piece_pool[i],1,ybase)
 	if i==selected_piece then
 		spr(2,20,ybase)
 	end
 end
 for y=1,4 do
 	for x=1,4 do
 		spr(grid[y][x],gridx+x*8,gridy+y*8)
 	end
 end
 draw_piece(selected_piece,gridx+px*8-3,gridy+py*8-3)
 rect(gridx+px*8,gridy+py*8,gridx+px*8+2,gridy+py*8+2,4)
end

__gfx__
00000000333bb3330002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000033bbbb330028200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070033bbbb330288222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700033bbbb332888888200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000333443330288222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333443330028200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000334444330002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
