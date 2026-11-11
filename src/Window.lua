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

    local holder = New("Frame", {
        Name = "WindowHolder", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(curW, curH), BackgroundTransparency = 1,
    })
    local shadow = New("ImageLabel", {
        Name = "DropShadow", Parent = holder, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(1, 36, 1, 36), BackgroundTransparency = 1, Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0), ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 0,
    })
    local main = New("CanvasGroup", {
        Name = "Main", Parent = holder, Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = theme.Background, GroupTransparency = 1, ZIndex = 1,
    }, { Corner(12), Stroke(theme.Stroke) })
    local scale = New("UIScale", { Parent = holder, Scale = 0.92 })

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
    Util.MakeDraggable(top, holder, connect)

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
    local searchBox = New("TextBox", { Name = "Search", Parent = sidebar, LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = theme.Element, ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.Text, PlaceholderText = "Ara...", PlaceholderColor3 = theme.SubText, Text = "", TextXAlignment = Enum.TextXAlignment.Left }, { Corner(7), Stroke(theme.Stroke), Pad(10, 0, 24, 0) })
    local clearBtn = New("TextButton", { Name = "Clear", Parent = searchBox, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 18, 0.5, 0), Size = UDim2.fromOffset(18, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = theme.SubText, Text = "X", Visible = false })
    clearBtn.Activated:Connect(function() searchBox.Text = "" end)

    local content = New("Frame", { Name = "Content", Parent = main, Position = UDim2.fromOffset(158, 44), Size = UDim2.new(1, -158, 1, -44), BackgroundTransparency = 1, ClipsDescendants = true })

    local env = {
        Theme = theme, Gui = gui, Main = main, Sidebar = sidebar, Content = content,
        TabState = { first = true }, TabCount = 0, TabList = {},
        Connect = connect, Call = Window.Call,
    }

    -- Arama: Row/Paragraph'lar OrbitSearch attribute'u tasir
    local function applySearch()
        local q = searchBox.Text:lower()
        clearBtn.Visible = (q ~= "")
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
            holder.Visible = true
            main.Visible = true
            fit()
            Tween(main, 0.25, { GroupTransparency = 0 })
            Tween(shadow, 0.25, { ImageTransparency = 0.45 })
            Tween(scale, 0.3, { Scale = fitScale }, Enum.EasingStyle.Back)
            if blur then Tween(blur, 0.3, { Size = 12 }) end
        else
            Tween(main, 0.2, { GroupTransparency = 1 })
            Tween(shadow, 0.2, { ImageTransparency = 1 })
            Tween(scale, 0.2, { Scale = 0.92 })
            if blur then Tween(blur, 0.2, { Size = 0 }) end
            task.delay(0.2, function()
                if not Window.Visible then
                    main.Visible = false
                    holder.Visible = false
                end
            end)
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
        if isStart then rs = { pos = pos, w = curW, h = curH, p = holder.Position } return end
        local s = math.max(scale.Scale, 0.1)
        local w = math.clamp(rs.w + (pos.X - rs.pos.X) / s, opts.MinWidth or 460, opts.MaxWidth or 1000)
        local h = math.clamp(rs.h + (pos.Y - rs.pos.Y) / s, opts.MinHeight or 320, opts.MaxHeight or 800)
        curW, curH = w, h
        holder.Size = UDim2.fromOffset(w, h)
        holder.Position = UDim2.new(rs.p.X.Scale, rs.p.X.Offset + (w - rs.w) * s / 2, rs.p.Y.Scale, rs.p.Y.Offset + (h - rs.h) * s / 2)
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
