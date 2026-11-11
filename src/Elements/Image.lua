local import = ...
local Util = import("Util")
local New, Corner, Stroke = Util.New, Util.Corner, Util.Stroke

-- Image({ Image = "rbxassetid://123", Height = 120 })
return function(ctx, o)
    local theme = ctx.Theme
    local frame = New("Frame", { Parent = ctx.Page, LayoutOrder = ctx.NextOrder(), Size = UDim2.new(1, 0, 0, o.Height or 120), BackgroundColor3 = theme.Element, ClipsDescendants = true }, { Corner(8), Stroke(theme.Stroke) })
    local img = New("ImageLabel", { Parent = frame, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = o.Image or "", ScaleType = o.ScaleType or Enum.ScaleType.Fit }, { Corner(8) })
    ctx.MarkStatic(frame)
    return { Set = function(_, image) img.Image = image end }
end
