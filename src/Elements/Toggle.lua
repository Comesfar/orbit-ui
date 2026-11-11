local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke = Util.New, Util.Tween, Util.Corner, Util.Stroke

local UserInputService = game:GetService("UserInputService")

-- Toggle. Keybind = Enum.KeyCode.X (veya Enum.KeyCode.Unknown) verilirse yaninda tus butonu cikar.
return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local state = o.Default or false
    local hasBind = o.Keybind ~= nil
    local key = (typeof(o.Keybind) == "EnumItem") and o.Keybind or Enum.KeyCode.Unknown

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
        if not silent and o.Callback then ctx.Call(o.Callback, state) end
    end
    function obj:Get() return state end
    btn.Activated:Connect(function() obj:Set(not state) end)
    render(false)
    ctx.Register(o.Flag, state, function(v) obj:Set(v) end)
    if state and o.Callback then ctx.Call(o.Callback, state) end

    if hasBind then
        local listening = false
        local keyBtn = New("TextButton", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -60, 0.5, 0), Size = UDim2.fromOffset(72, 22), BackgroundColor3 = theme.Background, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 11, TextColor3 = theme.SubText, Text = key.Name, ZIndex = 3 }, { Corner(6), Stroke(theme.Stroke) })
        local function setKey(k)
            if typeof(k) == "string" then k = Enum.KeyCode[k] end
            key = k
            keyBtn.Text = key.Name
            if o.Flag then Window.Flags[o.Flag .. "_bind"] = key end
        end
        keyBtn.Activated:Connect(function()
            listening = true
            keyBtn.Text = "..."
            Tween(keyBtn.UIStroke, 0.15, { Color = theme.Accent })
        end)
        ctx.Connect(UserInputService.InputBegan, function(i, gp)
            if listening then
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    setKey(i.KeyCode == Enum.KeyCode.Escape and Enum.KeyCode.Unknown or i.KeyCode)
                    Tween(keyBtn.UIStroke, 0.15, { Color = theme.Stroke })
                end
            elseif not gp and key ~= Enum.KeyCode.Unknown and i.KeyCode == key then
                obj:Set(not state)
            end
        end)
        function obj:SetKey(k) setKey(k) end
        function obj:GetKey() return key end
        ctx.Register(o.Flag and (o.Flag .. "_bind"), key, setKey)
    end
    return obj
end
