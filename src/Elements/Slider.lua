local import = ...
local Util = import("Util")
local New, Tween, Corner = Util.New, Util.Tween, Util.Corner

-- Slider: sag ustteki degere tiklayarak klavyeyle dogrudan sayi da girilebilir
return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local min, max, step = o.Min or 0, o.Max or 100, o.Step or 1
    local value = math.clamp(o.Default or min, min, max)
    local row, label = ctx.Row(52, o.Title)
    label.Size = UDim2.new(1, -90, 0, 30)

    local valBox = New("TextBox", {
        Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 4), Size = UDim2.fromOffset(74, 22),
        Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = theme.SubText, ClearTextOnFocus = false, Text = "", ZIndex = 3,
    }, { Corner(4) })

    local track = New("Frame", { Parent = row, Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = theme.Stroke }, { Corner(3) })
    local fill = New("Frame", { Parent = track, Size = UDim2.fromScale(0, 1), BackgroundColor3 = theme.Accent }, { Corner(3) })
    New("Frame", { Parent = fill, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.new(1, 1, 1) }, { Corner(6) })

    local obj = {}
    local function render()
        fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
        valBox.Text = tostring(value) .. (o.Suffix or "")
    end

    function obj:Set(v, silent)
        v = math.clamp(Util.round(v, step), min, max)
        v = tonumber(string.format("%.6g", v))
        if v == value then render() return end
        value = v
        if o.Flag then Window.Flags[o.Flag] = value end
        render()
        if not silent and o.Callback then ctx.Call(o.Callback, value) end
    end
    function obj:Get() return value end

    valBox.Focused:Connect(function()
        valBox.Text = tostring(value)
        Tween(valBox, 0.12, { TextColor3 = theme.Accent })
    end)
    valBox.FocusLost:Connect(function()
        Tween(valBox, 0.12, { TextColor3 = theme.SubText })
        local num = tonumber(valBox.Text:match("[-%d%.]+"))
        if num then obj:Set(num) else render() end
    end)

    Util.Drag(track, function(pos)
        local a = math.clamp((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        obj:Set(min + (max - min) * a)
    end, ctx.Connect)

    render()
    ctx.Register(o.Flag, value, function(v) obj:Set(v) end)
    return obj
end
