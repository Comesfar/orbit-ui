-- Orbit UI :: Util - ortak yardimcilar
local import = ...

local cloneref = (cloneref or clonereference or function(i) return i end)
local function Service(name)
    return cloneref(game:GetService(name))
end

local Players = Service("Players")
local TweenService = Service("TweenService")
local UserInputService = Service("UserInputService")

local Util = { Service = Service }

function Util.New(class, props, children)
    local inst = Instance.new(class)
    if class == "UIListLayout" and (not props or props.SortOrder == nil) then
        inst.SortOrder = Enum.SortOrder.LayoutOrder
    end
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

function Util.Tween(obj, time, props, style)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

function Util.Corner(r)
    return Util.New("UICorner", { CornerRadius = UDim.new(0, r) })
end

function Util.Stroke(color, t)
    return Util.New("UIStroke", { Color = color, Thickness = t or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
end

function Util.Pad(l, t, r, b)
    return Util.New("UIPadding", { PaddingLeft = UDim.new(0, l), PaddingTop = UDim.new(0, t), PaddingRight = UDim.new(0, r), PaddingBottom = UDim.new(0, b) })
end

-- Buton tiklamalarinda hafif dalga (ripple) efekti
function Util.Ripple(parent, color)
    task.spawn(function()
        local m = UserInputService:GetMouseLocation()
        local relX = m.X - parent.AbsolutePosition.X
        local relY = m.Y - parent.AbsolutePosition.Y - 36
        local maxD = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 1.6
        local circle = Util.New("Frame", {
            Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromOffset(relX, relY), Size = UDim2.fromOffset(0, 0),
            BackgroundColor3 = color or Color3.new(1, 1, 1), BackgroundTransparency = 0.75,
            BorderSizePixel = 0, ZIndex = parent.ZIndex + 1,
        }, { Util.Corner(999) })
        Util.Tween(circle, 0.4, { Size = UDim2.fromOffset(maxD, maxD), BackgroundTransparency = 1 })
        task.wait(0.42)
        if circle and circle.Parent then circle:Destroy() end
    end)
end

function Util.GetGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    ok, hui = pcall(function() return Service("CoreGui") end)
    if ok and hui then
        local test = Instance.new("Folder")
        if pcall(function() test.Parent = hui end) then test:Destroy() return hui end
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function defaultConnect(signal, fn) return signal:Connect(fn) end

function Util.MakeDraggable(handle, target, connect)
    connect = connect or defaultConnect
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startInput, startPos = true, i.Position, target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    connect(UserInputService.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Surukleme sirasinda input takibi (slider, color picker)
function Util.Drag(frame, callback, connect)
    connect = connect or defaultConnect
    local active = false
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true
            callback(i.Position, true)
        end
    end)
    connect(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then active = false end
    end)
    connect(UserInputService.InputChanged, function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            callback(i.Position, false)
        end
    end)
end

function Util.round(n, step)
    step = step or 1
    return math.floor(n / step + 0.5) * step
end

return Util
