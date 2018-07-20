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
   add_to_history("$"..input_text_colour_ctrl.."> "..input)
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
 for i=0,#history-1 do
  for j=1,#history[#history-i] do
   print(history[#history-i][j][1],(j-1)*4,117-6*i,history[#history-i][j][2])
  end
 end
 print(">"..input,0,123,input_text_colour)
 if (timer%16<8) rectfill(input_cursor*4+4,123,input_cursor*4+7,128,12)

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
 current_room=start_room
 show_room_description()

 --hard code menu command/alias
 aliases.m={"menu"}
 commands.menu={menu}

 aliases.q={"quit"}
 commands.quit={quit}
end

function show_room_description()
 add_to_history("== "..current_room.." ==")
 add_to_history(descriptions[current_room])
 for i in all(items_at_locations[current_room]) do
  add_to_history("there is a "..i.." here.")
 end
end

function move_item(item,place)
 local old_loc=item_locations[item]
 item_locations[item]=place
 del(items_at_locations[old_loc],item)
 add(items_at_locations[place],item)
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

start_room="field"

--token matching functions
function direction(t)
 return exits[current_room][t]~=nil
end

function local_item(t)
 return room_item(t) or inventory_item(t)
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
 move_item(tokens[2],"inventory")
 add_to_history("you get the "..tokens[2])
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

commands={
	look={look},
	go={"$direction",go},
	examine={"$local_item",examine},
	get={"$room_item",get},
	drop={"$inventory_item",drop},
	inventory={inventory},
}

aliases={
 the={},
 a={},
 an={},

	l={"look"},
	x={"examine"},
	i={"inventory"},

	n={"go","north"},
	s={"go","south"},
	e={"go","east"},
	w={"go","west"},
}

--data tables for commands
descriptions={
}

exits={
}

item_locations={
}

items_at_locations={
 inventory={}
}

scripts={
}
-->8
--data metaprogramming functions

function room(t)
 descriptions[t.name]=t.description
 exits[t.name]=t.exits
 items_at_locations[t.name]={}
end

function item(t)
 descriptions[t.name]=t.description
 add(items_at_locations[t.start_location],t.name)
 item_locations[t.name]=t.start_location
end

function script(t)
 s=scripts
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

--room data

room{
 name="field",
 description="you're standing in a field outside a white house.",
 exits={north="forest",west="house"},
}

room{
 name="forest",
 description="shafts of light shine through the leaves.",
 exits={south="field"},
}

room{
 name="house",
 description="inside a house i guess",
 exits={east="field"},
}

--item data

item{
 name="stick",
 start_location="field",
 description="it's sticky."
}

item{
 name="key",
 start_location="forest",
 description="a key, possibly for a door."
}

--script functions and data

function locked_door(tokens)
 if item_locations["key"]=="inventory" then
  add_to_history("you unlock the door.")
  go(tokens)
 else
  add_to_history("the door is locked.")
 end
end

script{"field","go","west",locked_door}
