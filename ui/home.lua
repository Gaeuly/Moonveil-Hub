-- // ui/home.lua
-- // Mengatur isi dari tab Main dan Premium

return function(MainTab, PremiumTab, Window, Library)

    -- ========================================== --
    -- // MAIN TAB
    -- ========================================== --
    local M_Page1 = MainTab:CreatePage("Page 1")
    local M_Page2 = MainTab:CreatePage("Page 2")

    -- Page 1: Combat
    local CombatCard = M_Page1:CreateSection("Combat")
    CombatCard:AddToggle("Aimbot", false, function(state) print("Aimbot:", state) end, {
        Title = "Aimbot Module",
        Description = "Automatically aims your weapon at the nearest valid enemy target to ensure high accuracy.",
        Example = "Enable this in competitive modes to secure consistent hits."
    })
    CombatCard:AddDropdown("Target Part", {"Head", "Torso", "Left Arm", "Right Arm", "Legs", "HumanoidRootPart"}, false, function(selected) print("Target:", selected) end, {
        Title = "Target Body Part",
        Description = "Select which specific part of the opponent's body the aimbot will lock onto."
    })

    -- Page 1: Movement
    local MovementCard = M_Page1:CreateSection("Movement")
    MovementCard:AddSlider("Walk Speed", 16, 150, 16, function(val) print("Speed:", val) end, {
        Title = "Walk Speed Adjustment",
        Description = "Modifies your character's base movement speed. Extremely high values might trigger server anti-cheat kicks."
    })
    MovementCard:AddButton("Teleport to Spawn", function() print("Teleported") end)

    -- Page 1: Visuals
    local VisualsCard = M_Page1:CreateSection("Visuals")
    VisualsCard:AddDropdown("ESP Filters", {"Players", "NPCs", "Items", "Vehicles", "Chests", "Ammunition", "Objectives", "Explosives", "Traps"}, true, function(selected) print("ESP:", unpack(selected)) end, {
        Title = "ESP Filtering Engine",
        Description = "Multi-select categories to highlight through walls. Use the real-time search bar to quickly find filters in large lists."
    })
    VisualsCard:AddColorPicker("ESP Color", Color3.fromRGB(255, 0, 0), function(color) print("Color:", color) end, {
        Title = "Master ESP Color",
        Description = "Define the global highlight color for all enabled ESP visuals."
    })

    -- Page 1: Miscellaneous
    local MiscCard = M_Page1:CreateSection("Miscellaneous")
    MiscCard:AddTextbox("Discord Webhook", "Enter link...", function(text) print("Webhook:", text) end, {
        Title = "Log Webhook",
        Description = "Input a Discord Webhook URL to automatically forward in-game logs and kill-feed data to your private server."
    })

    -- Page 2: Utilities
    local UtilitiesCard = M_Page2:CreateSection("Utilities")
    UtilitiesCard:AddCopyButton("Copy Example Word", "Example", {
        Title = "Copy To Clipboard",
        Description = "A built-in utility allowing you to quickly port specific string configurations locally to your machine.",
        Example = "Clicking this will natively push 'Example' to your OS Clipboard."
    })

    -- Page 2: UI Customization
    local UICustomCard = M_Page2:CreateSection("UI Customization")
    UICustomCard:AddColorPicker("Hub Title Color", Color3.fromRGB(255, 255, 255), function(color) Window.Title.TextColor3 = color end, {
        Title = "Dynamic Interface Theming",
        Description = "Drag the color wheel to alter the accent colors of your GUI in real-time."
    })

    -- Page 2: Notification Tests
    local NotifCard = M_Page2:CreateSection("Notifications Tests")
    NotifCard:AddToggle("Toggle Notification", false, function(state)
        if state then
            Library:Notify({
                Title = "Toggle Fired",
                Description = "You've summoned a custom notification via toggle.",
                Duration = 3
            })
        end
    end)
    NotifCard:AddButton("Button Notification", function()
        Library:Notify({
            Title = "Action Executed",
            Description = "Notification created perfectly on click.",
            Duration = 3
        })
    end)

    -- ========================================== --
    -- // PREMIUM TAB
    -- ========================================== --
    local P_Page1 = PremiumTab:CreatePage("Premium Tools")

    local ProCard = P_Page1:CreateSection("Pro Capabilities")
    ProCard:AddToggle("Premium Override", false, function(state) print("Override:", state) end, {
        Title = "Premium Override",
        Description = "An exclusive toggle switch lever for unlocking premium modules.",
        Example = "Activate to bypass security checks and unlock additional execution tools."
    })
    ProCard:AddButton("Execute Example Script", function() print("Executing Script...") end, {
        Title = "Execute Script",
        Description = "A working example button that runs privileged developer code."
    })
end