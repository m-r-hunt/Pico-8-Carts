local function new(class,...)
	local n=setmetatable({},{__index=class})
	if class.construct then
		n:construct(...)
	end
	return n
end
function Class(table)
	return setmetatable(table,{__call=new})
end


V2={
	__add=function(self,other)
		return V2(self.x+other.x,self.y+other.y)
	end,
	__sub=function(self,other)
		return V2(self.x-other.x,self.y-other.y)
	end,
	__mul=function(self,s)
		return V2(s*self.x,s*self.y)
	end,
	_unm=function(self)
		return V2(-self.x,-self.y)
	end,
	__len=function(self)
		return sqrt(self.x^2+self.y^2)
	end,
	__eq=function(self,other)
		return self.x==other.x and self.y==other.y
	end,
	unpack=function(self)
		return self.x,self.y
	end
}
V2.__index=V2
local function makeV2(t,x,y)
	return setmetatable({x=x,y=y},t)
end
setmetatable(V2,{__call=makeV2})

Grid=Class{
	construct=function(self)
		self.set={}
	end,

	add=function(self,pos,val)
		self.set[pos.x]=self.set[pos.x] or {}
		self.set[pos.x][pos.y]=val
	end,

	get=function(self,pos)
		return self.set[pos.x] and self.set[pos.x][pos.y]
	end,

	unionWith=function(self,other)
		for x,row in pairs(other.set) do
			for y,v in pairs(row) do
				self:add(V2(x,y),v)
			end
		end
	end
}
