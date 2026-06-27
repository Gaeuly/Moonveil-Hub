-- // src/execute/Free-Gamepass.lua
-- // UI and Execution Logic for Free Gamepass

return function(Moonveil)
    -- Get the page container created in execute.lua
    local Page = Moonveil.ExecutePage
    if not Page then return end

    local GamepassSection = Page:CreateSection("Free Gamepass")

    -- Button to execute the script
    GamepassSection:AddButton("Execute Script", function()
        local success, err = pcall(function()
            -- Directly execute the original script from the developer's github
            loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/FreeGamepass/main/Script.luau"))()
        end)
        
        if success then
            Moonveil.Notify({Title = "Success", Description = "Free Gamepass Script executed!", Duration = 3})
        else
            Moonveil.Notify({Title = "Error", Description = "Failed to execute script.", Duration = 3})
        end
    end, {
        Title = "Free Gamepass Info",
        Description = "Click to execute the Free Gamepass script. It will run with its default configurations."
    })
end