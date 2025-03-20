-- NotificationModule.lua
local TweenService = game:GetService("TweenService")

local NotificationModule = {}
local ScreenGui

local CONFIG = {
    Duration = 10,
    Position = UDim2.new(1, -20, 0, 20),
    Size = UDim2.new(0, 350, 0, 70),
    BackgroundColor = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    AccentColor = Color3.fromRGB(118, 185, 0),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    ParticleConfig = { Count = 50, MinSize = 1, MaxSize = 2, Speed = {4, 7} }
}

local function initGui()
    if not ScreenGui then
        ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "NotificationGui"
        ScreenGui.Parent = game.CoreGui
    end
end

local function createGlow(parent, color, transparency)
    local glow = Instance.new("ImageLabel")
    glow.BackgroundTransparency, glow.Image, glow.ImageColor3, glow.ImageTransparency = 1, "rbxassetid://7131988516", color, transparency
    glow.Size, glow.SizeConstraint, glow.Position, glow.AnchorPoint, glow.ZIndex, glow.Parent = UDim2.new(1.5, 0, 1.5, 0), Enum.SizeConstraint.RelativeXX, UDim2.new(0.5, 0, 0.5, 0), Vector2.new(0.5, 0.5), parent.ZIndex - 1, parent
    return glow
end

local function createAnimatedBackground(parent)
    local bg = Instance.new("Frame")
    bg.Name, bg.Size, bg.BackgroundTransparency, bg.ZIndex, bg.Parent = "AnimatedBackground", UDim2.new(1, 0, 1, 0), 1, 0, parent
    
    for _ = 1, CONFIG.ParticleConfig.Count do
        local particle = Instance.new("Frame")
        particle.BackgroundColor3, particle.BorderSizePixel = CONFIG.AccentColor, 0
        local size = math.random(CONFIG.ParticleConfig.MinSize, CONFIG.ParticleConfig.MaxSize)
        particle.Size, particle.Position = UDim2.new(0, size, 0, size), UDim2.new(math.random(), 0, math.random(), 0)
        createGlow(particle, CONFIG.AccentColor, 0.7)
        Instance.new("UICorner", particle).CornerRadius = UDim.new(1, 0)
        particle.Parent = bg

        local function animateParticle()
            local duration = math.random(CONFIG.ParticleConfig.Speed[1], CONFIG.ParticleConfig.Speed[2])
            local tween = TweenService:Create(particle, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(math.random(), 0, math.random(), 0)})
            tween:Play()
            wait(duration)
        end
        coroutine.wrap(animateParticle)()
    end
end

function NotificationModule.Create(title, message, accentColor)
    initGui()
    accentColor = accentColor or CONFIG.AccentColor

    local notification = Instance.new("Frame")
    notification.Size, notification.Position, notification.AnchorPoint, notification.BackgroundColor3 = CONFIG.Size, UDim2.new(1, 20, 0, CONFIG.Position.Y.Offset), Vector2.new(1, 0), CONFIG.BackgroundColor
    notification.BorderSizePixel, notification.BackgroundTransparency, notification.ClipsDescendants, notification.Parent = 0, 0.1, true, ScreenGui

    createAnimatedBackground(notification)

    local elements = {
        { "AccentBar", UDim2.new(1, 0, 1, 0), accentColor },
        { "FixedAccentBar", UDim2.new(0, 4, 1, 0), accentColor, false },
        { "Title", UDim2.new(0, 200, 0, 20), CONFIG.TextColor, title, UDim2.new(0, 20, 0, 15) },
        { "Message", UDim2.new(0, 200, 0, 20), CONFIG.TextColor, message, UDim2.new(0, 20, 0, 35) }
    }

    for _, data in ipairs(elements) do
        local element = data[4] and Instance.new("TextLabel") or Instance.new("Frame")
        element.Name, element.Size, element.Position, element.BackgroundColor3, element.Parent = data[1], data[2], data[5] or UDim2.new(), data[3], notification
        if data[4] then
            element.Font, element.TextSize, element.TextXAlignment, element.Text, element.TextTransparency, element.BackgroundTransparency = CONFIG.Font, CONFIG.TextSize, Enum.TextXAlignment.Left, data[4], 1, 1
        else
            element.BorderSizePixel, element.Visible = 0, data[5] or true
        end
    end

    local function animate()
        TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = CONFIG.Position}):Play()
        wait(CONFIG.Duration)
        TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 20, notification.Position.Y.Scale, notification.Position.Y.Offset)}):Play()
        wait(0.5)
        notification:Destroy()
    end
    task.spawn(animate)
end

return NotificationModule
