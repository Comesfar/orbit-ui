# Orbit UI

Roblox executor scriptleri icin moduler UI kutuphanesi.

```
orbit-ui/
├── loader.lua          # modulleri src/ altindan yukler (yerel veya HttpGet)
├── build.ps1           # src/ -> dist/Orbit.lua (tek dosya)
├── example.lua
├── dist/Orbit.lua      # build ciktisi
└── src/
    ├── init.lua        # giris noktasi (Orbit tablosu)
    ├── Util.lua        # New, Tween, Drag, ...
    ├── Themes.lua      # Dark, Midnight, Rose, Light
    ├── Window.lua      # CreateWindow
    ├── Tab.lua         # sekme + element baglami (ctx)
    ├── Dialog.lua      # Window:Dialog
    ├── Notify.lua      # Orbit:Notify
    ├── Config.lua      # Save/Load/ListConfigs
    └── Elements/       # Button, Toggle, Slider, Input, Dropdown, Keybind, ColorPicker, ...
```

## Kullanim
- Gelistirme: `OrbitUI/` klasorunu executor `workspace` icine kopyala, `loadstring(readfile("OrbitUI/loader.lua"))()`
- Dagitim: `./build.ps1` calistir, `dist/Orbit.lua` dosyasini kullan/yukle.

## Yeni element eklemek
1. `src/Elements/Ad.lua` olustur:
   ```lua
   local import = ...
   return function(ctx, o) -- ctx: Theme, Window, Page, Row(), Hoverable(), Register()
       ...
   end
   ```
2. `src/Tab.lua` icindeki `ELEMENTS` listesine `"Ad"` ekle. `Tab:Ad({...})` hazir.

Modul kurali: her dosya `local import = ...` ile baslar, bagimliliklari `import("Util")` ile alir.
