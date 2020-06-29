
function slime_update(sl)
	if not sl.timer or sl.timer<0 then
		sl.dx=0.1*rnd{vec2(1,0),vec2(-1,0),vec2(0,1),vec2(0,-1)}
		sl.timer=rnd(30)+15
	end
	sl.timer-=1
end

function charger_update(ch)
	local dv=pl.pos-ch.pos
	ch.dx=0.1/#dv*dv
end

actor_spawners={
	[96] = function(x,y)
		local e=make_actor(96,x,y)
		e.update=slime_update
		e.friction=0
	end,
	[100] = function(x,y)
		local e=make_actor(100,x,y)
		e.update=charger_update
	end,
	[104] = function(x,y)
		local e=make_actor(104,x,y)
		e.update=function() end
	end,
}
