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
