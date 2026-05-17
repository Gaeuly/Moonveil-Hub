local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local noclipLoop = nil

-- Kita return (kembalikan) sebuah fungsi biar bisa dipanggil dari Main.lua
return function(state)
    if state then
        -- Nyalain Noclip (Jalan setiap frame biar gak nyangkut)
        if not noclipLoop then
            noclipLoop = RunService.Stepped:Connect(function()
                local char = lp.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        end
    else
        -- Matiin Noclip
        if noclipLoop then
            noclipLoop:Disconnect()
            noclipLoop = nil
        end
    end
end