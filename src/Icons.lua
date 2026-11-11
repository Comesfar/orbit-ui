-- Orbit UI :: Icons (Lucide, ilk kullanimda internetten yuklenir)
local import = ...
local Util = import("Util")

local Icons = {
    Url = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua",
}

local set
local function load()
    if set then return set end
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(Icons.Url))()
    end)
    set = (ok and type(res) == "table") and res or {}
    return set
end

-- "lucide:settings", "settings", "rbxassetid://123", 123 -> image id (yoksa nil)
function Icons.Resolve(name)
    if type(name) == "number" then return "rbxassetid://" .. name end
    if type(name) ~= "string" or name == "" then return nil end
    if name:match("^rbxassetid://") or name:match("^rbxasset://") then return name end
    local clean = name:gsub("^lucide:", "")
    return load()[clean]
end

-- Ikon olusturur. Bulunamazsa kisa metin/glyph olarak gosterir.
-- props: Size, Position, AnchorPoint, Color
function Icons.Create(parent, name, props)
    props = props or {}
    local image = Icons.Resolve(name)
    if image then
        return Util.New("ImageLabel", {
            Parent = parent, BackgroundTransparency = 1, Image = image,
            Size = props.Size or UDim2.fromOffset(16, 16), Position = props.Position or UDim2.new(),
            AnchorPoint = props.AnchorPoint or Vector2.new(), ImageColor3 = props.Color or Color3.new(1, 1, 1),
        })
    end
    local text = tostring(name)
    if #text > 2 then text = "*" end
    return Util.New("TextLabel", {
        Parent = parent, BackgroundTransparency = 1, Text = text, Font = Enum.Font.GothamBold, TextSize = 14,
        Size = props.Size or UDim2.fromOffset(16, 16), Position = props.Position or UDim2.new(),
        AnchorPoint = props.AnchorPoint or Vector2.new(), TextColor3 = props.Color or Color3.new(1, 1, 1),
    })
end

function Icons.SetColor(icon, color)
    if icon:IsA("ImageLabel") then icon.ImageColor3 = color else icon.TextColor3 = color end
end

function Icons.TweenColor(icon, time, color)
    return Util.Tween(icon, time, icon:IsA("ImageLabel") and { ImageColor3 = color } or { TextColor3 = color })
end

return Icons
