---------------------------------------
------TOGGLE TV AS A THIRD SCREEN------
---------------------------------------

local tv_monitor = "DVI-D-1"

local function toggle_tv_layout()
    if hl.get_monitor(tv_monitor) ~= nil then
       hl.monitor({ output = tv_monitor, disabled = true})
    else
       hl.monitor({ output = tv_monitor, disabled = false})
    end
end

return {
    toggle_tv = toggle_tv_layout,
}

