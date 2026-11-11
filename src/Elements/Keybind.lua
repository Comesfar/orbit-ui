local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke = Util.New, Util.Tween, Util.Corner, Util.Stroke

local UserInputService = game:GetService("UserInputService")

return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local key = o.Default or Enum.KeyCode.Unknown
    local listening = false
    local row = ctx.Row(o.Description and 44 or 38, o.Title, o.Description)
    local btn = New("TextButton", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(80, 26), BackgroundColor3 = theme.Background, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text, Text = key.Name }, { Corner(6), Stroke(theme.Stroke) })
    local obj = {}
    function obj:Set(k)
        if typeof(k) == "string" then k = Enum.KeyCode[k] end
        key = k
        btn.Text = key.Name
        if o.Flag then Window.Flags[o.Flag] = key end
    end
    function obj:Get() return key end
    btn.Activated:Connect(function()
        listening = true
        btn.Text = "..."
        Tween(btn.UIStroke, 0.15, { Color = theme.Accent })
    end)
    UserInputService.InputBegan:Connect(function(i, gp)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                obj:Set(i.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or i.KeyCode)
                Tween(btn.UIStroke, 0.15, { Color = theme.Stroke })
                if o.Changed then task.spawn(o.Changed, key) end
            end
        elseif not gp and i.KeyCode == key and key ~= Enum.KeyCode.Unknown then
            if o.Callback then task.spawn(o.Callback, key) end
        end
    end)
    ctx.Register(o.Flag, key, function(v) obj:Set(v) end)
    return obj
end
