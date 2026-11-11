-- ============================================================================
-- Orbit UI v0.3.1-beta — Kapsamli Ozellik Test Scripti (Showcase)
-- ============================================================================
local Orbit = loadstring(game:HttpGet("https://raw.githubusercontent.com/Comesfar/orbit-ui/main/dist/Orbit.lua"))()

-- 1) Ozel Tema Olusturma (Ayarlar > Tema listesine otomatik eklenir!)
Orbit:CreateTheme("Cyberpunk", {
	Background   = Color3.fromRGB(13, 10, 22),
	Sidebar      = Color3.fromRGB(18, 14, 30),
	Element      = Color3.fromRGB(26, 20, 44),
	ElementHover = Color3.fromRGB(36, 28, 60),
	Stroke       = Color3.fromRGB(58, 44, 94),
	Text         = Color3.fromRGB(240, 240, 255),
	SubText      = Color3.fromRGB(155, 145, 195),
	Accent       = Color3.fromRGB(0, 240, 195),
	Danger       = Color3.fromRGB(255, 75, 105),
})

-- 2) Ana Pencere (9-Slice DropShadow + Mobil Buton + Arama Kutusu)
local Window = Orbit:CreateWindow({
	Title = "Orbit Hub",
	Subtitle = "v0.3.1-beta",
	Theme = "Midnight",                  -- Dark | Midnight | Rose | Light | Cyberpunk
	ToggleKey = Enum.KeyCode.RightShift, -- Menuyu ac/kapat tusu
	Blur = false,
	ConfigFolder = "OrbitHub_Test",
})

-- 3) Sol Ust Watermark (Sürüklenebilir FPS / Ping / Saat)
local Watermark = Orbit:AddWatermark({
	Title = "Orbit Hub",
	Build = "v0.3.1-beta",
	ShowFPS = true,
	ShowPing = true,
	ShowTime = true,
})

-- 4) Ekranda Canli Keybinds HUD Paneli (Atanan tuslar ve ON/OFF durumu)
local KeyList = Window:CreateKeybindList({
	Position = UDim2.new(0, 16, 0.42, 0),
})

-- ============================================================================
-- SEKME 1: OYUNCU (Slider Klavye Girisi, Yan Keybindli Toggle, Katlanabilir Kart)
-- ============================================================================
Window:TabSection("Ana Menu")
local OyuncuTab = Window:Tab({ Title = "Oyuncu", Icon = "user" })

OyuncuTab:Section("Hareket (Sayiya Tiklayip Klavyeyle Deger Yazabilirsin!)")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

OyuncuTab:Slider({
	Title = "Yürüme Hızı (WalkSpeed)",
	Flag = "walkspeed",
	Min = 16,
	Max = 250,
	Default = 16,
	Suffix = " stud",
	Tooltip = "Sag ustteki sayiya tiklayarak klavyeden istedigin degeri girebilirsin.",
	Callback = function(deger)
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = deger
		end
	end,
})

OyuncuTab:Slider({
	Title = "Zıplama Gücü (JumpPower)",
	Flag = "jumppower",
	Min = 50,
	Max = 350,
	Default = 50,
	Callback = function(deger)
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = deger
		end
	end,
})

local infJumpAktif = false
OyuncuTab:Toggle({
	Title = "Sonsuz Zıplama (Infinite Jump)",
	Description = "Yanindaki J tusuyla menuyu acmadan acip kapatabilirsin",
	Flag = "inf_jump",
	Default = false,
	Keybind = Enum.KeyCode.J,
	Callback = function(durum)
		infJumpAktif = durum
	end,
})

UserInputService.JumpRequest:Connect(function()
	if infJumpAktif then
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- Katlanabilir (Collapsible) Akordiyon Kart Bolumu
local FarmCard = OyuncuTab:Section({
	Title = "Otomatik Farm (Katlanabilir Kart)",
	Icon = "swords",
	Collapsible = true,
	Default = true,
})

FarmCard:Toggle({
	Title = "Otomatik Sandık Topla",
	Flag = "auto_chest",
	Keybind = Enum.KeyCode.F,
	Default = false,
	Callback = function(v)
		print("Oto Sandik:", v)
	end,
})

FarmCard:RangeSlider({
	Title = "Hedef Mesafe Aralığı",
	Flag = "target_range",
	Min = 5,
	Max = 150,
	Default = { 15, 80 },
	Suffix = "m",
	Callback = function(minVal, maxVal)
		print("Mesafe:", minVal, "-", maxVal)
	end,
})

local ProgBar = FarmCard:ProgressBar({
	Title = "XP / Görev İlerlemesi",
	Flag = "xp_progress",
	Min = 0,
	Max = 100,
	Default = 40,
	Suffix = "%",
})

FarmCard:Button({
	Title = "İlerlemeyi Artır (+20%) — Ripple Efektli",
	Description = "Butona tikladiginda dalga (ripple) efektini gorebilirsin",
	Icon = "zap",
	Callback = function()
		local cur = ProgBar:Get()
		local nextVal = cur >= 100 and 0 or (cur + 20)
		ProgBar:Set(nextVal)
	end,
})

-- ============================================================================
-- SEKME 2: SİLAH & DROPDOWN (Aramali Dropdown, Coklu Secim, Disari Tiklama)
-- ============================================================================
local SilahTab = Window:Tab({ Title = "Silah & Seçim", Icon = "crosshair" })

SilahTab:Section("Aramalı (Searchable) & Çoklu Dropdown")

SilahTab:Dropdown({
	Title = "Ana Silah Seç (Aramalı)",
	Flag = "main_weapon",
	Searchable = true,
	Values = {
		"AK-47", "M4A1 Carbine", "AWP Sniper", "Desert Eagle",
		"MP5 Submachine", "SPAS-12 Shotgun", "Katana", "RPG-7",
		"Plazma Tüfeği", "Minigun", "Taser", "Glock-18",
	},
	Default = "AK-47",
	Tooltip = "Acilan listede arama yapabilir, disari tiklayarak kapatabilirsin.",
	Callback = function(secilen)
		Orbit:Notify({
			Title = "Silah Seçildi",
			Content = "Aktif silah: " .. tostring(secilen),
			Type = "Info",
			Duration = 3,
		})
	end,
})

SilahTab:Dropdown({
	Title = "Eklentiler (Çoklu Seçim / Multi)",
	Flag = "attachments",
	Multi = true,
	Searchable = true,
	Values = { "Susturucu", "Lazer Nişangah", "Uzatılmış Şarjör", "4x Dürbün", "Hızlı Çekim", "Ağır Namlu" },
	Default = { "Susturucu", "Lazer Nişangah" },
	Callback = function(secilenTablo)
		local liste = {}
		for k, v in pairs(secilenTablo) do
			if v then table.insert(liste, k) end
		end
		print("Secili eklentiler:", table.concat(liste, ", "))
	end,
})

-- ============================================================================
-- SEKME 3: GÖRSEL & TEMA (Canli Tema Gecisi, ColorPicker, Keybinds HUD Kontrolu)
-- ============================================================================
local GorselTab = Window:Tab({ Title = "Görsel & Tema", Icon = "eye" })

GorselTab:Section("Canlı Tema & Görünüm")

GorselTab:Dropdown({
	Title = "Menü Temasını Değiştir",
	Values = { "Midnight", "Dark", "Rose", "Light", "Cyberpunk" },
	Default = "Midnight",
	Callback = function(tema)
		Window:SetTheme(tema)
	end,
})

GorselTab:ColorPicker({
	Title = "Vurgu Rengi (Canlı Accent)",
	Flag = "custom_accent",
	Default = Color3.fromRGB(99, 102, 241),
	Callback = function(renk)
		Window:SetAccent(renk)
	end,
})

GorselTab:Button({
	Title = "Vurgu Rengini Temanın Orijinaline Sıfırla",
	Icon = "refresh-cw",
	Callback = function()
		Window:ResetAccent()
	end,
})

GorselTab:Divider()

GorselTab:Toggle({
	Title = "Keybinds HUD Panelini Göster",
	Default = true,
	Callback = function(durum)
		KeyList:SetVisible(durum)
	end,
})

GorselTab:Toggle({
	Title = "Sol Üst Watermark'ı Göster",
	Default = true,
	Callback = function(durum)
		Watermark:SetVisible(durum)
	end,
})

-- ============================================================================
-- SEKME 4: BİLDİRİM & GİRDİLER (Success/Warning/Error Notify, Dialog, Input)
-- ============================================================================
local BildirimTab = Window:Tab({ Title = "Bildirim & Girdi", Icon = "bell" })

BildirimTab:Section("Zengin Bildirim Testleri (Sesli & Butonlu)")

BildirimTab:Button({
	Title = "Başarı Bildirimi (Success)",
	Icon = "check",
	Callback = function()
		Orbit:Notify({
			Title = "İşlem Başarılı",
			Content = "Tüm ayarların başarıyla senkronize edildi!",
			Type = "Success",
			Sound = true,
			Duration = 4,
			Buttons = {
				{ Title = "Harika", Primary = true },
			},
		})
	end,
})

BildirimTab:Button({
	Title = "Uyarı Bildirimi (Warning)",
	Icon = "shield",
	Callback = function()
		Orbit:Notify({
			Title = "Dikkat",
			Content = "Yüksek hız değeri bazı oyunlarda geri atabilir.",
			Type = "Warning",
			Sound = true,
			Duration = 5,
		})
	end,
})

BildirimTab:Button({
	Title = "Hata Bildirimi (Error) + Onay Penceresi (Dialog)",
	Icon = "trash",
	Callback = function()
		Orbit:Notify({
			Title = "Bağlantı Uyarısı",
			Content = "Sunucu yanıt vermedi, tekrar denemek ister misin?",
			Type = "Error",
			Sound = true,
			Duration = 6,
			Buttons = {
				{
					Title = "Dialog Aç",
					Primary = true,
					Callback = function()
						Window:Dialog({
							Title = "Ayarları Sıfırla?",
							Content = "Yürüme hızı ve zıplama gücü varsayılan değerlere döndürülsün mü?",
							Buttons = {
								{ Title = "İptal" },
								{
									Title = "Evet, Sıfırla",
									Danger = true,
									Callback = function()
										Window.Flags.walkspeed:Set(16)
										Window.Flags.jumppower:Set(50)
									end,
								},
							},
						})
					end,
				},
			},
		})
	end,
})

BildirimTab:Section("Metin Girdileri")

BildirimTab:Input({
	Title = "Özel Takma Ad",
	Flag = "nickname",
	Placeholder = "Bir isim yazın...",
	Callback = function(metin)
		print("Girilen isim:", metin)
	end,
})

BildirimTab:TextArea({
	Title = "Notlar (Çok Satırlı)",
	Flag = "user_notes",
	Placeholder = "Buraya uzun notlar ekleyebilirsin...",
	Height = 90,
})

-- ============================================================================
-- SİSTEM & AYARLAR SEKMESİ
-- ============================================================================
Window:TabSection("Sistem")
Window:AddSettingsTab()

-- Açılış bildirimi
Orbit:Notify({
	Title = "Orbit UI v0.3.1-beta",
	Content = "Hoş geldin! Yeni özellikleri sekmelerden test edebilirsin.",
	Type = "Success",
	Duration = 5,
})
