local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local row = ctx.Row(o.Description and 44 or 38, o.Title, o.Description)
    local box = New("TextBox", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(150, 26), BackgroundColor3 = theme.Background, ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.Text, PlaceholderText = o.Placeholder or "...", PlaceholderColor3 = theme.SubText, Text = o.Default or "", TextTruncate = Enum.TextTruncate.AtEnd }, { Corner(6), Stroke(theme.Stroke), Pad(8, 0, 8, 0) })
    local obj = {}
    function obj:Set(v, silent)
        box.Text = tostring(v)
        if o.Flag then Window.Flags[o.Flag] = box.Text end
        if not silent and o.Callback then ctx.Call(o.Callback, box.Text) end
    end
    function obj:Get() return box.Text end
    box.Focused:Connect(function() Tween(box.UIStroke, 0.15, { Color = theme.Accent }) end)
    box.FocusLost:Connect(function(enter)
        Tween(box.UIStroke, 0.15, { Color = theme.Stroke })
        if o.Flag then Window.Flags[o.Flag] = box.Text end
        if (enter or not o.EnterOnly) and o.Callback then ctx.Call(o.Callback, box.Text) end
    end)
    ctx.Register(o.Flag, box.Text, function(v) obj:Set(v) end)
    return obj
end
