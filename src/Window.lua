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
