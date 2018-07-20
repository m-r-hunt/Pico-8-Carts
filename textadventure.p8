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

function _draw()
 cls()
 for i=0,#history-1 do
  for j=1,#history[#history-i] do
   print(history[#history-i][j][1],(j-1)*4,117-6*i,history[#history-i][j][2])
  end
 end
 print("> "..input,0,123,input_text_colour)
 if (timer%16<8) rectfill(input_cursor*4+8,123,input_cursor*4+11,128,12)
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
 c=commands[tokens[1]]
 if (not c) return false
 for j=1,#c-1 do
  if not match_token(tokens[j+1],c[j]) then
   return false
  end
 end
 return true
end

function expand_aliases(tokens)
 expanded={}
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
 tokens=expand_aliases(tokens)

 command_done=false
 if match_command(tokens) then
  c[#c](tokens)
  command_done=true
 end

 if not command_done then
  add_to_history("sorry, i don't understand.")
 end
end
-->8
--game scripts and data

start_room="field"

--token matching functions
function match_direction(t)
 return exits[current_room][t]~=nil
end

function match_local_item(t)
 return item_locations[t]==current_room or item_locations[t]=="inventory"
end

token_matchers={
	direction=match_direction,
	local_item=match_local_item
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

commands={
	look={look},
	go={"$direction",go},
	examine={"$local_item",examine},
}

aliases={
	l={"look"},
	x={"examine"},

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

function room(t)
 descriptions[t.name]=t.description
 exits[t.name]=t.exits
 items_at_locations[t.name]={}
end

room{
 name="field",
 description="you're standing in a field outside a white house.",
 exits={north="forest"},
}

room{
 name="forest",
 description="shafts of light shine through the leaves.",
 exits={south="field"},
}

function item(t)
 descriptions[t.name]=t.description
 add(items_at_locations[t.start_location],t.name)
 item_locations[t.name]=t.start_location
end

item{
 name="stick",
 start_location="field",
 description="it's sticky."
}
