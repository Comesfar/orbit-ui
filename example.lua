local Orbit = loadstring(game:HttpGet("https://raw.githubusercontent.com/Comesfar/orbit-ui/main/dist/Orbit.lua"))()
-- Yerel gelistirme: local Orbit = loadstring(readfile("OrbitUI/loader.lua"))()

--[[
-- Istege bagli: Key System ile baslatma ornegi:
Orbit:CreateKeySystem({
    Title = "Orbit Hub",
    Subtitle = "Key Dogrulama",
    Note = "Devam etmek icin lutfen anahtari girin.",
    Keys = { "orbit_123", "vip_pass" },
    Link = "https://discord.gg/example",
    SaveKey = true,
    Callback = function(success)
        if success then
            -- Menuyu burada baslatabilirsiniz
        end
    end
})
]]

local Window = Orbit:CreateWindow({
    Title = "Orbit UI", Subtitle = "v2.1",
    Theme = "Dark",                       -- Dark, Midnight, Rose, Light
    ToggleKey = Enum.KeyCode.RightShift,
    Blur = false,
    ConfigFolder = "OrbitUI",
})

-- Ust/alt kosede Watermark (FPS, Ping, Saat)
local Watermark = Orbit:AddWatermark({
    Title = "Orbit UI", Build = "v2.1",
    ShowFPS = true, ShowPing = true, ShowTime = true,
})

-- Ekranda Keybinds HUD paneli (Tus takibi)
local KeyList = Window:CreateKeybindList({
    Position = UDim2.new(0, 16, 0.45, 0),
})

------------------------------------------------------------------ Ana Sekme
Window:TabSection("Genel")
local Main = Window:Tab({ Title = "Ana", Icon = "house" })

Main:Section("Temel")
Main:Button({
    Title = "Zengin Bildirim", Description = "Butonlu ve basarili bildirim", Icon = "bell",
    Callback = function()
        Orbit:Notify({
            Title = "Gorev Tamamlandi",
            Content = "Islem basariyla gerceklestirildi!",
            Type = "Success", -- Info, Success, Warning, Error
            Sound = true,
            Buttons = {
                { Title = "Harika", Primary = true },
            },
        })
    end,
})

Main:Toggle({ Title = "Uçma (Fly)", Flag = "fly", Keybind = Enum.KeyCode.F, Default = false, Callback = function(v)
    print("Fly:", v)
end })

Main:Toggle({ Title = "Hızlı Koşma (Speed)", Flag = "speed_boost", Keybind = Enum.KeyCode.V, Default = false, Callback = function(v)
    print("Speed Boost:", v)
end })

Main:Divider()

-- Katlanabilir (Collapsible) Accordion / Kart Bolumu
local FarmSec = Main:Section({
    Title = "Otomatik Farm (Kart)",
    Collapsible = true,
    Default = true,
    Icon = "swords",
})

FarmSec:Toggle({ Title = "Oto Sandik Topla", Flag = "auto_chest", Callback = print })
FarmSec:Slider({ Title = "Menzil", Flag = "farm_range", Min = 10, Max = 150, Default = 50, Suffix = "m", Callback = print })

-- Ilerleme Cubugu (ProgressBar)
local Prog = FarmSec:ProgressBar({
    Title = "Farm Ilerlemesi",
    Flag = "farm_prog",
    Min = 0, Max = 100, Default = 40, Suffix = "%",
})
FarmSec:Button({ Title = "Ilerlet (+20%)", Callback = function()
    local cur = Prog:Get()
    Prog:Set(cur >= 100 and 0 or (cur + 20))
end })

Main:RangeSlider({ Title = "Aralik", Flag = "range", Min = 0, Max = 100, Default = { 20, 70 }, Callback = function(lo, hi) print(lo, hi) end })
Main:Dropdown({ Title = "Mod", Flag = "mode", Values = { "Saldiri", "Savunma", "Pasif" }, Default = "Saldiri", Callback = print })

------------------------------------------------------------------ Girdiler
local Inputs = Window:Tab({ Title = "Girdiler", Icon = "keyboard" })
Inputs:Section("Metin")
Inputs:Input({ Title = "Isim", Flag = "name", Placeholder = "Kullanici adi...", Callback = print })
Inputs:TextArea({ Title = "Notlar", Flag = "notes", Placeholder = "Cok satirli aciklama...", Height = 100 })

Inputs:Section("Kontroller")
Inputs:Keybind({ Title = "Ozel Kisayol", Flag = "custom_bind", Default = Enum.KeyCode.G, Callback = function()
    Orbit:Notify({ Title = "Tus Tetiklendi", Content = "G tusuna basildi!", Type = "Info" })
end })
Inputs:ColorPicker({ Title = "Aura Rengi", Flag = "aura_col", Default = Color3.fromRGB(88, 130, 255), Callback = print })
Inputs:Paragraph({ Title = "Bilgi Kutusu", Content = "Sol ustteki arama kutusu tum sekmeleri ve katlanabilir bolumleri filtreler." })

------------------------------------------------------------------ Ayarlar (hazir sistem)
Window:TabSection("Sistem")
Window:AddSettingsTab()

-- Tum arayuz kurulduktan sonra otomatik kaydetmeyi baslat:
-- Window:EnableAutoSave("default")
