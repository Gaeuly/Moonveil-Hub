-- // src/setting/config.lua
-- // Logic untuk mengatur UI Config dan Saving

return function(SettingsTab)
    -- Create "Configurations" page untuk menyusun config
    local S_Page1 = SettingsTab:CreatePage("Configurations")
    
    local SavesCard = S_Page1:CreateSection("Config Manager")
    SavesCard:AddConfigManager("Moonveil-HUB")
end