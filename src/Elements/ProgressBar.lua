local import = ...
local Util = import("Util")
local New, Tween, Corner = Util.New, Util.Tween, Util.Corner

-- ProgressBar({ Title, Min, Max, Default, Suffix, Flag })
return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local min, max = o.Min or 0, o.Max or 100
    local value = math.clamp(o.Default or min, min, max)

    local row, label = ctx.Row(48, o.Title)
    label.Size = UDim2.new(1, -90, 0, 24)

    local valLabel = New("TextLabel", {
        Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(80, 24),
        Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
        TextColor3 = theme.SubText, Text = "",
    })

    local track = New("Frame", {
        Parent = row, Position = UDim2.new(0, 12, 0, 28), Size = UDim2.new(1, -24, 0, 8),
        BackgroundColor3 = theme.Stroke,
    }, { Corner(4) })

    local fill = New("Frame", {
        Parent = track, Size = UDim2.fromScale(0, 1), BackgroundColor3 = theme.Accent,
    }, { Corner(4) })

    local obj = {}

    local function render(animate)
        local a = math.clamp((value - min) / (max - min), 0, 1)
        valLabel.Text = tostring(math.floor(value + 0.5)) .. (o.Suffix or "")
        if animate ~= false then
            Tween(fill, 0.25, { Size = UDim2.fromScale(a, 1) })
        else
            fill.Size = UDim2.fromScale(a, 1)
        end
    end

    function obj:Set(v, animate)
        value = math.clamp(v, min, max)
        if o.Flag then Window.Flags[o.Flag] = value end
        render(animate)
    end

    function obj:Get() return value end
    function obj:SetTitle(t) label.Text = t end

    render(false)
    ctx.Register(o.Flag, value, function(v) obj:Set(v, false) end)
    return obj
end
