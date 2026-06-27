-- // src/setting/transparency.lua
-- // Logic untuk mengatur UI Transparency Hub

return function(SettingsTab, Window)
    -- Memastikan menggunakan Page 1 dari tab settings (atau membuat page baru)
    local S_Page1 = SettingsTab:CreatePage("Appearance")
    
    local AppearanceCard = S_Page1:CreateSection("UI Config")
    AppearanceCard:AddToggle("Transparency Toggle", false, function(state) 
        Window:SetTransparency(state and 0.2 or 0) 
    end, {
        Title = "Glass Architecture",
        Description = "Overrides main window background for a sleek 0.2 transparency visual."
    })
end