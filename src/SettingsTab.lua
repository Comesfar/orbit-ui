-- Orbit UI :: SettingsTab (hazir ayarlar sekmesi)
local import = ...

return function(Window, Orbit, o)
    o = o or {}
    local Tab = Window:Tab({ Title = o.Title or "Ayarlar", Icon = o.Icon or "settings" })

    Tab:Section("Gorunum")
    local names = {}
    for name in pairs(Orbit.Themes) do table.insert(names, name) end
    table.sort(names)
    Tab:Dropdown({ Title = "Tema", Flag = "Orbit_Theme", Values = names, Default = Window.ThemeName,
        Callback = function(v) Window:SetTheme(v) end })

    local accent = Tab:ColorPicker({ Title = "Aksan Rengi", Flag = "Orbit_Accent", Default = Window.Theme.Accent,
        Callback = function(c) Window:SetAccent(c) end })
    Tab:Button({ Title = "Aksan Rengini Sifirla", Description = "Temanin kendi rengine don", Callback = function()
        Window:ResetAccent()
        accent:Set(Window.Theme.Accent, true)
    end })

    Tab:Section("Kontroller")
    Tab:Keybind({ Title = "Menu Tusu", Flag = "Orbit_ToggleKey", Default = Window.ToggleKey, Tooltip = "ESC ile tusu kaldirabilirsin",
        Changed = function(k) Window.ToggleKey = k end })
    Tab:Toggle({ Title = "Mobil Buton", Default = Window.Gui.MobileToggle.Visible, Callback = function(v) Window:SetMobileButton(v) end })

    Tab:Section("Config")
    local cfgName = "default"
    local list
    Tab:Input({ Title = "Config adi", Default = cfgName, Callback = function(t) if t ~= "" then cfgName = t end end })
    list = Tab:Dropdown({ Title = "Kayitli configler", Values = Window:ListConfigs(), Callback = function(v) cfgName = v end })
    Tab:Button({ Title = "Kaydet", Callback = function()
        local ok, err = Window:SaveConfig(cfgName)
        Window:Notify({ Title = ok and "Kaydedildi" or "Hata", Content = ok and cfgName or tostring(err) })
        list:Refresh(Window:ListConfigs())
    end })
    Tab:Button({ Title = "Yukle", Callback = function()
        local ok, err = Window:LoadConfig(cfgName)
        Window:Notify({ Title = ok and "Yuklendi" or "Hata", Content = ok and cfgName or tostring(err) })
    end })
    Tab:Toggle({ Title = "Otomatik Kaydet", Description = "Her degisiklikte seçili config'e yazar", Callback = function(v)
        if v then Window:EnableAutoSave(cfgName) else Window:DisableAutoSave() end
    end })

    Tab:Section("Arayuz")
    Tab:Button({ Title = "Arayuzu Kaldir", Description = "Menuyu tamamen kapatir", Callback = function()
        Window:Dialog({ Title = "Emin misin?", Content = "Arayuz tamamen kaldirilacak.", Buttons = {
            { Title = "Iptal" }, { Title = "Kaldir", Danger = true, Callback = function() Window:Destroy() end },
        } })
    end })

    return Tab
end
