pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
input=""

history={}

function add_to_history(s)
 add(history,s)
end

function _init()
 poke(0x5f2d,1)--enable keyboard
end

function tokenize(i)
 local t={}
 local buf=""
 while #i~=0 do
  local next_c=sub(i,0,1)
  if next_c==" " then
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

function run_game(i)
 local tokens=tokenize(i)
 o=""
 for i=1,#tokens do
  o=o.."["..tokens[i].."] "
 end
 add_to_history(o)
end

function _update()
 poke(0x5f30,1)--disable pause so we can use enter
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
