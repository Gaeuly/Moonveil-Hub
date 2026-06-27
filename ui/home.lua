-- // ui/home.lua
-- // Manages UI Elements Logic & Tabs

return function(Moonveil)
    local Create = Moonveil.Create
    local Tween = Moonveil.Tween
    local AddBounce = Moonveil.AddBounce
    local AddInfoIcon = Moonveil.AddInfoIcon
    local UserInputService = Moonveil.UserInputService
    local SafeCopyToClipboard = Moonveil.SafeCopyToClipboard

    local AccentColor = Moonveil.Theme.AccentColor
    local BackgroundColor = Moonveil.Theme.BackgroundColor
    local CardColor = Moonveil.Theme.CardColor
    local HoverColor = Moonveil.Theme.HoverColor
    local TextColor = Moonveil.Theme.TextColor
    local SubTextColor = Moonveil.Theme.SubTextColor

    -- // METHOD: Page Builder
    function Moonveil.CreatePage(TabConfig, pageName)
        local PageBtn = Create("TextButton", {Parent = TabConfig.PageNav, Text = pageName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
        local PageHighlight = Create("Frame", {Parent = PageBtn, BackgroundColor3 = AccentColor, Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1})
        local PageScroll = Create("ScrollingFrame", {Parent = TabConfig.PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65), Visible = false, BorderSizePixel = 0})

        local LeftColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0)})
        local RightColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0)})
        
        local L_Layout = Create("UIListLayout", {Parent = LeftColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        local R_Layout = Create("UIListLayout", {Parent = RightColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
        L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20) end)
        R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20) end)

        local PageObj = {Scroll = PageScroll, Btn = PageBtn, Highlight = PageHighlight, Left = true, LeftCol = LeftColumn, RightCol = RightColumn}
        table.insert(TabConfig.Pages, PageObj)

        PageBtn.MouseButton1Click:Connect(function()
            if TabConfig.CurrentPage == PageObj then return end
            if TabConfig.CurrentPage then
                Tween(TabConfig.CurrentPage.Btn, {TextColor3 = SubTextColor}, 0.2)
                Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0.2)
                TabConfig.CurrentPage.Scroll.Visible = false
            end
            TabConfig.CurrentPage = PageObj
            PageObj.Scroll.Visible = true
            PageObj.Scroll.Position = UDim2.new(0, 5, 0, 20)
            Tween(PageObj.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)
            Tween(PageBtn, {TextColor3 = TextColor}, 0.2)
            Tween(PageHighlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.3)
        end)

        if #TabConfig.Pages == 1 then
            TabConfig.CurrentPage = PageObj
            PageObj.Scroll.Visible = true
            PageBtn.TextColor3 = TextColor
            PageHighlight.Size = UDim2.new(1, 0, 0, 2)
            PageHighlight.BackgroundTransparency = 0
        end

        function PageObj:CreateSection(sectionName)
            local targetColumn = PageObj.Left and LeftColumn or RightColumn
            PageObj.Left = not PageObj.Left

            local SectionContainer = Create("Frame", {Parent = targetColumn, BackgroundColor3 = CardColor, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
            Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 6)})
            table.insert(Moonveil.AllCards, {Card = SectionContainer, OrigParent = targetColumn, Tab = TabConfig, Page = PageObj, SearchIndex = nil})
            
            Create("TextLabel", {Parent = SectionContainer, Text = sectionName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
            local ItemContainer = Create("Frame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y})
            Create("UIPadding", {Parent = ItemContainer, PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})
            Create("UIListLayout", {Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

            local Elements = { ItemContainer = ItemContainer } -- Expose for config.lua

            function Elements:AddCopyButton(name, copyText, infoData)
                local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                local Btn = Create("TextButton", {Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
                Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Btn, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})
                AddBounce(Btn)
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = HoverColor}, 0.2) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = BackgroundColor}, 0.2) end)
                Btn.MouseButton1Click:Connect(function()
                    SafeCopyToClipboard(copyText)
                    local oldText = Btn.Text Btn.Text = "Copied to Clipboard!"
                    Tween(Btn, {TextColor3 = AccentColor, BackgroundColor3 = HoverColor}, 0.2)
                    task.wait(1.5)
                    if Btn.Parent then Btn.Text = oldText Tween(Btn, {TextColor3 = TextColor, BackgroundColor3 = BackgroundColor}, 0.2) end
                end)
                AddInfoIcon(BtnFrame, UDim2.new(1, -40, 0.5, -8), infoData)
            end

            function Elements:AddButton(name, callback, infoData)
                local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                local Btn = Create("TextButton", {Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
                Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Btn, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})
                AddBounce(Btn)
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = HoverColor}, 0.2) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = BackgroundColor}, 0.2) end)
                Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
                AddInfoIcon(BtnFrame, UDim2.new(1, -40, 0.5, -8), infoData)
            end

            function Elements:AddToggle(name, default, callback, infoData)
                local state = default or false
                local TogFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                Create("TextLabel", {Parent = TogFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                local Lever = Create("TextButton", {Parent = TogFrame, Text = "", BackgroundColor3 = state and AccentColor or Color3.fromRGB(45, 45, 50), Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), AutoButtonColor = false})
                Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
                AddBounce(Lever)
                local Knob = Create("Frame", {Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 14, 0, 14), Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                local function internalSet(val)
                    state = val
                    Tween(Lever, {BackgroundColor3 = state and AccentColor or Color3.fromRGB(45, 45, 50)}, 0.3)
                    Tween(Knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.3)
                    if callback then callback(state) end
                end
                Lever.MouseButton1Click:Connect(function() internalSet(not state) end)
                AddInfoIcon(TogFrame, UDim2.new(1, -70, 0.5, -8), infoData)
                Moonveil.ConfigElements[name] = { Set = internalSet, Get = function() return state end }
            end

            function Elements:AddSlider(name, min, max, default, callback, infoData)
                local val = default or min
                local SliFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
                Create("TextLabel", {Parent = SliFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                local ValTxt = Create("TextLabel", {Parent = SliFrame, Text = tostring(val), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 15), Position = UDim2.new(1, -40, 0, 0), TextXAlignment = Enum.TextXAlignment.Right})
                local TrackBase = Create("Frame", {Parent = SliFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 25)})
                Create("UICorner", {Parent = TrackBase, CornerRadius = UDim.new(1, 0)})
                Create("UIStroke", {Parent = TrackBase, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})
                local Fill = Create("Frame", {Parent = TrackBase, BackgroundColor3 = AccentColor, Size = UDim2.new((val-min)/(max-min), 0, 1, 0)})
                Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                local Knob = Create("Frame", {Parent = Fill, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)})
                Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

                local function internalSet(v)
                    val = math.clamp(v, min, max)
                    ValTxt.Text = tostring(val)
                    Tween(Fill, {Size = UDim2.new((val-min)/(max-min), 0, 1, 0)}, 0.1)
                    if callback then callback(val) end
                end

                local dragging = false
                Knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                UserInputService.InputChanged:Connect(function(input) 
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
                        local pos = math.clamp((input.Position.X - TrackBase.AbsolutePosition.X) / TrackBase.AbsoluteSize.X, 0, 1)
                        internalSet(math.floor(min + ((max - min) * pos)))
                    end 
                end)
                AddInfoIcon(SliFrame, UDim2.new(1, -65, 0, 0), infoData)
                Moonveil.ConfigElements[name] = { Set = internalSet, Get = function() return val end }
            end

            function Elements:AddDropdown(name, options, isMulti, callback, infoData)
                local selected = isMulti and {} or (options[1] or nil)
                local dropped = false
                local optionButtons = {}
                local maxVisible = math.min(#options, 3)
                local listHeight = maxVisible * 25
                
                local DropFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), ClipsDescendants = true})
                Create("TextLabel", {Parent = DropFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                
                local MainBtn = Create("TextButton", {Parent = DropFrame, Text = isMulti and "Select Options..." or "Select...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 20), AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left})
                Create("UIPadding", {Parent = MainBtn, PaddingLeft = UDim.new(0, 8)})
                Create("UICorner", {Parent = MainBtn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = MainBtn, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})
                AddBounce(MainBtn, 0.98)
                local Arrow = Create("TextLabel", {Parent = MainBtn, Text = "▼", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -28, 0, 0)})

                local SearchBox = Create("TextBox", {Parent = DropFrame, PlaceholderText = "Search...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(15, 15, 18), Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 50), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Visible = false})
                Create("UIPadding", {Parent = SearchBox, PaddingLeft = UDim.new(0, 8)})
                Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = SearchBox, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})

                local ListFrame = Create("ScrollingFrame", {Parent = DropFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, listHeight), Position = UDim2.new(0, 10, 0, 78), CanvasSize = UDim2.new(0, 0, 0, #options * 25), ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85), BorderSizePixel = 0})
                Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 4)})
                local DList = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})

                local function UpdateText()
                    if isMulti then
                        local txt = "" for _, v in pairs(selected) do txt = txt .. v .. ", " end
                        MainBtn.Text = txt == "" and "Select Options..." or txt:sub(1, -3)
                    else MainBtn.Text = selected or "Select..." end
                end

                local function internalSet(v)
                    selected = v UpdateText()
                    for _, btn in ipairs(optionButtons) do
                        local isSel = isMulti and (table.find(selected, btn.Text) ~= nil) or (selected == btn.Text)
                        Tween(btn, {TextColor3 = isSel and TextColor or SubTextColor}, 0.2)
                        Tween(btn:FindFirstChild("Frame"), {Size = isSel and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)}, 0.2)
                    end
                    if callback then callback(selected) end
                end

                for _, opt in pairs(options) do
                    local isInitialSelected = (not isMulti and selected == opt)
                    local OptBtn = Create("TextButton", {Parent = ListFrame, Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = isInitialSelected and TextColor or SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25), AutoButtonColor = false})
                    Create("Frame", {Parent = OptBtn, BackgroundColor3 = AccentColor, Size = isInitialSelected and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0), BackgroundTransparency = 0.8})
                    table.insert(optionButtons, OptBtn)
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        if isMulti then
                            if table.find(selected, opt) then table.remove(selected, table.find(selected, opt)) else table.insert(selected, opt) end
                            internalSet(selected)
                        else
                            internalSet(opt) dropped = false Tween(Arrow, {Rotation = 0}, 0.3) Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3) SearchBox.Visible = false
                        end
                    end)
                end
                UpdateText()

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    local q = SearchBox.Text:lower()
                    for _, btn in ipairs(optionButtons) do btn.Visible = (q == "" or string.find(btn.Text:lower(), q) ~= nil) end
                end)

                DList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    ListFrame.CanvasSize = UDim2.new(0, 0, 0, DList.AbsoluteContentSize.Y)
                    if dropped then
                        local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, listHeight)
                        ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50 + 32 + dynamicHeight)}, 0.1)
                    end
                end)

                MainBtn.MouseButton1Click:Connect(function()
                    dropped = not dropped
                    if dropped then
                        SearchBox.Visible = true SearchBox.Text = "" Tween(Arrow, {Rotation = 180}, 0.3)
                        local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, listHeight)
                        ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50 + 32 + dynamicHeight)}, 0.3)
                    else
                        SearchBox.Visible = false Tween(Arrow, {Rotation = 0}, 0.3) Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                    end
                end)
                AddInfoIcon(DropFrame, UDim2.new(1, -25, 0, 0), infoData)
                Moonveil.ConfigElements[name] = { Set = internalSet, Get = function() return selected end }
            end

            function Elements:AddTextbox(name, placeholder, callback, infoData)
                local TxtFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
                Create("TextLabel", {Parent = TxtFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                local Input = Create("TextBox", {Parent = TxtFrame, PlaceholderText = placeholder or "Type here...", Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
                Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 8)})
                Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = Input, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})

                local function internalSet(v) Input.Text = tostring(v) if callback then callback(v) end end
                Input.FocusLost:Connect(function() internalSet(Input.Text) end)
                AddInfoIcon(TxtFrame, UDim2.new(1, -25, 0, 0), infoData)
                Moonveil.ConfigElements[name] = { Set = internalSet, Get = function() return Input.Text end }
            end

            function Elements:AddColorPicker(name, defaultColor, callback, infoData)
                local color = defaultColor or Color3.fromRGB(255, 255, 255)
                local h, s, v_hsv = color:ToHSV()
                local dropped = false
                
                local CFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), ClipsDescendants = true})
                Create("TextLabel", {Parent = CFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                local DisplayBtn = Create("TextButton", {Parent = CFrame, Text = "", BackgroundColor3 = color, Size = UDim2.new(0, 30, 0, 16), Position = UDim2.new(1, -40, 0.5, -8), AutoButtonColor = false})
                Create("UICorner", {Parent = DisplayBtn, CornerRadius = UDim.new(0, 4)})
                Create("UIStroke", {Parent = DisplayBtn, Color = Color3.fromRGB(255,255,255), Transparency = 0.8, Thickness = 1})
                AddBounce(DisplayBtn)

                local PickerArea = Create("Frame", {Parent = CFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 140), Position = UDim2.new(0, 10, 0, 35)})
                Create("UICorner", {Parent = PickerArea, CornerRadius = UDim.new(0, 4)})

                local PickerClose = Create("TextButton", {Parent = PickerArea, Text = "X", Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(30, 20, 20), Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -22, 0, 4), ZIndex = 50, AutoButtonColor = false})
                Create("UICorner", {Parent = PickerClose, CornerRadius = UDim.new(0, 4)})
                AddBounce(PickerClose)
                PickerClose.MouseEnter:Connect(function() Tween(PickerClose, {TextColor3 = Color3.fromRGB(255, 60, 60)}, 0.2) end)
                PickerClose.MouseLeave:Connect(function() Tween(PickerClose, {TextColor3 = SubTextColor}, 0.2) end)
                PickerClose.MouseButton1Click:Connect(function() dropped = false Tween(CFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.3) end)

                local SVMap = Create("TextButton", {Parent = PickerArea, Text = "", BackgroundColor3 = Color3.fromHSV(h, 1, 1), Size = UDim2.new(1, -45, 0, 90), Position = UDim2.new(0, 10, 0, 10), AutoButtonColor = false, Active = true})
                Create("UICorner", {Parent = SVMap, CornerRadius = UDim.new(0, 4)})
                local WhiteGrad = Create("Frame", {Parent = SVMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 2})
                Create("UIGradient", {Parent = WhiteGrad, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}), Rotation = 0})
                local BlackGrad = Create("Frame", {Parent = SVMap, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), ZIndex = 3})
                Create("UIGradient", {Parent = BlackGrad, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}), Rotation = 90})
                local SVRing = Create("Frame", {Parent = BlackGrad, Size = UDim2.new(0, 10, 0, 10), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(s, 0, 1-v_hsv, 0), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 4})
                Create("UICorner", {Parent = SVRing, CornerRadius = UDim.new(1, 0)})
                Create("UIStroke", {Parent = SVRing, Color = Color3.new(0,0,0), Thickness = 1})

                local HueSlider = Create("TextButton", {Parent = PickerArea, Text = "", Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 110), AutoButtonColor = false, BackgroundColor3 = Color3.new(1,1,1), Active = true})
                Create("UICorner", {Parent = HueSlider, CornerRadius = UDim.new(0, 4)})
                Create("UIGradient", {Parent = HueSlider, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})
                local HueRing = Create("Frame", {Parent = HueSlider, Size = UDim2.new(0, 6, 0, 15), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(h, 0, 0.5, 0), BackgroundColor3 = Color3.new(1,1,1)})
                Create("UICorner", {Parent = HueRing, CornerRadius = UDim.new(0, 2)})
                Create("UIStroke", {Parent = HueRing, Color = Color3.new(0,0,0), Thickness = 1})

                local function internalSet(hexString)
                    local s_check, c = pcall(function() return Color3.fromHex(hexString) end)
                    if s_check then
                        color = c h, s, v_hsv = color:ToHSV()
                        DisplayBtn.BackgroundColor3 = color SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        SVRing.Position = UDim2.new(s, 0, 1-v_hsv, 0) HueRing.Position = UDim2.new(h, 0, 0.5, 0)
                        if callback then callback(color) end
                    end
                end

                local function UpdateColor()
                    color = Color3.fromHSV(h, s, v_hsv)
                    DisplayBtn.BackgroundColor3 = color SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    if callback then callback(color) end
                end

                local draggingSV, draggingHue = false, false
                SVMap.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = true if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = false end end end)
                HueSlider.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingHue = true if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = false end end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSV = false draggingHue = false if PageObj and PageObj.Scroll then PageObj.Scroll.ScrollingEnabled = true end end end)
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if draggingSV then
                            s = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                            v_hsv = 1 - math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                            SVRing.Position = UDim2.new(s, 0, 1-v_hsv, 0) UpdateColor()
                        elseif draggingHue then
                            h = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                            HueRing.Position = UDim2.new(h, 0, 0.5, 0) UpdateColor()
                        end
                    end
                end)
                DisplayBtn.MouseButton1Click:Connect(function() dropped = not dropped Tween(CFrame, {Size = UDim2.new(1, 0, 0, dropped and 185 or 30)}, 0.3) end)
                AddInfoIcon(CFrame, UDim2.new(1, -65, 0, 7), infoData)
                Moonveil.ConfigElements[name] = { Set = internalSet, Get = function() return color:ToHex() end }
            end

            return Elements
        end
        return PageObj
    end

    -- // POPULATE HOME CONTENT (CURRENTLY EMPTY, READY FOR LATER)
    local MainTab = Moonveil.CreatedTabs.Main
    
    -- Create Pages (So the screen isn't completely blank, but there is no content yet)
    local M_Page1 = MainTab:CreatePage("Page 1")
    local M_Page2 = MainTab:CreatePage("Page 2")

    -- NOTE: Empty for now.
    -- Later, if you want to add elements (e.g., adding a button to M_Page1), you can just add:
    -- local TestSection = M_Page1:CreateSection("Test")
    -- TestSection:AddButton("Click Me", function() print("Awesome") end)
    
    -- // SETUP SETTINGS TAB CONTENT
    local SettingsTab = Moonveil.CreatedTabs.Settings
    local S_Page1 = SettingsTab:CreatePage("Settings")
    local DisplayCard = S_Page1:CreateSection("Display Settings")

    DisplayCard:AddDropdown("UI Size", {"PC", "Mobile", "Small"}, false, function(value)
        Moonveil:SetUISize(value)
    end, {
        Title = "UI Scaler",
        Description = "Select the UI size to fit your screen."
    })
    
end