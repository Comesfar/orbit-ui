--[[
    Orbit UI :: loader (moduler surum)
    Modulleri src/ altindan ihtiyac oldukca yukler.

    Yerel (executor workspace icinde OrbitUI/src/...):
        local Orbit = loadstring(readfile("OrbitUI/loader.lua"))()

    Uzak (GitHub raw vb.):
        getgenv().OrbitBase = "https://raw.githubusercontent.com/KULLANICI/orbit-ui/main"
        local Orbit = loadstring(game:HttpGet(getgenv().OrbitBase .. "/loader.lua"))()

    Tek dosya istersen: dist/Orbit.lua (build.ps1 uretir).
]]

local env = (getgenv and getgenv()) or _G
local Base = env.OrbitBase or "OrbitUI"
local remote = Base:match("^https?://") ~= nil

local cache = {}

local function fetch(path)
    if remote then return game:HttpGet(path) end
    return readfile(path)
end

local function import(name)
    if cache[name] ~= nil then return cache[name] end
    local path = Base .. "/src/" .. (name:gsub("%.", "/")) .. ".lua"
    local fn, err = loadstring(fetch(path), "=" .. name)
    assert(fn, "[Orbit] modul derlenemedi: " .. name .. " -> " .. tostring(err))
    local result = fn(import)
    cache[name] = result
    return result
end

return import("init")
