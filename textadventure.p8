pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--core text engine

--engine constants
chars_per_line=32

devkit_addr=0x5f2d
pause_disable_addr=0x5f30

--engine state
input=""
history={}

function add_to_history(s)
 while #s>chars_per_line do
  for i=chars_per_line,0,-1 do
   if sub(s,i,i)==" " then
    add(history,sub(s,0,i))
    s=sub(s,i+1)
    break
   end
  end
 end
 add(history,s)
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
 for i=1,#tokens do
  o=o.."["..tokens[i].."] "
 end
 add_to_history(o)
end

function run_game(i)
 local tokens=tokenize(i)
 run_ta_command(tokens)
end

function _update()
 poke(pause_disable_addr,1)--disable pause so we can use enter
 while stat(30) do
  local c=stat(31)
  if c=="\b" then
   input=sub(input,0,#input-1)
  elseif c=="\r" or c=="\n" then
   add_to_history("> "..input)
   run_game(input)
   input=""
  else
   input=input..c
  end
 end
end

function _draw()
 cls()
 for i=0,#history-1 do
  print(history[#history-i],0,117-6*i,7)
 end
 print("> "..input,0,123,7)
end
-->8
--text adventure engine

--game state
current_room=""

function initialise_ta_engine()
 current_room=start_room
 show_room_description()
end

function show_room_description()
 add_to_history("== "..current_room.." ==")
 add_to_history(descriptions[current_room])
end

function match_token(t,expected)
 if sub(expected,0,1)=="$" then
  return token_matchers[sub(expected,2)](t)
 else
  return t==expected
 end
end

function match_command(tokens,c)
 for j=1,#c-1 do
  if not match_token(tokens[j],c[j]) then
   return false
  end
 end
 return true
end

function expand_aliases(tokens)
 expanded={}
 for i=1,#tokens do
  if aliases[tokens[i]]==nil then
   add(expanded,tokens[i])
  else
   for j=1,#aliases[tokens[i]] do
    add(expanded,aliases[tokens[i]][j])
   end
  end
 end
 return expanded
end

function run_ta_command(tokens)
 tokens=expand_aliases(tokens)

 command_done=false
 for i=1,#commands do
  if match_command(tokens,commands[i]) then
   commands[i][#commands[i]](tokens)
   command_done=true
   break
  end
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

token_matchers={
	direction=match_direction,
}

--command functions
function menu(tokens)
 extcmd("pause")
end

function go(tokens)
 current_room=exits[current_room][tokens[2]]
 add_to_history("you travel "..tokens[2].." to the "..current_room..".")
 show_room_description()
end

function look(tokens)
 show_room_description()
end

commands={
	{"menu",menu},
	{"look",look},
	{"go","$direction",go},
}

aliases={
	l={"look"},
	m={"menu"},
	x={"examine"},

	n={"go","north"},
	s={"go","south"},
	e={"go","east"},
	w={"go","west"},
}

--data tables for commands
descriptions={
 field="you're standing in a field outside a white house.",
 forest="shafts of light shine through the leaves.",
}

exits={
 field={north="forest"},
 forest={south="field"},
}
