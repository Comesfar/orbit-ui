local import = ...

return function(ctx, text)
    if type(text) == "table" then text = text.Title end
    local _, label = ctx.Row(30, text)
    return { Set = function(_, v) label.Text = v end }
end
