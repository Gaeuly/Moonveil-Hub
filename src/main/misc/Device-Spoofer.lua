-- // src/main/misc/Device-Spoofer.lua
-- // Device Spoofer for Moonveil-HUB (Tricks game into thinking you're on a different platform)

return function(Moonveil)
    local MainTab = Moonveil.CreatedTabs.Main
    
    -- Mencari page "Misc"
    local MiscPage = nil
    for _, page in ipairs(MainTab.Pages) do
        if page.Btn.Text == "Misc" then
            MiscPage = page
            break
        end
    end

    if not MiscPage then return end

    local SpooferSection = MiscPage:CreateSection("Device Spoofer")

    -- Variables
    local selectedDevice = "PC"
    local spoofingEnabled = false
    local oldIndex = nil

    -- Hooking fungsi inti Roblox menggunakan Metamethods
    -- Peringatan: Membutuhkan executor yang mendukung hookmetamethod (sebagian besar executor support ini)
    if hookmetamethod then
        oldIndex = hookmetamethod(game, "__index", function(self, key)
            if spoofingEnabled and not checkcaller() then
                -- Memanipulasi UserInputService
                if self == game:GetService("UserInputService") then
                    if selectedDevice == "PC" then
                        if key == "KeyboardEnabled" or key == "MouseEnabled" then return true end
                        if key == "TouchEnabled" or key == "GamepadEnabled" then return false end
                    elseif selectedDevice == "Mobile" then
                        if key == "TouchEnabled" then return true end
                        if key == "KeyboardEnabled" or key == "MouseEnabled" or key == "GamepadEnabled" then return false end
                    elseif selectedDevice == "Console" then
                        if key == "GamepadEnabled" then return true end
                        if key == "KeyboardEnabled" or key == "MouseEnabled" or key == "TouchEnabled" then return false end
                    elseif selectedDevice == "VR" then
                        if key == "VREnabled" then return true end
                    end
                -- Memanipulasi GuiService (Biasanya buat deteksi Console/Xbox)
                elseif self == game:GetService("GuiService") then
                    if selectedDevice == "Console" and key == "IsTenFootInterface" then
                        return true
                    end
                end
            end
            return oldIndex(self, key)
        end)
    else
        Moonveil.Notify({
            Title = "Unsupported",
            Description = "Executor lu nggak support hookmetamethod. Device Spoofer nggak bisa jalan.",
            Duration = 5
        })
    end

    -- UI Elements
    SpooferSection:AddDropdown("Target Device", {"PC", "Mobile", "Console", "VR"}, false, function(value)
        selectedDevice = value
        if spoofingEnabled then
            Moonveil.Notify({
                Title = "Device Spoofer", 
                Description = "Device spoofed to " .. value .. ". (Rejoin/Reset character mungkin diperlukan di beberapa game)", 
                Duration = 3
            })
        end
    end, {
        Title = "Select Device",
        Description = "Pilih platform yang mau ditampilin ke game (dan ke player lain)."
    })

    SpooferSection:AddToggle("Enable Spoofer", false, function(state)
        spoofingEnabled = state
        if state then
            Moonveil.Notify({
                Title = "Spoofer Active", 
                Description = "Lu sekarang kedetect sebagai player " .. selectedDevice .. "!", 
                Duration = 3
            })
        else
            Moonveil.Notify({
                Title = "Spoofer Disabled", 
                Description = "Device lu kembali normal.", 
                Duration = 3
            })
        end
    end, {
        Title = "Toggle Spoofer",
        Description = "Membajak deteksi sistem game. Karena ini memanipulasi deteksi lokal, player lain juga bakal ngeliat lu pakai device palsu ini."
    })
end