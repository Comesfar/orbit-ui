-- Orbit UI :: Notify (Zengin Bildirimler & Konumlandirma)
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

-- 4 Farkli Kose Konumlandirma Ayari
local POSITIONS = {
    BottomRight = {
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    },
    TopRight = {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 56), -- Roblox topbar butonlarini kapatmamasi icin 56px
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    },
    BottomLeft = {
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 16, 1, -16),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    },
    TopLeft = {
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0, 16, 0, 56),
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    },
}

return function(Orbit)
    local holder
    local currentPosName = "BottomRight"

    local function applyHolderPosition(posName)
        local cfg = POSITIONS[posName] or POSITIONS.BottomRight
        currentPosName = POSITIONS[posName] and posName or "BottomRight"
        Orbit.NotificationPosition = currentPosName
        if holder and holder.Parent then
            holder.AnchorPoint = cfg.AnchorPoint
            holder.Position = cfg.Position
            local layout = holder:FindFirstChildOfClass("UIListLayout")
            if layout then
                layout.VerticalAlignment = cfg.VerticalAlignment
                layout.HorizontalAlignment = cfg.HorizontalAlignment
            end
        end
    end

    local function ensureHolder(gui)
        if holder and holder.Parent then return holder end
        local cfg = POSITIONS[currentPosName] or POSITIONS.BottomRight
        holder = New("Frame", {
            Name = "Notifications", Parent = gui, BackgroundTransparency = 1,
            AnchorPoint = cfg.AnchorPoint, Position = cfg.Position, Size = UDim2.fromOffset(320, 480),
            ZIndex = 500,
        }, {
            New("UIListLayout", {
                Padding = UDim.new(0, 8),
                VerticalAlignment = cfg.VerticalAlignment,
                HorizontalAlignment = cfg.HorizontalAlignment,
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
        })
        return holder
    end

    function Orbit:SetNotificationPosition(pos)
        applyHolderPosition(pos)
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

        -- Eger ozel bir kose verilmisse o anlik degistirilebilir
        if opts.Position and POSITIONS[opts.Position] then
            applyHolderPosition(opts.Position)
        end

        local parent = ensureHolder(self.Gui)

        local nType = opts.Type or "Info"
        local accentColor = TYPE_COLORS[nType] or theme.Accent
        local iconName = opts.Icon or TYPE_ICONS[nType]
        local duration = opts.Duration or (opts.Buttons and 8 or 4)

        if opts.Sound then playSound(opts.Sound) end

        -- Dis konteyner ve yumusak golge (DropShadow)
        local cardHolder = New("Frame", {
            Parent = parent, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, ZIndex = 500,
        })

        local shadow = New("ImageLabel", {
            Parent = cardHolder, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(-12, -12), Size = UDim2.new(1, 24, 1, 24),
            Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 0.5, ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 500,
        })

        local card = New("CanvasGroup", {
            Parent = cardHolder, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Background, GroupTransparency = 1, ZIndex = 501,
        }, {
            Corner(10), Stroke(theme.Stroke), Pad(14, 12, 14, 14),
            New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }),
        })

        -- Baslik satiri (ikon + baslik + kapat butonu)
        local header = New("Frame", {
            Parent = card, LayoutOrder = 1, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20), ZIndex = 502,
        })

        local xOff = 0
        if iconName then
            local ic = Icons.Create(header, iconName, {
                Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(0, 1),
                Color = accentColor,
            })
            if ic then ic.ZIndex = 502 end
            xOff = 24
        end

        New("TextLabel", {
            Parent = header, BackgroundTransparency = 1,
            Position = UDim2.fromOffset(xOff, 0), Size = UDim2.new(1, -xOff - 24, 1, 0),
            Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = theme.Text, Text = opts.Title or "Bildirim", ZIndex = 502,
        })

        local closeBtn = New("TextButton", {
            Parent = header, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
            TextSize = 13, TextColor3 = theme.SubText, Text = "X", ZIndex = 503,
        })
        closeBtn.MouseEnter:Connect(function() Tween(closeBtn, 0.12, { TextColor3 = theme.Text }) end)
        closeBtn.MouseLeave:Connect(function() Tween(closeBtn, 0.12, { TextColor3 = theme.SubText }) end)

        if opts.Content then
            New("TextLabel", {
                Parent = card, LayoutOrder = 2, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
                Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText,
                Text = opts.Content, ZIndex = 502,
            })
        end

        local closed = false
        local function dismiss()
            if closed then return end
            closed = true
            Tween(card, 0.2, { GroupTransparency = 1 })
            Tween(shadow, 0.2, { ImageTransparency = 1 }).Completed:Wait()
            cardHolder:Destroy()
        end
        closeBtn.Activated:Connect(dismiss)

        -- Butonlar
        if opts.Buttons and #opts.Buttons > 0 then
            local btnRow = New("Frame", {
                Parent = card, LayoutOrder = 3, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28), ZIndex = 502,
            }, { New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8) }) })

            for _, b in ipairs(opts.Buttons) do
                local bg = b.Danger and theme.Danger or (b.Primary and accentColor or theme.Element)
                local txtCol = (b.Danger or b.Primary) and Color3.new(1, 1, 1) or theme.Text
                local btn = New("TextButton", {
                    Parent = btnRow, Size = UDim2.fromOffset(80, 28), BackgroundColor3 = bg,
                    AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 12,
                    TextColor3 = txtCol, Text = b.Title or "Tamam", ZIndex = 503,
                }, { Corner(6) })

                btn.MouseEnter:Connect(function()
                    Tween(btn, 0.12, { BackgroundTransparency = 0.15 })
                end)
                btn.MouseLeave:Connect(function()
                    Tween(btn, 0.12, { BackgroundTransparency = 0 })
                end)

                btn.Activated:Connect(function()
                    dismiss()
                    if b.Callback then task.spawn(b.Callback) end
                end)
            end
        end

        -- Alttaki Sure Cubugu (Progress Bar)
        local bar = New("Frame", {
            Parent = card, LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = accentColor, BorderSizePixel = 0, ZIndex = 502,
        }, { Corner(1) })

        Tween(card, 0.25, { GroupTransparency = 0 })
        Tween(shadow, 0.25, { ImageTransparency = 0.5 })

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
