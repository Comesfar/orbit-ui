local import = ...
local Util = import("Util")
local New, Tween, Corner, Pad = Util.New, Util.Tween, Util.Corner, Util.Pad

return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local values = o.Values or {}
    local multi = o.Multi or false
    local selected
    if multi then
        selected = {}
        for _, v in ipairs(o.Default or {}) do selected[v] = true end
    else
        selected = o.Default
    end

    local HEADER = 38
    local row = ctx.Row(HEADER, o.Title)
    local hbtn = ctx.Hoverable(row, HEADER)
    local valLabel = New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -30, 0, 0), Size = UDim2.new(0.5, -30, 0, HEADER), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = theme.SubText, Text = "", TextTruncate = Enum.TextTruncate.AtEnd })
    local arrow = New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(20, HEADER), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.SubText, Text = "v" })
    local list = New("ScrollingFrame", { Parent = row, Position = UDim2.fromOffset(8, HEADER), Size = UDim2.new(1, -16, 1, -HEADER - 8), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new() }, { New("UIListLayout", { Padding = UDim.new(0, 2) }) })

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
        for v, b in pairs(buttons) do
            local on = multi and selected[v] or selected == v
            Tween(b, 0.12, { BackgroundTransparency = on and 0 or 1, TextColor3 = on and Color3.new(1, 1, 1) or theme.SubText })
        end
    end
    local function listHeight() return math.min(#values, 5) * 28 + 8 end
    function obj:Open()
        open = true
        Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, HEADER + listHeight()) })
        Tween(arrow, 0.2, { Rotation = 180 })
    end
    function obj:Close()
        open = false
        Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, HEADER) })
        Tween(arrow, 0.2, { Rotation = 0 })
    end
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
