

local Entity=Class{
	construct=function(self,x,y,sprite)
		self.x=x
		self.y=y
		self.sprite=sprite
	end,

	move=function(self,dx,dy)
		self.x+=dx
		self.y+=dy
	end,

	draw=function(self)
		spr(self.sprite,self.x*8,self.y*8)
	end
}

local player=Entity(8,8,1)
local npc=Entity(6,8,2)
local entities={npc,player}