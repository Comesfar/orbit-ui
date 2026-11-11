local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke = Util.New, Util.Tween, Util.Corner, Util.Stroke

local UserInputService = game:GetService("UserInputService")

-- Keybind: Callback(key) tusa basilinca, Changed(key) tus degisince (config yuklemede de) calisir
return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local key = o.Default or Enum.KeyCode.Unknown
    local listening = false
    local bindId = o.Flag or o.Title

    local function syncKeybindList(state)
        if Window.UpdateKeybind then
            Window:UpdateKeybind(bindId, {
                Title = o.Title,
                Key = key,
                State = state or false,
            })
        end
    end

    local row = ctx.Row(o.Description and 44 or 38, o.Title, o.Description)
    local btn = New("TextButton", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0), Size = UDim2.fromOffset(90, 26), BackgroundColor3 = theme.Background, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text, Text = key.Name }, { Corner(6), Stroke(theme.Stroke) })
    local obj = {}

    function obj:Set(k, silent)
        if typeof(k) == "string" then k = Enum.KeyCode[k] end
        key = k
        btn.Text = key.Name
        if o.Flag then Window.Flags[o.Flag] = key end
        syncKeybindList(false)
        if not silent and o.Changed then ctx.Call(o.Changed, key) end
    end
    function obj:Get() return key end

    btn.Activated:Connect(function()
        listening = true
        btn.Text = "..."
        Tween(btn.UIStroke, 0.15, { Color = theme.Accent })
    end)

    ctx.Connect(UserInputService.InputBegan, function(i, gp)
        if listening then
            if i.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                obj:Set(i.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or i.KeyCode)
                Tween(btn.UIStroke, 0.15, { Color = theme.Stroke })
            end
        elseif not gp and i.KeyCode == key and key ~= Enum.KeyCode.Unknown then
            syncKeybindList(true)
            task.delay(0.25, function() syncKeybindList(false) end)
            if o.Callback then ctx.Call(o.Callback, key) end
        end
    end)

    ctx.Register(o.Flag, key, function(v) obj:Set(v) end)
    syncKeybindList(false)
    return obj
end
