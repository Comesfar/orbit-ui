-- Orbit UI (bundle) - build.ps1 tarafindan uretildi, elle duzenleme
local __modules = {}
__modules["Config"] = function(...)
-- Orbit UI :: Config (Flag tabanli kaydet/yukle)
local import = ...

local HttpService = game:GetService("HttpService")

return function(Window, folder)
    local function canFS()
        return writefile and readfile and isfolder and makefolder and isfile
    end

    function Window:SaveConfig(name)
        if not canFS() then return false, "dosya sistemi yok" end
        local data = {}
        for flag, v in pairs(Window.Flags) do
            if typeof(v) == "Color3" then data[flag] = { __c3 = { v.R, v.G, v.B } }
            elseif typeof(v) == "EnumItem" then data[flag] = { __enum = v.Name }
            else data[flag] = v end
        end
        if not isfolder(folder) then makefolder(folder) end
        writefile(folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
        return true
    end

    function Window:LoadConfig(name)
        if not canFS() then return false, "dosya sistemi yok" end
        local path = folder .. "/" .. name .. ".json"
        if not isfile(path) then return false, "config bulunamadi" end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if not ok then return false, "bozuk config" end
        for flag, v in pairs(data) do
            local setter = Window.Setters[flag]
            if setter then
                if type(v) == "table" and v.__c3 then v = Color3.new(v.__c3[1], v.__c3[2], v.__c3[3])
                elseif type(v) == "table" and v.__enum then v = Enum.KeyCode[v.__enum] end
                pcall(setter, v)
            end
        end
        return true
    end

    function Window:ListConfigs()
        local out = {}
        if canFS() and isfolder(folder) and listfiles then
            for _, f in ipairs(listfiles(folder)) do
                local n = f:match("([^/\\]+)%.json$")
                if n then table.insert(out, n) end
            end
        end
        return out
    end
end

end
__modules["Dialog"] = function(...)
-- Orbit UI :: Dialog
local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

-- Window:Dialog({ Title, Content, Buttons = { {Title, Callback, Danger} } })
return function(Window, env)
    local theme, main = env.Theme, env.Main

    function Window:Dialog(d)
        local overlay = New("Frame", { Parent = main, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 50, Active = true })
        local box = New("CanvasGroup", { Parent = overlay, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(320, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Element, GroupTransparency = 1, ZIndex = 51 }, {
            Corner(10), Stroke(theme.Stroke), Pad(16, 14, 16, 14), New("UIListLayout", { Padding = UDim.new(0, 8) }),
        })
        New("TextLabel", { Parent = box, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = d.Title or "Dialog", ZIndex = 52 })
        if d.Content then
            New("TextLabel", { Parent = box, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = d.Content, ZIndex = 52 })
        end
        local row = New("Frame", { Parent = box, LayoutOrder = 3, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), ZIndex = 52 }, {
            New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8) }),
        })
        local function close()
            Tween(box, 0.15, { GroupTransparency = 1 })
            Tween(overlay, 0.15, { BackgroundTransparency = 1 }).Completed:Wait()
            overlay:Destroy()
        end
        for _, b in ipairs(d.Buttons or { { Title = "Tamam" } }) do
            local neutral = not b.Danger and not b.Callback
            local color = b.Danger and theme.Danger or (neutral and theme.ElementHover or theme.Accent)
            local btn = New("TextButton", { Parent = row, Size = UDim2.fromOffset(90, 32), BackgroundColor3 = color, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = neutral and theme.Text or Color3.new(1, 1, 1), Text = b.Title, ZIndex = 53 }, { Corner(7) })
            btn.Activated:Connect(function()
                task.spawn(close)
                if b.Callback then task.spawn(b.Callback) end
            end)
        end
        Tween(overlay, 0.2, { BackgroundTransparency = 0.45 })
        Tween(box, 0.2, { GroupTransparency = 0 })
    end
end

end
__modules["Elements.Button"] = function(...)
local import = ...
local Util = import("Util")
local New, Tween = Util.New, Util.Tween

return function(ctx, b)
    local theme = ctx.Theme
    local row = ctx.Row(b.Description and 44 or 38, b.Title, b.Description)
    local btn = ctx.Hoverable(row, 44)
    btn.Size = UDim2.fromScale(1, 1)
    New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(20, 20), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.Accent, Text = ">" })
    btn.Activated:Connect(function()
        Tween(row, 0.08, { BackgroundColor3 = theme.Accent }).Completed:Connect(function() Tween(row, 0.2, { BackgroundColor3 = theme.Element }) end)
        if b.Callback then task.spawn(b.Callback) end
    end)
end

end
__modules["Elements.ColorPicker"] = function(...)
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
        if fire and o.Callback then task.spawn(o.Callback, color) end
    end
    Util.Drag(sv, function(pos)
        s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
        v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
        render(true)
    end)
    Util.Drag(hue, function(pos)
        h = math.clamp((pos.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
        render(true)
    end)
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

end
__modules["Elements.Dropdown"] = function(...)
local import = ...
local Util = import("Util")
local New, Tween, Corner, Pad = Util.New, Util.Tween, Util.Corner, Util.Pad

return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local values = o.Values or {}
    local multi = o.Multi or false
    local selected
    if multi then
        selected = {}
        for _, v in ipairs(o.Default or {}) do selected[v] = true end
    else
        selected = o.Default
    end

    local HEADER = 38
    local row = ctx.Row(HEADER, o.Title)
    local hbtn = ctx.Hoverable(row, HEADER)
    local valLabel = New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -30, 0, 0), Size = UDim2.new(0.5, -30, 0, HEADER), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = theme.SubText, Text = "", TextTruncate = Enum.TextTruncate.AtEnd })
    local arrow = New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0), Size = UDim2.fromOffset(20, HEADER), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.SubText, Text = "v" })
    local list = New("ScrollingFrame", { Parent = row, Position = UDim2.fromOffset(8, HEADER), Size = UDim2.new(1, -16, 1, -HEADER - 8), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new() }, { New("UIListLayout", { Padding = UDim.new(0, 2) }) })

    local open = false
    local obj = {}
    local buttons = {}

    local function value()
        if not multi then return selected end
        local t = {}
        for _, v in ipairs(values) do if selected[v] then table.insert(t, v) end end
        return t
    end
    local function text()
        if multi then
            local t = {}
            for _, v in ipairs(values) do if selected[v] then table.insert(t, tostring(v)) end end
            return #t > 0 and table.concat(t, ", ") or "Yok"
        end
        return selected ~= nil and tostring(selected) or "Sec"
    end
    local function refresh()
        valLabel.Text = text()
        for v, b in pairs(buttons) do
            local on = multi and selected[v] or selected == v
            Tween(b, 0.12, { BackgroundTransparency = on and 0 or 1, TextColor3 = on and Color3.new(1, 1, 1) or theme.SubText })
        end
    end
    local function listHeight() return math.min(#values, 5) * 28 + 8 end
    function obj:Open()
        open = true
        Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, HEADER + listHeight()) })
        Tween(arrow, 0.2, { Rotation = 180 })
    end
    function obj:Close()
        open = false
        Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, HEADER) })
        Tween(arrow, 0.2, { Rotation = 0 })
    end
    local function build()
        for _, b in pairs(buttons) do b:Destroy() end
        buttons = {}
        for _, v in ipairs(values) do
            local b = New("TextButton", { Parent = list, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = theme.Accent, BackgroundTransparency = 1, AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(v) }, { Corner(6), Pad(10, 0, 10, 0) })
            buttons[v] = b
            b.Activated:Connect(function()
                if multi then selected[v] = not selected[v] or nil else selected = v end
                if o.Flag then Window.Flags[o.Flag] = value() end
                refresh()
                if o.Callback then task.spawn(o.Callback, value()) end
                if not multi then obj:Close() end
            end)
        end
        refresh()
    end
    function obj:Set(v, silent)
        if multi then
            selected = {}
            for _, x in ipairs(v) do selected[x] = true end
        else
            selected = v
        end
        if o.Flag then Window.Flags[o.Flag] = value() end
        refresh()
        if not silent and o.Callback then task.spawn(o.Callback, value()) end
    end
    function obj:Get() return value() end
    function obj:Refresh(newValues)
        values = newValues
        build()
        if open then Tween(row, 0.2, { Size = UDim2.new(1, 0, 0, HEADER + listHeight()) }) end
    end
    hbtn.Activated:Connect(function() if open then obj:Close() else obj:Open() end end)
    build()
    ctx.Register(o.Flag, value(), function(v) obj:Set(v) end)
    return obj
end

end
__modules["Elements.Input"] = function(...)
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
        if not silent and o.Callback then task.spawn(o.Callback, box.Text) end
    end
    function obj:Get() return box.Text end
    box.Focused:Connect(function() Tween(box.UIStroke, 0.15, { Color = theme.Accent }) end)
    box.FocusLost:Connect(function(enter)
        Tween(box.UIStroke, 0.15, { Color = theme.Stroke })
        if o.Flag then Window.Flags[o.Flag] = box.Text end
        if (enter or not o.EnterOnly) and o.Callback then task.spawn(o.Callback, box.Text) end
    end)
    ctx.Register(o.Flag, box.Text, function(v) obj:Set(v) end)
    return obj
end

end
__modules["Elements.Keybind"] = function(...)
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

end
__modules["Elements.Label"] = function(...)
local import = ...

return function(ctx, text)
    if type(text) == "table" then text = text.Title end
    local _, label = ctx.Row(30, text)
    return { Set = function(_, v) label.Text = v end }
end

end
__modules["Elements.Paragraph"] = function(...)
local import = ...
local Util = import("Util")
local New, Corner, Stroke, Pad = Util.New, Util.Corner, Util.Stroke, Util.Pad

return function(ctx, p)
    local theme = ctx.Theme
    local row = New("Frame", { Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Element }, {
        Corner(8), Stroke(theme.Stroke), Pad(12, 10, 12, 10), New("UIListLayout", { Padding = UDim.new(0, 3) }),
    })
    local title = New("TextLabel", { Parent = row, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = p.Title or "" })
    local body = New("TextLabel", { Parent = row, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = p.Content or "" })
    return { Set = function(_, t, c) if t then title.Text = t end if c then body.Text = c end end }
end

end
__modules["Elements.Section"] = function(...)
local import = ...
local Util = import("Util")
local New = Util.New

return function(ctx, s)
    s = type(s) == "string" and { Title = s } or s
    New("TextLabel", { Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = ctx.Theme.Accent, Text = string.upper(s.Title or "") })
end

end
__modules["Elements.Slider"] = function(...)
local import = ...
local Util = import("Util")
local New, Corner = Util.New, Util.Corner

return function(ctx, o)
    local theme, Window = ctx.Theme, ctx.Window
    local min, max, step = o.Min or 0, o.Max or 100, o.Step or 1
    local value = math.clamp(o.Default or min, min, max)
    local row, label = ctx.Row(52, o.Title)
    label.Size = UDim2.new(1, -90, 0, 30)
    local valLabel = New("TextLabel", { Parent = row, BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 0), Size = UDim2.fromOffset(70, 30), Font = Enum.Font.GothamMedium, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = theme.SubText, Text = "" })
    local track = New("Frame", { Parent = row, Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = theme.Stroke }, { Corner(3) })
    local fill = New("Frame", { Parent = track, Size = UDim2.fromScale(0, 1), BackgroundColor3 = theme.Accent }, { Corner(3) })
    New("Frame", { Parent = fill, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(12, 12), BackgroundColor3 = Color3.new(1, 1, 1) }, { Corner(6) })
    local obj = {}
    local function render()
        fill.Size = UDim2.fromScale((value - min) / (max - min), 1)
        valLabel.Text = tostring(value) .. (o.Suffix or "")
    end
    function obj:Set(v, silent)
        v = math.clamp(Util.round(v, step), min, max)
        v = tonumber(string.format("%.6g", v))
        if v == value then render() return end
        value = v
        if o.Flag then Window.Flags[o.Flag] = value end
        render()
        if not silent and o.Callback then task.spawn(o.Callback, value) end
    end
    function obj:Get() return value end
    Util.Drag(track, function(pos)
        local a = math.clamp((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        obj:Set(min + (max - min) * a)
    end)
    render()
    ctx.Register(o.Flag, value, function(v) obj:Set(v) end)
    return obj
end

end
__modules["Elements.Toggle"] = function(...)
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

end
__modules["init"] = function(...)
-- Orbit UI :: giris noktasi
local import = ...

local Orbit = { Version = "2.0.0", Windows = {} }

Orbit.Themes = import("Themes")

-- Bildirimler: Orbit:Notify(...)
import("Notify")(Orbit)

-- Pencere: Orbit:CreateWindow(...)
function Orbit:CreateWindow(opts)
    return import("Window")(Orbit, opts)
end

return Orbit

end
__modules["Notify"] = function(...)
-- Orbit UI :: Notify
local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

return function(Orbit)
    local holder

    local function ensureHolder(gui)
        if holder and holder.Parent then return holder end
        holder = New("Frame", {
            Name = "Notifications", Parent = gui, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(300, 400),
        }, { New("UIListLayout", { Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder }) })
        return holder
    end

    function Orbit:Notify(opts)
        opts = opts or {}
        if not self.Gui then return end
        local theme = self.CurrentTheme or Orbit.Themes.Dark
        local parent = ensureHolder(self.Gui)
        local duration = opts.Duration or 4
        local card = New("CanvasGroup", {
            Parent = parent, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Background, GroupTransparency = 1,
        }, {
            Corner(8), Stroke(theme.Stroke), Pad(12, 10, 12, 14),
            New("UIListLayout", { Padding = UDim.new(0, 2) }),
        })
        New("TextLabel", { Parent = card, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = opts.Title or "Bildirim" })
        if opts.Content then
            New("TextLabel", { Parent = card, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = opts.Content })
        end
        local bar = New("Frame", { Parent = card, LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = theme.Accent, BorderSizePixel = 0 }, { Corner(1) })
        Tween(card, 0.25, { GroupTransparency = 0 })
        Tween(bar, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
        task.delay(duration, function()
            Tween(card, 0.25, { GroupTransparency = 1 }).Completed:Wait()
            card:Destroy()
        end)
    end
end

end
__modules["Tab"] = function(...)
-- Orbit UI :: Tab (sekme + element baglama)
local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

-- Eklemek icin: src/Elements/<Ad>.lua olustur ve buraya adi ekle
local ELEMENTS = { "Section", "Label", "Paragraph", "Button", "Toggle", "Slider", "Input", "Dropdown", "Keybind", "ColorPicker" }

return function(Window, env, t)
    t = t or {}
    local theme, sidebar, content, state = env.Theme, env.Sidebar, env.Content, env.TabState
    local Tab = {}

    local btn = New("TextButton", { Parent = sidebar, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = theme.Element, BackgroundTransparency = 1, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Text = (t.Icon and (t.Icon .. "  ") or "") .. (t.Title or "Tab") }, { Corner(7), Pad(12, 0, 8, 0) })
    local indicator = New("Frame", { Parent = btn, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -8, 0.5, 0), Size = UDim2.fromOffset(3, 0), BackgroundColor3 = theme.Accent, BorderSizePixel = 0 }, { Corner(2) })

    local page = New("ScrollingFrame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Stroke, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false }, {
        Pad(14, 14, 14, 14), New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local function select()
        if state.current == Tab then return end
        if state.current then state.current._deselect() end
        state.current = Tab
        page.Visible = true
        Tween(btn, 0.15, { BackgroundTransparency = 0, TextColor3 = theme.Text })
        Tween(indicator, 0.2, { Size = UDim2.fromOffset(3, 16) })
    end
    Tab._deselect = function()
        page.Visible = false
        Tween(btn, 0.15, { BackgroundTransparency = 1, TextColor3 = theme.SubText })
        Tween(indicator, 0.15, { Size = UDim2.fromOffset(3, 0) })
    end
    btn.Activated:Connect(select)
    if state.first then state.first = false; select() end

    -- Elementlerin paylastigi baglam
    local order = 0
    local ctx = { Window = Window, Tab = Tab, Theme = theme, Page = page }
    function ctx.NextOrder() order += 1 return order end

    function ctx.Row(height, title, desc)
        local row = New("Frame", { Parent = page, LayoutOrder = ctx.NextOrder(), Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = theme.Element, ClipsDescendants = true }, { Corner(8), Stroke(theme.Stroke) })
        local label = New("TextLabel", { Parent = row, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, desc and 7 or 0), Size = UDim2.new(1, -24, 0, desc and 16 or math.min(height, 38)), Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = title or "" })
        if desc then
            New("TextLabel", { Parent = row, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 23), Size = UDim2.new(1, -24, 0, 14), Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = desc })
        end
        return row, label
    end

    function ctx.Hoverable(row, height)
        local b = New("TextButton", { Parent = row, Size = UDim2.new(1, 0, 0, height or 38), BackgroundTransparency = 1, Text = "", ZIndex = 1 })
        b.MouseEnter:Connect(function() Tween(row, 0.12, { BackgroundColor3 = theme.ElementHover }) end)
        b.MouseLeave:Connect(function() Tween(row, 0.12, { BackgroundColor3 = theme.Element }) end)
        return b
    end

    function ctx.Register(flag, default, setter)
        if flag then
            Window.Flags[flag] = default
            Window.Setters[flag] = setter
        end
    end

    for _, name in ipairs(ELEMENTS) do
        Tab[name] = function(_, o)
            return import("Elements." .. name)(ctx, o)
        end
    end

    return Tab
end

end
__modules["Themes"] = function(...)
-- Orbit UI :: Themes
local import = ...

return {
    Dark = {
        Background = Color3.fromRGB(18, 18, 22), Sidebar = Color3.fromRGB(23, 23, 29),
        Element = Color3.fromRGB(30, 30, 38), ElementHover = Color3.fromRGB(38, 38, 48),
        Stroke = Color3.fromRGB(48, 48, 60), Text = Color3.fromRGB(235, 235, 245),
        SubText = Color3.fromRGB(150, 150, 168), Accent = Color3.fromRGB(88, 130, 255),
        Danger = Color3.fromRGB(235, 80, 90),
    },
    Midnight = {
        Background = Color3.fromRGB(10, 12, 24), Sidebar = Color3.fromRGB(14, 17, 33),
        Element = Color3.fromRGB(21, 25, 46), ElementHover = Color3.fromRGB(28, 33, 60),
        Stroke = Color3.fromRGB(38, 44, 78), Text = Color3.fromRGB(230, 235, 255),
        SubText = Color3.fromRGB(135, 145, 185), Accent = Color3.fromRGB(120, 90, 255),
        Danger = Color3.fromRGB(240, 85, 110),
    },
    Rose = {
        Background = Color3.fromRGB(24, 17, 21), Sidebar = Color3.fromRGB(30, 21, 26),
        Element = Color3.fromRGB(40, 28, 34), ElementHover = Color3.fromRGB(52, 37, 44),
        Stroke = Color3.fromRGB(70, 50, 59), Text = Color3.fromRGB(250, 235, 240),
        SubText = Color3.fromRGB(180, 150, 160), Accent = Color3.fromRGB(255, 100, 140),
        Danger = Color3.fromRGB(240, 80, 80),
    },
    Light = {
        Background = Color3.fromRGB(242, 243, 247), Sidebar = Color3.fromRGB(232, 234, 240),
        Element = Color3.fromRGB(255, 255, 255), ElementHover = Color3.fromRGB(240, 242, 248),
        Stroke = Color3.fromRGB(215, 218, 228), Text = Color3.fromRGB(30, 32, 42),
        SubText = Color3.fromRGB(110, 115, 135), Accent = Color3.fromRGB(70, 110, 240),
        Danger = Color3.fromRGB(220, 60, 70),
    },
}

end
__modules["Util"] = function(...)
-- Orbit UI :: Util - ortak yardimcilar
local import = ...

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Util = {}

function Util.New(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

function Util.Tween(obj, time, props, style)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

function Util.Corner(r)
    return Util.New("UICorner", { CornerRadius = UDim.new(0, r) })
end

function Util.Stroke(color, t)
    return Util.New("UIStroke", { Color = color, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

function Util.Pad(l, t, r, b)
    return Util.New("UIPadding", { PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b) })
end

function Util.GetGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    ok, hui = pcall(function() return game:GetService("CoreGui") end)
    if ok and hui then
        local test = Instance.new("Folder")
        if pcall(function() test.Parent = hui end) then test:Destroy() return hui end
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

function Util.MakeDraggable(handle, target)
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startInput, startPos = true, i.Position, target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Surukleme sirasinda input takibi (slider, color picker)
function Util.Drag(frame, callback)
    local active = false
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true
            callback(i.Position)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            callback(i.Position)
        end
    end)
end

function Util.round(n, step)
    step = step or 1
    return math.floor(n / step + 0.5) * step
end

return Util

end
__modules["Window"] = function(...)
-- Orbit UI :: Window
local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

return function(Orbit, opts)
    opts = opts or {}
    local theme = Orbit.Themes[opts.Theme or "Dark"] or Orbit.Themes.Dark
    Orbit.CurrentTheme = theme

    local Window = { Flags = {}, Setters = {}, Theme = theme, Visible = false }
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    local size = opts.Size or UDim2.fromOffset(620, 420)

    local gui = New("ScreenGui", { Name = "OrbitUI_" .. HttpService:GenerateGUID(false):sub(1, 8), ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, IgnoreGuiInset = true })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = Util.GetGuiParent()
    Orbit.Gui = gui
    Window.Gui = gui

    local blur
    if opts.Blur then blur = New("BlurEffect", { Size = 0, Parent = Lighting }) end

    local main = New("CanvasGroup", {
        Name = "Main", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = size, BackgroundColor3 = theme.Background, GroupTransparency = 1,
    }, { Corner(12), Stroke(theme.Stroke) })
    local scale = New("UIScale", { Parent = main, Scale = 0.92 })

    -- Kucuk ekranlara otomatik sigdir
    local fitScale = 1
    local function fit()
        local vp = gui.AbsoluteSize
        fitScale = math.min(1, vp.X / (size.X.Offset + 40), vp.Y / (size.Y.Offset + 40))
        if Window.Visible then scale.Scale = fitScale end
    end
    gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)

    -- Ust bar
    local top = New("Frame", { Name = "Topbar", Parent = main, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0 })
    New("Frame", { Parent = top, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = theme.Stroke, BorderSizePixel = 0 })
    local titleLabel = New("TextLabel", { Parent = top, BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -120, 1, 0), Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = opts.Title or "Orbit UI" })
    if opts.Subtitle then
        local c = theme.SubText
        titleLabel.RichText = true
        titleLabel.Text = string.format("%s  <font color='rgb(%d,%d,%d)' size='12'>%s</font>", opts.Title or "Orbit UI", c.R * 255, c.G * 255, c.B * 255, opts.Subtitle)
    end
    Util.MakeDraggable(top, main)

    local function topButton(text, xOff, hoverColor)
        local b = New("TextButton", { Parent = top, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOff, 0.5, 0), Size = UDim2.fromOffset(28, 28), BackgroundColor3 = theme.Element, AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.SubText, Text = text }, { Corner(7) })
        b.MouseEnter:Connect(function() Tween(b, 0.12, { BackgroundColor3 = hoverColor, TextColor3 = Color3.new(1, 1, 1) }) end)
        b.MouseLeave:Connect(function() Tween(b, 0.12, { BackgroundColor3 = theme.Element, TextColor3 = theme.SubText }) end)
        return b
    end
    local closeBtn = topButton("X", -10, theme.Danger)
    local minBtn = topButton("-", -44, theme.ElementHover)

    -- Sidebar + icerik
    local sidebar = New("ScrollingFrame", { Name = "Sidebar", Parent = main, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(0, 158, 1, -44), BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new() }, {
        Pad(10, 10, 10, 10), New("UIListLayout", { Padding = UDim.new(0, 4) }),
    })
    local content = New("Frame", { Name = "Content", Parent = main, Position = UDim2.fromOffset(158, 44), Size = UDim2.new(1, -158, 1, -44), BackgroundTransparency = 1, ClipsDescendants = true })

    -- Gorunurluk
    function Window:SetVisible(v)
        Window.Visible = v
        if v then
            main.Visible = true
            fit()
            Tween(main, 0.25, { GroupTransparency = 0 })
            Tween(scale, 0.3, { Scale = fitScale }, Enum.EasingStyle.Back)
            if blur then Tween(blur, 0.3, { Size = 12 }) end
        else
            Tween(main, 0.2, { GroupTransparency = 1 })
            Tween(scale, 0.2, { Scale = 0.92 })
            if blur then Tween(blur, 0.2, { Size = 0 }) end
            task.delay(0.2, function() if not Window.Visible then main.Visible = false end end)
        end
    end
    function Window:Toggle() Window:SetVisible(not Window.Visible) end
    function Window:Destroy()
        if blur then blur:Destroy() end
        gui:Destroy()
    end
    function Window:Notify(o) Orbit:Notify(o) end

    -- Alt moduller
    local env = { Theme = theme, Main = main, Sidebar = sidebar, Content = content, TabState = { first = true } }
    import("Dialog")(Window, env)
    import("Config")(Window, opts.ConfigFolder or "OrbitUI")

    function Window:Tab(t)
        return import("Tab")(Window, env, t)
    end

    closeBtn.Activated:Connect(function()
        Window:Dialog({ Title = "Kapat", Content = "Arayuz tamamen kapatilsin mi?", Buttons = {
            { Title = "Iptal" },
            { Title = "Kapat", Danger = true, Callback = function() Window:Destroy() end },
        } })
    end)
    minBtn.Activated:Connect(function() Window:SetVisible(false) end)
    UserInputService.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == toggleKey then Window:Toggle() end
    end)

    Window:SetVisible(true)
    table.insert(Orbit.Windows, Window)
    return Window
end

end
local __cache = {}
local function import(name)
    if __cache[name] ~= nil then return __cache[name] end
    local fn = assert(__modules[name], "[Orbit] modul yok: " .. tostring(name))
    local result = fn(import)
    __cache[name] = result
    return result
end
return import("init")
