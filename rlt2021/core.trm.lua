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
