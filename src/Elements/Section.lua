local import = ...
local Util = import("Util")
local New = Util.New

return function(ctx, s)
    s = type(s) == "string" and { Title = s } or s
    local l = New("TextLabel", { Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 22), Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = ctx.Theme.Accent, Text = string.upper(s.Title or "") })
    ctx.MarkStatic(l)
end
