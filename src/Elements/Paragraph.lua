local import = ...
local Util = import("Util")
local New, Corner, Stroke, Pad = Util.New, Util.Corner, Util.Stroke, Util.Pad

return function(ctx, p)
    local theme = ctx.Theme
    local row = New("Frame", { Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Element }, {
        Corner(8), Stroke(theme.Stroke), Pad(12, 10, 12, 10), New("UIListLayout", { Padding = UDim.new(0, 3) }),
    })
    local title = New("TextLabel", { Parent = row, LayoutOrder = 1, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16), Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.Text, Text = p.Title or "" })
    local body = New("TextLabel", { Parent = row, LayoutOrder = 2, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = theme.SubText, Text = p.Content or "" })
    return { Set = function(_, t, c) if t then title.Text = t end if c then body.Text = c end end }
end
