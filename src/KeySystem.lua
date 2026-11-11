-- Orbit UI :: KeySystem (Anahtar Dogrulama Arayuzu)
local import = ...
local Util = import("Util")
local Icons = import("Icons")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local HttpService = game:GetService("HttpService")

return function(Orbit, opts)
    opts = opts or {}
    local theme = Orbit.CurrentTheme or Orbit.Themes.Dark
    local folder = opts.ConfigFolder or "OrbitUI"
    local savePath = folder .. "/saved_key.txt"

    local function canFS()
        return writefile and readfile and isfolder and makefolder and isfile
    end

    local function checkKey(key)
        if opts.CheckKey then
            local ok, res = pcall(opts.CheckKey, key)
            return ok and res
        end
        if opts.Keys then
            for _, k in ipairs(opts.Keys) do
                if k == key then return true end
            end
        end
        if opts.Key and opts.Key == key then return true end
        return false
    end

    -- Otomatik hatirlanan key kontrolu
    if opts.SaveKey ~= false and canFS() and isfile(savePath) then
        local saved = readfile(savePath):gsub("%s+", "")
        if checkKey(saved) then
            if opts.Callback then task.spawn(opts.Callback, true) end
            return
        end
    end

    -- GUI olustur
    local gui = New("ScreenGui", {
        Name = "OrbitKeySystem_" .. HttpService:GenerateGUID(false):sub(1, 8),
        ResetOnSpawn = false, DisplayOrder = 1000, IgnoreGuiInset = true,
    })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = Util.GetGuiParent()

    local card = New("CanvasGroup", {
        Name = "KeyCard", Parent = gui, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(360, 0),
        AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Background,
        GroupTransparency = 1, ZIndex = 600,
    }, {
        Corner(12), Stroke(theme.Stroke), Pad(18, 16, 18, 16),
        New("UIListLayout", { Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
    })

    -- Baslik alani
    local topRow = New("Frame", {
        Parent = card, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
    })
    Icons.Create(topRow, "key", {
        Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0, 0, 0.5, -10),
        Color = theme.Accent,
    })
    New("TextLabel", {
        Parent = topRow, BackgroundTransparency = 1, Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -28, 1, 0), Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Text = opts.Title or "Key System",
    })

    if opts.Subtitle or opts.Note then
        New("TextLabel", {
            Parent = card, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y, Font = Enum.Font.Gotham, TextSize = 12,
            TextColor3 = theme.SubText, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
            Text = opts.Note or opts.Subtitle or "Lutfen anahtarinizi girin.",
        })
    end

    -- Girdi kutusu
    local inputWrap = New("Frame", {
        Parent = card, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = theme.Element,
    }, { Corner(8), Stroke(theme.Stroke), Pad(10, 0, 10, 0) })

    local box = New("TextBox", {
        Parent = inputWrap, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = theme.Text, PlaceholderText = "Anahtar buraya...", PlaceholderColor3 = theme.SubText,
        Text = "",
    })

    -- Butonlar
    local btnRow = New("Frame", {
        Parent = card, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1,
    }, { New("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8) }) })

    local verifyBtn = New("TextButton", {
        Parent = btnRow, Size = UDim2.new(opts.Link and 0.55 or 1, -4, 1, 0),
        BackgroundColor3 = theme.Accent, AutoButtonColor = false,
        Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.new(1, 1, 1),
        Text = "Dogrula",
    }, { Corner(8) })

    if opts.Link then
        local linkBtn = New("TextButton", {
            Parent = btnRow, Size = UDim2.new(0.45, -4, 1, 0),
            BackgroundColor3 = theme.Element, AutoButtonColor = false,
            Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
            Text = "Key Al",
        }, { Corner(8), Stroke(theme.Stroke) })

        linkBtn.Activated:Connect(function()
            local setClip = setclipboard or toclipboard or (Clipboard and Clipboard.set)
            if setClip then
                setClip(opts.Link)
                Orbit:Notify({ Title = "Kopyalandi", Content = "Key linki panoya kopyalandi!", Type = "Success" })
            else
                Orbit:Notify({ Title = "Link", Content = opts.Link, Duration = 8 })
            end
        end)
    end

    Util.MakeDraggable(topRow, card)

    -- Dogrulama islemi
    local function verify()
        local entered = box.Text:gsub("%s+", "")
        if checkKey(entered) then
            Tween(inputWrap.UIStroke, 0.15, { Color = Color3.fromRGB(50, 205, 120) })
            if opts.SaveKey ~= false and canFS() then
                if not isfolder(folder) then makefolder(folder) end
                writefile(savePath, entered)
            end
            Orbit:Notify({ Title = "Basarili", Content = "Key dogrulandi! Yukleniyor...", Type = "Success", Duration = 3 })
            Tween(card, 0.25, { GroupTransparency = 1 }).Completed:Wait()
            gui:Destroy()
            if opts.Callback then task.spawn(opts.Callback, true) end
        else
            Tween(inputWrap.UIStroke, 0.15, { Color = theme.Danger })
            Orbit:Notify({ Title = "Gecersiz Key", Content = "Girdiginiz anahtar yanlis, tekrar deneyin.", Type = "Error" })
            task.delay(1, function()
                Tween(inputWrap.UIStroke, 0.15, { Color = theme.Stroke })
            end)
        end
    end

    verifyBtn.Activated:Connect(verify)
    box.FocusLost:Connect(function(enter)
        if enter then verify() end
    end)

    Tween(card, 0.3, { GroupTransparency = 0 })
end
