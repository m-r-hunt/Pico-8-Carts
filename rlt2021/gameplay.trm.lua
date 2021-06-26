

Entity=Class{
	construct=function(self,x,y,sprite,name,blocks)
		self.x=x
		self.y=y
		self.sprite=sprite
		self.name=name
		self.blocks=blocks
	end,

	move=function(self,dx,dy)
		self.x=dx
		self.y=dy
	end,

	draw=function(self)
		spr(self.sprite,self.x*8,self.y*8)
	end
}

local player=Entity(8,8,1,"player",true)
entities={player}

local function getBlockingEntitiesAt(dx,dy)
	for e in all(entities) do
		if e.blocks and e.x==dx and e.y==dy then
			return e
		end
	end
end
