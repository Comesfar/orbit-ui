local import = ...
local Util = import("Util")
local New = Util.New

return function(ctx)
    local line = New("Frame", { Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = ctx.Theme.Stroke, BorderSizePixel = 0 })
    ctx.MarkStatic(line)
end
