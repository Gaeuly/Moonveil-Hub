-- // ui/sidebar.lua
-- // Mengatur pembuatan Tab / Sidebar untuk Hub

return function(Window)
    -- Create the main tabs
    local MainTab = Window:CreateTab("Main", true, false)
    local SettingsTab = Window:CreateTab("Settings", false, false)
    local PremiumTab = Window:CreateTab("Pro Configs", false, true)

    -- Return as a table so the bootstrapper can pass them to other modules
    return {
        MainTab = MainTab,
        SettingsTab = SettingsTab,
        PremiumTab = PremiumTab
    }
end