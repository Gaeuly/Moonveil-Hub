-- // src/execute/Free-Gamepass.lua
-- // UI dan Logika Eksekusi untuk Free Gamepass

return function(Moonveil)
    -- Ambil wadah halaman yang udah dibuat di execute.lua
    local Page = Moonveil.ExecutePage
    if not Page then return end

    local GamepassSection = Page:CreateSection("Free Gamepass")

    -- Setup Default Global Settings biar nggak error kalau belum ada yang di-klik
    getgenv().Settings = getgenv().Settings or {
        CopyButton = false,
        AutoButton = false,
        AutoInterval = 0.1,
        InstantPurchase = false,
        AutoMassPurchase = false,
        Debug = false,
    }

    -- Toggles untuk mengubah Settings secara real-time
    GamepassSection:AddToggle("Copy Button", false, function(state)
        getgenv().Settings.CopyButton = state
    end)

    GamepassSection:AddToggle("Auto Button", false, function(state)
        getgenv().Settings.AutoButton = state
    end)

    GamepassSection:AddToggle("Instant Purchase", false, function(state)
        getgenv().Settings.InstantPurchase = state
    end)

    GamepassSection:AddToggle("Auto Mass Purchase", false, function(state)
        getgenv().Settings.AutoMassPurchase = state
    end)
    
    GamepassSection:AddToggle("Debug Mode", false, function(state)
        getgenv().Settings.Debug = state
    end)

    -- Tombol untuk menjalankan script
    GamepassSection:AddButton("Execute Script", function()
        local success, err = pcall(function()
            -- Eksekusi langsung script aslinya dari github dev-nya
            loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/FreeGamepass/main/Script.luau"))()
        end)
        
        if success then
            Moonveil.Notify({Title = "Success", Description = "Free Gamepass Script executed!", Duration = 3})
        else
            Moonveil.Notify({Title = "Error", Description = "Failed to execute script.", Duration = 3})
        end
    end, {
        Title = "Free Gamepass Info",
        Description = "Jalankan script Free Gamepass. Lu bisa atur konfigurasinya dari toggle di atas sebelum eksekusi."
    })
end