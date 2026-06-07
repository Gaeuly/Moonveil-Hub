local cg = game:GetService("CoreGui")
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")

for _, v in pairs(cg:GetChildren()) do
    if v.Name == "MoonveilUI" then v:Destroy() end
end

local sg = Instance.new("ScreenGui")
sg.Name = "MoonveilUI"
sg.Parent = cg
sg.ResetOnSpawn = false

local mid = "134665675914525" 
local lUrl = "rbxthumb://type=Asset&id=" .. mid .. "&w=150&h=150"

local ob = Instance.new("ImageButton")
ob.Parent = sg
ob.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ob.Position = UDim2.new(0, 20, 0, 20)
ob.Size = UDim2.new(0, 45, 0, 45)
ob.Image = lUrl
ob.Visible = false
Instance.new("UICorner", ob).CornerRadius = UDim.new(1, 0)
local os = Instance.new("UIStroke", ob)
os.Color = Color3.fromRGB(128, 0, 255)
os.Thickness = 2

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

drag(ob, ob)

local main = Instance.new("Frame")
main.Parent = sg
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.Size = UDim2.new(0, 500, 0, 350)
main.BorderSizePixel = 0
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
drag(main, main)

ob.MouseButton1Click:Connect(function()
    ob.Visible = false
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
logoLabel.Image = lUrl

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

local cb = Instance.new("TextButton")
cb.Parent = side
cb.BackgroundTransparency = 1
cb.Position = UDim2.new(0, 10, 1, -35)
cb.Size = UDim2.new(1, -20, 0, 25)
cb.Font = Enum.Font.GothamBold
cb.Text = "Close"
cb.TextColor3 = Color3.fromRGB(150, 150, 150)
cb.TextSize = 12
cb.MouseButton1Click:Connect(function()
    main.Visible = false
    ob.Visible = true
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
    local tb = Instance.new("TextButton")
    tb.Parent = tabCont
    tb.BackgroundColor3 = isDef and Color3.fromRGB(128, 0, 255) or Color3.fromRGB(25, 25, 25)
    tb.Size = UDim2.new(1, -20, 0, 30)
    tb.Font = Enum.Font.GothamSemibold
    tb.Text = name
    tb.TextColor3 = isDef and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
    tb.TextSize = 12
    tb.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
    
    local tPad = Instance.new("UIPadding", tb)
    tPad.PaddingLeft = UDim.new(0, 30)
    
    local ti = Instance.new("ImageLabel", tb)
    ti.BackgroundTransparency = 1
    ti.Position = UDim2.new(0, -22, 0.5, -8)
    ti.Size = UDim2.new(0, 16, 0, 16)
    ti.Image = iconId
    ti.ImageColor3 = isDef and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
    
    local ps = Instance.new("ScrollingFrame")
    ps.Parent = pageCont
    ps.BackgroundTransparency = 1
    ps.Size = UDim2.new(1, 0, 1, 0)
    ps.ScrollBarThickness = 2
    ps.ScrollBarImageColor3 = Color3.fromRGB(128, 0, 255)
    ps.Visible = isDef
    
    local pl = Instance.new("UIListLayout", ps)
    pl.Padding = UDim.new(0, 8)
    pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ps.CanvasSize = UDim2.new(0, 0, 0, pl.AbsoluteContentSize.Y + 10)
    end)
    
    table.insert(tabs, {b = tb, i = ti})
    table.insert(pages, ps)
    
    tb.MouseButton1Click:Connect(function()
        for _, p in ipairs(pages) do p.Visible = false end
        for _, t in ipairs(tabs) do
            ts:Create(t.b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
            ts:Create(t.i, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        ps.Visible = true
        ts:Create(tb, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(128, 0, 255), TextColor3 = Color3.new(1,1,1)}):Play()
        ts:Create(ti, TweenInfo.new(0.2), {ImageColor3 = Color3.new(1,1,1)}):Play()
    end)
    
    local els = {}
    
    function els:Toggle(txt, cb)
        local f = Instance.new("Frame")
        f.Parent = ps; f.BackgroundColor3 = Color3.fromRGB(20, 20, 20); f.Size = UDim2.new(1, -10, 0, 40)
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
    
    function els:Dropdown(txt, opts, cb)
        local f = Instance.new("Frame")
        f.Parent = ps; f.BackgroundColor3 = Color3.fromRGB(20, 20, 20); f.ClipsDescendants = true; f.Size = UDim2.new(1, -10, 0, 40)
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        
        local b = Instance.new("TextButton")
        b.Parent = f; b.BackgroundTransparency = 1; b.Size = UDim2.new(1, 0, 0, 40)
        b.Font = Enum.Font.GothamSemibold; b.Text = "  " .. txt .. " : " .. opts[1]; b.TextColor3 = Color3.new(0.9,0.9,0.9); b.TextSize = 13; b.TextXAlignment = Enum.TextXAlignment.Left
        
        local arr = Instance.new("ImageLabel")
        arr.Parent = f; arr.BackgroundTransparency = 1; arr.Position = UDim2.new(1, -25, 0, 12); arr.Size = UDim2.new(0, 16, 0, 16)
        arr.Image = "rbxassetid://6031091004"; arr.ImageColor3 = Color3.fromRGB(150, 150, 150)
        
        local sf = Instance.new("ScrollingFrame")
        sf.Parent = f; sf.BackgroundTransparency = 1; sf.Position = UDim2.new(0, 0, 0, 40); sf.Size = UDim2.new(1, 0, 1, -40); sf.ScrollBarThickness = 2
        local sl = Instance.new("UIListLayout", sf)
        
        local opn = false
        b.MouseButton1Click:Connect(function()
            opn = not opn
            local ty = opn and math.min(40 + (#opts * 30), 130) or 40
            ts:Create(f, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, ty)}):Play()
            ts:Create(arr, TweenInfo.new(0.2), {Rotation = opn and 180 or 0}):Play()
        end)
        
        for _, v in ipairs(opts) do
            local ob = Instance.new("TextButton")
            ob.Parent = sf; ob.BackgroundTransparency = 1; ob.Size = UDim2.new(1, 0, 0, 30)
            ob.Font = Enum.Font.Gotham; ob.Text = "  " .. v; ob.TextColor3 = Color3.fromRGB(150, 150, 150); ob.TextSize = 12; ob.TextXAlignment = Enum.TextXAlignment.Left
            ob.MouseButton1Click:Connect(function()
                opn = false
                ts:Create(f, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 40)}):Play()
                ts:Create(arr, TweenInfo.new(0.2), {Rotation = 0}):Play()
                b.Text = "  " .. txt .. " : " .. v
                cb(v)
            end)
        end
    end
    
    function els:Button(txt, cb)
        local b = Instance.new("TextButton")
        b.Parent = ps; b.BackgroundColor3 = Color3.fromRGB(20, 20, 20); b.Size = UDim2.new(1, -10, 0, 40)
        b.Font = Enum.Font.GothamSemibold; b.Text = txt; b.TextColor3 = Color3.new(0.9,0.9,0.9); b.TextSize = 13
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function()
            local eff = Instance.new("Frame", b)
            eff.BackgroundColor3 = Color3.new(1,1,1); eff.BackgroundTransparency = 0.8; eff.Size = UDim2.new(1,0,1,0)
            Instance.new("UICorner", eff).CornerRadius = UDim.new(0, 6)
            ts:Create(eff, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            game.Debris:AddItem(eff, 0.3)
            cb()
        end)
    end

    return els
end

local t1 = CreateTab("General", "rbxassetid://7733658504", true)
local t2 = CreateTab("Misc", "rbxassetid://7734068321", false)

local ncMod = "https://raw.githubusercontent.com/Gaeuly/Moonveil-Hub/main/misc/noclip.lua"
local spMod = "https://raw.githubusercontent.com/Gaeuly/Moonveil-Hub/main/misc/speed.lua"
local dvMod = "https://raw.githubusercontent.com/Gaeuly/Moonveil-Hub/main/misc/devicespoof.lua"

local togNc = loadstring(game:HttpGet(ncMod))()
local setSp = loadstring(game:HttpGet(spMod))()
local setDv = loadstring(game:HttpGet(dvMod))()

t2:Toggle("Noclip", function(s) 
    togNc(s)
end)

t2:Dropdown("WalkSpeed", {"16 (Default)", "32 (Fast)", "50 (Flash)", "100 (Sonic)"}, function(v)
    setSp(v)
end)

t2:Dropdown("Device Spoofer", {"Default", "PC", "Mobile", "Console"}, function(v)
    setDv(v)
end)

t2:Button("Reset Character (Apply Spoof)", function()
    local c = game:GetService("Players").LocalPlayer.Character
    if c then c:BreakJoints() end
end)