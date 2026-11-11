local import = ...
local Util = import("Util")
local New, Corner = Util.New, Util.Corner

-- RangeSlider({ Title, Min, Max, Step, Default = {lo, hi}, Callback(lo, hi) })  Get() -> {lo, hi}
return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local min, max, step = o.Min or 0, o.Max or 100, o.Step or 1
    local d = o.Default or {}
    local lo = math.clamp(d[1] or min, min, max)
    local hi = math.clamp(d[2] or max, min, max)
    if lo > hi then lo, hi = hi, lo end

    local row, label = ctx.Row(52, o.Title)
    label.Size = UDim2.new(1, -120, 0, 30)
    local valLabel = New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(100, 30), Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = theme.SubText, Text = "" })
    local track = New("Frame", { Parent = row, Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = theme.Stroke }, { Corner(3) })
    local fill = New("Frame", { Parent = track, Size = UDim2.fromScale(1, 1), BackgroundColor3 = theme.Accent }, { Corner(3) })
    local function knob() return New("Frame", { Parent = track, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.new(1, 1, 1), ZIndex = 2 }, { Corner(6) }) end
    local kLo, kHi = knob(), knob()

    local obj = {}
    local function render()
        local a, b = (lo - min) / (max - min), (hi - min) / (max - min)
        fill.Position = UDim2.fromScale(a, 0)
        fill.Size = UDim2.fromScale(b - a, 1)
        kLo.Position = UDim2.fromScale(a, 0.5)
        kHi.Position = UDim2.fromScale(b, 0.5)
        valLabel.Text = tostring(lo) .. (o.Suffix or "") .. " - " .. tostring(hi) .. (o.Suffix or "")
    end
    local function norm(v)
        v = math.clamp(Util.round(v, step), min, max)
        return tonumber(string.format("%.6g", v))
    end
    function obj:Set(v, silent)
        local a, b = norm(v[1] or min), norm(v[2] or max)
        if a > b then a, b = b, a end
        lo, hi = a, b
        if o.Flag then Window.Flags[o.Flag] = { lo, hi } end
        render()
        if not silent and o.Callback then ctx.Call(o.Callback, lo, hi) end
    end
    function obj:Get() return { lo, hi } end

    local activeKnob
    Util.Drag(track, function(pos, isStart)
        local a = math.clamp((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * a
        if isStart then
            -- en yakin ucu sec; esitse hareket yonune gore
            if math.abs(value - lo) < math.abs(value - hi) then activeKnob = "lo"
            elseif math.abs(value - lo) > math.abs(value - hi) then activeKnob = "hi"
            else activeKnob = (value > hi) and "hi" or "lo" end
        end
        local nlo, nhi = lo, hi
        if activeKnob == "lo" then nlo = math.min(norm(value), hi) else nhi = math.max(norm(value), lo) end
        if nlo ~= lo or nhi ~= hi then obj:Set({ nlo, nhi }) end
    end, ctx.Connect)

    render()
    if o.Flag then Window.Flags[o.Flag] = { lo, hi } end
    ctx.Register(o.Flag, { lo, hi }, function(v) obj:Set(v) end)
    return obj
end
