-- // ui/home/setting.lua
-- // Populates the Settings Tab

return function(Moonveil)
    local SettingsTab = Moonveil.CreatedTabs.Settings
    if not SettingsTab then return end

    -- Changed page name to "UI Config" to prevent "Settings Settings" duplication
    local S_Page1 = SettingsTab:CreatePage("UI Config")
    local DisplayCard = S_Page1:CreateSection("Display Settings")

    DisplayCard:AddDropdown("UI Size", {"PC", "Mobile", "Small"}, false, function(value)
        if Moonveil.SetUISize then
            Moonveil:SetUISize(value)
        end
    end, {
        Title = "UI Scaler",
        Description = "Select the UI size to fit your screen."
    })
    
    -- You can add more Settings sections here later
end