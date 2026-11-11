local Orbit = loadstring(readfile("OrbitUI/loader.lua"))() -- veya game:HttpGet(RAW_URL)

local Window = Orbit:CreateWindow({
    Title = "Orbit UI", Subtitle = "v1.0", Theme = "Dark", -- Dark, Midnight, Rose, Light
    ToggleKey = Enum.KeyCode.RightShift, Blur = false, ConfigFolder = "OrbitUI",
})

local Main = Window:Tab({ Title = "Ana", Icon = "*" })
Main:Section("Genel")
Main:Button({ Title = "Bildirim Gonder", Description = "Test bildirimi", Callback = function()
    Orbit:Notify({ Title = "Merhaba", Content = "Orbit UI calisiyor!", Duration = 4 })
end })
Main:Toggle({ Title = "Ornek Toggle", Flag = "toggle1", Default = false, Callback = function(v) print("Toggle:", v) end })
Main:Slider({ Title = "Hiz", Flag = "speed", Min = 0, Max = 100, Default = 16, Step = 1, Callback = function(v) print(v) end })
Main:Input({ Title = "Isim", Flag = "name", Placeholder = "yaz...", Callback = function(t) print(t) end })
Main:Dropdown({ Title = "Mod", Flag = "mode", Values = { "A", "B", "C" }, Default = "A", Callback = print })
Main:Dropdown({ Title = "Coklu", Flag = "multi", Values = { "X", "Y", "Z" }, Multi = true, Default = { "X" }, Callback = function(t) print(table.concat(t, ",")) end })
Main:Keybind({ Title = "Kisayol", Flag = "bind", Default = Enum.KeyCode.F, Callback = function() print("Basildi") end })
Main:ColorPicker({ Title = "Renk", Flag = "color", Default = Color3.fromRGB(88, 130, 255), Callback = print })
Main:Paragraph({ Title = "Bilgi", Content = "Paragraph uzun metinleri otomatik sarar." })

local Settings = Window:Tab({ Title = "Ayarlar", Icon = "#" })
Settings:Section("Config")
local cfgName = "default"
Settings:Input({ Title = "Config adi", Default = cfgName, Callback = function(t) cfgName = t end })
Settings:Button({ Title = "Kaydet", Callback = function()
    local ok, err = Window:SaveConfig(cfgName)
    Orbit:Notify({ Title = ok and "Kaydedildi" or "Hata", Content = tostring(err or cfgName) })
end })
Settings:Button({ Title = "Yukle", Callback = function()
    local ok, err = Window:LoadConfig(cfgName)
    Orbit:Notify({ Title = ok and "Yuklendi" or "Hata", Content = tostring(err or cfgName) })
end })
Settings:Button({ Title = "Dialog Ac", Callback = function()
    Window:Dialog({ Title = "Emin misin?", Content = "Bu bir dialog ornegi.", Buttons = {
        { Title = "Iptal" }, { Title = "Tamam", Callback = function() print("onaylandi") end },
    } })
end })


