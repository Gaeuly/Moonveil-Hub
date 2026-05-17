local cg = game:GetService("CoreGui")
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local players = game:GetService("Players")
local lp = players.LocalPlayer

for _, v in pairs(cg:GetChildren()) do
    if v.Name == "MoonveilUI" then v:Destroy() end
end

local sg = Instance.new("ScreenGui")
sg.Name = "MoonveilUI"
sg.Parent = cg
sg.ResetOnSpawn = false

-- Asset ID Logo
local myLogoID = "134665675914525" 
local logoUrl = "rbxthumb://type=Asset&id=" .. myLogoID .. "&w=150&h=150"

local openBtn = Instance.new("ImageButton")
openBtn.Parent = sg
openBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
openBtn.Position = UDim2.new(0, 20, 0, 20)
openBtn.Size = UDim2.new(0, 45, 0, 45)
openBtn.Image = logoUrl
openBtn.Visible = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Color = Color3.fromRGB(128, 0, 255)
openStroke.Thickness = 2

local function drag(obj, dragObj)
    local drg, inpt, start, pos
    obj.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drg = true; start = i.Position; pos = dragObj.Position
            i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drg = false end end)
        end
    end)
    obj.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then inpt = i end
    end)
    uis.InputChanged:Connect(function(i)
        if i == inpt and drg then
            local d = i.Position - start
            dragObj.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
        end
    end)
end

drag(openBtn, openBtn)

local main = Instance.new("Frame")
main.Parent = sg
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.Size = UDim2.new(0, 500, 0, 350)
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
drag(main, main)

openBtn.MouseButton1Click:Connect(function()
    openBtn.Visible = false
    main.Visible = true
end)

local side = Instance.new("Frame")
side.Parent = main
side.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
side.Size = UDim2.new(0, 140, 1, 0)
side.BorderSizePixel = 0
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 8)
local sideFix = Instance.new("Frame", side)
sideFix.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
sideFix.Position = UDim2.new(1, -10, 0, 0)
sideFix.Size = UDim2.new(0, 10, 1, 0)
sideFix.BorderSizePixel = 0

local logoLabel = Instance.new("ImageLabel")
logoLabel.Parent = side
logoLabel.BackgroundTransparency = 1
logoLabel.Position = UDim2.new(0, 10, 0, 12)
logoLabel.Size = UDim2.new(0, 20, 0, 20)
logoLabel.Image = logoUrl

local title = Instance.new("TextLabel")
title.Parent = side
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 35, 0, 12)
title.Size = UDim2.new(1, -35, 0, 20)
title.Font = Enum.Font.GothamBlack
title.Text = "MOONVEIL"
title.TextColor3 = Color3.fromRGB(128, 0, 255)
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = side
closeBtn.BackgroundTransparency = 1
closeBtn.Position = UDim2.new(0, 10, 1, -35)
closeBtn.Size = UDim2.new(1, -20, 0, 25)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "Close UI"
closeBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
closeBtn.TextSize = 12
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    openBtn.Visible = true
end)

local tabCont = Instance.new("ScrollingFrame")
tabCont.Parent = side
tabCont.BackgroundTransparency = 1
tabCont.Position = UDim2.new(0, 0, 0, 50)
tabCont.Size = UDim2.new(1, 0, 1, -95)
tabCont.ScrollBarThickness = 0
local tList = Instance.new("UIListLayout", tabCont)
tList.Padding = UDim.new(0, 5)
tList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local pageCont = Instance.new("Frame")
pageCont.Parent = main
pageCont.BackgroundTransparency = 1
pageCont.Position = UDim2.new(0, 150, 0, 15)
pageCont.Size = UDim2.new(1, -165, 1, -30)

local tabs = {}
local pages = {}

local function CreateTab(name, iconId, isDef)
    local tBtn = Instance.new("TextButton")
    tBtn.Parent = tabCont
    tBtn.BackgroundColor3 = isDef and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(25, 25, 25)
    tBtn.Size = UDim2.new(1, -20, 0, 30)
    tBtn.Font = Enum.Font.GothamSemibold
    tBtn.Text = name
    tBtn.TextColor3 = isDef and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
    tBtn.TextSize = 12
    tBtn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
    
    local tPad = Instance.new("UIPadding", tBtn)
    tPad.PaddingLeft = UDim.new(0, 30)
    
    local tIcon = Instance.new("ImageLabel", tBtn)
    tIcon.BackgroundTransparency = 1
    tIcon.Position = UDim2.new(0, -22, 0.5, -8)
    tIcon.Size = UDim2.new(0, 16, 0, 16)
    tIcon.Image = iconId
    tIcon.ImageColor3 = isDef and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
    
    local pScroll = Instance.new("ScrollingFrame")
    pScroll.Parent = pageCont
    pScroll.BackgroundTransparency = 1
    pScroll.Size = UDim2.new(1, 0, 1, 0)
    pScroll.ScrollBarThickness = 2
    pScroll.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
    pScroll.Visible = isDef
    
    local pList = Instance.new("UIListLayout", pScroll)
    pList.Padding = UDim.new(0, 8)
    pList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        pScroll.CanvasSize = UDim2.new(0, 0, 0, pList.AbsoluteContentSize.Y + 10)
    end)
    
    table.insert(tabs, {btn = tBtn, icon = tIcon})
    table.insert(pages, pScroll)
    
    tBtn.MouseButton1Click:Connect(function()
        for _, p in ipairs(pages) do p.Visible = false end
        for _, t in ipairs(tabs) do
            ts:Create(t.btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            ts:Create(t.icon, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        pScroll.Visible = true
        ts:Create(tBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(128, 0, 255), TextColor3 = Color3.new(1,1,1)}):Play()
        ts:Create(tIcon, TweenInfo.new(0.2), {ImageColor3 = Color3.new(1,1,1)}):Play()
    end)
    
    local els = {}
    
    function els:Toggle(txt, cb)
        local f = Instance.new("Frame")
        f.Parent = pScroll; f.BackgroundColor3 = Color3.fromRGB(20, 20, 20); f.Size = UDim2.new(1, -10, 0, 40)
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local l = Instance.new("TextLabel")
        l.Parent = f; l.BackgroundTransparency = 1; l.Position = UDim2.new(0, 15, 0, 0); l.Size = UDim2.new(1, -60, 1, 0)
        l.Font = Enum.Font.GothamSemibold; l.Text = txt; l.TextColor3 = Color3.new(0.9,0.9,0.9); l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left
        
        local b = Instance.new("TextButton")
        b.Parent = f; b.BackgroundColor3 = Color3.fromRGB(35, 35, 35); b.Position = UDim2.new(1, -55, 0.5, -10); b.Size = UDim2.new(0, 40, 0, 20); b.Text = ""
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        
        local c = Instance.new("Frame")
        c.Parent = b; c.BackgroundColor3 = Color3.new(1,1,1); c.Position = UDim2.new(0, 2, 0.5, -8); c.Size = UDim2.new(0, 16, 0, 16)
        Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
        
        local act = false
        b.MouseButton1Click:Connect(function()
            act = not act; cb(act)
            if act then
                ts:Create(c, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
                ts:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(128, 0, 255)}):Play()
            else
                ts:Create(c, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
                ts:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            end
        end)
    end
    
    return els
end

-- ==========================================
-- TABS & TOGGLES
-- ==========================================

local tabGeneral = CreateTab("General", "rbxassetid://7733658504", true)
-- Isi tab General nanti disini

local tabMisc = CreateTab("Misc", "rbxassetid://7734068321", false)

-- IMPORT MODULE NOCLIP DARI GITHUB
-- JANGAN LUPA GANTI "USERNAME_GITHUB_LU" SAMA USERNAME ASLI LU!
local noclipModuleURL = "https://raw.githubusercontent.com/Gaeuly/Moonveil-Hub/main/misc/noclip.lua"
local toggleNoclip = loadstring(game:HttpGet(noclipModuleURL))()

tabMisc:Toggle("Noclip", function(state) 
    toggleNoclip(state)
end)