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
