
function instance(scene)
    local newn = scene[1]:new()
    for name,value in pairs(scene) do
        if type(name)!="number" then
            newn[name]=value
        end
    end
    for i=2,#scene do
        newn:add_child(instance(scene[i]))
    end
    return newn
end

function scene(t)
    t.instance=instance
    return t
end

player_scene=scene{
    faller,
    {sprite,s=33},
    {camerafollow},
    position=vec2(72*8,60*8),
}

enemy_scene=scene{
    kinematicbody,
    {sprite,s=6}
}

hook_powerup_scene=scene{
    powerup,
    {sprite,s=20},
    {remove_if_offscreen},
}

tile_spawn_scenes={
    [5]=enemy_scene,
    [20]=hook_powerup_scene,
}

root:add_child(player_scene:instance())
