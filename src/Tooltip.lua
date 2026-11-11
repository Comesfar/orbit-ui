-- Orbit UI :: Tooltip (fare ustune gelince aciklama)
local import = ...
local Util = import("Util")
local New, Corner, Stroke, Pad = Util.New, Util.Corner, Util.Stroke, Util.Pad

local UserInputService = game:GetService("UserInputService")

return function(env)
    local theme, gui = env.Theme, env.Gui

    local tip = New("TextLabel", {
        Name = "Tooltip", Parent = gui, Visible = false, BackgroundColor3 = theme.Element, BorderSizePixel = 0,
        TextColor3 = theme.Text, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0), ZIndex = 200,
    }, {
        Corner(6), Stroke(theme.Stroke), Pad(8, 5, 8, 5),
        New("UISizeConstraint", { MaxSize = Vector2.new(260, math.huge) }),
    })

    local function place()
        local m = UserInputService:GetMouseLocation()
        local vp = gui.AbsoluteSize
        local x = math.min(m.X + 14, vp.X - tip.AbsoluteSize.X - 6)
        local y = math.min(m.Y + 18, vp.Y - tip.AbsoluteSize.Y - 6)
        tip.Position = UDim2.fromOffset(x, y)
    end

    -- row ve icindeki tam-boy butonlar ayni "hover" sayacini paylasir
    function env.AttachTooltip(row, text)
        local targets = { row }
        for _, c in ipairs(row:GetChildren()) do
            if c:IsA("TextButton") then table.insert(targets, c) end
        end
        local hover, token = 0, 0
        for _, t in ipairs(targets) do
            t.MouseEnter:Connect(function()
                hover += 1
                token += 1
                local my = token
                task.delay(0.45, function()
                    if my == token and hover > 0 then
                        tip.Text = text
                        place()
                        tip.Visible = true
                    end
                end)
            end)
            t.MouseMoved:Connect(function()
                if tip.Visible then place() end
            end)
            t.MouseLeave:Connect(function()
                hover = math.max(0, hover - 1)
                if hover == 0 then
                    token += 1
                    tip.Visible = false
                end
            end)
        end
    end
end
