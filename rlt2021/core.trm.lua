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
		return V2(self[1]+other[1],self[2]+other[2])
	end,
	__sub=function(self,other)
		return V2(self[1]-other[1],self[2]-other[2])
	end,
	__mul=function(self,s)
		return V2(s*self[1],s*self[2])
	end,
	_unm=function(self)
		return V2(-self[1],-self[2])
	end,
	__len=function(self)
		return sqrt(self[1]^2+self[2]^2)
	end,
	__eq=function(self,other)
		return self[1]==other[1] and self[2]==other[2]
	end
}
local function makeV2(t,x,y)
	return setmetatable({x,y},t)
end
setmetatable(V2,{__call=makeV2})

Grid=Class{
	construct=function(self)
		self.set={}
	end,

	add=function(self,pos,val)
		local x=pos[1]
		self.set[x]=self.set[x] or {}
		self.set[x][pos[2]]=val
	end,

	get=function(self,pos)
		return self.set[pos[1]] and self.set[pos[1]][pos[2]]
	end,

	unionWith=function(self,other)
		for x,row in pairs(other.set) do
			for y,v in pairs(row) do
				self:add({x,y},v)
			end
		end
	end
}
