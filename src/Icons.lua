-- Orbit UI :: Icons (Dahili temel ikonlar + arka planda dinamik yukleyici)
local import = ...
local Util = import("Util")

local Icons = {
    Url = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua",
}

-- Sik kullanilan temel Lucide ikonlari (Aga bagimli olmadan aninda yuklenir)
local BUILTIN_ICONS = {
    ["user"] = "rbxassetid://81589895647169",
    ["house"] = "rbxassetid://98755624629571",
    ["settings"] = "rbxassetid://80758916183665",
    ["bell"] = "rbxassetid://97392696311902",
    ["eye"] = "rbxassetid://100033680381365",
    ["keyboard"] = "rbxassetid://121474456068237",
    ["swords"] = "rbxassetid://81872698913435",
    ["layout-dashboard"] = "rbxassetid://139929981863901",
    ["info"] = "rbxassetid://124560466474914",
    ["circle-check"] = "rbxassetid://85262178816537",
    ["triangle-alert"] = "rbxassetid://125920361880643",
    ["circle-alert"] = "rbxassetid://83898160590116",
    ["key"] = "rbxassetid://96510194465420",
    ["shield"] = "rbxassetid://110987169760162",
    ["crosshair"] = "rbxassetid://134242818164054",
    ["search"] = "rbxassetid://121018724060431",
    ["check"] = "rbxassetid://93898873302694",
    ["x"] = "rbxassetid://110786993356448",
    ["chevron-down"] = "rbxassetid://134243273101015",
    ["chevron-right"] = "rbxassetid://92473583511724",
    ["folder"] = "rbxassetid://80846616596607",
    ["trash"] = "rbxassetid://106723740584310",
    ["save"] = "rbxassetid://126116963775616",
    ["zap"] = "rbxassetid://130551565616516",
    ["flame"] = "rbxassetid://98218034436456",
    ["globe"] = "rbxassetid://114238209622913",
    ["play"] = "rbxassetid://135609604299893",
    ["pause"] = "rbxassetid://74873705394436",
    ["sparkles"] = "rbxassetid://138635884129147",
    ["refresh-cw"] = "rbxassetid://138133190015277",
}

local extraIcons = nil
local loadingExtra = false

local function loadExtraAsync()
    if extraIcons or loadingExtra then return end
    loadingExtra = true
    task.spawn(function()
        pcall(function()
            local raw = game:HttpGet(Icons.Url)
            local fn = loadstring(raw)
            if fn then
                local res = fn()
                if type(res) == "table" then
                    extraIcons = res
                end
            end
        end)
        loadingExtra = false
    end)
end

-- "lucide:settings", "settings", "rbxassetid://123", 123 -> image id (yoksa nil)
function Icons.Resolve(name)
    if type(name) == "number" then return "rbxassetid://" .. name end
    if type(name) ~= "string" or name == "" then return nil end
    if name:match("^rbxassetid://") or name:match("^rbxasset://") then return name end
    local clean = name:gsub("^lucide:", "")

    -- Once dahili haritada ara (aninda calisir, hic bekletmez)
    if BUILTIN_ICONS[clean] then
        return BUILTIN_ICONS[clean]
    end

    -- Dahili haritada yoksa ekstra paketten ara (arka planda yukler)
    if extraIcons and extraIcons[clean] then
        return extraIcons[clean]
    end

    loadExtraAsync()
    return nil
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
