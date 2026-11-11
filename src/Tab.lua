-- Orbit UI :: Tab (sekme + element baglama)
local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

-- Eklemek icin: src/Elements/<Ad>.lua olustur ve buraya adi ekle
local ELEMENTS = {
    "Section", "Divider", "Label", "Paragraph", "Image",
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

    -- Arama disinda kalan (baslik/ayirici/resim) elemanlar icin isaretleyici
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
            -- o.Tooltip verilmisse son olusturulan satira ekle
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
