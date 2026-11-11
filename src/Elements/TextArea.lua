local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

-- TextArea({ Title, Placeholder, Default, Height, Flag, Callback(text) })
return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local height = o.Height or 100
    local row, label = ctx.Row(height, o.Title)
    label.Position = UDim2.fromOffset(12, 4)
    label.Size = UDim2.new(1, -24, 0, 24)
    local box = New("TextBox", { Parent = row, Position = UDim2.fromOffset(10, 30), Size = UDim2.new(1, -20, 1, -40), BackgroundColor3 = theme.Background, ClearTextOnFocus = false, MultiLine = true, TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, PlaceholderText = o.Placeholder or "...", PlaceholderColor3 = theme.SubText, Text = o.Default or "" }, { Corner(6), Stroke(theme.Stroke), Pad(8, 6, 8, 6) })
    local obj = {}
    function obj:Set(v, silent)
        box.Text = tostring(v)
        if o.Flag then Window.Flags[o.Flag] = box.Text end
        if not silent and o.Callback then ctx.Call(o.Callback, box.Text) end
    end
    function obj:Get() return box.Text end
    box.Focused:Connect(function() Tween(box.UIStroke, 0.15, { Color = theme.Accent }) end)
    box.FocusLost:Connect(function()
        Tween(box.UIStroke, 0.15, { Color = theme.Stroke })
        if o.Flag then Window.Flags[o.Flag] = box.Text end
        if o.Callback then ctx.Call(o.Callback, box.Text) end
    end)
    ctx.Register(o.Flag, box.Text, function(v) obj:Set(v) end)
    return obj
end
