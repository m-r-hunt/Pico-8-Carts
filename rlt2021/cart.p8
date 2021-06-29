pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
#include core.trm.lua

-->8
#include map.trm.lua
-->8
#include gameplay.trm.lua
-->8
#include fov.trm.lua
-->8
#include flow.trm.lua
-->8
#include pathfind.trm.lua

-->8
#include state.trm.lua
-->8
#include particles.trm.lua
__gfx__
000000000007cc000044500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000c5c00004f450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000c15100000f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000078c11100122210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000c888ca100122210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000c8c11600012100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c8c51060011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c501000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000008b80ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0083800000bbb0ff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003330000b333b0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
015551063b355b3f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03555366bb554bff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
035556000b444bf00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00535000034433000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00505000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000080000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700007770006787600800000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077c77007c7c70077c7700700000000
000350000088b00800000000000000000000000000000000000000000000000000000000000000000000000000000000007c7c70077c77007c7c787778000000
008356808b55b3ff000000000000000000000000000000000000000000000000000000000000000000000000000000000077c77007c7c70077c7700700000000
0558856033443f8f0000000000000000000000000000000000000000000000000000000000000000000000000000000000077700007770000777000800000000
00494400000000000000000000000000000000000000000000000000000000000000000000000000770000000000000077000077000000007708807700000000
00644600000000000000000000000000000000000000000000000000000000000000000000000000677000000066650070000007077777007008880700000000
06222260000000000000000000000000000000000000000000000000000000000000000000000000067700006655556670777707000000007089990700000000
068e28600000000000000000000000000000000000000000000000000000000000000000000000000067699055555655700070070777770079a7aa9700000000
068e88600000000000000000000000000000000000000000000000000000000000000000000000000006995000665500700700070000000078aaaa8700000000
068e886000000000000000000000000000000000000000000000000000000000000000000000000000099500006655007077770707777700708aa80700000000
00688600000000000000000000000000000000000000000000000000000000000000000000000000000950500065550070000007000000007008800700000000
00066000000000000000000000000000000000000000000000000000000000000000000000000000000000050065560077000077077777007700007700000000
66666666555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
56555565555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55565555555655550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666555565550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555655555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55655555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
04040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
4040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040404040
