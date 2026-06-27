-- // src/execute/Fake-Purchase.lua
-- // Remastered Fake Purchase Logic integrated into Moonveil-HUB

return function(Moonveil)
    local Page = Moonveil.ExecutePage
    if not Page then return end

    -- Create a new section in the Execute Page
    local PurchaseSection = Page:CreateSection("Fake Purchase (Ultra Fast)")

    local MarketplaceService = game:GetService("MarketplaceService")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Local states for the script
    local ugcId = ""
    local loopDelay = 0.001
    local isLooping = false

    -- Caching system (to avoid rate limits when spamming)
    local lastId = nil
    local cachedName = "Unknown"
    local cachedPrice = "-"
    local lastNotifTime = 0

    -- Textbox for ID input
    PurchaseSection:AddTextbox("UGC Asset ID", "Enter UGC ID...", function(value)
        ugcId = value
    end, {
        Title = "Asset ID",
        Description = "Enter the numeric ID of the UGC item you want to fake purchase."
    })

    -- Textbox for Delay input
    PurchaseSection:AddTextbox("Loop Delay (Sec)", "0.001", function(value)
        loopDelay = tonumber(value) or 0.001
    end, {
        Title = "Delay Speed",
        Description = "Minimum is 0.001 for ultra-fast looping."
    })

    -- Core function to trigger fake purchase
    local function doPurchase()
        local id = tonumber(ugcId)
        
        if not id then
            -- Spam protection for error notif
            if os.clock() - lastNotifTime > 2 then
                Moonveil.Notify({Title = "Error", Description = "Invalid UGC ID! Please enter numbers only.", Duration = 2})
                lastNotifTime = os.clock()
            end
            return
        end

        local name = cachedName
        
        -- Fetch item info if it's a new ID
        if id ~= lastId then
            local success, info = pcall(function()
                return MarketplaceService:GetProductInfo(id)
            end)
            
            if success and info then
                name = info.Name
                cachedName = name
                cachedPrice = (info.PriceInRobux or 0) .. " R$"
            else
                name = "Unknown Item"
            end
            lastId = id
            
            -- Show item fetch success
            Moonveil.Notify({Title = "Item Fetched", Description = name .. " | " .. cachedPrice, Duration = 3})
        end

        -- Trigger the fake purchase prompt
        pcall(function()
            MarketplaceService:SignalPromptPurchaseFinished(player, id, true)
        end)

        -- Throttle notifications to prevent UI lag during ultra loop
        if not isLooping or (os.clock() - lastNotifTime > 0.5) then
            Moonveil.Notify({Title = "Fake Purchase", Description = "Purchased: " .. tostring(name), Duration = 1.5})
            lastNotifTime = os.clock()
        end
    end

    -- Single execute button
    PurchaseSection:AddButton("Purchase Once", function()
        doPurchase()
    end, {
        Title = "Purchase Once",
        Description = "Executes the fake purchase script exactly one time."
    })

    -- Loop toggle
    PurchaseSection:AddToggle("Ultra Fast Loop", false, function(state)
        isLooping = state
        
        if isLooping then
            Moonveil.Notify({Title = "Loop Started", Description = "Ultra fast loop is now running.", Duration = 2})
            task.spawn(function()
                while isLooping do
                    doPurchase()
                    task.wait(math.max(0.001, loopDelay))
                end
            end)
        else
            Moonveil.Notify({Title = "Loop Stopped", Description = "Purchase loop has been stopped.", Duration = 2})
        end
    end, {
        Title = "Ultra Loop",
        Description = "Spams the fake purchase. Recommended delay: 0.001 - 0.05. Warning: May cause lag if set too low!"
    })
end