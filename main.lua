-- // Moonveil-HUB Main Bootstrapper
-- // Modular Architecture by gaeuly

local RepoURL = "https://raw.githubusercontent.com/Gaeuly/Moonveil-HUB/main/"

-- // Master Table (Global State)
local Moonveil = {
    WhitelistedUsers = {"Username", "Username1", "Username2", "Username3", "Username4"},
    Tabs = {}, 
    AllCards = {}, 
    ConfigElements = {}, 
    CurrentTransparency = 0,
    Theme = {
        AccentColor = Color3.fromRGB(190, 140, 255),
        BackgroundColor = Color3.fromRGB(18, 18, 20),
        CardColor = Color3.fromRGB(24, 24, 27),
        HoverColor = Color3.fromRGB(35, 35, 40),
        TextColor = Color3.fromRGB(240, 240, 240),
        SubTextColor = Color3.fromRGB(150, 150, 150)
    }
}

-- // Services
Moonveil.TweenService = game:GetService("TweenService")
Moonveil.UserInputService = game:GetService("UserInputService")
Moonveil.RunService = game:GetService("RunService")
Moonveil.HttpService = game:GetService("HttpService")

-- // File System Mocks
Moonveil.FileSystem = {
    isfolder = isfolder or function() return true end,
    makefolder = makefolder or function() end,
    writefile = writefile or function(path, data) warn("File saving not supported.") end,
    readfile = readfile or function() return "{}" end,
    listfiles = listfiles or function() return {} end,
    delfile = delfile or function() warn("File deletion not supported.") end
}

-- // Utility Functions
function Moonveil.SafeCopyToClipboard(text)
    if setclipboard then setclipboard(text)
    elseif toclipboard then toclipboard(text)
    else warn("Clipboard copying not supported.") end
end

function Moonveil.Create(className, properties)
    local instance = Instance.new(className)
    if className == "TextBox" then instance.Text = "" end
    for k, v in pairs(properties or {}) do instance[k] = v end
    if (className == "TextLabel" or className == "TextButton" or className == "TextBox") then
        if properties.TextSize and properties.RichText ~= true then
            instance.TextScaled = true
            local constraint = Instance.new("UITextSizeConstraint")
            constraint.MaxTextSize = properties.TextSize
            constraint.MinTextSize = 6
            constraint.Parent = instance
        end
    end
    return instance
end

function Moonveil.Tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = Moonveil.TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Moonveil.AddBounce(button, scaleFactor)
    scaleFactor = scaleFactor or 0.96
    local scaleObj = button:FindFirstChild("UIScale") or Moonveil.Create("UIScale", {Parent = button, Scale = 1})
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Moonveil.Tween(scaleObj, {Scale = scaleFactor}, 0.15)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Moonveil.Tween(scaleObj, {Scale = 1}, 0.15)
        end
    end)
    button.MouseLeave:Connect(function() Moonveil.Tween(scaleObj, {Scale = 1}, 0.15) end)
end

function Moonveil.MakeDraggable(topbar, object)
    topbar.Active = true
    object.Active = true
    local dragging, dragInput, dragStart, startPos
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    
    Moonveil.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Moonveil.Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.08)
        end
    end)
end

function Moonveil.BuildSearchIndex(card)
    local parts = {}
    for _, desc in ipairs(card:GetDescendants()) do
        if (desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox")) and desc.Text ~= "" then
            table.insert(parts, desc.Text:lower())
        end
    end
    return table.concat(parts, " ")
end

-- // Core Interface Setup
local uniqueID = Moonveil.HttpService:GenerateGUID(false)
local ScreenGui = Moonveil.Create("ScreenGui", { Name = "Moonveil_UI_" .. uniqueID, Parent = Moonveil.RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui"), ResetOnSpawn = false, IgnoreGuiInset = true })
Moonveil.ScreenGui = ScreenGui

-- Notifications
local NotifContainer = Moonveil.Create("Frame", { Parent = ScreenGui, BackgroundTransparency = 1, Size = UDim2.new(0, 320, 1, -20), Position = UDim2.new(1, -340, 0, 10), ZIndex = 200, Active = false })
Moonveil.Create("UIListLayout", {Parent = NotifContainer, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})

function Moonveil.Notify(options)
    local title, desc, duration = options.Title or "Notification", options.Description or "Information updated.", options.Duration or 3
    local Notif = Moonveil.Create("Frame", {Parent = NotifContainer, BackgroundColor3 = Color3.fromRGB(20, 20, 22), Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 1, ZIndex = 201, ClipsDescendants = true})
    Moonveil.Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
    local Stroke = Moonveil.Create("UIStroke", {Parent = Notif, Color = Moonveil.Theme.AccentColor, Thickness = 1.5, Transparency = 1})
    local TitleText = Moonveil.Create("TextLabel", {Parent = Notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Moonveil.Theme.TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(1, -30, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
    local DescText = Moonveil.Create("TextLabel", {Parent = Notif, Text = desc, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Moonveil.Theme.SubTextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 32), Size = UDim2.new(1, -30, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})

    Moonveil.Tween(Notif, {BackgroundTransparency = 0}, 0.3)
    Moonveil.Tween(Stroke, {Transparency = 0}, 0.3)
    Moonveil.Tween(TitleText, {TextTransparency = 0}, 0.3)
    Moonveil.Tween(DescText, {TextTransparency = 0}, 0.3)

    task.delay(duration, function()
        Moonveil.Tween(Notif, {BackgroundTransparency = 1}, 0.4)
        Moonveil.Tween(Stroke, {Transparency = 1}, 0.4)
        Moonveil.Tween(TitleText, {TextTransparency = 1}, 0.4)
        Moonveil.Tween(DescText, {TextTransparency = 1}, 0.4)
        task.wait(0.4)
        Notif:Destroy()
    end)
end

function Moonveil.SendPremiumNotification()
    local Notif = Moonveil.Create("Frame", {Parent = NotifContainer, BackgroundColor3 = Color3.fromRGB(20, 20, 22), Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 1, ZIndex = 201, ClipsDescendants = true})
    Moonveil.Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
    local Stroke = Moonveil.Create("UIStroke", {Parent = Notif, Thickness = 1.5, Transparency = 1})
    Moonveil.Create("UIGradient", {Parent = Stroke, Color = ColorSequence.new(Color3.fromRGB(255, 215, 0), Color3.fromRGB(180, 130, 20)), Rotation = 45})
    local LockIcon = Moonveil.Create("ImageLabel", {Parent = Notif, BackgroundTransparency = 1, Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 15, 0.5, -12), Image = "rbxassetid://6031082533", ImageColor3 = Color3.fromRGB(255, 215, 0), ImageTransparency = 1, ZIndex = 202})
    local TitleText = Moonveil.Create("TextLabel", {Parent = Notif, Text = "ACCESS DENIED", Font = Enum.Font.GothamBlack, TextSize = 12, TextColor3 = Moonveil.Theme.SubTextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 15), Size = UDim2.new(1, -60, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
    local DescText = Moonveil.Create("TextLabel", {Parent = Notif, Text = 'This Is For <font color="#FFD700"><b>Whitelisted Users</b></font>', RichText = true, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Moonveil.Theme.TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 32), Size = UDim2.new(1, -60, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
    
    Moonveil.Tween(Notif, {BackgroundTransparency = 0}, 0.3)
    Moonveil.Tween(Stroke, {Transparency = 0}, 0.3)
    Moonveil.Tween(LockIcon, {ImageTransparency = 0}, 0.3)
    Moonveil.Tween(TitleText, {TextTransparency = 0}, 0.3)
    Moonveil.Tween(DescText, {TextTransparency = 0}, 0.3)

    task.delay(4, function()
        Moonveil.Tween(Notif, {BackgroundTransparency = 1}, 0.4)
        Moonveil.Tween(Stroke, {Transparency = 1}, 0.4)
        Moonveil.Tween(LockIcon, {ImageTransparency = 1}, 0.4)
        Moonveil.Tween(TitleText, {TextTransparency = 1}, 0.4)
        Moonveil.Tween(DescText, {TextTransparency = 1}, 0.4)
        task.wait(0.4)
        Notif:Destroy()
    end)
end

-- Info Overlay Window
local InfoOverlay = Moonveil.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(5, 5, 8), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 150, Visible = false, Active = true})
local InfoCard = Moonveil.Create("Frame", {Parent = InfoOverlay, BackgroundColor3 = Color3.fromRGB(16, 16, 20), Size = UDim2.new(0, 360, 0, 280), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 151, BackgroundTransparency = 1, ClipsDescendants = true})
Moonveil.Create("UICorner", {Parent = InfoCard, CornerRadius = UDim.new(0, 8)})
Moonveil.Create("UIStroke", {Parent = InfoCard, Color = Moonveil.Theme.AccentColor, Thickness = 1.5, Transparency = 1})
local InfoScale = Moonveil.Create("UIScale", {Parent = InfoCard, Scale = 0})

local InfoHeader = Moonveil.Create("Frame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), ZIndex = 152})
local InfoTitle = Moonveil.Create("TextLabel", {Parent = InfoHeader, Text = "Feature Info", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Moonveil.Theme.TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 152})
local InfoCloseBtn = Moonveil.Create("TextButton", {Parent = InfoHeader, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Moonveil.Theme.SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -40, 0, 0), ZIndex = 152, TextTransparency = 1})
Moonveil.AddBounce(InfoCloseBtn)

local InfoScroll = Moonveil.Create("ScrollingFrame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -60), Position = UDim2.new(0, 20, 0, 50), CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = Moonveil.Theme.AccentColor, BorderSizePixel = 0, ZIndex = 152})
local InfoLayout = Moonveil.Create("UIListLayout", {Parent = InfoScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
local InfoDesc = Moonveil.Create("TextLabel", {Parent = InfoScroll, Text = "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Moonveil.Theme.SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 152, TextTransparency = 1})
local InfoExampleBox = Moonveil.Create("Frame", {Parent = InfoScroll, BackgroundColor3 = Color3.fromRGB(10, 10, 12), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 152})
Moonveil.Create("UICorner", {Parent = InfoExampleBox, CornerRadius = UDim.new(0, 6)})
Moonveil.Create("UIStroke", {Parent = InfoExampleBox, Color = Color3.fromRGB(40, 40, 45), Thickness = 1})
local InfoExampleText = Moonveil.Create("TextLabel", {Parent = InfoExampleBox, Text = "", Font = Enum.Font.Code, TextSize = 12, TextColor3 = Moonveil.Theme.AccentColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, 10), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 152, TextTransparency = 1})
Moonveil.Create("UIPadding", {Parent = InfoExampleBox, PaddingBottom = UDim.new(0, 10)})
InfoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() InfoScroll.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 10) end)

local function OpenInfoWindow(data)
    InfoTitle.Text = data.Title or "Information"
    InfoDesc.Text = data.Description or "No description provided."
    if data.Example then InfoExampleText.Text = data.Example InfoExampleBox.Visible = true else InfoExampleBox.Visible = false end
    InfoOverlay.Visible = true
    Moonveil.Tween(InfoOverlay, {BackgroundTransparency = 0.4}, 0.3)
    Moonveil.Tween(InfoCard, {BackgroundTransparency = 0}, 0.3)
    Moonveil.Tween(InfoCard:FindFirstChild("UIStroke"), {Transparency = 0.3}, 0.3)
    Moonveil.Tween(InfoScale, {Scale = 1}, 0.3)
    Moonveil.Tween(InfoTitle, {TextTransparency = 0}, 0.3)
    Moonveil.Tween(InfoCloseBtn, {TextTransparency = 0}, 0.3)
    Moonveil.Tween(InfoDesc, {TextTransparency = 0}, 0.3)
    if data.Example then Moonveil.Tween(InfoExampleText, {TextTransparency = 0}, 0.3) end
end

InfoCloseBtn.MouseButton1Click:Connect(function()
    Moonveil.Tween(InfoOverlay, {BackgroundTransparency = 1}, 0.3)
    Moonveil.Tween(InfoCard, {BackgroundTransparency = 1}, 0.3)
    Moonveil.Tween(InfoCard:FindFirstChild("UIStroke"), {Transparency = 1}, 0.3)
    Moonveil.Tween(InfoScale, {Scale = 0}, 0.3)
    Moonveil.Tween(InfoTitle, {TextTransparency = 1}, 0.3)
    Moonveil.Tween(InfoCloseBtn, {TextTransparency = 1}, 0.3)
    Moonveil.Tween(InfoDesc, {TextTransparency = 1}, 0.3)
    if InfoExampleBox.Visible then Moonveil.Tween(InfoExampleText, {TextTransparency = 1}, 0.3) end
    task.wait(0.3)
    InfoOverlay.Visible = false
end)

function Moonveil.AddInfoIcon(parent, pos, data)
    if not data then return end
    local Btn = Moonveil.Create("TextButton", {Parent = parent, Text = "?", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = Moonveil.Theme.SubTextColor, BackgroundColor3 = Color3.fromRGB(35, 35, 40), Size = UDim2.new(0, 16, 0, 16), Position = pos, AutoButtonColor = false, ZIndex = 5})
    Moonveil.Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(1, 0)})
    Moonveil.AddBounce(Btn)
    Btn.MouseEnter:Connect(function() Moonveil.Tween(Btn, {TextColor3 = Moonveil.Theme.TextColor, BackgroundColor3 = Moonveil.Theme.AccentColor}, 0.2) end)
    Btn.MouseLeave:Connect(function() Moonveil.Tween(Btn, {TextColor3 = Moonveil.Theme.SubTextColor, BackgroundColor3 = Color3.fromRGB(35, 35, 40)}, 0.2) end)
    Btn.MouseButton1Click:Connect(function() OpenInfoWindow(data) end)
end

-- Main Frame & UI Setup
local MainFrame = Moonveil.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Moonveil.Theme.BackgroundColor, Size = UDim2.new(0, 650, 0, 420), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true, BackgroundTransparency = 1, Active = true})
Moonveil.MainFrame = MainFrame
local MainScale = Moonveil.Create("UIScale", {Parent = MainFrame, Scale = 0.8})
Moonveil.Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
Moonveil.Create("UIStroke", {Parent = MainFrame, Color = Color3.fromRGB(40, 40, 45), Thickness = 1})
Moonveil.Tween(MainScale, {Scale = 1}, 0.5)
Moonveil.Tween(MainFrame, {BackgroundTransparency = 0}, 0.5)

local BottomDragHitbox = Moonveil.Create("Frame", {Parent = ScreenGui, BackgroundTransparency = 1, Size = UDim2.new(0, 350, 0, 30), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 145, Active = true})
local FloatingBottomBar = Moonveil.Create("Frame", {Parent = BottomDragHitbox, BackgroundColor3 = Moonveil.Theme.CardColor, BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0.5, -3), ZIndex = 146})
Moonveil.FloatingBottomBar = FloatingBottomBar
Moonveil.Create("UICorner", {Parent = FloatingBottomBar, CornerRadius = UDim.new(1, 0)})
local BottomBarStroke = Moonveil.Create("UIStroke", {Parent = FloatingBottomBar, Color = Color3.fromRGB(50, 50, 55), Thickness = 1.2, Transparency = 0})
Moonveil.MakeDraggable(BottomDragHitbox, MainFrame)

Moonveil.RunService.RenderStepped:Connect(function()
    if MainFrame and MainFrame.Visible then
        BottomDragHitbox.Visible = true
        local currentScale = MainScale.Scale
        BottomDragHitbox.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + ((420 * currentScale) / 2) + 20)
        BottomDragHitbox.Size = UDim2.new(0, (650 * currentScale) * 0.6, 0, 30 * currentScale)
        FloatingBottomBar.Size = UDim2.new(1, 0, 0, 6 * currentScale)
        FloatingBottomBar.Position = UDim2.new(0, 0, 0.5, -(3 * currentScale))
    else
        BottomDragHitbox.Visible = false
    end
end)

local TopBar = Moonveil.Create("Frame", {Parent = MainFrame, BackgroundColor3 = Moonveil.Theme.BackgroundColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 0), Active = true})
Moonveil.MakeDraggable(TopBar, MainFrame)

local TopbarIcon = Moonveil.Create("ImageLabel", {Parent = TopBar, BackgroundTransparency = 1, Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 8, 0.5, -16), Image = "rbxassetid://134665675914525", ScaleType = Enum.ScaleType.Fit})
local TitleContainer = Moonveil.Create("Frame", {Parent = TopBar, BackgroundTransparency = 1, Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(0, 48, 0, 0)})
Moonveil.Title = Moonveil.Create("TextLabel", {Parent = TitleContainer, Text = "Moonveil-HUB", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Moonveil.Theme.TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left})
Moonveil.Create("TextLabel", {Parent = TitleContainer, Text = "Made by gaeuly", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = Moonveil.Theme.AccentColor, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left})

local SearchBar = Moonveil.Create("Frame", {Parent = TopBar, BackgroundColor3 = Moonveil.Theme.CardColor, Size = UDim2.new(0, 250, 0, 26), Position = UDim2.new(0, 180, 0.5, -13)})
Moonveil.Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
Moonveil.Create("ImageLabel", {Parent = SearchBar, BackgroundTransparency = 1, Image = "rbxassetid://6031154871", ImageColor3 = Moonveil.Theme.SubTextColor, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7)})
local SearchInput = Moonveil.Create("TextBox", {Parent = SearchBar, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = Moonveil.Theme.TextColor, PlaceholderText = "Search..", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchInput.Text:lower()
    if query == "" then
        for _, data in ipairs(Moonveil.AllCards) do data.Card.Parent = data.OrigParent data.Card.Visible = true end
    else
        if not Moonveil.CurrentTab or not Moonveil.CurrentTab.CurrentPage then return end
        local activeLeft, activeRight = Moonveil.CurrentTab.CurrentPage.LeftCol, Moonveil.CurrentTab.CurrentPage.RightCol
        local placeLeft = true
        for _, data in ipairs(Moonveil.AllCards) do
            local card = data.Card
            if data.Tab == Moonveil.CurrentTab then
                if not data.SearchIndex then data.SearchIndex = Moonveil.BuildSearchIndex(card) end
                if string.find(data.SearchIndex, query, 1, true) then
                    card.Parent = placeLeft and activeLeft or activeRight
                    placeLeft = not placeLeft
                    card.Visible = true
                else
                    card.Visible = false
                end
            else
                card.Parent = data.OrigParent
                card.Visible = true
            end
        end
    end
end)

local CloseBtn = Moonveil.Create("TextButton", {Parent = TopBar, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Moonveil.Theme.SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -35, 0, 0)})
local MinBtn = Moonveil.Create("TextButton", {Parent = TopBar, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Moonveil.Theme.SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -65, 0, 0)})

local Sphere = Moonveil.Create("ImageButton", {Parent = ScreenGui, BackgroundColor3 = Moonveil.Theme.BackgroundColor, BackgroundTransparency = 0.2, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Visible = false, AutoButtonColor = false, ImageTransparency = 1, ClipsDescendants = true})
Moonveil.Create("UICorner", {Parent = Sphere, CornerRadius = UDim.new(1, 0)})
Moonveil.Create("UIStroke", {Parent = Sphere, Color = Moonveil.Theme.AccentColor, Thickness = 2})
local SphereImageLabel = Moonveil.Create("ImageLabel", {Parent = Sphere, BackgroundTransparency = 1, Size = UDim2.new(0, 38, 0, 38), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Image = "rbxassetid://134665675914525", ImageTransparency = 1, Visible = true})
Moonveil.MakeDraggable(Sphere, Sphere)

MinBtn.MouseButton1Click:Connect(function()
    Moonveil.Tween(MainScale, {Scale = 0}, 0.4)
    Moonveil.Tween(MainFrame, {BackgroundTransparency = 1}, 0.4)
    Moonveil.Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.4)
    Moonveil.Tween(BottomBarStroke, {Transparency = 1}, 0.4)
    task.wait(0.3)
    MainFrame.Visible = false
    BottomDragHitbox.Visible = false
    Sphere.Visible = true
    Moonveil.Tween(Sphere, {Size = UDim2.new(0, 50, 0, 50)}, 0.4)
    Moonveil.Tween(SphereImageLabel, {ImageTransparency = 0}, 0.4)
end)

Sphere.MouseButton1Click:Connect(function()
    Moonveil.Tween(Sphere, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
    Moonveil.Tween(SphereImageLabel, {ImageTransparency = 1}, 0.3)
    task.wait(0.2)
    Sphere.Visible = false
    MainFrame.Visible = true
    BottomDragHitbox.Visible = true
    Moonveil.Tween(MainScale, {Scale = 1}, 0.4)
    Moonveil.Tween(MainFrame, {BackgroundTransparency = Moonveil.CurrentTransparency}, 0.4)
    Moonveil.Tween(FloatingBottomBar, {BackgroundTransparency = Moonveil.CurrentTransparency > 0 and 0.2 or 0}, 0.4)
    Moonveil.Tween(BottomBarStroke, {Transparency = 0}, 0.4)
end)

local Popup = Moonveil.Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(0, 0, 0), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 100, Visible = false, Active = true})
local PopupCard = Moonveil.Create("Frame", {Parent = Popup, BackgroundColor3 = Color3.fromRGB(20, 20, 24), Size = UDim2.new(0, 320, 0, 160), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 101, BackgroundTransparency = 1})
Moonveil.Create("UICorner", {Parent = PopupCard, CornerRadius = UDim.new(0, 12)})
local PopupScale = Moonveil.Create("UIScale", {Parent = PopupCard, Scale = 0.8})
local PopupStroke = Moonveil.Create("UIStroke", {Parent = PopupCard, Color = Color3.fromRGB(50, 50, 55), Thickness = 1, Transparency = 1})
local PopupTitle = Moonveil.Create("TextLabel", {Parent = PopupCard, Text = "Exit Application", Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Moonveil.Theme.TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 25), ZIndex = 102, TextTransparency = 1})
local PopupText = Moonveil.Create("TextLabel", {Parent = PopupCard, Text = "Are you sure you want to close Moonveil-HUB?", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = Moonveil.Theme.SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 55), ZIndex = 102, TextTransparency = 1, TextWrapped = true})
local YesBtn = Moonveil.Create("TextButton", {Parent = PopupCard, Text = "Confirm", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Moonveil.Theme.AccentColor, Size = UDim2.new(0, 125, 0, 36), Position = UDim2.new(0.5, 10, 0, 105), ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false})
Moonveil.Create("UICorner", {Parent = YesBtn, CornerRadius = UDim.new(0, 6)})
Moonveil.AddBounce(YesBtn)
local NoBtn = Moonveil.Create("TextButton", {Parent = PopupCard, Text = "Cancel", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Moonveil.Theme.TextColor, BackgroundColor3 = Color3.fromRGB(40, 40, 45), Size = UDim2.new(0, 125, 0, 36), Position = UDim2.new(0.5, -135, 0, 105), ZIndex = 102, BackgroundTransparency = 1, TextTransparency = 1, AutoButtonColor = false})
Moonveil.Create("UICorner", {Parent = NoBtn, CornerRadius = UDim.new(0, 6)})
Moonveil.AddBounce(NoBtn)

CloseBtn.MouseButton1Click:Connect(function()
    Popup.Visible = true
    Moonveil.Tween(Popup, {BackgroundTransparency = 0.5}, 0.3)
    Moonveil.Tween(PopupCard, {BackgroundTransparency = 0}, 0.3)
    Moonveil.Tween(PopupScale, {Scale = 1}, 0.3)
    Moonveil.Tween(PopupStroke, {Transparency = 0}, 0.3)
    Moonveil.Tween(PopupTitle, {TextTransparency = 0}, 0.3)
    Moonveil.Tween(PopupText, {TextTransparency = 0}, 0.3)
    Moonveil.Tween(YesBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
    Moonveil.Tween(NoBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
end)

YesBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
NoBtn.MouseButton1Click:Connect(function()
    Moonveil.Tween(Popup, {BackgroundTransparency = 1}, 0.3)
    Moonveil.Tween(PopupCard, {BackgroundTransparency = 1}, 0.3)
    Moonveil.Tween(PopupScale, {Scale = 0.8}, 0.3)
    task.wait(0.3)
    Popup.Visible = false
end)

-- // Loading External Modules (Modular Architecture)
local function LoadModule(path)
    local success, result = pcall(function() return loadstring(game:HttpGetAsync(RepoURL .. path))() end)
    if success and type(result) == "function" then 
        result(Moonveil) 
    else 
        warn("Moonveil-HUB | Failed to load module: " .. path .. " | Error: " .. tostring(result)) 
    end
end

-- 1. Load the core logic and sidebar
LoadModule("ui/sidebar.lua")
LoadModule("src/setting/uisize.lua")

-- 2. Load the core UI Builder 
LoadModule("ui/home.lua") 

-- 3. Load the Tab Contents
LoadModule("ui/home/main.lua")
LoadModule("ui/home/execute.lua")
LoadModule("ui/home/setting.lua")

-- 4. Load the Tab Misc
LoadModule("src/main/misc/Optimize-Fps.lua")
LoadModule("src/main/misc/Device-Spoofer.lua")

-- 5. Load External Scripts
LoadModule("src/execute/Free-Gamepass.lua")
LoadModule("src/execute/Fake-Purchase.lua")

-- 6. Load other configs
LoadModule("src/setting/transparency.lua")
LoadModule("src/setting/config.lua")