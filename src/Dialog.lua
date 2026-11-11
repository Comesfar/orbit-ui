-- Orbit UI :: Dialog
local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

-- Window:Dialog({ Title, Content, Buttons = { {Title, Callback, Danger} } })
return function(Window, env)
    local theme, main = env.Theme, env.Main

    function Window:Dialog(d)
        local overlay = New("Frame", { Parent = main, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1, ZIndex = 50, Active = true })
        local box = New("CanvasGroup", { Parent = overlay, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(320, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Element, GroupTransparency = 1, ZIndex = 51 }, {
            Corner(10), Stroke(theme.Stroke), Pad(16, 14, 16, 14), New("UIListLayout", { Padding = UDim.new(0, 8) }),
        })
        New("TextLabel", { Parent = box, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 20), Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = d.Title or "Dialog", ZIndex = 52 })
        if d.Content then
            New("TextLabel", { Parent = box, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = d.Content, ZIndex = 52 })
        end
        local row = New("Frame", { Parent = box, LayoutOrder = 3, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 32), ZIndex = 52 }, {
            New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 8) }),
        })
        local function close()
            Tween(box, 0.15, { GroupTransparency = 1 })
            Tween(overlay, 0.15, { BackgroundTransparency = 1 }).Completed:Wait()
            overlay:Destroy()
        end
        for _, b in ipairs(d.Buttons or { { Title = "Tamam" } }) do
            local neutral = not b.Danger and not b.Callback
            local color = b.Danger and theme.Danger or (neutral and theme.ElementHover or theme.Accent)
            local btn = New("TextButton", { Parent = row, Size = UDim2.fromOffset(90, 32), BackgroundColor3 = color, AutoButtonColor = false, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = neutral and theme.Text or Color3.new(1, 1, 1), Text = b.Title, ZIndex = 53 }, { Corner(7) })
            btn.Activated:Connect(function()
                task.spawn(close)
                if b.Callback then task.spawn(b.Callback) end
            end)
        end
        Tween(overlay, 0.2, { BackgroundTransparency = 0.45 })
        Tween(box, 0.2, { GroupTransparency = 0 })
    end
end
