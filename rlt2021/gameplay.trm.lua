




entities={}

function getBlockingEntitiesAt(dx,dy)
	for e in all(entities) do
		if e.blocks and e.x==dx and e.y==dy then
			return e
		end
	end
end

Fighter=Class{
	construct=function(self,hp,defence,power)
		self.max_hp=hp
		self.hp=hp
		self.defence=defence
		self.power=power
	end
}

BasicMonster=Class{
	takeTurn=function(self)
		if fov_map:contains(self.owner.x,self.owner.y) then
			if self.owner:distanceTo(player)>1 then
				self.owner:moveTowards(player.x,player.y)
			elseif player.fighter.hp>0 then
				message="The "..self.owner.name.." hits you."
			end
		end
	end
}

local function blocks(x,y)
	return GameMap:isBlocked(x,y)
end

Entity=Class{
	construct=function(self,x,y,sprite,name,blocks,fighter,ai)
		self.x=x
		self.y=y
		self.sprite=sprite
		self.name=name
		self.blocks=blocks
		self.fighter=fighter
		self.ai=ai

		if self.fighter then
			self.fighter.owner=self
		end
		if self.ai then
			self.ai.owner=self
		end
	end,

	move=function(self,dx,dy)
		self.x=dx
		self.y=dy
	end,

	moveTowards=function(self,tx,ty,entities)
		local path=pathfind(self.x,self.y,tx,ty,blocks)
		if path and #path>=3 and not getBlockingEntitiesAt(unpack(path[2])) then
			self:move(unpack(path[2]))
		end
	end,

	distanceTo=function(self,other)
		local dx=other.x-self.x
		local dy=other.y-self.y
		return sqrt(dx^2+dy^2)
	end,

	draw=function(self)
		spr(self.sprite,self.x*8,self.y*8)
	end
}
