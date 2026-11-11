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
