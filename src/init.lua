-- Orbit UI :: giris noktasi
local import = ...

local Orbit = { Version = "2.0.0", Windows = {} }

Orbit.Themes = import("Themes")

-- Bildirimler: Orbit:Notify(...)
import("Notify")(Orbit)

-- Pencere: Orbit:CreateWindow(...)
function Orbit:CreateWindow(opts)
    return import("Window")(Orbit, opts)
end

return Orbit
