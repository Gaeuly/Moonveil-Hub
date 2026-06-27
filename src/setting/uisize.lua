-- // src/setting/uisize.lua
-- // Resizer System for Desktop / Mobile / Small

return function(Moonveil)
    -- We can get MainFrame directly from the Moonveil global table
    local MainFrame = Moonveil.MainFrame

    local UI_Sizes = {
        ["PC"] = {Size = UDim2.new(0, 550, 0, 400), Pos = UDim2.new(0.5, -275, 0.5, -200)},
        ["Mobile"] = {Size = UDim2.new(0, 400, 0, 300), Pos = UDim2.new(0.5, -200, 0.5, -150)},
        ["Small"] = {Size = UDim2.new(0, 300, 0, 220), Pos = UDim2.new(0.5, -150, 0.5, -110)}
    }

    function Moonveil:SetUISize(mode)
        local target = UI_Sizes[mode]
        if target then
            Moonveil.Tween(MainFrame, {Size = target.Size, Position = target.Pos}, 0.4)
        end
    end
end