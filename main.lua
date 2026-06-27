-- // Moonveil-HUB Main Bootstrapper
-- // Made by gaeuly

local RepoURL = "https://raw.githubusercontent.com/Gaeuly/Moonveil-HUB/main/"

-- // 1. Load the Core UI Engine
local Library = loadstring(game:HttpGetAsync(RepoURL .. "ui.lua"))()

-- // 2. Set Whitelisted Users for Paid Access
Library.WhitelistedUsers = {
    "Username",
    "Username1",
    "Username2",
    "Username3",
    "Username4"
}

-- // 3. Create Main Window
local Window = Library:CreateWindow({
    Title = "Moonveil-HUB",
    Subtitle = "Made by gaeuly",
    SubtitleColor = Color3.fromRGB(190, 140, 255),
    Logo = "rbxassetid://134665675914525",
    LogoSize = 32,
    
    SphereText = false,
    SphereWords = "Moonveil-HUB",
    SphereImage = "rbxassetid://134665675914525",
    SphereIconSize = 38
})

-- // 4. Secure Module Loader (Loads pieces from GitHub securely)
local function LoadModule(path, ...)
    local url = RepoURL .. path
    local success, result = pcall(function()
        return loadstring(game:HttpGetAsync(url))()
    end)
    
    if success and type(result) == "function" then
        return result(...) -- Execute the module and pass dependencies (Window, Tabs, dll)
    elseif success then
        return result
    else
        warn("Moonveil-HUB | Gagal memuat module: " .. path .. " | Error: " .. tostring(result))
    end
end

-- // 5. Initialize the Hub Structure

-- Load Sidebar (Returns generated tabs)
local Tabs = LoadModule("ui/sidebar.lua", Window)

if Tabs then
    -- Load Main & Premium UI
    LoadModule("ui/home.lua", Tabs.MainTab, Tabs.PremiumTab, Window, Library)
    
    -- Load Settings Components
    LoadModule("src/setting/transparency.lua", Tabs.SettingsTab, Window)
    LoadModule("src/setting/config.lua", Tabs.SettingsTab)
end

-- Folder src/main/ bisa lu pakai nanti buat logic gameplay/script aslinya.