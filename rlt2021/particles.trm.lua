local number_particles={}

function tickParticles()
	foreach(number_particles,function(p)
		p.lifetime-=1
		p.pos+=p.dx
	end)
	local i=1
	while i<=#number_particles do
		if number_particles[i].lifetime<=0 then
			deli(number_particles,i)
		else
			i+=1
		end
	end
end

function drawParticles()
	foreach(number_particles,function(p)
		print(p.n,p.pos.x,p.pos.y,p.c)
	end)
end

function addNumber(n,c,pos,dx,lifetime)
	add(number_particles,{n=n,c=c,pos=pos,dx=dx,lifetime=lifetime})
end
