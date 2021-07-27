

function xpToNextLevel()
	return level_up_base+current_level*level_up_factor
end

function addXp(xp)
	current_xp+=xp

	if current_xp>xpToNextLevel() then
		current_xp-=xpToNextLevel()
		current_level+=1

		return true
	else
		return false
	end
end
