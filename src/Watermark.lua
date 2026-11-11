-- Orbit UI :: Watermark (FPS, Ping, Saat ve Bilgi Ekrani)
local import = ...
local Util = import("Util")
local New, Tween, Corner, Stroke, Pad = Util.New, Util.Tween, Util.Corner, Util.Stroke, Util.Pad

local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Players = game:GetService("Players")

return function(Orbit, opts)
    opts = opts or {}
    local theme = Orbit.CurrentTheme or Orbit.Themes.Dark
    local gui = Orbit.Gui

    if not gui then
        local HttpService = game:GetService("HttpService")
        gui = New("ScreenGui", {
            Name = "OrbitWatermark_" .. HttpService:GenerateGUID(false):sub(1, 8),
            ResetOnSpawn = false, DisplayOrder = 998, IgnoreGuiInset = true,
        })
        pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
        gui.Parent = Util.GetGuiParent()
    end

    local showFps = opts.ShowFPS ~= false
    local showPing = opts.ShowPing ~= false
    local showTime = opts.ShowTime ~= false
    local title = opts.Title or "Orbit UI"
    local build = opts.Build or Orbit.Version or "v0.3.0"
    local customText = opts.CustomText

    -- Roblox topbar'i altinda guvenli konum (Y = 56)
    local pos = opts.Position or UDim2.new(0, 16, 0, 56)

    local frame = New("Frame", {
        Name = "Watermark", Parent = gui, Position = pos,
        Size = UDim2.fromOffset(0, 28), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = theme.Background, ZIndex = 300,
    }, {
        Corner(14), Stroke(theme.Stroke), Pad(10, 4, 10, 4),
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 8),
        }),
    })

    local dot = New("Frame", {
        Parent = frame, Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = theme.Accent, BorderSizePixel = 0, ZIndex = 301,
    }, { Corner(4) })

    local label = New("TextLabel", {
        Parent = frame, BackgroundTransparency = 1,
        Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextColor3 = theme.Text,
        RichText = true, Text = "", ZIndex = 301,
    })

    Util.MakeDraggable(frame, frame)

    local Watermark = { Frame = frame, Visible = true }

    function Watermark:SetTitle(t) title = t end
    function Watermark:SetCustomText(t) customText = t end
    function Watermark:SetVisible(v)
        Watermark.Visible = v
        frame.Visible = v
    end
    function Watermark:Toggle() Watermark:SetVisible(not Watermark.Visible) end

    local fps = 60
    local lastTime = tick()
    local frameCount = 0

    local function updateStats()
        local parts = {}
        table.insert(parts, string.format("<b>%s</b> <font color='rgb(%d,%d,%d)'>%s</font>", title, math.floor(theme.SubText.R * 255), math.floor(theme.SubText.G * 255), math.floor(theme.SubText.B * 255), build))

        if customText then
            table.insert(parts, customText)
        end
        if showFps then
            table.insert(parts, string.format("<font color='rgb(%d,%d,%d)'>%d FPS</font>", math.floor(theme.Accent.R * 255), math.floor(theme.Accent.G * 255), math.floor(theme.Accent.B * 255), fps))
        end
        if showPing then
            local ping = 0
            pcall(function()
                local net = Stats:FindFirstChild("Network")
                local sItem = net and net:FindFirstChild("ServerStatsItem")
                local dPing = sItem and sItem:FindFirstChild("Data Ping")
                if dPing then
                    ping = math.floor(tonumber(dPing:GetValueString():match("%d+")) or 0)
                else
                    local p = Players.LocalPlayer
                    if p and p.GetNetworkPing then ping = math.floor((p:GetNetworkPing() or 0) * 1000) end
                end
            end)
            table.insert(parts, string.format("%dms", ping))
        end
        if showTime then
            local ok, tStr = pcall(function() return os.date("%H:%M:%S") end)
            if ok and tStr then table.insert(parts, tStr) end
        end

        label.Text = table.concat(parts, "  <font color='rgb(100,100,120)'>|</font>  ")
    end

    -- Hemen ilk guncellemeyi yap (metin bos kalmasin)
    updateStats()

    local conn = RunService.RenderStepped:Connect(function()
        frameCount += 1
        local now = tick()
        if now - lastTime >= 0.5 then
            fps = math.floor(frameCount / (now - lastTime))
            frameCount = 0
            lastTime = now
            updateStats()
        end
    end)

    function Watermark:Destroy()
        if conn then conn:Disconnect() end
        frame:Destroy()
    end

    return Watermark
end
