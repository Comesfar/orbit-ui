<div align="center">

# 🪐 Orbit UI

**Roblox Executor Scriptleri İçin Modern, Modüler ve Yüksek Performanslı Arayüz Kütüphanesi**

[![Sürüm](https://img.shields.io/badge/s%C3%BCr%C3%BCm-v0.3.1--beta-5882ff?style=for-the-badge)](https://github.com/Comesfar/orbit-ui/releases)
[![Dil](https://img.shields.io/badge/dil-Luau-00a2ff?style=for-the-badge&logo=lua&logoColor=white)](https://luau-lang.org/)
[![Lisans](https://img.shields.io/badge/durum-Beta-f5af32?style=for-the-badge)](https://github.com/Comesfar/orbit-ui)

*WindUI ve Fluent tasarım dilinden ilham alan; canlı tema geçişi, dahili ikon motoru, otomatik kayıt, Key System, Watermark ve Keybind HUD destekli tek satırlık UI kütüphanesi.*

</div>

---

## 📸 Ekran Görüntüleri (Showcase)

> Ekran görüntüleri `assets/` klasörüne eklendikçe burada görüntülenecektir.

| Ana Menü (Midnight) | Katlanabilir Kartlar & Bileşenler | Ayarlar & Canlı Tema |
| :---: | :---: | :---: |
| *(Görsel eklenecek)* | *(Görsel eklenecek)* | *(Görsel eklenecek)* |

---

## ✨ Öne Çıkan Özellikler

- 🎨 **Canlı Tema & Özel Renk Motoru:** Oyun içinden anında tema (`Dark`, `Midnight`, `Rose`, `Light`) ve vurgu rengi (`Accent`) değiştirme veya `Orbit:CreateTheme` ile kendi temanı tanımlama.
- ⚡ **Çevrimdışı Hızlı İkonlar + Lucide Desteği:** En sık kullanılan 30+ Lucide ikonu doğrudan pakete gömülüdür (sıfır ağ gecikmesi); 1500+ ek ikon arka planda asenkron yüklenir.
- 📱 **Mobil & Masaüstü Uyumlu:** Dokunmatik cihazlar için sürüklenebilir yuvarlak aç/kapat butonu, küçük ekranlara otomatik ölçekleme (`UIScale`) ve sağ alt köşeden boyutlandırma.
- 🔍 **Anlık Global Arama:** Sol üstteki arama kutusu tüm sekmelerdeki bileşenleri anında filtreler ve eşleşen sekmeye otomatik geçer.
- 🛡️ **Executor Güvenliği & Hata Koruması:** `cloneref` servis koruması, `gethui` / `CoreGui` / `PlayerGui` otomatik seçimi ve menüyü çökertmeyen `pcall` sarmallı callback sistemi.
- 💾 **Otomatik Config Sistemi:** `Flag` verilen tüm bileşenleri JSON olarak kaydeder, yükler ve `EnableAutoSave` ile her değişiklikte otomatik günceller.
- 🧰 **Hazır Hub Araçları:** Dahili **Key System** (anahtar doğrulama + kaydetme), **Watermark** (FPS, Ping, Saat) ve **Keybinds HUD** (aktif tuş takip paneli).

---

## 🚀 Hızlı Başlangıç

Executor'ına yapıştırıp hemen çalıştırabilirsin:

```lua
local Orbit = loadstring(game:HttpGet("https://raw.githubusercontent.com/Comesfar/orbit-ui/main/dist/Orbit.lua"))()

local Window = Orbit:CreateWindow({
    Title = "Orbit Hub",
    Subtitle = "v0.3.1-beta",
    Theme = "Midnight",                  -- Dark | Midnight | Rose | Light
    ToggleKey = Enum.KeyCode.RightShift, -- Menüyü aç/kapat tuşu
    Blur = false,                        -- Arka plan bulanıklığı
    ConfigFolder = "OrbitHub",           -- Config kayıt klasörü
})

-- Sol üstte canlı FPS / Ping / Saat göstergesi
Orbit:AddWatermark({
    Title = "Orbit Hub",
    Build = "v0.3.1",
    ShowFPS = true,
    ShowPing = true,
    ShowTime = true,
})

local Main = Window:Tab({ Title = "Oyuncu", Icon = "user" })

Main:Section("Hareket")

Main:Slider({
    Title = "Yürüme Hızı",
    Flag = "walkspeed",
    Min = 16, Max = 150, Default = 16,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})

Main:Toggle({
    Title = "Sonsuz Zıplama",
    Flag = "infjump",
    Keybind = Enum.KeyCode.J, -- Yanında J kısayol tuşuyla birlikte gelir
    Default = false,
    Callback = function(state)
        print("Sonsuz Zıplama:", state)
    end,
})

Window:TabSection("Sistem")
Window:AddSettingsTab() -- Hazır tema, renk, tuş ve config sekmesi
```

---

## 📖 Bileşen Referansı (API)

### 1. Pencere & Sekmeler (`Window` & `Tab`)
```lua
Window:TabSection("Kategori Başlığı")
local Tab = Window:Tab({ Title = "Sekme Adı", Icon = "house" })

-- Canlı tema ve renk değiştirme
Window:SetTheme("Rose")
Window:SetAccent(Color3.fromRGB(0, 220, 180))
Window:ResetAccent()

-- Otomatik kayıt (tüm sekmeler oluşturulduktan sonra çağrılır)
Window:EnableAutoSave("default")
```

### 2. Katlanabilir Kart / Bölüm (`Section`)
Hem düz başlık hem de içine bileşen eklenebilen akordiyon kart olarak kullanılabilir:
```lua
-- Düz başlık
Tab:Section("Genel Ayarlar")

-- Katlanabilir (Collapsible) Kart
local Card = Tab:Section({
    Title = "Otomatik Farm",
    Icon = "swords",
    Collapsible = true,
    Default = true, -- Açık başlasın
})
Card:Toggle({ Title = "Oto Sandık", Flag = "auto_chest", Callback = print })
Card:Slider({ Title = "Menzil", Min = 10, Max = 100, Default = 40, Suffix = "m" })
```

### 3. Temel Bileşenler
```lua
-- Buton (Ripple animasyonlu)
Tab:Button({
    Title = "İşlemi Başlat",
    Description = "Alt açıklama metni",
    Icon = "zap",
    Tooltip = "Üzerine gelince çıkan ipucu",
    Callback = function() end,
})

-- Toggle (İsteğe bağlı yan Keybind ile)
local Tgl = Tab:Toggle({
    Title = "Uçma (Fly)",
    Description = "F tuşuyla açıp kapatabilirsin",
    Flag = "fly",
    Default = false,
    Keybind = Enum.KeyCode.F,
    Callback = function(state) end,
})
Tgl:Set(true)

-- Slider (Değerin üstüne tıklayıp klavyeyle sayı da yazılabilir!)
local Sld = Tab:Slider({
    Title = "Hız",
    Flag = "speed",
    Min = 0, Max = 200, Step = 0.5, Default = 16,
    Suffix = " stud/s",
    Callback = function(val) end,
})

-- İkili Aralık Slider (RangeSlider)
Tab:RangeSlider({
    Title = "Mesafe Aralığı",
    Flag = "dist_range",
    Min = 0, Max = 100, Default = { 20, 80 },
    Callback = function(minVal, maxVal) end,
})

-- İlerleme Çubuğu (ProgressBar)
local Bar = Tab:ProgressBar({
    Title = "Görev İlerlemesi",
    Min = 0, Max = 100, Default = 35, Suffix = "%",
})
Bar:Set(80)
```

### 4. Seçim & Girdi Bileşenleri
```lua
-- Dropdown (Tekli, Çoklu ve Aramalı)
local Dp = Tab:Dropdown({
    Title = "Hedef Seç",
    Flag = "target",
    Values = { "Oyuncu 1", "Oyuncu 2", "Oyuncu 3" },
    Multi = false,       -- true yapılırsa çoklu seçim
    Searchable = true,   -- İçinde filtreleme kutusu açar (>8 elemanda otomatik açılır)
    Default = "Oyuncu 1",
    Callback = function(selected) end,
})
Dp:Refresh({ "Yeni 1", "Yeni 2" })

-- Metin Kutusu (Input & Çok Satırlı TextArea)
Tab:Input({ Title = "Kullanıcı Adı", Flag = "user", Placeholder = "Yazın...", Callback = print })
Tab:TextArea({ Title = "Notlar", Flag = "notes", Height = 100, Placeholder = "Çok satırlı..." })

-- Tuş Atama (Keybind) & Renk Seçici (ColorPicker)
Tab:Keybind({ Title = "Hızlı Tuş", Flag = "bind", Default = Enum.KeyCode.G, Callback = print })
Tab:ColorPicker({ Title = "ESP Rengi", Flag = "esp_col", Default = Color3.fromRGB(88, 130, 255), Callback = print })
```

### 5. Zengin Bildirimler, Dialog & Ekstralar
```lua
-- Zengin Bildirim (Info, Success, Warning, Error)
Orbit:Notify({
    Title = "İşlem Tamamlandı",
    Content = "Ayarlar başarıyla uygulandı.",
    Type = "Success",
    Duration = 5,
    Sound = true,
    Buttons = {
        { Title = "Tamam", Primary = true, Callback = function() end },
    },
})

-- Onay Penceresi (Dialog)
Window:Dialog({
    Title = "Emin misin?",
    Content = "Bu işlem geri alınamaz.",
    Buttons = {
        { Title = "İptal" },
        { Title = "Evet, Sil", Danger = true, Callback = function() end },
    },
})

-- Aktif Tuşlar Paneli (Keybinds HUD)
local KeyList = Window:CreateKeybindList()

-- Key System (Anahtar Doğrulama Ekranı)
Orbit:CreateKeySystem({
    Title = "Orbit Key System",
    Note = "Anahtarı Discord sunucumuzdan alabilirsiniz.",
    Keys = { "orbit_2026", "vip_key" },
    Link = "https://discord.gg/ornek",
    SaveKey = true,
    Callback = function(ok)
        if ok then print("Giriş başarılı!") end
    end,
})

-- Özel Tema Oluşturma
Orbit:CreateTheme("Cyberpunk", {
    Background = Color3.fromRGB(14, 11, 24),
    Sidebar = Color3.fromRGB(20, 15, 34),
    Element = Color3.fromRGB(28, 22, 46),
    ElementHover = Color3.fromRGB(38, 30, 62),
    Stroke = Color3.fromRGB(58, 45, 92),
    Text = Color3.fromRGB(240, 240, 255),
    SubText = Color3.fromRGB(155, 145, 190),
    Accent = Color3.fromRGB(0, 240, 195),
    Danger = Color3.fromRGB(255, 75, 105),
})
```

---

## 🗂️ Mimari & Geliştirme

```
orbit-ui/
├── loader.lua          # Modülleri src/ altından dinamik yükler (yerel veya HttpGet)
├── build.ps1           # src/ altındaki tüm modülleri dist/Orbit.lua olarak tek dosyada birleştirir
├── example.lua         # Tüm özellikleri içeren örnek script
├── dist/Orbit.lua      # Tek dosyalık dağıtım paketi
└── src/
    ├── init.lua        # Giriş noktası (Orbit tablosu, CreateTheme, CreateWindow)
    ├── Util.lua        # New, Tween, Drag, MakeDraggable, Ripple, cloneref Service
    ├── Themes.lua      # Dark, Midnight, Rose, Light temaları
    ├── Icons.lua       # 30+ dahili Lucide ikon + arka plan yükleyici
    ├── Window.lua      # Pencere, DropShadow, Arama, Boyutlandırma, Canlı Tema
    ├── Tab.lua         # Sekme yönetimi ve element bağlamı
    ├── Notify.lua      # Tipli, ikonlu, sesli ve butonlu bildirimler
    ├── Dialog.lua      # Onay pencereleri
    ├── Watermark.lua   # Canlı FPS / Ping / Saat göstergesi
    ├── KeybindList.lua # Canlı tuş takip HUD paneli
    ├── KeySystem.lua   # Lisans / anahtar doğrulama ekranı
    ├── SettingsTab.lua # Hazır ayarlar sekmesi
    ├── Config.lua      # JSON kayıt / yükleme ve AutoSave
    ├── Tooltip.lua     # Fare ipucu sistemi
    └── Elements/       # Tüm UI bileşenleri
```

Değişiklik yaptıktan sonra tek dosya paketini güncellemek için PowerShell'de `./build.ps1` çalıştırman yeterlidir.
