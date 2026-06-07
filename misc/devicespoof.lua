local uis = game:GetService("UserInputService")
local gs = game:GetService("GuiService")
local mt = getrawmetatable(game)
local old = mt.__index
local tgt = "Default"

setreadonly(mt, false)
mt.__index = newcclosure(function(self, k)
    if not checkcaller() then
        if self == uis then
            if tgt == "PC" then
                if k == "KeyboardEnabled" then return true end
                if k == "TouchEnabled" then return false end
                if k == "GamepadEnabled" then return false end
            elseif tgt == "Mobile" then
                if k == "KeyboardEnabled" then return false end
                if k == "TouchEnabled" then return true end
                if k == "GamepadEnabled" then return false end
            elseif tgt == "Console" then
                if k == "KeyboardEnabled" then return false end
                if k == "TouchEnabled" then return false end
                if k == "GamepadEnabled" then return true end
            end
        elseif self == gs and tgt == "Console" then
            if k == "IsTenFootInterface" then return true end
        end
    end
    return old(self, k)
end)
setreadonly(mt, true)

return function(v)
    tgt = v
end