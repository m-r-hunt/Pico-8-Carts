pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
#include palettes.p8

pal(overworld,1)
keep_pal()

function _draw()
	cls()
	for i=0,15 do
		rectfill(0,i*8,16,(i+1)*8,i)
	end
end

__gfx__
00000000000bdb001111cccc0000800000022200022222200000000003d33d3000000000000000000000000009a1cccc1111cccc1111ca9009a1cccc1111ca90
0000000000bbbbb0ccccc611000880000027772024444442000000003b3bb3b300009999999999999999000009acc611ccccc611ccccca9009acc611ccccca90
007007000dddbbdd6616cc61000888000277ff7224774742000030003d3bd3d30009aaaaaaaaaaaaaaaa900009a6cc616616cc616616ca9009a6cc616616ca90
00077000031dddd311116cc100888800277ffff22447744200030300333bd333009a6cc111116cc11111a90009a16cc111116cc111116a9009a16cc111116a90
00077000003111301cccccc10889988027ffffe224444442000000003bd33bb309acccc11cccccc11cccca90009accc11cccccc11ccca90009acccc11cccca90
0070070000055400cc1c66cc089f798027ffffe20225522000300000b33bdd3b09ac66cccc1c66cccc1c6a900009aaaaaaaaaaaaaaaa900009ac66cccc1c6a90
000000000005f400c66cc16c089779802ffeee2000254200030300003bd3d3d309acc16cc66cc16cc66cca9000009999999999999999000009acc16cc66cca90
000000000005f4006611c16600899800022222000025420000000000033d3d3009a1c1666611c1666611ca9000000000000000000000000009a1c1666611ca90
000000000005f40000bbbb0000707777777707000000000077777777777777777777777700707777777707000000000000000000007077777777070000000000
0000000000f444f00bbddbb000707777777707000000000077777777777777777777777700707777777707000000000000000000007077777777070000000000
000000000f40004fbbbbbbbb00707777777707007777777777777777777777777777777777707777777707770077777777777700007077777777070000000000
00000000000000003dbbbbd300707777777707000000000077777777777777777777777700007777777700000070000000000700007077777777070000000000
00000000000000003dddddd300707777777707007777777700000000000077777777000077777777777777770070777777770700007000000000070000000000
000000000000000033dddd3300707777777707007777777777777777777077777777077777777777777777770070777777770700007777777777770000000000
00000000000000001333333100707777777707007777777700000000007077777777070077777777777777770070777777770700000000000000000000000000
00000000000000000113311000707777777707007777777700000000007077777777070077777777777777770070777777770700000000000000000000000000
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
00022200000222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00267620002676200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02767672027676720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02777772027777720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02ddddd202ddddd20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02dd2dd202dd2dd20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02dd222000222dd20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00220000000002200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000024499aa7
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288eeff7
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000288eeff7
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021166cc7
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021166cc7
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000233ddbb7
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000233ddbb7
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000025544ff7
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
00000000111111112222222233333333444444445555555566666666777777778888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021000000000000000000000000000021
21212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000021212121212121212121212121212121
21212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121
21212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21000000000000000000000000000021210000000000000000000000000000212100000000000000000000000000002121000000000000000000000000000021
21212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121
21212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121
__gff__
0055020002020000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
1200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000000000000000000000000000012120008090909090909090909090a0012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
1200000006000600000404040000001212000e020202020202020202020f0012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
1200000600060000000000000000001212000e020202020202020202020f0012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
1200000000000000000005000000001212000b0c0c0c0c0c0c0c0c0c0c0d0012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
1200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
120000000000001b151515151515151515151515151515151515151515151515150000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
1200000000000013181616161616161616161616161616161616161616161616160000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
120008090a000013140007070707001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000e020f000013140007070707001212000006000000060600000006000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
12000b0c0d000013140007070707001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012120000000000000000000000000000121200000000000000000000000000001212000000000000000000000000000012
1212121212121213141212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212121212
1212121212121213141212121212121212121212121212121212121212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012121212121212121212121212121212
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
12000000000000131a1515151515151500000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013181616161616161600000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1200000000000013140000000000001212000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
1212121212121213141212121212121212121212121212121212121212121212000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012121212121212121212121212121212
1212121212121213141212121212121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012121212121212121212121212121212
1200000000000000000000000000001200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000012
