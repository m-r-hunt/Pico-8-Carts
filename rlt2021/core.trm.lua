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
