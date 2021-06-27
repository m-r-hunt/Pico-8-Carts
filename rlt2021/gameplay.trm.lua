




function getBlockingEntitiesAt(dx)
	for e in all(entities) do
		if e.blocks and e.pos==dx then
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
		if fov_map:get(self.owner.pos) then
			if self.owner:distanceTo(player)>1 then
				self.owner:moveTowards(player.pos)
			elseif player.fighter.hp>0 then
				message="The "..self.owner.name.." hits you."
			end
		end
	end
}

local function blocks(pos)
	return GameMap:isBlocked(pos)
end

Entity=Class{
	construct=function(self,pos,sprite,name,blocks,fighter,ai)
		self.pos=pos
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

	move=function(self,dx)
		local init=self.pos
		local t=0
		while t<7 do
			yield()
			if btnp()!=0 then
				break
			end
			t+=1
			self.pos=init+(dx-init)*(t/7)
		end
		self.pos=dx
	end,

	moveTowards=function(self,tpos,entities)
		local path=pathfind(self.pos,tpos,blocks)
		if path and #path>=3 and not getBlockingEntitiesAt(path[2]:unpack()) then
			self:move(path[2])
		end
	end,

	distanceTo=function(self,other)
		return #(other.pos-self.pos)
	end,

	draw=function(self)
		spr(self.sprite,(self.pos*8):unpack())
	end
}
