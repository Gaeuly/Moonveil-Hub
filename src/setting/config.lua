-- // src/setting/config.lua
-- // Sistem Logic & UI Config (Saves Loader)

return function(Moonveil)
    local Create = Moonveil.Create
    local Tween = Moonveil.Tween
    local AddBounce = Moonveil.AddBounce
    local AddInfoIcon = Moonveil.AddInfoIcon
    local FS = Moonveil.FileSystem
    local HttpService = Moonveil.HttpService

    local AccentColor = Moonveil.Theme.AccentColor
    local BackgroundColor = Moonveil.Theme.BackgroundColor
    local CardColor = Moonveil.Theme.CardColor
    local HoverColor = Moonveil.Theme.HoverColor
    local TextColor = Moonveil.Theme.TextColor
    local SubTextColor = Moonveil.Theme.SubTextColor

    -- Buat Section khusus Config
    local SavesCard = Moonveil.SettingsPage:CreateSection("Config")
    local ItemContainer = SavesCard.ItemContainer -- Connects directly to the UI Core
    
    local folderName = "Moonveil-HUB"
    if not FS.isfolder(folderName) then FS.makefolder(folderName) end

    -- Logika Builder Config Manager
    local ManagerFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 240)})
    
    local ManagerSearch = Create("TextBox", {Parent = ManagerFrame, PlaceholderText = "Search Saves Loader...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
    Create("UIPadding", {Parent = ManagerSearch, PaddingLeft = UDim.new(0, 8)})
    Create("UICorner", {Parent = ManagerSearch, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = ManagerSearch, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})

    local Monitor = Create("ScrollingFrame", {Parent = ManagerFrame, BackgroundColor3 = Color3.fromRGB(15, 15, 18), Size = UDim2.new(1, -20, 0, 110), Position = UDim2.new(0, 10, 0, 35), ScrollBarThickness = 2, BorderSizePixel = 0, CanvasSize = UDim2.new(0, 0, 0, 0)})
    Create("UICorner", {Parent = Monitor, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = Monitor, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})
    local MonitorLayout = Create("UIListLayout", {Parent = Monitor, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    Create("UIPadding", {Parent = Monitor, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

    MonitorLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Monitor.CanvasSize = UDim2.new(0, 0, 0, MonitorLayout.AbsoluteContentSize.Y + 10)
    end)

    local deleteMode = false
    local editMode = false
    local selectedForDelete = {}
    local editTargetFile = ""

    local Controls = Create("Frame", {Parent = ManagerFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 80), Position = UDim2.new(0, 10, 0, 155)})

    local NameBox = Create("TextBox", {Parent = Controls, PlaceholderText = "Enter save name...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
    Create("UIPadding", {Parent = NameBox, PaddingLeft = UDim.new(0, 8)})
    Create("UICorner", {Parent = NameBox, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = NameBox, Color = Color3.fromRGB(45, 45, 50), Thickness = 1})

    local CreateBtn = Create("TextButton", {Parent = Controls, Text = "Create Save", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = AccentColor, Size = UDim2.new(0.5, -5, 0, 26), Position = UDim2.new(0, 0, 0, 35), AutoButtonColor = false})
    Create("UICorner", {Parent = CreateBtn, CornerRadius = UDim.new(0, 4)})
    AddBounce(CreateBtn)

    local DeleteTogBtn = Create("TextButton", {Parent = Controls, Text = "Delete Mode: OFF", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(45, 45, 50), Size = UDim2.new(0.5, -5, 0, 26), Position = UDim2.new(0.5, 5, 0, 35), AutoButtonColor = false})
    Create("UICorner", {Parent = DeleteTogBtn, CornerRadius = UDim.new(0, 4)})
    AddBounce(DeleteTogBtn)

    local ActionArea = Create("Frame", {Parent = Controls, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 35), Visible = false})
    
    local ConfirmActionBtn = Create("TextButton", {Parent = ActionArea, Text = "Confirm", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = Color3.fromRGB(200, 50, 50), Size = UDim2.new(0.5, -5, 0, 26), Position = UDim2.new(0, 0, 0, 0), AutoButtonColor = false})
    Create("UICorner", {Parent = ConfirmActionBtn, CornerRadius = UDim.new(0, 4)})
    AddBounce(ConfirmActionBtn)

    local CancelActionBtn = Create("TextButton", {Parent = ActionArea, Text = "Cancel", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(60, 60, 65), Size = UDim2.new(0.5, -5, 0, 26), Position = UDim2.new(0.5, 5, 0, 0), AutoButtonColor = false})
    Create("UICorner", {Parent = CancelActionBtn, CornerRadius = UDim.new(0, 4)})
    AddBounce(CancelActionBtn)

    AddInfoIcon(ManagerFrame, UDim2.new(1, -20, 0, -22), {
        Title = "Saves Loader Config",
        Description = "Create or delete specific settings locally."
    })

    local InternalConfirmPopup = Create("Frame", {Parent = ManagerFrame, BackgroundColor3 = Color3.fromRGB(20, 20, 24), Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10), ZIndex = 60, BackgroundTransparency = 1, Visible = false})
    Create("UICorner", {Parent = InternalConfirmPopup, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = InternalConfirmPopup, Color = Color3.fromRGB(180, 50, 50), Thickness = 1, Transparency = 1})
    
    local P_Title = Create("TextLabel", {Parent = InternalConfirmPopup, Text = "Confirm Deletion?", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.fromRGB(255, 60, 60), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 40), TextTransparency = 1, ZIndex = 61})
    local P_Desc = Create("TextLabel", {Parent = InternalConfirmPopup, Text = "You are about to delete these specific saves loaders permanently.", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 70), TextWrapped = true, TextTransparency = 1, ZIndex = 61})
    
    local P_Yes = Create("TextButton", {Parent = InternalConfirmPopup, Text = "Yes", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(180, 50, 50), Size = UDim2.new(0.5, -30, 0, 30), Position = UDim2.new(0, 20, 0, 130), AutoButtonColor = false, BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 61})
    Create("UICorner", {Parent = P_Yes, CornerRadius = UDim.new(0, 4)})
    AddBounce(P_Yes)
    
    local P_No = Create("TextButton", {Parent = InternalConfirmPopup, Text = "No", Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(45, 45, 50), Size = UDim2.new(0.5, -30, 0, 30), Position = UDim2.new(0.5, 10, 0, 130), AutoButtonColor = false, BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 61})
    Create("UICorner", {Parent = P_No, CornerRadius = UDim.new(0, 4)})
    AddBounce(P_No)

    local function HideInternalPopup()
        Tween(InternalConfirmPopup, {BackgroundTransparency = 1}, 0.3)
        Tween(InternalConfirmPopup:FindFirstChild("UIStroke"), {Transparency = 1}, 0.3)
        Tween(P_Title, {TextTransparency = 1}, 0.3)
        Tween(P_Desc, {TextTransparency = 1}, 0.3)
        Tween(P_Yes, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        Tween(P_No, {BackgroundTransparency = 1, TextTransparency = 1}, 0.3)
        task.wait(0.3)
        InternalConfirmPopup.Visible = false
    end

    local function RefreshMonitor()
        for _, v in ipairs(Monitor:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end
        selectedForDelete = {}

        local files = FS.listfiles(folderName)
        for _, filepath in ipairs(files) do
            local rawName = filepath:match("([^/\\]+)%.json$")
            if rawName then
                local displayFName = rawName:gsub("_%d+%.%d+$", ""):gsub("_%d+$", "")
                local Row = Create("Frame", {Parent = Monitor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, 0, 0, 30)})
                Create("UICorner", {Parent = Row, CornerRadius = UDim.new(0, 4)})
                
                Create("TextLabel", {Parent = Row, Text = displayFName, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                
                local LoadBtn = Create("TextButton", {Parent = Row, Text = "Load", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(45, 120, 60), Size = UDim2.new(0, 35, 0, 20), Position = UDim2.new(1, -70, 0.5, -10), AutoButtonColor = false})
                Create("UICorner", {Parent = LoadBtn, CornerRadius = UDim.new(0, 4)})
                AddBounce(LoadBtn)

                local EditBtn = Create("TextButton", {Parent = Row, Text = "Edit", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(150, 100, 45), Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -33, 0.5, -10), AutoButtonColor = false})
                Create("UICorner", {Parent = EditBtn, CornerRadius = UDim.new(0, 4)})
                AddBounce(EditBtn)

                local SelectionMask = Create("TextButton", {Parent = Row, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, -80, 1, 0), ZIndex = 2})
                
                SelectionMask.MouseButton1Click:Connect(function()
                    if deleteMode then
                        if selectedForDelete[filepath] then
                            selectedForDelete[filepath] = nil
                            Tween(Row, {BackgroundColor3 = BackgroundColor}, 0.2)
                        else
                            selectedForDelete[filepath] = true
                            Tween(Row, {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}, 0.2)
                        end
                    end
                end)

                LoadBtn.MouseButton1Click:Connect(function()
                    if deleteMode or editMode then return end
                    local s, data = pcall(function() return HttpService:JSONDecode(FS.readfile(filepath)) end)
                    if s and type(data) == "table" then
                        for k, v in pairs(data) do
                            if Moonveil.ConfigElements[k] and Moonveil.ConfigElements[k].Set then
                                Moonveil.ConfigElements[k].Set(v)
                            end
                        end
                        Moonveil.Notify({Title = "Saves Loader", Description = "Successfully loaded " .. displayFName})
                    end
                end)

                EditBtn.MouseButton1Click:Connect(function()
                    if deleteMode then return end
                    editMode = true
                    editTargetFile = filepath
                    NameBox.Text = displayFName
                    CreateBtn.Visible = false
                    DeleteTogBtn.Visible = false
                    ActionArea.Visible = true
                    ConfirmActionBtn.Text = "Save Edit"
                    ConfirmActionBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 200)
                end)
            end
        end
    end

    local function ExecuteSave(saveName)
        local payload = {}
        for k, el in pairs(Moonveil.ConfigElements) do if el.Get then payload[k] = el.Get() end end
        local encoded = HttpService:JSONEncode(payload)
        local finalPath = folderName .. "/" .. saveName .. "_" .. tostring(math.floor(tick())) .. ".json"
        FS.writefile(finalPath, encoded)
        RefreshMonitor()
        Moonveil.Notify({Title = "Saved Successfully", Description = "Config [" .. saveName .. "] secured."})
    end

    CreateBtn.MouseButton1Click:Connect(function() if NameBox.Text ~= "" then ExecuteSave(NameBox.Text) end end)

    DeleteTogBtn.MouseButton1Click:Connect(function()
        if editMode then return end
        deleteMode = not deleteMode
        DeleteTogBtn.Text = deleteMode and "Delete Mode: ON" or "Delete Mode: OFF"
        Tween(DeleteTogBtn, {BackgroundColor3 = deleteMode and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(45, 45, 50)}, 0.2)
        ActionArea.Visible = deleteMode
        CreateBtn.Visible = not deleteMode
        if deleteMode then ConfirmActionBtn.Text = "Delete Selected" ConfirmActionBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        else RefreshMonitor() end
    end)

    ConfirmActionBtn.MouseButton1Click:Connect(function()
        if deleteMode then
            InternalConfirmPopup.Visible = true
            Tween(InternalConfirmPopup, {BackgroundTransparency = 0.1}, 0.3)
            Tween(InternalConfirmPopup:FindFirstChild("UIStroke"), {Transparency = 0.5}, 0.3)
            Tween(P_Title, {TextTransparency = 0}, 0.3)
            Tween(P_Desc, {TextTransparency = 0}, 0.3)
            Tween(P_Yes, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
            Tween(P_No, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)
        elseif editMode then
            local newName = NameBox.Text
            if newName ~= "" then pcall(function() FS.delfile(editTargetFile) end) ExecuteSave(newName) end
            editMode = false ActionArea.Visible = false CreateBtn.Visible = true DeleteTogBtn.Visible = true
            RefreshMonitor()
        end
    end)

    P_Yes.MouseButton1Click:Connect(function()
        for file, _ in pairs(selectedForDelete) do pcall(function() FS.delfile(file) end) end
        deleteMode = false
        DeleteTogBtn.Text = "Delete Mode: OFF" DeleteTogBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        ActionArea.Visible = false CreateBtn.Visible = true
        RefreshMonitor() Moonveil.Notify({Title = "Deletions Complete", Description = "Selected saves erased from system."})
        HideInternalPopup()
    end)

    P_No.MouseButton1Click:Connect(function() HideInternalPopup() end)

    CancelActionBtn.MouseButton1Click:Connect(function()
        editMode = false deleteMode = false
        DeleteTogBtn.Text = "Delete Mode: OFF" DeleteTogBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        ActionArea.Visible = false CreateBtn.Visible = true DeleteTogBtn.Visible = true
        NameBox.Text = "" RefreshMonitor()
    end)

    ManagerSearch:GetPropertyChangedSignal("Text"):Connect(function()
        local q = ManagerSearch.Text:lower()
        for _, v in ipairs(Monitor:GetChildren()) do
            if v:IsA("Frame") then
                local lbl = v:FindFirstChildOfClass("TextLabel")
                if lbl then v.Visible = (q == "" or string.find(lbl.Text:lower(), q) ~= nil) end
            end
        end
    end)

    RefreshMonitor()
end