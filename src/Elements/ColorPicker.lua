local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke = Util.New, Util.Tween, Util.Corner, Util.Stroke

return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local HEADER = 38
    local color = o.Default or Color3.fromRGB(255, 255, 255)
    local h, s, v = color:ToHSV()
    local row = ctx.Row(HEADER, o.Title)
    local hbtn = ctx.Hoverable(row, HEADER)
    local preview = New("Frame", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0, HEADER / 2), Size = UDim2.fromOffset(34, 20), BackgroundColor3 = color, ZIndex = 2 }, { Corner(5), Stroke(theme.Stroke) })

    local sv = New("Frame", { Parent = row, Position = UDim2.fromOffset(12, HEADER + 4), Size = UDim2.new(1, -62, 0, 110), BackgroundColor3 = Color3.fromHSV(h, 1, 1) }, { Corner(6) })
    New("Frame", { Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1) }, { Corner(6), New("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
    New("Frame", { Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0) }, { Corner(6), New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
    local svKnob = New("Frame", { Parent = sv, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(10, 10), BackgroundTransparency = 1, ZIndex = 3 }, { Corner(5), Stroke(Color3.new(1, 1, 1), 2) })

    local hue = New("Frame", { Parent = row, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, HEADER + 4), Size = UDim2.fromOffset(28, 110), BackgroundColor3 = Color3.new(1, 1, 1) }, {
        Corner(6),
        New("UIGradient", { Rotation = 90, Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
            ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)), ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        }) }),
    })
    local hueKnob = New("Frame", { Parent = hue, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.new(1, 4, 0, 4), BackgroundColor3 = Color3.new(1, 1, 1) }, { Corner(2), Stroke(Color3.new(0, 0, 0), 1) })

    local obj = {}
    local function render(fire)
        color = Color3.fromHSV(h, s, v)
        preview.BackgroundColor3 = color
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svKnob.Position = UDim2.fromScale(s, 1 - v)
        hueKnob.Position = UDim2.fromScale(0.5, h)
        if o.Flag then Window.Flags[o.Flag] = color end
        if fire and o.Callback then ctx.Call(o.Callback, color) end
    end
    Util.Drag(sv, function(pos)
        s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
        v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
        render(true)
    end, ctx.Connect)
    Util.Drag(hue, function(pos)
        h = math.clamp((pos.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
        render(true)
    end, ctx.Connect)
    local open = false
    hbtn.Activated:Connect(function()
        open = not open
        Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, open and HEADER + 124 or HEADER) })
    end)
    function obj:Set(c, silent)
        h, s, v = c:ToHSV()
        render(not silent)
    end
    function obj:Get() return color end
    render(false)
    ctx.Register(o.Flag, color, function(c) obj:Set(c) end)
    return obj
end
