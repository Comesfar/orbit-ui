-- Orbit UI (bundle) - build.ps1 tarafindan uretildi, elle duzenleme
local __modules = {}
__modules["Config"] = function(...)
-- Orbit UI :: Config (Flag tabanli kaydet/yukle + otomatik kayit)
local import = ...

local HttpService = game:GetService("HttpService")

return function(Window, folder)
    local function canFS()
        return writefile and readfile and isfolder and makefolder and isfile
    end

    function Window:SaveConfig(name)
        if not canFS() then return false, "dosya sistemi yok" end
        local data = {}
        for flag, v in pairs(Window._flagData) do
            if typeof(v) == "Color3" then data[flag] = { __c3 = { v.R, v.G, v.B } }
            elseif typeof(v) == "EnumItem" then data[flag] = { __enum = v.Name }
            else data[flag] = v end
        end
        local ok, err = pcall(function()
            if not isfolder(folder) then makefolder(folder) end
            writefile(folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
        end)
        if not ok then return false, tostring(err) end
        return true
    end

    function Window:LoadConfig(name)
        if not canFS() then return false, "dosya sistemi yok" end
        local path = folder .. "/" .. name .. ".json"
        if not isfile(path) then return false, "config bulunamadi" end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if not ok then return false, "bozuk config" end
        Window._loading = true -- yuklerken otomatik kaydi tetikleme
        for flag, v in pairs(data) do
            local setter = Window.Setters[flag]
            if setter then
                if type(v) == "table" and v.__c3 then v = Color3.new(v.__c3[1], v.__c3[2], v.__c3[3])
                elseif type(v) == "table" and v.__enum then v = Enum.KeyCode[v.__enum] end
                pcall(setter, v)
            end
        end
        Window._loading = false
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
        table.sort(out)
        return out
    end

    -- Arayuzu kurduktan SONRA cagir: varsa config'i yukler, sonra her degisiklikte kaydeder
    function Window:EnableAutoSave(name)
        Window:LoadConfig(name)
        Window.AutoSaveName = name
    end
    function Window:DisableAutoSave()
        Window.AutoSaveName = nil
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
                if b.Callback then env.Call(b.Callback) end
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
        if fire and o.Callback then ctx.Call(o.Callback, color) end
    end
    Util.Drag(sv, function(pos)
        s = math.clamp((pos.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
        v = 1 - math.clamp((pos.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
        render(true)
    end, ctx.Connect)
    Util.Drag(hue, function(pos)
        h = math.clamp((pos.Y - hue.AbsolutePosition.Y) / hue.AbsoluteSize.Y, 0, 1)
        render(true)
    end, ctx.Connect)
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
__modules["Elements.Divider"] = function(...)
local import = ...
local Util = import("Util")
local New = Util.New

return function(ctx)
    local line = New("Frame", { Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = ctx.Theme.Stroke, BorderSizePixel = 0 })
    ctx.MarkStatic(line)
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
        for idx, v in ipairs(values) do
            local b = New("TextButton", { Parent = list, LayoutOrder = idx, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = theme.Accent, BackgroundTransparency = 1, AutoButtonColor = false, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(v) }, { Corner(6), Pad(10, 0, 10, 0) })
            buttons[v] = b
            b.Activated:Connect(function()
                if multi then selected[v] = not selected[v] or nil else selected = v end
                if o.Flag then Window.Flags[o.Flag] = value() end
                refresh()
                if o.Callback then ctx.Call(o.Callback, value()) end
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
        if not silent and o.Callback then ctx.Call(o.Callback, value()) end
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
__modules["Elements.Image"] = function(...)
local import = ...
local Util = import("Util")
local New, Corner, Stroke = Util.New, Util.Corner, Util.Stroke

-- Image({ Image = "rbxassetid://123", Height = 120 })
return function(ctx, o)
    local theme = ctx.Theme
    local frame = New("Frame", { Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), Size = UDim2.new(1, 0, 0, o.Height or 120), BackgroundColor3 = theme.Element, ClipsDescendants = true }, { Corner(8), Stroke(theme.Stroke) })
    local img = New("ImageLabel", { Parent = frame, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = o.Image or "", ScaleType = o.ScaleType or Enum.ScaleType.Fit }, { Corner(8) })
    ctx.MarkStatic(frame)
    return { Set = function(_, image) img.Image = image end }
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

end
__modules["Elements.Keybind"] = function(...)
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
    row:SetAttribute("OrbitSearch", ((p.Title or "") .. " " .. (p.Content or "")):lower())
    local title = New("TextLabel", { Parent = row, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = p.Title or "" })
    local body = New("TextLabel", { Parent = row, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = p.Content or "" })
    return { Set = function(_, t, c) if t then title.Text = t end if c then body.Text = c end end }
end

end
__modules["Elements.ProgressBar"] = function(...)
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

end
__modules["Elements.RangeSlider"] = function(...)
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

end
__modules["Elements.Section"] = function(...)
local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local ELEMENTS = {
    "Divider", "Label", "Paragraph", "Image", "ProgressBar",
    "Button", "Toggle", "Slider", "RangeSlider", "Input", "TextArea", "Dropdown", "Keybind", "ColorPicker",
}

return function(ctx, s)
    if type(s) == "string" then
        s = { Title = s }
    end
    s = s or {}

    -- Eger Collapsible istenmiyorsa basit baslik etiketi olarak kal
    if not s.Collapsible then
        local l = New("TextLabel", {
            Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBold, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = ctx.Theme.Accent,
            Text = string.upper(s.Title or ""),
        })
        ctx.MarkStatic(l)
        return {
            SetTitle = function(_, t) l.Text = string.upper(t) end,
        }
    end

    -- Collapsible Kart / Grup Bolumu
    local theme = ctx.Theme
    local open = s.Default ~= false

    local card = New("Frame", {
        Parent = ctx.Page, LayoutOrder = ctx.NextOrder(),
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Sidebar, ClipsDescendants = true,
    }, { Corner(9), Stroke(theme.Stroke) })

    local header = New("TextButton", {
        Parent = card, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.Sidebar, AutoButtonColor = false, Text = "",
    }, { Corner(9), Pad(10, 0, 10, 0) })

    local xOff = 0
    if s.Icon then
        Icons.Create(header, s.Icon, {
            Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 0, 0.5, -8),
            Color = theme.Accent,
        })
        xOff = 24
    end

    local titleLbl = New("TextLabel", {
        Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(xOff, 0),
        Size = UDim2.new(1, -xOff - 24, 1, 0), Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = s.Title or "Section",
    })

    local arrow = New("TextLabel", {
        Parent = header, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.SubText,
        Text = "v", Rotation = open and 0 or -90,
    })

    local content = New("Frame", {
        Parent = card, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        Visible = open,
    }, {
        Pad(8, 0, 8, 8),
        New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local function toggleState()
        open = not open
        content.Visible = open
        Tween(arrow, 0.2, { Rotation = open and 0 or -90 })
    end
    header.Activated:Connect(toggleState)

    -- Alt elemanlar icin ozel baglam
    local subOrder = 0
    local subCtx = {
        Window = ctx.Window,
        Tab = ctx.Tab,
        Theme = theme,
        Page = content,
        Connect = ctx.Connect,
        Call = ctx.Call,
    }
    function subCtx.NextOrder() subOrder += 1 return subOrder end
    function subCtx.Row(height, title, desc)
        local row = New("Frame", { Parent = content, LayoutOrder = subCtx.NextOrder(), Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = theme.Element, ClipsDescendants = true }, { Corner(8), Stroke(theme.Stroke) })
        row:SetAttribute("OrbitSearch", ((title or "") .. " " .. (desc or "")):lower())
        local label = New("TextLabel", { Parent = row, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, desc and 7 or 0), Size = UDim2.new(1, -24, 0, desc and 16 or math.min(height, 38)), Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = title or "" })
        if desc then
            New("TextLabel", { Parent = row, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 23), Size = UDim2.new(1, -24, 0, 14), Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = desc })
        end
        return row, label
    end
    function subCtx.MarkStatic(inst)
        inst:SetAttribute("OrbitSearch", "")
        inst:SetAttribute("OrbitStatic", true)
    end
    function subCtx.Hoverable(row, height)
        local b = New("TextButton", { Parent = row, Size = UDim2.new(1, 0, 0, height or 38), BackgroundTransparency = 1, Text = "", ZIndex = 1 })
        b.MouseEnter:Connect(function() Tween(row, 0.12, { BackgroundColor3 = theme.ElementHover }) end)
        b.MouseLeave:Connect(function() Tween(row, 0.12, { BackgroundColor3 = theme.Element }) end)
        return b
    end
    function subCtx.Register(flag, default, setter)
        ctx.Register(flag, default, setter)
    end

    local SectionObj = {
        Frame = card,
        Content = content,
        Toggle = toggleState,
        SetTitle = function(_, t) titleLbl.Text = t end,
    }

    for _, name in ipairs(ELEMENTS) do
        SectionObj[name] = function(_, o)
            return import("Elements." .. name)(subCtx, o)
        end
    end

    return SectionObj
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
        if not silent and o.Callback then ctx.Call(o.Callback, value) end
    end
    function obj:Get() return value end
    Util.Drag(track, function(pos)
        local a = math.clamp((pos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        obj:Set(min + (max - min) * a)
    end, ctx.Connect)
    render()
    ctx.Register(o.Flag, value, function(v) obj:Set(v) end)
    return obj
end

end
__modules["Elements.TextArea"] = function(...)
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

end
__modules["Elements.Toggle"] = function(...)
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
    local bindId = o.Flag or o.Title

    local row = ctx.Row(o.Description and 44 or 38, o.Title, o.Description)
    local btn = ctx.Hoverable(row, 44)
    btn.Size = UDim2.fromScale(1, 1)
    local track = New("Frame", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(38, 20), BackgroundColor3 = theme.Stroke }, { Corner(10) })
    local knob = New("Frame", { Parent = track, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.new(1, 1, 1) }, { Corner(7) })

    local function syncKeybindList()
        if hasBind and Window.UpdateKeybind then
            Window:UpdateKeybind(bindId, {
                Title = o.Title,
                Key = key,
                State = state,
            })
        end
    end

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
        syncKeybindList()
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
            syncKeybindList()
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
        syncKeybindList()
    end
    return obj
end

end
__modules["Icons"] = function(...)
-- Orbit UI :: Icons (Dahili temel ikonlar + arka planda dinamik yukleyici)
local import = ...
local Util = import("Util")

local Icons = {
    Url = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua",
}

-- Sik kullanilan temel Lucide ikonlari (Aga bagimli olmadan aninda yuklenir)
local BUILTIN_ICONS = {
    ["user"] = "rbxassetid://81589895647169",
    ["house"] = "rbxassetid://98755624629571",
    ["settings"] = "rbxassetid://80758916183665",
    ["bell"] = "rbxassetid://97392696311902",
    ["eye"] = "rbxassetid://100033680381365",
    ["keyboard"] = "rbxassetid://121474456068237",
    ["swords"] = "rbxassetid://81872698913435",
    ["layout-dashboard"] = "rbxassetid://139929981863901",
    ["info"] = "rbxassetid://124560466474914",
    ["circle-check"] = "rbxassetid://85262178816537",
    ["triangle-alert"] = "rbxassetid://125920361880643",
    ["circle-alert"] = "rbxassetid://83898160590116",
    ["key"] = "rbxassetid://96510194465420",
    ["shield"] = "rbxassetid://110987169760162",
    ["crosshair"] = "rbxassetid://134242818164054",
    ["search"] = "rbxassetid://121018724060431",
    ["check"] = "rbxassetid://93898873302694",
    ["x"] = "rbxassetid://110786993356448",
    ["chevron-down"] = "rbxassetid://134243273101015",
    ["chevron-right"] = "rbxassetid://92473583511724",
    ["folder"] = "rbxassetid://80846616596607",
    ["trash"] = "rbxassetid://106723740584310",
    ["save"] = "rbxassetid://126116963775616",
    ["zap"] = "rbxassetid://130551565616516",
    ["flame"] = "rbxassetid://98218034436456",
    ["globe"] = "rbxassetid://114238209622913",
    ["play"] = "rbxassetid://135609604299893",
    ["pause"] = "rbxassetid://74873705394436",
    ["sparkles"] = "rbxassetid://138635884129147",
    ["refresh-cw"] = "rbxassetid://138133190015277",
}

local extraIcons = nil
local loadingExtra = false

local function loadExtraAsync()
    if extraIcons or loadingExtra then return end
    loadingExtra = true
    task.spawn(function()
        pcall(function()
            local raw = game:HttpGet(Icons.Url)
            local fn = loadstring(raw)
            if fn then
                local res = fn()
                if type(res) == "table" then
                    extraIcons = res
                end
            end
        end)
        loadingExtra = false
    end)
end

-- "lucide:settings", "settings", "rbxassetid://123", 123 -> image id (yoksa nil)
function Icons.Resolve(name)
    if type(name) == "number" then return "rbxassetid://" .. name end
    if type(name) ~= "string" or name == "" then return nil end
    if name:match("^rbxassetid://") or name:match("^rbxasset://") then return name end
    local clean = name:gsub("^lucide:", "")

    -- Once dahili haritada ara (aninda calisir, hic bekletmez)
    if BUILTIN_ICONS[clean] then
        return BUILTIN_ICONS[clean]
    end

    -- Dahili haritada yoksa ekstra paketten ara (arka planda yukler)
    if extraIcons and extraIcons[clean] then
        return extraIcons[clean]
    end

    loadExtraAsync()
    return nil
end

-- Ikon olusturur. Bulunamazsa kisa metin/glyph olarak gosterir.
-- props: Size, Position, AnchorPoint, Color
function Icons.Create(parent, name, props)
    props = props or {}
    local image = Icons.Resolve(name)
    if image then
        return Util.New("ImageLabel", {
            Parent = parent, BackgroundTransparency = 1, Image = image,
            Size = props.Size or UDim2.fromOffset(16, 16), Position = props.Position or UDim2.new(),
            AnchorPoint = props.AnchorPoint or Vector2.new(), ImageColor3 = props.Color or Color3.new(1, 1, 1),
        })
    end
    local text = tostring(name)
    if #text > 2 then text = "*" end
    return Util.New("TextLabel", {
        Parent = parent, BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 14,
        Size = props.Size or UDim2.fromOffset(16, 16), Position = props.Position or UDim2.new(),
        AnchorPoint = props.AnchorPoint or Vector2.new(), TextColor3 = props.Color or Color3.new(1, 1, 1),
    })
end

function Icons.SetColor(icon, color)
    if icon:IsA("ImageLabel") then icon.ImageColor3 = color else icon.TextColor3 = color end
end

function Icons.TweenColor(icon, time, color)
    return Util.Tween(icon, time, icon:IsA("ImageLabel") and { ImageColor3 = color } or { TextColor3 = color })
end

return Icons

end
__modules["init"] = function(...)
-- Orbit UI :: giris noktasi
local import = ...

local Orbit = { Version = "0.3.0", Windows = {} }

Orbit.Themes = import("Themes")

-- Bildirimler: Orbit:Notify(...)
import("Notify")(Orbit)

-- Pencere: Orbit:CreateWindow(...)
function Orbit:CreateWindow(opts)
    return import("Window")(Orbit, opts)
end

-- Watermark: Orbit:AddWatermark(...)
function Orbit:AddWatermark(opts)
    local ok, res = pcall(function()
        return import("Watermark")(Orbit, opts)
    end)
    if not ok then
        warn("[Orbit] Watermark hatasi: " .. tostring(res))
    end
    return res
end

-- Key System: Orbit:CreateKeySystem(...)
function Orbit:CreateKeySystem(opts)
    return import("KeySystem")(Orbit, opts)
end

return Orbit

end
__modules["KeybindList"] = function(...)
-- Orbit UI :: KeybindList (Ekranda tus ve ozellik durumu paneli)
local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

return function(Window, opts)
    opts = opts or {}
    local theme = Window.Theme
    local gui = Window.Gui

    local frame = New("CanvasGroup", {
        Name = "KeybindList", Parent = gui,
        Position = opts.Position or UDim2.new(0, 16, 0.4, 0),
        Size = UDim2.fromOffset(180, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Background, GroupTransparency = 0, ZIndex = 250,
    }, {
        Corner(10), Stroke(theme.Stroke),
        New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }),
    })

    -- Baslik
    local top = New("Frame", {
        Parent = frame, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0, ZIndex = 251,
    }, {
        Pad(10, 0, 10, 0),
        New("UIStroke", { Color = theme.Stroke, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }),
    })
    Icons.Create(top, "keyboard", {
        Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0, 0, 0.5, -7), Color = theme.Accent,
    }).ZIndex = 252
    New("TextLabel", {
        Parent = top, BackgroundTransparency = 1, Position = UDim2.fromOffset(20, 0),
        Size = UDim2.new(1, -20, 1, 0), Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = opts.Title or "Keybinds", ZIndex = 252,
    })

    Util.MakeDraggable(top, frame, Window.Connect)

    -- Liste konteyneri
    local list = New("Frame", {
        Parent = frame, LayoutOrder = 2, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 251,
    }, {
        Pad(8, 6, 8, 8),
        New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local entries = {}
    local KeybindList = { Frame = frame, Visible = true }

    function KeybindList:SetVisible(v)
        KeybindList.Visible = v
        frame.Visible = v
    end
    function KeybindList:Toggle() KeybindList:SetVisible(not KeybindList.Visible) end

    function KeybindList:Update(id, data)
        if not id then return end
        local item = entries[id]

        -- Eger gosterilmeyecekse veya kaldirilacaksa
        if data == nil or data.Hidden or data.Key == Enum.KeyCode.Unknown then
            if item then
                item.Row:Destroy()
                entries[id] = nil
            end
            return
        end

        local keyName = typeof(data.Key) == "EnumItem" and data.Key.Name or tostring(data.Key or "?")
        local state = data.State

        if not item then
            local row = New("Frame", {
                Parent = list, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20),
                ZIndex = 252,
            })
            local titleLbl = New("TextLabel", {
                Parent = row, BackgroundTransparency = 1, Size = UDim2.new(1, -70, 1, 0),
                Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                Text = data.Title or id, ZIndex = 253,
            })
            local badge = New("TextLabel", {
                Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.fromOffset(68, 18), BackgroundTransparency = 1,
                Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right,
                RichText = true, ZIndex = 253,
            })
            item = { Row = row, TitleLabel = titleLbl, Badge = badge }
            entries[id] = item
        end

        item.TitleLabel.Text = data.Title or id
        local stateStr = state and string.format("<font color='rgb(%d,%d,%d)'>[ON]</font>", math.floor(theme.Accent.R * 255), math.floor(theme.Accent.G * 255), math.floor(theme.Accent.B * 255))
            or string.format("<font color='rgb(%d,%d,%d)'>[OFF]</font>", math.floor(theme.SubText.R * 255), math.floor(theme.SubText.G * 255), math.floor(theme.SubText.B * 255))
        item.Badge.Text = string.format("[%s] %s", keyName, stateStr)
    end

    function KeybindList:Remove(id)
        if entries[id] then
            entries[id].Row:Destroy()
            entries[id] = nil
        end
    end

    function KeybindList:Destroy()
        frame:Destroy()
        table.clear(entries)
    end

    return KeybindList
end

end
__modules["KeySystem"] = function(...)
-- Orbit UI :: KeySystem (Anahtar Dogrulama Arayuzu)
local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local HttpService = game:GetService("HttpService")

return function(Orbit, opts)
    opts = opts or {}
    local theme = Orbit.CurrentTheme or Orbit.Themes.Dark
    local folder = opts.ConfigFolder or "OrbitUI"
    local savePath = folder .. "/saved_key.txt"

    local function canFS()
        return writefile and readfile and isfolder and makefolder and isfile
    end

    local function checkKey(key)
        if opts.CheckKey then
            local ok, res = pcall(opts.CheckKey, key)
            return ok and res
        end
        if opts.Keys then
            for _, k in ipairs(opts.Keys) do
                if k == key then return true end
            end
        end
        if opts.Key and opts.Key == key then return true end
        return false
    end

    -- Otomatik hatirlanan key kontrolu
    if opts.SaveKey ~= false and canFS() and isfile(savePath) then
        local saved = readfile(savePath):gsub("%s+", "")
        if checkKey(saved) then
            if opts.Callback then task.spawn(opts.Callback, true) end
            return
        end
    end

    -- GUI olustur
    local gui = New("ScreenGui", {
        Name = "OrbitKeySystem_" .. HttpService:GenerateGUID(false):sub(1, 8),
        ResetOnSpawn = false, DisplayOrder = 1000, IgnoreGuiInset = true,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = Util.GetGuiParent()

    local card = New("CanvasGroup", {
        Name = "KeyCard", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(360, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Background,
        GroupTransparency = 1, ZIndex = 600,
    }, {
        Corner(12), Stroke(theme.Stroke), Pad(18, 16, 18, 16),
        New("UIListLayout", { Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
    })

    -- Baslik alani
    local topRow = New("Frame", {
        Parent = card, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
    })
    Icons.Create(topRow, "key", {
        Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, 0, 0.5, -10),
        Color = theme.Accent,
    })
    New("TextLabel", {
        Parent = topRow, BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -28, 1, 0), Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = opts.Title or "Key System",
    })

    if opts.Subtitle or opts.Note then
        New("TextLabel", {
            Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = theme.SubText, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            Text = opts.Note or opts.Subtitle or "Lutfen anahtarinizi girin.",
        })
    end

    -- Girdi kutusu
    local inputWrap = New("Frame", {
        Parent = card, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = theme.Element,
    }, { Corner(8), Stroke(theme.Stroke), Pad(10, 0, 10, 0) })

    local box = New("TextBox", {
        Parent = inputWrap, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = theme.Text, PlaceholderText = "Anahtar buraya...", PlaceholderColor3 = theme.SubText,
        Text = "",
    })

    -- Butonlar
    local btnRow = New("Frame", {
        Parent = card, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1,
    }, { New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8) }) })

    local verifyBtn = New("TextButton", {
        Parent = btnRow, Size = UDim2.new(opts.Link and 0.55 or 1, -4, 1, 0),
        BackgroundColor3 = theme.Accent, AutoButtonColor = false,
        Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
        Text = "Dogrula",
    }, { Corner(8) })

    if opts.Link then
        local linkBtn = New("TextButton", {
            Parent = btnRow, Size = UDim2.new(0.45, -4, 1, 0),
            BackgroundColor3 = theme.Element, AutoButtonColor = false,
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
            Text = "Key Al",
        }, { Corner(8), Stroke(theme.Stroke) })

        linkBtn.Activated:Connect(function()
            local setClip = setclipboard or toclipboard or (Clipboard and Clipboard.set)
            if setClip then
                setClip(opts.Link)
                Orbit:Notify({ Title = "Kopyalandi", Content = "Key linki panoya kopyalandi!", Type = "Success" })
            else
                Orbit:Notify({ Title = "Link", Content = opts.Link, Duration = 8 })
            end
        end)
    end

    Util.MakeDraggable(topRow, card)

    -- Dogrulama islemi
    local function verify()
        local entered = box.Text:gsub("%s+", "")
        if checkKey(entered) then
            Tween(inputWrap.UIStroke, 0.15, { Color = Color3.fromRGB(50, 205, 120) })
            if opts.SaveKey ~= false and canFS() then
                if not isfolder(folder) then makefolder(folder) end
                writefile(savePath, entered)
            end
            Orbit:Notify({ Title = "Basarili", Content = "Key dogrulandi! Yukleniyor...", Type = "Success", Duration = 3 })
            Tween(card, 0.25, { GroupTransparency = 1 }).Completed:Wait()
            gui:Destroy()
            if opts.Callback then task.spawn(opts.Callback, true) end
        else
            Tween(inputWrap.UIStroke, 0.15, { Color = theme.Danger })
            Orbit:Notify({ Title = "Gecersiz Key", Content = "Girdiginiz anahtar yanlis, tekrar deneyin.", Type = "Error" })
            task.delay(1, function()
                Tween(inputWrap.UIStroke, 0.15, { Color = theme.Stroke })
            end)
        end
    end

    verifyBtn.Activated:Connect(verify)
    box.FocusLost:Connect(function(enter)
        if enter then verify() end
    end)

    Tween(card, 0.3, { GroupTransparency = 0 })
end

end
__modules["Notify"] = function(...)
-- Orbit UI :: Notify (Zengin Bildirimler)
local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local SoundService = game:GetService("SoundService")

local TYPE_COLORS = {
    Info = Color3.fromRGB(88, 130, 255),
    Success = Color3.fromRGB(50, 205, 120),
    Warning = Color3.fromRGB(245, 175, 50),
    Error = Color3.fromRGB(240, 75, 85),
}

local TYPE_ICONS = {
    Info = "info",
    Success = "circle-check",
    Warning = "triangle-alert",
    Error = "circle-alert",
}

return function(Orbit)
    local holder

    local function ensureHolder(gui)
        if holder and holder.Parent then return holder end
        holder = New("Frame", {
            Name = "Notifications", Parent = gui, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(320, 460),
            ZIndex = 500,
        }, { New("UIListLayout", { Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder }) })
        return holder
    end

    local function playSound(soundId)
        if not soundId then return end
        task.spawn(function()
            local id = soundId == true and "rbxassetid://4590662766" or (typeof(soundId) == "number" and ("rbxassetid://" .. soundId) or soundId)
            local s = Instance.new("Sound")
            s.SoundId = tostring(id)
            s.Volume = 0.5
            s.Parent = SoundService
            s:Play()
            s.Ended:Connect(function() s:Destroy() end)
            task.delay(3, function() if s and s.Parent then s:Destroy() end end)
        end)
    end

    function Orbit:Notify(opts)
        opts = opts or {}
        if not self.Gui then return end
        local theme = self.CurrentTheme or Orbit.Themes.Dark
        local parent = ensureHolder(self.Gui)

        local nType = opts.Type or "Info"
        local accentColor = TYPE_COLORS[nType] or theme.Accent
        local iconName = opts.Icon or TYPE_ICONS[nType]
        local duration = opts.Duration or (opts.Buttons and 8 or 4)

        if opts.Sound then playSound(opts.Sound) end

        local card = New("CanvasGroup", {
            Parent = parent, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Background, GroupTransparency = 1, ZIndex = 501,
        }, {
            Corner(10), Stroke(theme.Stroke), Pad(12, 12, 12, 12),
            New("UIListLayout", { Padding = UDim.new(0, 6) }),
        })

        -- Baslik satiri (ikon + baslik + kapat butonu)
        local header = New("Frame", {
            Parent = card, LayoutOrder = 1, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
        })

        local xOff = 0
        if iconName then
            local ic = Icons.Create(header, iconName, {
                Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(0, 1),
                Color = accentColor,
            })
            ic.ZIndex = 502
            xOff = 24
        end

        New("TextLabel", {
            Parent = header, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(xOff, 0), Size = UDim2.new(1, -xOff - 20, 1, 0),
            Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = theme.Text, Text = opts.Title or "Bildirim", ZIndex = 502,
        })

        local closeBtn = New("TextButton", {
            Parent = header, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            TextSize = 12, TextColor3 = theme.SubText, Text = "X", ZIndex = 503,
        })

        if opts.Content then
            New("TextLabel", {
                Parent = card, LayoutOrder = 2, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText,
                Text = opts.Content, ZIndex = 502,
            })
        end

        -- Butonlar
        local closed = false
        local function dismiss()
            if closed then return end
            closed = true
            Tween(card, 0.2, { GroupTransparency = 1 }).Completed:Wait()
            card:Destroy()
        end
        closeBtn.Activated:Connect(dismiss)

        if opts.Buttons and #opts.Buttons > 0 then
            local btnRow = New("Frame", {
                Parent = card, LayoutOrder = 3, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26), ZIndex = 502,
            }, { New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 6) }) })

            for _, b in ipairs(opts.Buttons) do
                local bg = b.Danger and theme.Danger or (b.Primary and accentColor or theme.Element)
                local txtCol = (b.Danger or b.Primary) and Color3.new(1, 1, 1) or theme.Text
                local btn = New("TextButton", {
                    Parent = btnRow, Size = UDim2.fromOffset(72, 26), BackgroundColor3 = bg,
                    AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 11,
                    TextColor3 = txtCol, Text = b.Title or "Tamam", ZIndex = 503,
                }, { Corner(6) })
                btn.Activated:Connect(function()
                    dismiss()
                    if b.Callback then task.spawn(b.Callback) end
                end)
            end
        end

        -- Ilerleme cubugu
        local bar = New("Frame", {
            Parent = card, LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = accentColor, BorderSizePixel = 0, ZIndex = 502,
        }, { Corner(1) })

        Tween(card, 0.25, { GroupTransparency = 0 })
        if duration and duration > 0 then
            Tween(bar, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
            task.delay(duration, function()
                if not closed then dismiss() end
            end)
        else
            bar.Visible = false
        end
    end
end

end
__modules["SettingsTab"] = function(...)
-- Orbit UI :: SettingsTab (hazir ayarlar sekmesi)
local import = ...

return function(Window, Orbit, o)
    o = o or {}
    local Tab = Window:Tab({ Title = o.Title or "Ayarlar", Icon = o.Icon or "settings" })

    Tab:Section("Gorunum")
    local names = {}
    for name in pairs(Orbit.Themes) do table.insert(names, name) end
    table.sort(names)
    Tab:Dropdown({ Title = "Tema", Flag = "Orbit_Theme", Values = names, Default = Window.ThemeName,
        Callback = function(v) Window:SetTheme(v) end })

    local accent = Tab:ColorPicker({ Title = "Aksan Rengi", Flag = "Orbit_Accent", Default = Window.Theme.Accent,
        Callback = function(c) Window:SetAccent(c) end })
    Tab:Button({ Title = "Aksan Rengini Sifirla", Description = "Temanin kendi rengine don", Callback = function()
        Window:ResetAccent()
        accent:Set(Window.Theme.Accent, true)
    end })

    Tab:Section("Overlay & Araclar")
    local watermarkInstance
    Tab:Toggle({ Title = "Watermark", Default = false, Callback = function(v)
        if v then
            if not watermarkInstance then watermarkInstance = Window:AddWatermark() end
            watermarkInstance:SetVisible(true)
        else
            if watermarkInstance then watermarkInstance:SetVisible(false) end
        end
    end })

    local keyListInstance
    Tab:Toggle({ Title = "Keybind Listesi", Default = false, Callback = function(v)
        if v then
            if not keyListInstance then keyListInstance = Window:CreateKeybindList() end
            keyListInstance:SetVisible(true)
        else
            if keyListInstance then keyListInstance:SetVisible(false) end
        end
    end })

    Tab:Section("Kontroller")
    Tab:Keybind({ Title = "Menu Tusu", Flag = "Orbit_ToggleKey", Default = Window.ToggleKey, Tooltip = "ESC ile tusu kaldirabilirsin",
        Changed = function(k) Window.ToggleKey = k end })
    Tab:Toggle({ Title = "Mobil Buton", Default = Window.Gui.MobileToggle.Visible, Callback = function(v) Window:SetMobileButton(v) end })

    Tab:Section("Config")
    local cfgName = "default"
    local list
    Tab:Input({ Title = "Config adi", Default = cfgName, Callback = function(t) if t ~= "" then cfgName = t end end })
    list = Tab:Dropdown({ Title = "Kayitli configler", Values = Window:ListConfigs(), Callback = function(v) cfgName = v end })
    Tab:Button({ Title = "Kaydet", Callback = function()
        local ok, err = Window:SaveConfig(cfgName)
        Window:Notify({ Title = ok and "Kaydedildi" or "Hata", Content = ok and cfgName or tostring(err), Type = ok and "Success" or "Error" })
        list:Refresh(Window:ListConfigs())
    end })
    Tab:Button({ Title = "Yukle", Callback = function()
        local ok, err = Window:LoadConfig(cfgName)
        Window:Notify({ Title = ok and "Yuklendi" or "Hata", Content = ok and cfgName or tostring(err), Type = ok and "Success" or "Error" })
    end })
    Tab:Toggle({ Title = "Otomatik Kaydet", Description = "Her degisiklikte secili config'e yazar", Callback = function(v)
        if v then Window:EnableAutoSave(cfgName) else Window:DisableAutoSave() end
    end })

    Tab:Section("Arayuz")
    Tab:Button({ Title = "Arayuzu Kaldir", Description = "Menuyu tamamen kapatir", Callback = function()
        Window:Dialog({ Title = "Emin misin?", Content = "Arayuz tamamen kaldirilacak.", Buttons = {
            { Title = "Iptal" }, { Title = "Kaldir", Danger = true, Callback = function() Window:Destroy() end },
        } })
    end })

    return Tab
end

end
__modules["Tab"] = function(...)
-- Orbit UI :: Tab (sekme + element baglama)
local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local ELEMENTS = {
    "Section", "Divider", "Label", "Paragraph", "Image", "ProgressBar",
    "Button", "Toggle", "Slider", "RangeSlider", "Input", "TextArea", "Dropdown", "Keybind", "ColorPicker",
}

return function(Window, env, t)
    t = t or {}
    local theme, sidebar, content, state = env.Theme, env.Sidebar, env.Content, env.TabState
    local Tab = {}

    env.TabCount += 1
    local btn = New("TextButton", { Parent = sidebar, LayoutOrder = 10 + env.TabCount, Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = theme.Element, BackgroundTransparency = 1, AutoButtonColor = false, Text = "" }, { Corner(7) })
    local indicator = New("Frame", { Parent = btn, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, -8, 0.5, 0), Size = UDim2.fromOffset(3, 0), BackgroundColor3 = theme.Accent, BorderSizePixel = 0 }, { Corner(2) })
    local icon
    if t.Icon then
        icon = Icons.Create(btn, t.Icon, { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 12, 0.5, -8), Color = theme.SubText })
    end
    local label = New("TextLabel", { Parent = btn, BackgroundTransparency = 1, Position = UDim2.fromOffset(icon and 36 or 12, 0), Size = UDim2.new(1, icon and -44 or -20, 1, 0), Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = t.Title or "Tab" })

    local page = New("ScrollingFrame", { Parent = content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Stroke, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false }, {
        Pad(14, 14, 14, 14), New("UIListLayout", { Padding = UDim.new(0, 8) }),
    })

    -- CanvasSize guvencesi: CanvasGroup icinde AutomaticCanvasSize calismazsa bile AbsoluteContentSize ile guncelle
    local pageLayout = page:FindFirstChildOfClass("UIListLayout")
    if pageLayout then
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.fromOffset(0, pageLayout.AbsoluteContentSize.Y + 28)
        end)
    end

    local function select()
        if state.current == Tab then return end
        if state.current then state.current._deselect() end
        state.current = Tab
        page.Visible = true
        Tween(btn, 0.15, { BackgroundTransparency = 0 })
        Tween(label, 0.15, { TextColor3 = theme.Text })
        if icon then Icons.TweenColor(icon, 0.15, theme.Text) end
        Tween(indicator, 0.2, { Size = UDim2.fromOffset(3, 16) })
    end
    Tab._deselect = function()
        page.Visible = false
        Tween(btn, 0.15, { BackgroundTransparency = 1 })
        Tween(label, 0.15, { TextColor3 = theme.SubText })
        if icon then Icons.TweenColor(icon, 0.15, theme.SubText) end
        Tween(indicator, 0.15, { Size = UDim2.fromOffset(3, 0) })
    end
    Tab.Select = select
    btn.Activated:Connect(select)
    table.insert(env.TabList, { Page = page, Select = select })
    if state.first then state.first = false; select() end

    -- Elementlerin paylastigi baglam
    local order = 0
    local ctx = { Window = Window, Tab = Tab, Theme = theme, Page = page, Connect = env.Connect, Call = env.Call }
    function ctx.NextOrder() order += 1 return order end

    function ctx.Row(height, title, desc)
        local row = New("Frame", { Parent = page, LayoutOrder = ctx.NextOrder(), Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = theme.Element, ClipsDescendants = true }, { Corner(8), Stroke(theme.Stroke) })
        row:SetAttribute("OrbitSearch", ((title or "") .. " " .. (desc or "")):lower())
        local label = New("TextLabel", { Parent = row, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, desc and 7 or 0), Size = UDim2.new(1, -24, 0, desc and 16 or math.min(height, 38)), Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = title or "" })
        if desc then
            New("TextLabel", { Parent = row, BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 23), Size = UDim2.new(1, -24, 0, 14), Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = desc })
        end
        return row, label
    end

    function ctx.MarkStatic(inst)
        inst:SetAttribute("OrbitSearch", "")
        inst:SetAttribute("OrbitStatic", true)
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
            local obj = import("Elements." .. name)(ctx, o)
            if type(o) == "table" and o.Tooltip then
                for _, ch in ipairs(page:GetChildren()) do
                    if ch:IsA("GuiObject") and ch.LayoutOrder == order then
                        env.AttachTooltip(ch, o.Tooltip)
                        break
                    end
                end
            end
            return obj
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
        Element = Color3.fromRGB(252, 252, 254), ElementHover = Color3.fromRGB(240, 242, 248),
        Stroke = Color3.fromRGB(215, 218, 228), Text = Color3.fromRGB(30, 32, 42),
        SubText = Color3.fromRGB(110, 115, 135), Accent = Color3.fromRGB(70, 110, 240),
        Danger = Color3.fromRGB(220, 60, 70),
    },
}

end
__modules["Tooltip"] = function(...)
-- Orbit UI :: Tooltip (fare ustune gelince aciklama)
local import = ...
local Util = import("Util")
local New, Corner, Stroke, Pad = Util.New, Util.Corner, Util.Stroke, Util.Pad

local UserInputService = game:GetService("UserInputService")

return function(env)
    local theme, gui = env.Theme, env.Gui

    local tip = New("TextLabel", {
        Name = "Tooltip", Parent = gui, Visible = false, BackgroundColor3 = theme.Element, BorderSizePixel = 0,
        TextColor3 = theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0), ZIndex = 200,
    }, {
        Corner(6), Stroke(theme.Stroke), Pad(8, 5, 8, 5),
        New("UISizeConstraint", { MaxSize = Vector2.new(260, math.huge) }),
    })

    local function place()
        local m = UserInputService:GetMouseLocation()
        local vp = gui.AbsoluteSize
        local x = math.min(m.X + 14, vp.X - tip.AbsoluteSize.X - 6)
        local y = math.min(m.Y + 18, vp.Y - tip.AbsoluteSize.Y - 6)
        tip.Position = UDim2.fromOffset(x, y)
    end

    -- row ve icindeki tam-boy butonlar ayni "hover" sayacini paylasir
    function env.AttachTooltip(row, text)
        local targets = { row }
        for _, c in ipairs(row:GetChildren()) do
            if c:IsA("TextButton") then table.insert(targets, c) end
        end
        local hover, token = 0, 0
        for _, t in ipairs(targets) do
            t.MouseEnter:Connect(function()
                hover += 1
                token += 1
                local my = token
                task.delay(0.45, function()
                    if my == token and hover > 0 then
                        tip.Text = text
                        place()
                        tip.Visible = true
                    end
                end)
            end)
            t.MouseMoved:Connect(function()
                if tip.Visible then place() end
            end)
            t.MouseLeave:Connect(function()
                hover = math.max(0, hover - 1)
                if hover == 0 then
                    token += 1
                    tip.Visible = false
                end
            end)
        end
    end
end

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
    if class == "UIListLayout" and (not props or props.SortOrder == nil) then
        inst.SortOrder = Enum.SortOrder.LayoutOrder
    end
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

local function defaultConnect(signal, fn) return signal:Connect(fn) end

function Util.MakeDraggable(handle, target, connect)
    connect = connect or defaultConnect
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startInput, startPos = true, i.Position, target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    connect(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Surukleme sirasinda input takibi (slider, color picker)
-- callback(pos, isStart)
function Util.Drag(frame, callback, connect)
    connect = connect or defaultConnect
    local active = false
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true
            callback(i.Position, true)
        end
    end)
    connect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end
    end)
    connect(UserInputService.InputChanged, function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            callback(i.Position, false)
        end
    end)
end

function Util.round(n, step)
    step = step or 1
    return math.floor(n / step + 0.5) * step
end

return Util

end
__modules["Watermark"] = function(...)
-- Orbit UI :: Watermark (FPS, Ping, Saat ve Bilgi Ekrani)
local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")

return function(Orbit, opts)
    opts = opts or {}
    local theme = Orbit.CurrentTheme or Orbit.Themes.Dark
    local gui = Orbit.Gui

    if not gui then
        local HttpService = game:GetService("HttpService")
        gui = New("ScreenGui", {
            Name = "OrbitWatermark_" .. HttpService:GenerateGUID(false):sub(1, 8),
            ResetOnSpawn = false, DisplayOrder = 998, IgnoreGuiInset = true,
        })
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
        gui.Parent = Util.GetGuiParent()
    end

    local showFps = opts.ShowFPS ~= false
    local showPing = opts.ShowPing ~= false
    local showTime = opts.ShowTime ~= false
    local title = opts.Title or "Orbit UI"
    local build = opts.Build or Orbit.Version or "v0.3.0"
    local customText = opts.CustomText

    -- Roblox topbar'i altinda guvenli konum (Y = 56)
    local pos = opts.Position or UDim2.new(0, 16, 0, 56)

    local frame = New("Frame", {
        Name = "Watermark", Parent = gui, Position = pos,
        Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = theme.Background, ZIndex = 300,
    }, {
        Corner(14), Stroke(theme.Stroke), Pad(10, 4, 10, 4),
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
        }),
    })

    local dot = New("Frame", {
        Parent = frame, Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = theme.Accent, BorderSizePixel = 0, ZIndex = 301,
    }, { Corner(4) })

    local label = New("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
        RichText = true, Text = "", ZIndex = 301,
    })

    Util.MakeDraggable(frame, frame)

    local Watermark = { Frame = frame, Visible = true }

    function Watermark:SetTitle(t) title = t end
    function Watermark:SetCustomText(t) customText = t end
    function Watermark:SetVisible(v)
        Watermark.Visible = v
        frame.Visible = v
    end
    function Watermark:Toggle() Watermark:SetVisible(not Watermark.Visible) end

    local fps = 60
    local lastTime = tick()
    local frameCount = 0

    local function updateStats()
        local parts = {}
        table.insert(parts, string.format("<b>%s</b> <font color='rgb(%d,%d,%d)'>%s</font>", title, math.floor(theme.SubText.R * 255), math.floor(theme.SubText.G * 255), math.floor(theme.SubText.B * 255), build))

        if customText then
            table.insert(parts, customText)
        end
        if showFps then
            table.insert(parts, string.format("<font color='rgb(%d,%d,%d)'>%d FPS</font>", math.floor(theme.Accent.R * 255), math.floor(theme.Accent.G * 255), math.floor(theme.Accent.B * 255), fps))
        end
        if showPing then
            local ping = 0
            pcall(function()
                local net = Stats:FindFirstChild("Network")
                local sItem = net and net:FindFirstChild("ServerStatsItem")
                local dPing = sItem and sItem:FindFirstChild("Data Ping")
                if dPing then
                    ping = math.floor(tonumber(dPing:GetValueString():match("%d+")) or 0)
                else
                    local p = Players.LocalPlayer
                    if p and p.GetNetworkPing then ping = math.floor((p:GetNetworkPing() or 0) * 1000) end
                end
            end)
            table.insert(parts, string.format("%dms", ping))
        end
        if showTime then
            local ok, tStr = pcall(function() return os.date("%H:%M:%S") end)
            if ok and tStr then table.insert(parts, tStr) end
        end

        label.Text = table.concat(parts, "  <font color='rgb(100,100,120)'>|</font>  ")
    end

    -- Hemen ilk guncellemeyi yap (metin bos kalmasin)
    updateStats()

    local conn = RunService.RenderStepped:Connect(function()
        frameCount += 1
        local now = tick()
        if now - lastTime >= 0.5 then
            fps = math.floor(frameCount / (now - lastTime))
            frameCount = 0
            lastTime = now
            updateStats()
        end
    end)

    function Watermark:Destroy()
        if conn then conn:Disconnect() end
        frame:Destroy()
    end

    return Watermark
end

end
__modules["Window"] = function(...)
-- Orbit UI :: Window
local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local function copy(t)
    local c = {}
    for k, v in pairs(t) do c[k] = v end
    return c
end

local function colorKey(c)
    return string.format("%d,%d,%d", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

return function(Orbit, opts)
    opts = opts or {}
    local themeName = Orbit.Themes[opts.Theme or "Dark"] and (opts.Theme or "Dark") or "Dark"
    local theme = copy(Orbit.Themes[themeName]) -- pencereye ozel kopya (canli degisebilir)
    if opts.Accent then theme.Accent = opts.Accent end
    Orbit.CurrentTheme = theme

    local Window = { Setters = {}, Tabs = {}, Theme = theme, ThemeName = themeName, Visible = false, ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift }
    local size = opts.Size or UDim2.fromOffset(620, 420)
    local curW, curH = size.X.Offset, size.Y.Offset

    ---------------------------------------------------------------- baglanti yonetimi
    local conns = {}
    local function connect(signal, fn)
        local c = signal:Connect(fn)
        table.insert(conns, c)
        return c
    end
    Window.Connect = connect

    ---------------------------------------------------------------- hata korumali callback
    function Window.Call(fn, ...)
        if not fn then return end
        local args = table.pack(...)
        task.spawn(function()
            local ok, err = pcall(fn, table.unpack(args, 1, args.n))
            if not ok then
                warn("[Orbit] callback hatasi: " .. tostring(err))
                Orbit:Notify({ Title = "Callback hatasi", Content = tostring(err):sub(1, 140), Duration = 6 })
            end
        end)
    end

    ---------------------------------------------------------------- flag deposu (otomatik kayit icin proxy)
    local flagData = {}
    local saveQueued = false
    Window._flagData = flagData
    Window.Flags = setmetatable({}, {
        __index = flagData,
        __newindex = function(_, k, v)
            flagData[k] = v
            if Window.AutoSaveName and not Window._loading and not saveQueued then
                saveQueued = true
                task.delay(1, function()
                    saveQueued = false
                    if Window.AutoSaveName then Window:SaveConfig(Window.AutoSaveName) end
                end)
            end
        end,
    })

    ---------------------------------------------------------------- ScreenGui
    local gui = New("ScreenGui", { Name = "OrbitUI_" .. HttpService:GenerateGUID(false):sub(1, 8), ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999, IgnoreGuiInset = true })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = Util.GetGuiParent()
    Orbit.Gui = gui
    Window.Gui = gui

    local blur
    if opts.Blur then blur = New("BlurEffect", { Size = 0, Parent = Lighting }) end

    local main = New("CanvasGroup", {
        Name = "Main", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(curW, curH), BackgroundColor3 = theme.Background, GroupTransparency = 1,
    }, { Corner(12), Stroke(theme.Stroke) })
    local scale = New("UIScale", { Parent = main, Scale = 0.92 })

    -- Kucuk ekranlara otomatik sigdir
    local fitScale = 1
    local function fit()
        local vp = gui.AbsoluteSize
        fitScale = math.min(1, vp.X / (curW + 40), vp.Y / (curH + 40))
        if Window.Visible then scale.Scale = fitScale end
    end
    gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)

    ---------------------------------------------------------------- ust bar
    local top = New("Frame", { Name = "Topbar", Parent = main, Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0 })
    New("Frame", { Parent = top, Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = theme.Stroke, BorderSizePixel = 0 })
    local titleLabel = New("TextLabel", { Parent = top, BackgroundTransparency = 1, Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -120, 1, 0), Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, RichText = true })
    local function renderTitle()
        local title = opts.Title or "Orbit UI"
        if opts.Subtitle then
            local c = theme.SubText
            titleLabel.Text = string.format("%s  <font color='rgb(%d,%d,%d)' size='12'>%s</font>", title,
                math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5), opts.Subtitle)
        else
            titleLabel.Text = title
        end
    end
    renderTitle()
    Util.MakeDraggable(top, main, connect)

    local function topButton(text, xOff, hoverColor)
        local b = New("TextButton", { Parent = top, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xOff, 0.5, 0), Size = UDim2.fromOffset(28, 28), BackgroundColor3 = theme.Element, AutoButtonColor = false, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.SubText, Text = text }, { Corner(7) })
        b.MouseEnter:Connect(function() Tween(b, 0.12, { BackgroundColor3 = hoverColor(), TextColor3 = Color3.new(1, 1, 1) }) end)
        b.MouseLeave:Connect(function() Tween(b, 0.12, { BackgroundColor3 = theme.Element, TextColor3 = theme.SubText }) end)
        return b
    end
    local closeBtn = topButton("X", -10, function() return theme.Danger end)
    local minBtn = topButton("-", -44, function() return theme.ElementHover end)

    ---------------------------------------------------------------- sidebar + arama + icerik
    local sidebar = New("ScrollingFrame", { Name = "Sidebar", Parent = main, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(0, 158, 1, -44), BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new() }, {
        Pad(10, 10, 10, 10), New("UIListLayout", { Padding = UDim.new(0, 4) }),
    })
    local sidebarLayout = sidebar:FindFirstChildOfClass("UIListLayout")
    if sidebarLayout then
        sidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            sidebar.CanvasSize = UDim2.fromOffset(0, sidebarLayout.AbsoluteContentSize.Y + 20)
        end)
    end
    local searchBox = New("TextBox", { Name = "Search", Parent = sidebar, LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = theme.Element, ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.Text, PlaceholderText = "Ara...", PlaceholderColor3 = theme.SubText, Text = "", TextXAlignment = Enum.TextXAlignment.Left }, { Corner(7), Stroke(theme.Stroke), Pad(10, 0, 8, 0) })

    local content = New("Frame", { Name = "Content", Parent = main, Position = UDim2.fromOffset(158, 44), Size = UDim2.new(1, -158, 1, -44), BackgroundTransparency = 1, ClipsDescendants = true })

    local env = {
        Theme = theme, Gui = gui, Main = main, Sidebar = sidebar, Content = content,
        TabState = { first = true }, TabCount = 0, TabList = {},
        Connect = connect, Call = Window.Call,
    }

    -- Arama: Row/Paragraph'lar OrbitSearch attribute'u tasir
    local function applySearch()
        local q = searchBox.Text:lower()
        local counts = {}
        for _, tab in ipairs(env.TabList) do
            local n = 0
            for _, ch in ipairs(tab.Page:GetChildren()) do
                if ch:IsA("GuiObject") then
                    local s = ch:GetAttribute("OrbitSearch")
                    if s ~= nil then
                        local show
                        if q == "" then show = true
                        elseif ch:GetAttribute("OrbitStatic") then show = false
                        else show = s:find(q, 1, true) ~= nil end
                        ch.Visible = show
                        if show and not ch:GetAttribute("OrbitStatic") then n += 1 end
                    end
                end
            end
            counts[tab] = n
        end
        -- aktif sekmede sonuc yoksa, sonucu olan ilk sekmeye gec
        if q ~= "" then
            local cur
            for _, tab in ipairs(env.TabList) do
                if tab.Page.Visible then cur = tab end
            end
            if cur and counts[cur] == 0 then
                for _, tab in ipairs(env.TabList) do
                    if counts[tab] > 0 then tab.Select() break end
                end
            end
        end
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)

    ---------------------------------------------------------------- gorunurluk
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
        for _, c in ipairs(conns) do c:Disconnect() end
        table.clear(conns)
        Window.AutoSaveName = nil
        if blur then blur:Destroy() end
        if Window.KeybindList then Window.KeybindList:Destroy() end
        gui:Destroy()
        for i, w in ipairs(Orbit.Windows) do
            if w == Window then table.remove(Orbit.Windows, i) break end
        end
        if Orbit.Gui == gui then Orbit.Gui = nil end
    end
    function Window:Notify(o) Orbit:Notify(o) end

    ---------------------------------------------------------------- mobil ac/kapat butonu
    local mobile = New("TextButton", {
        Name = "MobileToggle", Parent = gui, Size = UDim2.fromOffset(46, 46), Position = UDim2.new(0, 20, 0.5, -23),
        BackgroundColor3 = theme.Accent, Text = "", AutoButtonColor = false, ZIndex = 100,
        Visible = opts.MobileButton ~= nil and opts.MobileButton or UserInputService.TouchEnabled,
    }, { Corner(23), Stroke(theme.Stroke) })
    Icons.Create(mobile, opts.MobileIcon or "layout-dashboard", { Size = UDim2.fromOffset(22, 22), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), Color = Color3.new(1, 1, 1) }).ZIndex = 101
    Util.MakeDraggable(mobile, mobile, connect)
    mobile.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            local start = i.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End and (i.Position - start).Magnitude < 8 then
                    Window:Toggle()
                end
            end)
        end
    end)
    function Window:SetMobileButton(v) mobile.Visible = v and true or false end

    ---------------------------------------------------------------- yeniden boyutlandirma
    local grip = New("TextButton", { Name = "ResizeGrip", Parent = main, AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1, 1), Size = UDim2.fromOffset(22, 22), BackgroundTransparency = 1, Text = "", ZIndex = 20 })
    for _, l in ipairs({ { 12, 10 }, { 6, 15 } }) do
        New("Frame", { Parent = grip, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(l[2] + 2, l[2] + 2), Size = UDim2.fromOffset(l[1], 2), Rotation = -45, BackgroundColor3 = theme.SubText, BorderSizePixel = 0 }, { Corner(1) })
    end
    local rs
    Util.Drag(grip, function(pos, isStart)
        if isStart then rs = { pos = pos, w = curW, h = curH, p = main.Position } return end
        local s = math.max(scale.Scale, 0.1)
        local w = math.clamp(rs.w + (pos.X - rs.pos.X) / s, opts.MinWidth or 460, opts.MaxWidth or 1000)
        local h = math.clamp(rs.h + (pos.Y - rs.pos.Y) / s, opts.MinHeight or 320, opts.MaxHeight or 800)
        curW, curH = w, h
        main.Size = UDim2.fromOffset(w, h)
        main.Position = UDim2.new(rs.p.X.Scale, rs.p.X.Offset + (w - rs.w) * s / 2, rs.p.Y.Scale, rs.p.Y.Offset + (h - rs.h) * s / 2)
    end, connect)

    ---------------------------------------------------------------- canli tema
    local function applyMap(inst, prop, map)
        local nc = map[colorKey(inst[prop])]
        if nc then inst[prop] = nc end
    end
    local function retheme(old)
        local map = {}
        for k, oc in pairs(old) do
            local nc = theme[k]
            if nc and colorKey(oc) ~= colorKey(nc) then map[colorKey(oc)] = nc end
        end
        for _, d in ipairs(gui:GetDescendants()) do
            if d:IsA("GuiObject") then
                applyMap(d, "BackgroundColor3", map)
                if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then applyMap(d, "TextColor3", map) end
                if d:IsA("TextBox") then applyMap(d, "PlaceholderColor3", map) end
                if d:IsA("ImageLabel") or d:IsA("ImageButton") then applyMap(d, "ImageColor3", map) end
                if d:IsA("ScrollingFrame") then applyMap(d, "ScrollBarImageColor3", map) end
            elseif d:IsA("UIStroke") then
                applyMap(d, "Color", map)
            end
        end
    end

    -- SetTheme("Midnight")  veya  SetTheme({ Accent = Color3.fromRGB(...) })
    function Window:SetTheme(t)
        local old = copy(theme)
        if type(t) == "string" then
            local base = Orbit.Themes[t]
            if not base then return false end
            Window.ThemeName = t
            for k, v in pairs(base) do theme[k] = v end
            if Window.CustomAccent then theme.Accent = Window.CustomAccent end
        elseif type(t) == "table" then
            for k, v in pairs(t) do theme[k] = v end
        else
            return false
        end
        retheme(old)
        renderTitle()
        return true
    end
    function Window:SetAccent(color)
        Window.CustomAccent = color
        return Window:SetTheme({ Accent = color })
    end
    function Window:ResetAccent()
        Window.CustomAccent = nil
        return Window:SetTheme(Window.ThemeName)
    end

    ---------------------------------------------------------------- keybind listesi & watermark
    Window.Keybinds = {}
    function Window:UpdateKeybind(id, data)
        Window.Keybinds[id] = data
        if Window.KeybindList then
            Window.KeybindList:Update(id, data)
        end
    end

    function Window:CreateKeybindList(o)
        local kl = import("KeybindList")(Window, o)
        Window.KeybindList = kl
        for id, data in pairs(Window.Keybinds) do
            kl:Update(id, data)
        end
        return kl
    end

    function Window:AddWatermark(o)
        return Orbit:AddWatermark(o)
    end

    ---------------------------------------------------------------- alt moduller
    import("Tooltip")(env)
    import("Dialog")(Window, env)
    import("Config")(Window, opts.ConfigFolder or "OrbitUI")

    function Window:Tab(t)
        local ok, tab = pcall(function()
            return import("Tab")(Window, env, t)
        end)
        if not ok then
            warn("[Orbit] Tab olusturulamadi: " .. tostring(tab))
            Orbit:Notify({ Title = "Tab Hatasi", Content = tostring(tab):sub(1, 100), Type = "Error" })
            return nil
        end
        table.insert(Window.Tabs, tab)
        return tab
    end

    -- Sidebar'da baslik: Window:TabSection("Combat")
    function Window:TabSection(title)
        env.TabCount += 1
        New("TextLabel", { Parent = sidebar, LayoutOrder = 10 + env.TabCount, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24), Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = string.upper(title or "") }, { Pad(6, 6, 0, 0) })
    end

    -- Hazir ayarlar sekmesi: tema, aksan, tus, config, otomatik kayit
    function Window:AddSettingsTab(o)
        return import("SettingsTab")(Window, Orbit, o)
    end

    ---------------------------------------------------------------- pencere olaylari
    closeBtn.Activated:Connect(function()
        Window:Dialog({ Title = "Kapat", Content = "Arayuz tamamen kapatilsin mi?", Buttons = {
            { Title = "Iptal" },
            { Title = "Kapat", Danger = true, Callback = function() Window:Destroy() end },
        } })
    end)
    minBtn.Activated:Connect(function() Window:SetVisible(false) end)
    connect(UserInputService.InputBegan, function(i, gp)
        if not gp and Window.ToggleKey ~= Enum.KeyCode.Unknown and i.KeyCode == Window.ToggleKey then Window:Toggle() end
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
