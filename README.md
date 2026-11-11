# Orbit UI

Roblox executor scriptleri icin modern, moduler ve performansli UI kutuphanesi (WindUI / Fluent tarzı).

```
orbit-ui/
├── loader.lua          # modulleri src/ altindan yukler (yerel veya HttpGet)
├── build.ps1           # src/ -> dist/Orbit.lua (tek dosya paketi)
├── example.lua         # calisan tum ornekler
├── dist/Orbit.lua      # tek dosya cikti
└── src/
    ├── init.lua        # giris noktasi (Orbit tablosu)
    ├── Util.lua        # New, Tween, Drag, MakeDraggable, Pad, Corner, Stroke
    ├── Themes.lua      # Dark, Midnight, Rose, Light
    ├── Window.lua      # CreateWindow, SetTheme, SetAccent, Boyutlandirma
    ├── Tab.lua         # sekme + element baglami (ctx)
    ├── Dialog.lua      # Window:Dialog
    ├── Notify.lua      # Orbit:Notify (Zengin bildirimler: Info, Success, Warning, Error)
    ├── Watermark.lua   # Orbit:AddWatermark (FPS, Ping, Saat)
    ├── KeybindList.lua # Window:CreateKeybindList (Ekranda tus durumu paneli)
    ├── KeySystem.lua   # Orbit:CreateKeySystem (Anahtar dogrulama)
    ├── SettingsTab.lua # Window:AddSettingsTab
    ├── Config.lua      # Save/Load/ListConfigs + AutoSave
    ├── Icons.lua       # Lucide ikon cozumleyici
    ├── Tooltip.lua     # Fare uzerine gelince ipucu
    └── Elements/       # Button, Toggle, Slider, RangeSlider, ProgressBar,
                        # Dropdown, Input, TextArea, Keybind, ColorPicker,
                        # Section (Collapsible), Divider, Label, Paragraph, Image
```

## Hizli Baslangic (Tek Link)
```lua
local Orbit = loadstring(game:HttpGet("https://raw.githubusercontent.com/Comesfar/orbit-ui/main/dist/Orbit.lua"))()

local Window = Orbit:CreateWindow({
    Title = "Benim Hub",
    Theme = "Dark", -- Dark, Midnight, Rose, Light
    ToggleKey = Enum.KeyCode.RightShift,
})

local Tab = Window:Tab({ Title = "Ana", Icon = "house" })
Tab:Button({ Title = "Merhaba", Callback = function()
    Orbit:Notify({ Title = "Basarili", Content = "Islem tamam!", Type = "Success" })
end })
```

---

## v2.1 Ozellikleri
- **Watermark (FPS & Ping HUD):** `Orbit:AddWatermark({ Title = "Hub", ShowFPS = true, ShowPing = true, ShowTime = true })`
- **Keybinds Overlay Paneli:** `Window:CreateKeybindList()` ile ekranda aktif tus ve ozelliklerin canlı takibi.
- **Key System (Anahtar Doğrulama):** `Orbit:CreateKeySystem({ Keys = {"123"}, Link = "...", SaveKey = true, Callback = ... })`
- **Collapsible Section (Kartlar):** `Tab:Section({ Title = "Farm", Collapsible = true, Default = true, Icon = "swords" })`
- **ProgressBar:** `Tab:ProgressBar({ Title = "Ilerleme", Default = 50, Suffix = "%" })`
- **Zengin Bildirimler:** `Type = "Info" | "Success" | "Warning" | "Error"`, ozel ikonlar, eylem butonlari ve ses destegi.

## v2.0 Ozellikleri
- **Canli tema & Ozel Renk:** `Window:SetTheme("Midnight")`, `Window:SetAccent(Color3)`, `Window:ResetAccent()`
- **Mobil Buton:** Dokunmatik cihazlarda otomatik acilan suruklenebilir ac/kapat butonu.
- **Canli Arama:** Sol ustteki arama kutusu tum sekmeleri ve icerikleri aninda filtreler.
- **Lucide Ikonlar:** `Icon = "house"`, `Icon = "bell"` gibi isimlerle tum bilesenlerde kullanilabilir.
- **Yeniden Boyutlandirma:** Sag alt koseden tutup surukleyerek pencere boyutu degistirilebilir.
- **Tooltip:** Her bilesene `Tooltip = "Aciklama..."` eklenebilir.
- **Otomatik Config (AutoSave):** `Window:EnableAutoSave("default")` ile her degisiklikte otomatik kayit.
