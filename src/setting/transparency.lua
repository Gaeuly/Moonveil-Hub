-- // src/setting/transparency.lua
-- // Logika Transparansi Hub

return function(Moonveil)
    local Tween = Moonveil.Tween

    -- System Transparency Logic
    function Moonveil:SetTransparency(val)
        Moonveil.CurrentTransparency = val
        if Moonveil.MainFrame.Visible then
            Tween(Moonveil.MainFrame, {BackgroundTransparency = val}, 0.3)
            Tween(Moonveil.FloatingBottomBar, {BackgroundTransparency = val > 0 and 0.2 or 0}, 0.3)
        end
    end

    -- Integrasi UI ke dalam Tab Settings
    local SettingsTab = Moonveil.CreatedTabs.Settings
    Moonveil.SettingsPage = SettingsTab:CreatePage("Settings")
    
    local AppearanceCard = Moonveil.SettingsPage:CreateSection("UI Config")
    AppearanceCard:AddToggle("Transparency Toggle", false, function(state) 
        Moonveil:SetTransparency(state and 0.2 or 0) 
    end, {
        Title = "Glass Architecture",
        Description = "Overrides main window background for a sleek 0.2 transparency visual."
    })
end