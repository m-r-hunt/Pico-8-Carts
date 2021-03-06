pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--core text engine

--todo
--software/hardware keyboard switch

--engine constants
chars_per_line=32

devkit_addr=0x5f2d
pause_disable_addr=0x5f30

input_text_colour=15
input_text_colour_ctrl="f"

max_history=128
max_command_history=128

--engine state
timer=0

input=""
input_cursor=0

history={}
command_history={""}
command_history_cursor=1

scroll_pos=0
scroll_mode=false

function scroll()
 scroll_mode=true
 scroll_pos=0
end

function add_to_history(s)
 local colour_chars={}
 local current_colour=7
 local i=1
 while i<=#s do
  if sub(s,i,i)=="$" then
   current_colour=tonum("0x"..sub(s,i+1,i+1))
   i+=1
  else
   add(colour_chars,{sub(s,i,i),current_colour})
  end
  i+=1
 end

 while #colour_chars>chars_per_line do
  for i=chars_per_line,1,-1 do
   if colour_chars[i][1]==" " then
    local tmp={}
    for j=1,i do
     add(tmp,colour_chars[1])
     del(colour_chars,colour_chars[1])
    end
    add(history,tmp)
    break
   end
  end
 end
 add(history,colour_chars)

 while #history>max_history do
  del(history,history[1])
 end
end

function _init()
 cartdata("mrh_escape_from_darkness_0_1")

 poke(devkit_addr,1)--enable keyboard

 initialise_ta_engine()
end

function tokenize(i)
 local t={}
 local buf=""
 while #i~=0 do
  local next_c=sub(i,0,1)
  if next_c==" " or next_c=="\t" then
   if (#buf>0) add(t,buf)
   buf=""
  else
   buf=buf..next_c
  end
  i=sub(i,2)
 end
 if (#buf>0) add(t,buf)
 return t
end

function print_tokens(tokens)
 o=""
 for t in all(tokens) do
  o=o.."["..t.."] "
 end
 add_to_history(o)
end

function run_game(i)
 local tokens=tokenize(i)
 run_ta_command(tokens)
end

function _update()
 timer+=1

 --disable pause so we can use enter
 --specific engine will need to expose
 --some way of pausing via extcmd("pause")
 poke(pause_disable_addr,1)

 if scroll_mode then
  if (btn(2)) scroll_pos+=1
  if (btn(3)) scroll_pos-=1
  scroll_pos=mid(0,scroll_pos,#history)

  while stat(30) do
   c=stat(31)
   if c==" " or c=="\r" or c=="\n" then
    scroll_mode=false
    scroll_pos=0
   end
  end
  return
 end

 if btnp(2) then
  command_history_cursor=(command_history_cursor-1)
  command_history_cursor=mid(1,command_history_cursor,#command_history)
  input=command_history[command_history_cursor]
  input_cursor=#input
 elseif btnp(3) then
  command_history_cursor=(command_history_cursor+1)
  command_history_cursor=mid(1,command_history_cursor,#command_history)
  input=command_history[command_history_cursor]
  input_cursor=#input
 elseif btnp(0) then
  input_cursor-=1
  input_cursor=mid(0,input_cursor,#input)
 elseif btnp(1) then
  input_cursor+=1
  input_cursor=mid(0,input_cursor,#input)
 end

 while stat(30) do
  local c=stat(31)
  if c=="\b" then
   input=sub(input,0,max(0,input_cursor-1))..sub(input,input_cursor+1,#input)
   input_cursor-=1
  input_cursor=mid(0,input_cursor,#input)
   if (input_cursor<0) input_cursor=0
  elseif c=="\r" or c=="\n" then
   add_to_history("$"..input_text_colour_ctrl..">"..input)
   command_history[#command_history]=input
   add(command_history,"")
   while #command_history>max_command_history do
    del(command_history,command_history[1])
   end
   command_history_cursor=#command_history
   run_game(input)
   input=""
   input_cursor=0
  else
   input=sub(input,0,input_cursor)..c..sub(input,input_cursor+1,#input)
   input_cursor+=1
  end
 end
end

debugs={
 {"cpu",function() return stat(1) end},
 {"mem",function() return stat(0) end},
 --{"his",function() return #history end},
 --{"chs",function() return #command_history end},
}

function _draw()
 cls()
 for i=0,#history-1-scroll_pos do
  for j=1,#history[#history-i-scroll_pos] do
   print(history[#history-i-scroll_pos][j][1],(j-1)*4,117-6*i,history[#history-i-scroll_pos][j][2])
  end
 end
 print(">"..input,0,123,input_text_colour)
 if (timer%16<8) rectfill(input_cursor*4+4,123,input_cursor*4+7,128,12)
 if scroll_mode then
  rectfill(0,123,128,128,12)
  print("scroll",0,123,7)
 end

 rectfill(80,0,128,6*#debugs,0)
 for i=1,#debugs do
  local d=debugs[i]
  print(d[1]..":"..d[2](),80,(i-1)*6,12)
 end
end
-->8
--text adventure engine

--game state
current_room=""

function initialise_ta_engine()
 startup()
 current_room=start_room
 show_room_description()
 add_to_history("$c[type $bhelp$c for help]")

 --hard code menu command/alias
 aliases.m={"menu"}
 commands.menu={menu}

 aliases.q={"quit"}
 commands.quit={quit}

 aliases.s={"scroll"}
 commands.scroll={scroll}
end

function show_room_title()

end

function show_room_description()
 add_to_history("== "..current_room.." ==")
 local s=descriptions[current_room]
 for _,d in pairs(hidden_descriptions[current_room]) do
  s=s.." "..d
 end
 add_to_history(s)
 for i in all(items_at_locations[current_room]) do
  add_to_history("there is a "..i.." here.")
 end
 for e,_ in pairs(exits[current_room]) do
  add_to_history("there is an exit to the "..e..".")
 end
end

function move_item(item,place)
 local old_loc=item_locations[item]
 item_locations[item]=place
 del(items_at_locations[old_loc],item)
 add(items_at_locations[place],item)
 undisturbed[item]=false
 hidden_descriptions[old_loc][item]=nil
end

function menu(tokens)
 extcmd("pause")
end

function quit(tokens)
 stop()
end

function match_token(t,expected)
 if sub(expected,0,1)=="$" then
  return token_matchers[sub(expected,2)](t)
 else
  return t==expected
 end
end

function match_command(tokens)
 local c=commands[tokens[1]]
 if (not c) return false
 for j=1,#c-1 do
  if not match_token(tokens[j+1],c[j]) then
   return false
  end
 end
 return true
end

function expand_aliases(tokens)
 local expanded={}
 for t in all(tokens) do
  if not aliases[t] then
   add(expanded,t)
  else
   for j=1,#aliases[t] do
    add(expanded,aliases[t][j])
   end
  end
 end
 return expanded
end

function run_ta_command(tokens)
 local tokens=expand_aliases(tokens)

 local command_done=false
 if match_command(tokens) then
  local s=scripts[current_room]
  local scripted=false
  for i=1,#tokens do
   if (not s) break
   s=s[tokens[i]]
   if type(s)=="function" then
    s(tokens)
    scripted=true
    break
   end
  end
  if not scripted then
   s=scripts["any"]
   for i=1,#tokens do
    if (not s) break
    s=s[tokens[i]]
    if type(s)=="function" then
     s(tokens)
     scripted=true
     break
    end
   end
  end
  if not scripted then
   local c=commands[tokens[1]]
   c[#c](tokens)
  end
  command_done=true
 end

 if not command_done and #tokens>0 then
  local errstr="sorry, i don't understand. i interpreted your input as '"..tokens[1]
  for i=2,#tokens do
   errstr=errstr.." "..tokens[i]
  end
  errstr=errstr.."'"
  add_to_history(errstr)
 end
end
-->8
--game scripts and data

start_room="cell"

function startup()
 init_tables()
 load_data()
 add_to_history("===== escape from darkness =====")
 add_to_history("")
 add_to_history("the guard shoves you roughly into a dank cell. you must escape to the surface with all haste.")
 add_to_history("")
end

--token matching functions
function direction(t)
 return exits[current_room][t]~=nil
end

function local_item(t)
 return room_item(t) or inventory_item(t) or t=="self"
end

function room_item(t)
 return item_locations[t]==current_room
end

function inventory_item(t)
 return item_locations[t]=="inventory"
end

token_matchers={
	direction=direction,
	local_item=local_item,
	room_item=room_item,
	inventory_item=inventory_item,
}

--command functions
function go(tokens)
 current_room=exits[current_room][tokens[2]]
 add_to_history("you travel "..tokens[2].." to the "..current_room..".")
 show_room_description()
end

function look(tokens)
 show_room_description()
end

function examine(tokens)
 add_to_history(descriptions[tokens[2]])
end

function get(tokens)
 if static_items[tokens[2]] then
  add_to_history("you can't pick that up.")
 else
  hidden_descriptions[current_room][tokens[2]]=nil
  move_item(tokens[2],"inventory")
  add_to_history("you get the "..tokens[2])
 end
end

function drop(tokens)
 move_item(tokens[2],current_room)
 add_to_history("you drop the "..tokens[2])
end

function inventory(tokens)
 if #items_at_locations["inventory"]>0 then
  add_to_history("you are holding:")
  for i in all(items_at_locations["inventory"]) do
   add_to_history("- "..i)
  end
 else
  add_to_history("your pockets are empty.")
 end
end

function use(tokens)
 add_to_history("nothing happens.")
end

function ta_help(tokens)
 add_to_history("this is a classic text adventure. your object is to escape the underground and return to the surface.")
 add_to_history("type in commands to interact with the world. all commands are english sentences that start with a verb.")
 add_to_history("examples: \"use sword on troll\" \"examine book\" etc")
 add_to_history("important commands:")
 add_to_history("- look")
 add_to_history("- examine <thing>")
 add_to_history("- go <direction>")
 add_to_history("- use <item> on <thing>")
 add_to_history("- scroll")
 add_to_history("shorthands exist: n=go north, x=examine, etc")
end


aliases={
 the={},
 a={},
 an={},

 with={"on"},

	l={"look"},
	x={"examine"},
	i={"inventory"},
	h={"help"},

	n={"go","north"},
	s={"go","south"},
	e={"go","east"},
	w={"go","west"},
}

function init_tables()
--data tables for commands
commands={
	look={look},
	go={"$direction",go},
	examine={"$local_item",examine},
	get={"$room_item",get},
	drop={"$inventory_item",drop},
	use={"$inventory_item","on","$local_item",use},
	inventory={inventory},
	help={ta_help},
	save={game_save},
	load={game_load},
}

rooms={"undisturbed","inventory"}
items={}

descriptions={
}

exits={
}

item_locations={
}

items_at_locations={
 inventory={}
}

hidden_descriptions={
 inventory={}
}

static_items={
}

scripts={
}

undisturbed={}

serializable_scripts={}
serializable_scripts_triggered={}
end
-->8
--data metaprogramming functions

function load_data()
function room(t)
 descriptions[t.name]=t.description
 exits[t.name]=t.exits
 items_at_locations[t.name]={}
 hidden_descriptions[t.name]={}
 add(rooms,t.name)
end

function item(t)
 descriptions[t.name]=t.description
 if not t.hidden then
  add(items_at_locations[t.start_location],t.name)
 end
 item_locations[t.name]=t.start_location
 static_items[t.name]=t.static
 hidden_descriptions[t.start_location][t.name]=t.hidden_description
 add(items,t.name)
 undisturbed[t.name]=true
end

function script(t)
 local s=scripts
 for i=1,#t-2 do
  print(i)
  print(t[i])
  if not s[t[i]] then
   s[t[i]]={}
  end
  s=s[t[i]]
 end
 s[t[#t-1]]=t[#t]
end

function serializable_script(f)
 local i=#serializable_scripts+1
 local wrapped=function()
  serializable_scripts_triggered[i]=true
  f()
 end
 serializable_scripts[i]=wrapped
 serializable_scripts_triggered[i]=false
 return wrapped
end

--room data

room{
 name="cell",
 description="you stand stooped in a dungeon cell, which is low ceilinged and dank. a a rough straw $bbed$7 sits in one corner and a $bbucket$7 in another.",
 exits={},
}

room{
 name="tunnel",
 description="a dark tunnel.",
 exits={east="cell",west="atrium"},
}

room{
	name="atrium",
	description="a spacious chamber. a breeze can be felt from stairs leading upwards.",
	exits={east="tunnel",up="door room"},
}

--item data

item{
 name="bed",
 start_location="cell",
 static=true,
 hidden=true,
 description="a rough straw bed sits on the stone floor. you spot a $bneedle$7 mixed into the straw.",
}

item{
 name="bucket",
 start_location="cell",
 hidden=true,
 description="a pungent odour rises from the bucket. your eyes begin to water.",
}

item{
 name="needle",
 start_location="cell",
 hidden=true,
 description="a metal knitting needle. not so hard to spot in a haystack."
}

item{
 name="wall",
 start_location="cell",
 hidden=true,
 static=true,
 hidden_description="the west $bwall$7 looks cracked.",
 description="the stone wall is cracked and crumbling. the mortar around one section looks loose."
}

--script functions and data

function x_self(tokens)
 add_to_history("lookin' good.")
end
script{"any","examine","self",x_self}

function get_bucket(tokens)
 add_to_history("as you go to pick up the bucket, your eyes start to burn. you leave it alone.")
end
script{"any","get","bucket",get_bucket}

remove_needle_desc=serializable_script(function()
descriptions.bed="a rough straw bed sits on the stone floor."
 scripts.cell.get.needle=nil
end)
function get_needle(tokens)
 get(tokens)
 remove_needle_desc()
end
script{"cell","get","needle",get_needle}

open_wall=serializable_script(function()
 exits.cell.west="tunnel"
end)
function use_needle_on_wall(tokens)
 add_to_history("you scrape away the loose mortar and manage to create a hole big enough to squeeze through.")
 open_wall()
 move_item("wall",nil)
 move_item("needle",nil)
end
script{"cell","use","needle","on","wall",use_needle_on_wall}
end
-->8
function find(t,i)
 for j,r in pairs(t) do
  if (r==i) return j
 end
 return 0
end

--save file format:
--byte 0   :current room
--byte 1+  :item locations
--byte 255-:script flag bits
save_base=0x5e00
save_max =0x5eff

function game_save()
 for i=save_base,save_max do
  poke(i,0)
 end

 poke(save_base,find(rooms,current_room))

 for i=1,#items do
  if (undisturbed[items[i]]) then
   poke(save_base+i,find(rooms,"undisturbed"))
  else
   poke(save_base+i,find(rooms,item_locations[items[i]]))
  end
 end

 for i=1,#serializable_scripts do
  val=serializable_scripts_triggered[i] and 1 or 0
  addr=save_max-flr((i-1)/8)
  a=peek(addr)
  poke(addr,bor(a,shl(val,(i-1)%8)))
 end
end

function game_load()
 init_tables()
 load_data()

 current_room=rooms[peek(save_base)]

 for i=1,#items do
  local item=items[i]
  local room=rooms[peek(save_base+i)]
  if room~="undisturbed" then
   move_item(item,room)
  end
 end

 for i=1,#serializable_scripts do
  addr=save_max-flr((i-1)/8)
  a=peek(addr)
  if band(1,lshr(a,(i-1)%8))==1 then
   serializable_scripts[i]()
  end
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000033333330000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000003300000003330000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000033300ffffffff03333000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000003330ffffffffffffff03333000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000033300ffffffffffffffffff033330000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000033333ff3fffffffffffffffffff330000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000030fffffffffffffffffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000030fffffffffffffffffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000030fffffffffffffffffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000330fffffffffffffffffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030ffffffffffffffffffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030ffffffffffffffffffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030ffffffffffffffffffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030ffffffffffffffffffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030fffffffffffff000ffffffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030fffffffffff0f0000fffffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030ffffffffff00f30000ffffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030ffffffff333300333000ffffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000030ffffff3335555555533300ffff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000300ff333300000000000050330fff030000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000300333000000000000000500033ff030000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000033300500000000000000050000033330000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000050000000300000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000500000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005500000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000005000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000050000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000050000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000050000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000050000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000550000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000500000000000000000055000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000500000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000005000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000050000000000000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000055555555555555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000
