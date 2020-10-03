pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--mobius station
--by maximilian hunt
--(c) 2020 cc-by-sa

--todo

--switch to more small crates(?)
--fix crate pathfinding around joins
--better ui on fment
--day summary screen
--banners/transitions between states
--reconceptualize crate management as push/pull
--redraw crates as nicer icons

--done
--multi delivery
--multi fment
--animated crates

-->8
--core

loop_width=48*8
half_loop_width=24*8

function new_game()
	px=0
	pcarried=nil
	cargo={}
	for i=1,12 do
		cargo[i]={}
	end
	inventory={}
	crates={}
end

function get_empty_slot(row,aside)
	local order=aside and {"mid","a","b"} or {"mid", "b", "a"}
	for i=1,#order do
		if not cargo[row][order[i]] then
			return order[i]
		end
	end
	return "b"
end

function get_filled_slot(row,aside)
	local order=aside and {"b","mid","a"} or {"a", "mid", "b"}
	for i=1,#order do
		if cargo[row][order[i]] then
			return order[i]
		end
	end
	return aside and "a" or "b"
end

function get_target_crate()
	local row=(px%half_loop_width)\16+1
	local aside=px<half_loop_width
	local pos
	if pcarried then
		pos=get_empty_slot(row,aside)
	else
		pos=get_filled_slot(row,aside)
	end
	return row,pos
end

function update_player()
	if (btn(0)) px-=1
	if (btn(1)) px+=1
	if (px<0) px+=loop_width
	if (px>=loop_width) px-=loop_width
	if btnp(4) then
		local n,pos=get_target_crate()
		if not pcarried and cargo[n][pos] then
			pcarried=cargo[n][pos]
			pcarried.target="player"
			cargo[n][pos]=nil
		elseif pcarried and not cargo[n][pos] then
			cargo[n][pos]=pcarried
			pcarried.target="storage"
			pcarried.targetshelf=n
			pcarried.targetpos=pos
			pcarried=nil
		end
	end
end

function get_crate_target_pos(c)
	if c.target=="storage" then
		local post={a=9*8,mid=7*8,b=5*8}
		assert(post[c.targetpos],c.targetpos)
		return (c.targetshelf-1)*16,post[c.targetpos]
	elseif c.target=="player" then
		return px,10*8
	end
end

function update_crates()
	for _,c in pairs(crates) do
		local tx,ty=get_crate_target_pos(c)
		c.x=c.x+(tx-c.x)/2
		c.y=c.y+(ty-c.y)/2
	end
end

function draw_loop()
	map(0,0,0,0,48,16)
end

function draw_objects()
	for _,crate in pairs(crates) do
		spr(crate.type,crate.x,crate.y,2,2)
		spr(crate.type,crate.x+half_loop_width,112-crate.y,2,2)
	end

	local n,pos=get_target_crate()
	local t1={a=9*8,mid=7*8,b=5*8}
	local y1=t1[pos]
	local t2={a=5*8,mid=7*8,b=9*8}
	local y2=t2[pos]
	spr(108,(n-1)*16,y1,2,2)
	spr(108,half_loop_width+(n-1)*16,y2,2,2)
	spr(64,px-4,104)
end

function draw_world()
	cls()

	camera(px-60+loop_width)
	draw_loop()

	camera(px-60)
	draw_loop()

	camera(px-60-loop_width)
	draw_loop()

	camera(px-60+loop_width)
	draw_objects()

	camera(px-60)
	draw_objects()

	camera(px-60-loop_width)
	draw_objects()

	camera()
	--ui probably
	print(t,0,0,7)
end

-->8
--delivery

function add_crate(c)
	inventory[c]=inventory[c] and inventory[c]+1 or 1
	for x=0,6 do
		for pos=1,3 do
			local pt={"mid","a","b"}
			local p=pt[pos]
			if not cargo[1+x][p] then
				local newc={type=c,x=0,y=0,target="storage",targetshelf=1+x,targetpos=p}
				cargo[1+x][p]=newc
				add(crates,newc)
				return
			end
			if not cargo[12-x][p] then
				local newc={type=c,x=0,y=0,target="storage",targetshelf=12-x,targetpos=p}
				cargo[12-x][p]=newc
				add(crates,newc)
				return
			end
		end
	end
	assert(false)
end

function random_crate_type()
	local c=128+(flr(rnd(16)))*2
	if c>=144 then
		c+=16
	end
	return c
end

total_slots=12*3
max_fraction=flr(2/3*total_slots)

function count_inventory()
	local total=0
	for _,n in pairs(inventory) do
		total+=n
	end
	return total
end

function enter_delivery_prep()
	local filled_slots=count_inventory()
	local max_delivered=mid(1,max_fraction-filled_slots,6)
	delivery_type=random_crate_type()
	delivery_n=ceil(rnd(max_delivered))
	transition("delivering")
end

function enter_delivering()
	add_crate(delivery_type)
	delivery_n-=1
end

delivery_time=1.5

function update_delivery()
	update_player()
	update_crates()

	if t>=delivery_time then
		if delivery_n>=0 then
			transition("delivering")
		else
			transition("chill")
		end
	end
end

function draw_delivery()
	draw_world()
end

-->8
--chill

function update_chill()
	update_player()
	update_crates()

	if btnp(5) and px>=25*8 and px<=26*8 then
		transition("fment")
	end
end

function draw_chill()
	draw_world()
end

-->8
--fment

function enter_fment()
	local types={}
	for type,number in pairs(inventory) do
		if number>0 then
			add(types,type)
		end
	end
	target=rnd(types)
	local max_target_number=min(3,inventory[target])
	target_number=ceil(rnd(max_target_number))
	time_limit=10
end

function update_fment()
	update_player()
	update_crates()
	if btnp(5) and px>=26*8 and px<=28*8 and pcarried==target then
		pcarried=nil
		inventory[target]-=1
		target_number-=1
		if target_number<=0 then
			transition("delivery_prep")
		end
	elseif t>=time_limit then
		transition("gameover")
	end
	
end

function draw_fment()
	draw_world()
	spr(target,0,0,2,2)
	print(target_number,8,8,7)
end

-->8
--menus

function update_gameover()
	if btnp()&0b110000~=0 then
		transition("title")
	end
end

function draw_gameover()
	cls()
	print("game over",60,64,7)
	print("🅾️/❎: return to title",60,78,7)
end

function update_title()
	if btnp()&0b110000~=0 then
		new_game()
		transition("delivery_prep")
	end
end

function draw_title()
	cls()
	print("mobius station",60,64,7)
	print("🅾️/❎: start game",60,78,7)
end

-->8
--state machine & callbacks

states={
	title={update=update_title,draw=draw_title},

	delivery_prep={enter=enter_delivery_prep},
	delivering={enter=enter_delivering,update=update_delivery,draw=draw_delivery},
	chill={update=update_chill,draw=draw_chill},
	fment={enter=enter_fment,update=update_fment,draw=draw_fment},
	summary={update=update_summary,draw=draw_summary},

	gameover={update=update_gameover,draw=draw_gameover},
}

function transition(new_state)
	current_state=new_state
	t=0
	if states[new_state].enter then
		states[new_state].enter()
	end
end

function _init()
	new_game()
	transition("title")
end

function _update60()
	t+=1/60
	states[current_state].update()
end

function _draw()
	states[current_state].draw()
end

__gfx__
00000000000000005555555566666666000000000000000000000000000000000000000000000000000000000000000000000000000000006888888888888886
00000000000000006666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
00600600000007005555555566666666000000000000000000000000000000000000000000000000000000000000000000000000000000008668886886866868
00066000000000006666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000008666866886886868
00066000000000006555556666666666000000000000000000000000000000000000000000000000000000000000000000000000000000008666866886886868
00600600007000005566655566666666000000000000000000000000000000000000000000000000000000000000000000000000000000008666866886868868
00000000000000006666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000008668886886866868
00000000000000005555555566666666000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
00000000000000006dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd68666666886666668
0000000000000000d66656666666566dd66555666665556dd66656666666566dd66555666665556dd66556666666566dd66556666665556d8666666886666668
0000000000000000d66556666665656dd66656666665665dd66565666665656dd66566666665665dd66665666665656dd66665666665665d8666666886666668
0000000000000000d66656666665656dd66656666665556dd66665666665656dd66656666665556dd66665666665656dd66555666665556d8666666886666668
0000000000000000d66656666665556dd66656666665665dd66656666665556dd66665666665665dd66555666665556dd66665666665665d8666666886666668
0000000000000000d66656666665656dd66556666665665dd66566666665656dd66565666665665dd66665666665656dd66665666665665d8666666886666668
0000000000000000d66555666665656dd66656666665556dd66555666665656dd66656666665556dd66556666665656dd66556666665556d8666666886666668
00000000000000006dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd68666666886666668
00000000000000006dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66111111111111116
0000000000000000d66656666665556dd66555666665656dd66656666665556dd66555666665656dd66556666665556dd66556666665656d1666666666666661
0000000000000000d66556666665665dd66656666665656dd66565666665665dd66566666665656dd66665666665665dd66665666665656d166d66d66d6ddd61
0000000000000000d66656666665665dd66656666665556dd66665666665665dd66656666665556dd66665666665665dd66555666665556d16d6d6d66d66d661
0000000000000000d66656666665556dd66656666665656dd66656666665556dd66665666665656dd66555666665556dd66665666665656d16d6d6d66d66d661
0000000000000000d66656666665665dd66556666665656dd66566666665665dd66565666665656dd66665666665665dd66665666665656d16d6d6d66d66d661
0000000000000000d66555666665556dd66656666666566dd66555666665556dd66656666666566dd66556666665556dd66556666666566d166d666dd666d661
00000000000000006dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd66dddddddddddddd61666666666666661
00000000000000006666666666666666666886666657756600000000000000000000000000000000000000000000000000000000000000001666666116666661
00000000000000006555555555555556668e88666657756600000000000000000000000000000000000000000000000000000000000000001666666116666661
00000000000000006511111111111156662882666657756600000000000000000000000000000000000000000000000000000000000000001666666116666661
00000000000000006511111111111156665225666657756600000000000000000000000000000000000000000000000000000000000000001666666116666661
00000000000000006511111111111156665775666652256600000000000000000000000000000000000000000000000000000000000000001666666116666661
00000000000000006511111111111156665775666628826600000000000000000000000000000000000000000000000000000000000000001666666116666661
0000000000000000651111111111115666577566668e886600000000000000000000000000000000000000000000000000000000000000001666666116666661
00000000000000006511111111111156665775666668866600000000000000000000000000000000000000000000000000000000000000001666666116666661
50500505000000006511111111111156000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
05055050000000006511111111111156000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
05166150000000006511111111111156000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
0d56c5d0000000006511111111111156000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
05666650000000006511111111111156000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
01555510000000006511111111111156000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
56d66d65000000006555555555555556000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
05555550000000006666666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008668886886866868
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008666866886868868
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008666866886886868
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008666866886886868
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008668886886866868
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008666666886666668
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006888888888888886
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c01666666116666661
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc00cccc00cccc1666666116666661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c01666666116666661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c01666666116666661
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001666666116666661
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001666666116666661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c01666666116666661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c01666666116666661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c01666666666666661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c0166d666dd666d661
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016d6d6d66d66d661
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016d6d6d66d66d661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c016d6d6d66d66d661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c0166d66d66d6ddd61
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cccc00cccc00cccc1666666666666661
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000000000000c06111111111111116
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444444444444400444444444444440044444444444444004444444444444400444444444444440044444444444444004444444444444400444444444444440
044ffffffffff4400448888888888440044bbbbbbbbbb440044cccccccccc440044dddddddddd4400449999999999440044aaaaaaaaaa4400445555555555440
04f4ffffffff4f40048488888888484004b4bbbbbbbb4b4004c4cccccccc4c4004d4dddddddd4d40049499999999494004a4aaaaaaaa4a400454555555554540
04ff4ffffff4ff40048848888884884004bb4bbbbbb4bb4004cc4cccccc4cc4004dd4dddddd4dd40049949999994994004aa4aaaaaa4aa400455455555545540
04fff4ffff4fff40048884888848884004bbb4bbbb4bbb4004ccc4cccc4ccc4004ddd4dddd4ddd40049994999949994004aaa4aaaa4aaa400455545555455540
04ffff4ff4ffff40048888488488884004bbbb4bb4bbbb4004cccc4cc4cccc4004dddd4dd4dddd40049999499499994004aaaa4aa4aaaa400455554554555540
04fffff44fffff40048888844888884004bbbbb44bbbbb4004ccccc44ccccc4004ddddd44ddddd40049999944999994004aaaaa44aaaaa400455555445555540
04fffff44fffff40048888844888884004bbbbb44bbbbb4004ccccc44ccccc4004ddddd44ddddd40049999944999994004aaaaa44aaaaa400455555445555540
04ffff4ff4ffff40048888488488884004bbbb4bb4bbbb4004cccc4cc4cccc4004dddd4dd4dddd40049999499499994004aaaa4aa4aaaa400455554554555540
04fff4ffff4fff40048884888848884004bbb4bbbb4bbb4004ccc4cccc4ccc4004ddd4dddd4ddd40049994999949994004aaa4aaaa4aaa400455545555455540
04ff4ffffff4ff40048848888884884004bb4bbbbbb4bb4004cc4cccccc4cc4004dd4dddddd4dd40049949999994994004aa4aaaaaa4aa400455455555545540
04f4ffffffff4f40048488888888484004b4bbbbbbbb4b4004c4cccccccc4c4004d4dddddddd4d40049499999999494004a4aaaaaaaa4a400454555555554540
044ffffffffff4400448888888888440044bbbbbbbbbb440044cccccccccc440044dddddddddd4400449999999999440044aaaaaaaaaa4400445555555555440
04444444444444400444444444444440044444444444444004444444444444400444444444444440044444444444444004444444444444400444444444444440
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444444444444400444444444444440044444444444444004444444444444400444444444444440044444444444444004444444444444400444444444444440
0446666666666440044111111111144004422222222224400443333333333440044eeeeeeeeee44004477777777774400444444444444440044ffffffffff440
046466666666464004141111111141400424222222224240043433333333434004e4eeeeeeee4e40047477777777474004f4444444444f400444ffffffff4440
046646666664664004114111111411400422422222242240043343333334334004ee4eeeeee4ee40047747777774774004ff44444444ff4004444ffffff44440
046664666646664004111411114111400422242222422240043334333343334004eee4eeee4eee40047774777747774004fff444444fff40044444ffff444440
046666466466664004111141141111400422224224222240043333433433334004eeee4ee4eeee40047777477477774004ffff4444ffff400444444ff4444440
046666644666664004111114411111400422222442222240043333344333334004eeeee44eeeee40047777744777774004fffff44fffff400444444444444440
046666644666664004111114411111400422222442222240043333344333334004eeeee44eeeee40047777744777774004fffff44fffff400444444444444440
046666466466664004111141141111400422224224222240043333433433334004eeee4ee4eeee40047777477477774004ffff4444ffff400444444ff4444440
046664666646664004111411114111400422242222422240043334333343334004eee4eeee4eee40047774777747774004fff444444fff40044444ffff444440
046646666664664004114111111411400422422222242240043343333334334004ee4eeeeee4ee40047747777774774004ff44444444ff4004444ffffff44440
046466666666464004141111111141400424222222224240043433333333434004e4eeeeeeee4e40047477777777474004f4444444444f400444ffffffff4440
0446666666666440044111111111144004422222222224400443333333333440044eeeeeeeeee44004477777777774400444444444444440044ffffffffff440
04444444444444400444444444444440044444444444444004444444444444400444444444444440044444444444444004444444444444400444444444444440
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001230000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045660000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000089ab0000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cdef0000
__map__
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03356e6f030303030303030303030303030303030303030303034e4f03030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03037e7f0303141503030303030318190303030303031c1d03035e5f0303242503030303030328290303030303032c2d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4243424342434243424342434243424342434243424342434243424342434243424342434243424342434243424342430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4243424342434243424342434243424342434243424342434243424342434243424342434243424342434243424342430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3233323332333233323332333233323332333233323332333233323332333233323332333233323332333233323332330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4243424342434243424342434243424342434243424342434243424342434243424342434243424342434243424342430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03030e0f0303121303030303030316170303030303031a1b03032e2f0303222303030303030326270303030303032a2b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03031e1f030303030303030303030303030303030303030303343e3f03030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
