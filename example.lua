local Orbit = loadstring(game:HttpGet("https://raw.githubusercontent.com/Comesfar/orbit-ui/main/dist/Orbit.lua"))()
-- Yerel gelistirme: local Orbit = loadstring(readfile("OrbitUI/loader.lua"))()

local Window = Orbit:CreateWindow({
    Title = "Orbit UI", Subtitle = "v2.0",
    Theme = "Dark",                       -- Dark, Midnight, Rose, Light
    ToggleKey = Enum.KeyCode.RightShift,
    Blur = false,
    -- MobileButton = true,               -- varsayilan: dokunmatik cihazda acik
    ConfigFolder = "OrbitUI",
})

------------------------------------------------------------------ Ana
Window:TabSection("Genel")
local Main = Window:Tab({ Title = "Ana", Icon = "house" }) -- Lucide ikon adi

Main:Section("Temel")
Main:Button({ Title = "Bildirim Gonder", Description = "Test bildirimi", Icon = "bell", Tooltip = "Sag altta bildirim cikar", Callback = function()
    Orbit:Notify({ Title = "Merhaba", Content = "Orbit UI calisiyor!", Duration = 4 })
end })
Main:Toggle({ Title = "Toggle", Flag = "toggle1", Default = false, Callback = function(v) print("Toggle:", v) end })
Main:Toggle({ Title = "Toggle + Tus", Flag = "toggle2", Keybind = Enum.KeyCode.X, Callback = function(v) print("Tus toggle:", v) end })
Main:Divider()
Main:Slider({ Title = "Hiz", Flag = "speed", Min = 0, Max = 100, Default = 16, Callback = print })
Main:RangeSlider({ Title = "Aralik", Flag = "range", Min = 0, Max = 100, Default = { 20, 70 }, Callback = function(lo, hi) print(lo, hi) end })
Main:Dropdown({ Title = "Mod", Flag = "mode", Values = { "A", "B", "C" }, Default = "A", Callback = print })
Main:Dropdown({ Title = "Coklu", Flag = "multi", Values = { "X", "Y", "Z" }, Multi = true, Default = { "X" }, Callback = function(t) print(table.concat(t, ",")) end })

------------------------------------------------------------------ Girdiler
local Inputs = Window:Tab({ Title = "Girdiler", Icon = "keyboard" })
Inputs:Section("Metin")
Inputs:Input({ Title = "Isim", Flag = "name", Placeholder = "yaz...", Callback = print })
Inputs:TextArea({ Title = "Notlar", Flag = "notes", Placeholder = "Cok satirli...", Height = 110 })
Inputs:Section("Diger")
Inputs:Keybind({ Title = "Kisayol", Flag = "bind", Default = Enum.KeyCode.F, Callback = function() print("Basildi") end })
Inputs:ColorPicker({ Title = "Renk", Flag = "color", Default = Color3.fromRGB(88, 130, 255), Callback = print })
Inputs:Paragraph({ Title = "Bilgi", Content = "Sol ustteki arama kutusu tum sekmelerdeki bilesenleri filtreler." })

------------------------------------------------------------------ Ayarlar (hazir)
Window:TabSection("Sistem")
Window:AddSettingsTab() -- tema, aksan, menu tusu, config, otomatik kayit

-- Tum arayuz kurulduktan SONRA (istege bagli):
-- Window:EnableAutoSave("default")
