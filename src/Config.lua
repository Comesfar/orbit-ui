-- Orbit UI :: Config (Flag tabanli kaydet/yukle)
local import = ...

local HttpService = game:GetService("HttpService")

return function(Window, folder)
    local function canFS()
        return writefile and readfile and isfolder and makefolder and isfile
    end

    function Window:SaveConfig(name)
        if not canFS() then return false, "dosya sistemi yok" end
        local data = {}
        for flag, v in pairs(Window.Flags) do
            if typeof(v) == "Color3" then data[flag] = { __c3 = { v.R, v.G, v.B } }
            elseif typeof(v) == "EnumItem" then data[flag] = { __enum = v.Name }
            else data[flag] = v end
        end
        if not isfolder(folder) then makefolder(folder) end
        writefile(folder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
        return true
    end

    function Window:LoadConfig(name)
        if not canFS() then return false, "dosya sistemi yok" end
        local path = folder .. "/" .. name .. ".json"
        if not isfile(path) then return false, "config bulunamadi" end
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if not ok then return false, "bozuk config" end
        for flag, v in pairs(data) do
            local setter = Window.Setters[flag]
            if setter then
                if type(v) == "table" and v.__c3 then v = Color3.new(v.__c3[1], v.__c3[2], v.__c3[3])
                elseif type(v) == "table" and v.__enum then v = Enum.KeyCode[v.__enum] end
                pcall(setter, v)
            end
        end
        return true
    end

    function Window:ListConfigs()
        local out = {}
        if canFS() and isfolder(folder) and listfiles then
            for _, f in ipairs(listfiles(folder)) do
                local n = f:match("([^/\\]+)%.json$")
                if n then table.insert(out, n) end
            end
        end
        return out
    end
end
