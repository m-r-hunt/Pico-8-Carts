pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
#include mj73.lua

__gfx__
00000000001122330000000000033000003333000033330000333300003333000000000000000000000000000000000000000000000000000000000000000000
00000000001122330000000000322300032112300321123003211230032112300000000000000000000000000000000000000000000000000000000000000000
00700700445566771111111100312300322222233222222332222223322222230000000000000000000000000000000000000000000000000000000000000000
00077000445566771111111103111130312244233122442331224423312244230000000000000000000000000000000000000000000000000000000000000000
000770008899aabb2222222232333323312224233122242331222423312224230000000000000000000000000000000000000000000000000000000000000000
007007008899aabb2222222232222223311222233112222331122223311222230000000000000000000000000000000000000000000000000000000000000000
00000000ccddeeff3333333332224223031112300311123003111230031112300000000000000000000000000000000000000000000000000000000000000000
00000000ccddeeff4444444432224223003333000033330000333300003333000000000000000000000000000000000000000000000000000000000000000000
03333333333333333333333031244223031442300314423003144230031442300000000000000000000000000000000000000000000000000000000000000000
30000000000000000000000331244223032442300324423003244230032442300000000000000000000000000000000000000000000000000000000000000000
30033330000000000000000331244223312222233122222331222223312222230000000000000000000000000000000000000000000000000000000000000000
30333300000000000000000331242213312222233122222331222223312222230000000000000000000000000000000000000000000000000000000000000000
30300000000000000000030331242213312331233123312331233123312331230000000000000000000000000000000000000000000000000000000000000000
30000000000000000000330331222113312331233123312331233123312331230000000000000000000000000000000000000000000000000000000000000000
30000000000000000000000332221113311331133113333031133113033031130000000000000000000000000000000000000000000000000000000000000000
03333333333333333333333003333330033003300330000003300330000003300000000000000000000000000000000000000000000000000000000000000000
03333333333333300333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31121111111111133112111111111113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31221111111111133122114444444113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31121111111111133112114444444113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31222111111111133122211141411113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111133111111141411113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111414111133111111141411113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111414111133111111141411113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111414111133111111141411113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111414111133111111141411113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31121111414111133112111111111113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31212111414111133121211111111113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31212144444441133121211111111113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31212144444441133121211111111113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31121111111111133112111111111113000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34411111111114433441111111111443000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333333333333333333333011111111111111113343343303333333333333333333333000000000000000000000000000000000000000000000000000000000
32222222222222222222222311111111111111112242242230000000000000000000000300000000000000000000000000000000000000000000000000000000
32211111111111111111112311111111111111111141141130033330000000000000000300000000000000000000000000000000000000000000000000000000
32111111111111111111111311111111111111111141141130333300000000000000000300000000000000000000000000000000000000000000000000000000
32111111111111111111111311111111111111111141141130300000000000000000030300000000000000000000000000000000000000000000000000000000
31111111111111111111111311111111111111111424424130000000000000000000330300000000000000000000000000000000000000000000000000000000
311111111111111111111113111111112c1111111121121130000000000000000000000300000000000000000000000000000000000000000000000000000000
31111111111111111111111311111113311111111111111103333333333333333333333000000000000000000000000000000000000000000000000000000000
31111111111111111111111311111113311111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
311111111211112111111113111111c2111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111111311111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111111311111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111111311111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111111311111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111121111211111111311111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111111311111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111111300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111111300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111111300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111112300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111111111111111112300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32111111111111111111122300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
32222222222222222222222300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333333333333333333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssscsssscsscsssscsscsssscs00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssscsssscsscsssscsscsssscs00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssscsssscsscsssscsscsssscs00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssscsssscsscsssscsscsssscs00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007cssssssssssssssssssssssssssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000007cccccccccccccccccccccccccssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000777777777777777777777777sssssss00000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
000000000007cssc7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007cccccc700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007caaccs700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007cacccs700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007ccccss700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
000000000007csss7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000000077770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
000000000007caas7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
000000000007caac7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007cccccs700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007cccccs700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007cs77cs700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007cs77cs700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
00000000007ss77ss700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007sssssss00000000
0777777777777777777777777777777777a77a777777777777777777777777777777777777777770000000000777777777777770000000007sssssss00000000
7cccccccccccccccccccccccccccccccccaccaccccccccccccccccccccccccccccccccccccccccc7000000007sscsssssssssss7000000007sssssss00000000
7ccsssssssssssssssssssssssssssssssassassssssssssssssssssssssssssssssssssssssssc7000000007sccsssssssssss7000000007sssssss00000000
7cssssssssssssssssssssssssssssssssassasssssssssssssssssssssssssssssssssssssssss7000000007sscsssssssssss7000000007sssssss00000000
7cssssssssssssssssssssssssssssssssassasssssssssssssssssssssssssssssssssssssssss7000000007scccssssssssss7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssacaacassssssssssssssssssssssssssssssssssssssss7000000007ssssssssssssss7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssscsscsssssssssssssssssssssssssssssssssssssssss7000000007sssssssasassss7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss7000000007sssssssasassss7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss7000000007sssssssasassss7000000007sssssss00000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss7000000007sssssssasassss7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss7000000007sscssssasassss7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss7000000007scscsssasassss7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss7000000007scscsaaaaaaass7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss7000000007scscsaaaaaaass7000000007sssssss00000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss7000000007sscsssssssssss7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss7000000007aassssssssssaa7000000007sssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss7777777777777777777777777777777777sssssss00000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsssssssccccccccccccccccccccccccccccccccccssssssss00000000
7sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss00000000
7sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss00000000
7sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss00000000
7sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss00000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsssssssssssssssssssssssssssssssssssssssssssssssss00000000
7sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss00000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
7sssssssscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscsscsssscssssssss700000000
7ssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss700000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007aaaaaaaaaaaaa0000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007aa7777aaaaaaa0000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007a7777aaaaaaaa0000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007a7aaaaaaaaaaa0000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007aaaaaaaaaaaaa0000007707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007aaaaaaaaaaaaa0000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0000000000000000000000000000000000000004000000000000000000000000080800000000000000000000000000000808000000000000000000000000000001010101010300000000000000000000010101010100000000000000000000000101010000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000505151510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000505151510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000606161440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000030000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000130000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4041414145414141414200202100500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515200303100500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515341414141540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051515151515151515151515151520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000014550145501455014550145501455014550145501455015550155501455015550155501555015550135501555015550155501555014550145500000000000000000000000000000000000000000
000500002625023250202501e2501c2501a2501925016250142501325012250102500f2500e2500e2500d2500c2500c2500b2500b2500b2500b2500b250072500525004250032500225001250012500025000250
0106000016730187301b7301f7302473000700007002471016730187301b7301f7302473000700007002471016730187301b7301f7302473000700007002471016730187301b7301f73024730007000070024710
00080000271202712027120271201b1201b1201b1201b120271202712027120271201b1201b1201b1201b120271202712027120271201b1201b1201b1201b120271202712027120271201b1201b1201b1201b120
000b00000c7500c7500f7500f7500f75000000117501175013750137501675016750187501b7501b7501b7501d7501f750227502475027750297502e750307503375035750357503575035750357203571000000
