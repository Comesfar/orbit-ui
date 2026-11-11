-- Orbit UI :: Notify
local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

return function(Orbit)
    local holder

    local function ensureHolder(gui)
        if holder and holder.Parent then return holder end
        holder = New("Frame", {
            Name = "Notifications", Parent = gui, BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.fromOffset(300, 400),
        }, { New("UIListLayout", { Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder }) })
        return holder
    end

    function Orbit:Notify(opts)
        opts = opts or {}
        if not self.Gui then return end
        local theme = self.CurrentTheme or Orbit.Themes.Dark
        local parent = ensureHolder(self.Gui)
        local duration = opts.Duration or 4
        local card = New("CanvasGroup", {
            Parent = parent, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = theme.Background, GroupTransparency = 1,
        }, {
            Corner(8), Stroke(theme.Stroke), Pad(12, 10, 12, 14),
            New("UIListLayout", { Padding = UDim.new(0, 2) }),
        })
        New("TextLabel", { Parent = card, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = opts.Title or "Bildirim" })
        if opts.Content then
            New("TextLabel", { Parent = card, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = opts.Content })
        end
        local bar = New("Frame", { Parent = card, LayoutOrder = 3, Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = theme.Accent, BorderSizePixel = 0 }, { Corner(1) })
        Tween(card, 0.25, { GroupTransparency = 0 })
        Tween(bar, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
        task.delay(duration, function()
            Tween(card, 0.25, { GroupTransparency = 1 }).Completed:Wait()
            card:Destroy()
        end)
    end
end
