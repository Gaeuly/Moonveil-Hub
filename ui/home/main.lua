-- // ui/home/main.lua
-- // Populates the Main Tab

return function(Moonveil)
    local MainTab = Moonveil.CreatedTabs.Main
    if not MainTab then return end

    -- Create Pages for Main Tab
    local M_Page1 = MainTab:CreatePage("General")
    local M_Page2 = MainTab:CreatePage("Misc")

    -- NOTE: Empty for now.
    -- Later, you can add elements to M_Page1 like this:
    -- local TestSection = M_Page1:CreateSection("Auto Farm")
    -- TestSection:AddToggle("Enable Farm", false, function(state) print(state) end)
end