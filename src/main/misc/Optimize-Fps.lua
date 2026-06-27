-- // src/main/misc/Optimize-Fps.lua
-- // Remastered FPS Booster for Moonveil-HUB

return function(Moonveil)
    local MainTab = Moonveil.CreatedTabs.Main
    -- Kita cari Page "Misc" yang udah ada di main.lua lu
    local MiscPage = nil
    for _, page in ipairs(MainTab.Pages) do
        if page.Btn.Text == "Misc" then
            MiscPage = page
            break
        end
    end

    if not MiscPage then return end

    local FpsSection = MiscPage:CreateSection("Graphics Optimizer")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    local optimizationEnabled = false

    -- Fungsi utama buat "ngelukis" map jadi burik
    local function setPotatoGraphics(state)
        optimizationEnabled = state
        
        if state then
            -- 1. Matikan Efek Lighting
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 2
            
            -- Hapus efek berat di Lighting
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("PostEffect") or child:IsA("SunRaysEffect") or child:IsA("BloomEffect") or child:IsA("BlurEffect") then
                    child.Enabled = false
                end
            end

            -- 2. Optimasi Terrain & Rumput
            if Terrain then
                Terrain.Decoration = false
                Terrain.WaterWaveSize = 0
            end

            -- 3. Loop Scan Workspace buat matiin detail
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                elseif obj:IsA("MeshPart") then
                    obj.TextureID = ""
                end
            end
            
            Moonveil.Notify({Title = "FPS Boost", Description = "Graphics set to Potato Mode!", Duration = 3})
        else
            Moonveil.Notify({Title = "FPS Boost", Description = "Please rejoin game to restore original graphics.", Duration = 3})
        end
    end

    -- Toggle di UI
    FpsSection:AddToggle("Potato Graphics", false, function(state)
        setPotatoGraphics(state)
    end, {
        Title = "Potato Graphics",
        Description = "Change all textures to plain and remove shadows to drastically increase FPS."
    })
end