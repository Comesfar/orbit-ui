-- Orbit UI :: Util - ortak yardimcilar
local import = ...

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Util = {}

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

function Util.GetGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    ok, hui = pcall(function() return game:GetService("CoreGui") end)
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
-- callback(pos, isStart)
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
