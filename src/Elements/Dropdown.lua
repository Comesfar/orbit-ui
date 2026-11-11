local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local UserInputService = Util.Service("UserInputService")

-- Dropdown: disari basinca kapanir, Searchable = true (veya >8 secenekte otomatik) ile icinde arama yapilir
return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local values = o.Values or {}
    local multi = o.Multi or false
    local searchable = o.Searchable ~= nil and o.Searchable or (#values > 8)
    local selected
    if multi then
        selected = {}
        for _, v in ipairs(o.Default or {}) do selected[v] = true end
    else
        selected = o.Default
    end

    local HEADER = 38
    local SEARCH_H = searchable and 30 or 0
    local row = ctx.Row(HEADER, o.Title)
    local hbtn = ctx.Hoverable(row, HEADER)
    local valLabel = New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -30, 0, 0), Size = UDim2.new(0.5, -30, 0, HEADER), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = theme.SubText, Text = "", TextTruncate = Enum.TextTruncate.AtEnd })
    local arrow = New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(20, HEADER), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.SubText, Text = "v" })

    local filterBox
    if searchable then
        filterBox = New("TextBox", {
            Parent = row, Position = UDim2.fromOffset(8, HEADER + 2), Size = UDim2.new(1, -16, 0, 24),
            BackgroundColor3 = theme.Background, ClearTextOnFocus = false, Font = Enum.Font.Gotham,
            TextSize = 11, TextColor3 = theme.Text, PlaceholderText = "Filtrele...", PlaceholderColor3 = theme.SubText,
            Text = "", TextXAlignment = Enum.TextXAlignment.Left,
        }, { Corner(6), Stroke(theme.Stroke), Pad(8, 0, 8, 0) })
    end

    local list = New("ScrollingFrame", {
        Parent = row, Position = UDim2.fromOffset(8, HEADER + SEARCH_H),
        Size = UDim2.new(1, -16, 1, -HEADER - SEARCH_H - 8), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(),
    }, { New("UIListLayout", { Padding = UDim.new(0, 2) }) })

    local listLayout = list:FindFirstChildOfClass("UIListLayout")
    if listLayout then
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            list.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 4)
        end)
    end

    local open = false
    local obj = {}
    local buttons = {}

    local function value()
        if not multi then return selected end
        local t = {}
        for _, v in ipairs(values) do if selected[v] then table.insert(t, v) end end
        return t
    end
    local function text()
        if multi then
            local t = {}
            for _, v in ipairs(values) do if selected[v] then table.insert(t, tostring(v)) end end
            return #t > 0 and table.concat(t, ", ") or "Yok"
        end
        return selected ~= nil and tostring(selected) or "Sec"
    end
    local function refresh()
        valLabel.Text = text()
        local q = filterBox and filterBox.Text:lower() or ""
        for v, b in pairs(buttons) do
            local on = multi and selected[v] or selected == v
            b.Visible = (q == "") or (tostring(v):lower():find(q, 1, true) ~= nil)
            Tween(b, 0.12, { BackgroundTransparency = on and 0 or 1, TextColor3 = on and Color3.new(1, 1, 1) or theme.SubText })
        end
    end
    if filterBox then
        filterBox:GetPropertyChangedSignal("Text"):Connect(refresh)
    end

    local function listHeight() return math.min(#values, 5) * 28 + 8 + SEARCH_H end
    function obj:Open()
        open = true
        if Window._openDropdown and Window._openDropdown ~= obj then
            Window._openDropdown:Close()
        end
        Window._openDropdown = obj
        Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, HEADER + listHeight()) })
        Tween(arrow, 0.2, { Rotation = 180 })
    end
    function obj:Close()
        if not open then return end
        open = false
        if Window._openDropdown == obj then Window._openDropdown = nil end
        if filterBox then filterBox.Text = "" end
        Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, HEADER) })
        Tween(arrow, 0.2, { Rotation = 0 })
    end

    -- Disariya tiklaninca kapat
    ctx.Connect(UserInputService.InputBegan, function(i)
        if not open then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local p = i.Position
            local rp, rs = row.AbsolutePosition, row.AbsoluteSize
            if p.X < rp.X or p.X > rp.X + rs.X or p.Y < rp.Y or p.Y > rp.Y + rs.Y then
                obj:Close()
            end
        end
    end)

    local function build()
        for _, b in pairs(buttons) do b:Destroy() end
        buttons = {}
        for idx, v in ipairs(values) do
            local b = New("TextButton", { Parent = list, LayoutOrder = idx, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = theme.Accent, BackgroundTransparency = 1, AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(v) }, { Corner(6), Pad(10, 0, 10, 0) })
            buttons[v] = b
            b.Activated:Connect(function()
                if multi then selected[v] = not selected[v] or nil else selected = v end
                if o.Flag then Window.Flags[o.Flag] = value() end
                refresh()
                if o.Callback then ctx.Call(o.Callback, value()) end
                if not multi then obj:Close() end
            end)
        end
        refresh()
    end
    function obj:Set(v, silent)
        if multi then
            selected = {}
            for _, x in ipairs(v) do selected[x] = true end
        else
            selected = v
        end
        if o.Flag then Window.Flags[o.Flag] = value() end
        refresh()
        if not silent and o.Callback then ctx.Call(o.Callback, value()) end
    end
    function obj:Get() return value() end
    function obj:Refresh(newValues)
        values = newValues
        build()
        if open then Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, HEADER + listHeight()) }) end
    end
    hbtn.Activated:Connect(function() if open then obj:Close() else obj:Open() end end)
    build()
    ctx.Register(o.Flag, value(), function(v) obj:Set(v) end)
    return obj
end
