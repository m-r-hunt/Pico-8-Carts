pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
function p(plt)
	for src,dest in pairs(plt) do
		pal(src,dest,1)
	end
end

overworld={
	131,
	128,
	3,
	4,
	132,
	140,
	15,
	8,
	9,
	10,
	11,
	12,
	139,
	142,
	143,
}

function overworld_palette()
	p(overworld)
end

underworld={
	128,
	130,
	2,
	133,
	5,
	134,
	14,
	15,
	9,
	10,
	135,
	129,
	1,
	140,
	3,
}

function underworld_palette()
	p(underworld)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
