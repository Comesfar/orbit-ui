-- Orbit UI :: giris noktasi
local import = ...

local Orbit = { Version = "0.3.1-beta", Windows = {} }

Orbit.Themes = import("Themes")

-- Ozel tema olusturma: Orbit:CreateTheme("Cyberpunk", { Background = ..., Accent = ... })
function Orbit:CreateTheme(name, palette)
    assert(type(name) == "string" and type(palette) == "table", "[Orbit] CreateTheme: gecersiz parametre")
    local base = Orbit.Themes.Dark
    local merged = {}
    for k, v in pairs(base) do merged[k] = palette[k] or v end
    Orbit.Themes[name] = merged
    return merged
end

-- Bildirimler: Orbit:Notify(...)
import("Notify")(Orbit)

-- Pencere: Orbit:CreateWindow(...)
function Orbit:CreateWindow(opts)
    return import("Window")(Orbit, opts)
end

-- Watermark: Orbit:AddWatermark(...)
function Orbit:AddWatermark(opts)
    local ok, res = pcall(function()
        return import("Watermark")(Orbit, opts)
    end)
    if not ok then
        warn("[Orbit] Watermark hatasi: " .. tostring(res))
    end
    return res
end

-- Key System: Orbit:CreateKeySystem(...)
function Orbit:CreateKeySystem(opts)
    return import("KeySystem")(Orbit, opts)
end

return Orbit
