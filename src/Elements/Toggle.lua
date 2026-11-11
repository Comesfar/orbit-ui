local import = ...
local Util = import("Util")
local New, Tween, Corner = Util.New, Util.Tween, Util.Corner

return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local state = o.Default or false
    local row = ctx.Row(o.Description and 44 or 38, o.Title, o.Description)
    local btn = ctx.Hoverable(row, 44)
    btn.Size = UDim2.fromScale(1, 1)
    local track = New("Frame", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(38, 20), BackgroundColor3 = theme.Stroke }, { Corner(10) })
    local knob = New("Frame", { Parent = track, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1) }, { Corner(7) })
    local obj = {}
    local function render(animate)
        local t = animate and 0.18 or 0
        Tween(track, t, { BackgroundColor3 = state and theme.Accent or theme.Stroke })
        Tween(knob, t, { Position = state and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
    end
    function obj:Set(v, silent)
        state = v and true or false
        if o.Flag then Window.Flags[o.Flag] = state end
        render(true)
        if not silent and o.Callback then task.spawn(o.Callback, state) end
    end
    function obj:Get() return state end
    btn.Activated:Connect(function() obj:Set(not state) end)
    render(false)
    ctx.Register(o.Flag, state, function(v) obj:Set(v) end)
    if state and o.Callback then task.spawn(o.Callback, state) end
    return obj
end
