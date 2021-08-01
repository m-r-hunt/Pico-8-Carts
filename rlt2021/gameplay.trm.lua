





local animation_time=6

function getBlockingEntitiesAt(dx)
	for e in all(entities) do
		if e.blocks and e.pos==dx then
			return e
		end
	end
end

Fighter=Class{
	construct=function(self,hp,defence,power,xp)
		self.max_hp=hp
		self.hp=hp
		self.defence=defence
		self.power=power
		self.xp=xp
	end,

	takeDamage=function(self,amount)
		self.hp-=amount
		if self.hp<0 and self.owner!=player then
			self.owner.sprite+=16
			self.owner.blocks=false
			self.owner.name="Remains of "..self.owner.name
			self.owner.fighter=nil
			self.owner.ai=nil
			self.owner.z=1

			return self.xp
		end
		return 0
	end,

	heal=function(self,amount)
		self.hp=min(self.hp+amount,self.max_hp)
	end,

	attack=function(self,target)
		local damage=self.power-target.fighter.defence
		local xp=target.fighter:takeDamage(damage)
		addNumber(damage,8,target.pos*8+V2(2,0),V2(0,-1),120)

		local init=self.owner.pos
		local dx=target.pos
		local t=0
		while t<animation_time/2 do
			yield()
			if btnp()!=0 then
				break
			end
			t+=1
			self.owner.pos=init+(dx-init)*(t/animation_time)
		end
		while t>=0 do
			yield()
			if btnp()!=0 then
				break
			end
			t-=1
			self.owner.pos=init+(dx-init)*(t/animation_time)
		end
		self.owner.pos=init
		return xp
	end
}

BasicMonster=Class{
	takeTurn=function(self)
		if fov_map:get(self.owner.pos) then
			if self.owner:distanceTo(player)>1 then
				self.owner:moveTowards(player.pos)
			elseif player.fighter.hp>0 then
				self.owner.fighter:attack(player)
			end
		end
	end
}

function pickupItem(item)
	if held_item then
		held_item.pos=item.pos
		add(entities,held_item)
	end
	held_item=item
	del(entities,item)
end

function useItem()
	if held_item then
		local consumed=held_item.item:use_function()
		if consumed then
			held_item=nil
		end
	end
end

Item=Class{
	construct=function(self,use_function)
		self.use_function=use_function
	end
}

local function blocks(pos)
	return GameMap:isBlocked(pos)
end

Stairs=Class{
	construct=function(self,floor)
		self.floor=floor
	end
}

Entity=Class{
	construct=function(self,pos,sprite,name,blocks,fighter,ai,item,stairs)
		self.pos=pos
		self.sprite=sprite
		self.name=name
		self.blocks=blocks
		self.fighter=fighter
		self.ai=ai
		self.item=item
		self.stairs=stairs
		self.z=3

		if self.fighter then
			self.fighter.owner=self
		end
		if self.ai then
			self.ai.owner=self
		end
		if self.stairs then
			self.stairs.owner=self
		end
	end,

	move=function(self,dx)
		local init=self.pos
		local t=0
		while t<animation_time do
			yield()
			if btnp()!=0 then
				break
			end
			t+=1
			self.pos=init+(dx-init)*(t/animation_time)
		end
		self.pos=dx
	end,

	moveTowards=function(self,tpos,entities)
		local path=pathfind(self.pos,tpos,blocks)
		if path and #path>=3 and not getBlockingEntitiesAt(path[2]) then
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
