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
