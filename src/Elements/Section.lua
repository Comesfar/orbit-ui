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

    -- Ana kart kutusu (UIListLayout ile header ve content alt alta dizilir)
    local card = New("Frame", {
        Parent = ctx.Page, LayoutOrder = ctx.NextOrder(),
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Sidebar, ClipsDescendants = true,
    }, {
        Corner(9),
        Stroke(theme.Stroke),
        New("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 0),
        }),
    })
    card:SetAttribute("OrbitSearch", (s.Title or ""):lower())

    -- Kart Basligi (tiklanabilir akordiyon baslik)
    local header = New("TextButton", {
        Parent = card, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = theme.Sidebar, AutoButtonColor = false, Text = "",
    }, { Pad(12, 0, 12, 0) })

    header.MouseEnter:Connect(function()
        Tween(header, 0.15, { BackgroundColor3 = theme.Element })
    end)
    header.MouseLeave:Connect(function()
        Tween(header, 0.15, { BackgroundColor3 = theme.Sidebar })
    end)

    local xOff = 0
    if s.Icon then
        local ic = Icons.Create(header, s.Icon, {
            Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 0, 0.5, -8),
            Color = theme.Accent,
        })
        if ic then ic.ZIndex = 2 end
        xOff = 24
    end

    local titleLbl = New("TextLabel", {
        Parent = header, BackgroundTransparency = 1, Position = UDim2.fromOffset(xOff, 0),
        Size = UDim2.new(1, -xOff - 28, 1, 0), Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = s.Title or "Section", ZIndex = 2,
    })

    local arrow = Icons.Create(header, "chevron-down", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.new(1, -16, 0.5, -8),
        Color = theme.SubText,
    })
    if arrow then
        arrow.Rotation = open and 0 or -90
        arrow.ZIndex = 2
    end

    -- Baslik ile icerik arasindaki ince cizgi
    local divider = New("Frame", {
        Parent = card, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme.Stroke, BorderSizePixel = 0,
        Visible = open,
    })

    -- Icerik Alani (Kenarlardan 8px iceride, elemanlarin tasma ve kesilmesini onler)
    local content = New("Frame", {
        Parent = card, LayoutOrder = 3, Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        Visible = open,
    }, {
        Pad(0, 8, 0, 8),
        New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local function toggleState()
        open = not open
        content.Visible = open
        divider.Visible = open
        if arrow then
            Tween(arrow, 0.2, { Rotation = open and 0 or -90 })
        end
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
        local row = New("Frame", {
            Parent = content, LayoutOrder = subCtx.NextOrder(),
            Size = UDim2.new(1, 0, 0, height),
            BackgroundColor3 = theme.Element, ClipsDescendants = true,
        }, { Corner(8), Stroke(theme.Stroke) })
        row:SetAttribute("OrbitSearch", ((title or "") .. " " .. (desc or "")):lower())

        -- Ana kartin arama indeksini de guncelle
        local oldSearch = card:GetAttribute("OrbitSearch") or ""
        card:SetAttribute("OrbitSearch", oldSearch .. " " .. ((title or "") .. " " .. (desc or "")):lower())

        local label = New("TextLabel", {
            Parent = row, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(12, desc and 7 or 0),
            Size = UDim2.new(1, -24, 0, desc and 16 or math.min(height, 38)),
            Font = Enum.Font.GothamMedium, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text,
            Text = title or "",
        })
        if desc then
            New("TextLabel", {
                Parent = row, BackgroundTransparency = 1,
                Position = UDim2.fromOffset(12, 23), Size = UDim2.new(1, -24, 0, 14),
                Font = Enum.Font.Gotham, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText,
                Text = desc,
            })
        end
        return row, label
    end
    function subCtx.MarkStatic(inst)
        inst:SetAttribute("OrbitSearch", "")
        inst:SetAttribute("OrbitStatic", true)
    end
    function subCtx.Hoverable(row, height)
        local b = New("TextButton", {
            Parent = row, Size = UDim2.new(1, 0, 0, height or 38),
            BackgroundTransparency = 1, Text = "", ZIndex = 1,
        })
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
