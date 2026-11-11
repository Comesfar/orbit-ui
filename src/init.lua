-- Orbit UI :: giris noktasi
local import = ...

local Orbit = { Version = "0.3.0", Windows = {} }

Orbit.Themes = import("Themes")

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
