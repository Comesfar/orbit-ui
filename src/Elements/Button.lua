local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween = Util.New, Util.Tween

-- Button({ Title, Description, Icon = "lucide-ismi", Callback })
return function(ctx, b)
    local theme = ctx.Theme
    local row = ctx.Row(b.Description and 44 or 38, b.Title, b.Description)
    local btn = ctx.Hoverable(row, 44)
    btn.Size = UDim2.fromScale(1, 1)
    if b.Icon then
        Icons.Create(row, b.Icon, { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -12, 0.5, 0), AnchorPoint = Vector2.new(1, 0.5), Color = theme.Accent })
    else
        New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(20, 20), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.Accent, Text = ">" })
    end
    btn.Activated:Connect(function()
        Tween(row, 0.08, { BackgroundColor3 = theme.Accent }).Completed:Connect(function() Tween(row, 0.2, { BackgroundColor3 = theme.Element }) end)
        if b.Callback then ctx.Call(b.Callback) end
    end)
end
