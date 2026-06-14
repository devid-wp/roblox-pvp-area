-- UIManager.lua (Client)
-- Красивый UI в стиле Sekiro: HP, Posture (стойка), КД руко-хвата
-- Расположение: левый верхний угол

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Удалить старый UI если есть
local oldGui = playerGui:FindFirstChild("SekiroHUD")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SekiroHUD"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- ============================================
-- КОНТЕЙНЕР: левый верхний угол
-- ============================================
local container = Instance.new("Frame")
container.Name = "HUDContainer"
container.Size = UDim2.new(0, 320, 0, 220)
container.Position = UDim2.new(0, 20, 0, 20)
container.BackgroundTransparency = 1
container.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 12)
layout.Parent = container

-- ============================================
-- ЗАГОЛОВОК: имя игрока
-- ============================================
local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "PlayerName"
nameLabel.Size = UDim2.new(1, 0, 0, 24)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextSize = 18
nameLabel.TextColor3 = Color3.fromRGB(220, 200, 160)
nameLabel.TextStrokeTransparency = 0.5
nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.LayoutOrder = 1
nameLabel.Text = player.Name
nameLabel.Parent = container

-- ============================================
-- HP BAR (здоровье)
-- ============================================
local hpFrame = Instance.new("Frame")
hpFrame.Name = "HPFrame"
hpFrame.Size = UDim2.new(1, 0, 0, 28)
hpFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
hpFrame.BorderSizePixel = 0
hpFrame.LayoutOrder = 2
hpFrame.Parent = container

local hpCorner = Instance.new("UICorner")
hpCorner.CornerRadius = UDim.new(0, 4)
hpCorner.Parent = hpFrame

local hpStroke = Instance.new("UIStroke")
hpStroke.Color = Color3.fromRGB(120, 90, 60)
hpStroke.Thickness = 1.5
hpStroke.Parent = hpFrame

-- Фон полоски (тёмно-красный)
local hpBackground = Instance.new("Frame")
hpBackground.Name = "HPBackground"
hpBackground.Size = UDim2.new(1, -6, 1, -6)
hpBackground.Position = UDim2.new(0, 3, 0, 3)
hpBackground.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
hpBackground.BorderSizePixel = 0
hpBackground.Parent = hpFrame

local hpBgCorner = Instance.new("UICorner")
hpBgCorner.CornerRadius = UDim.new(0, 3)
hpBgCorner.Parent = hpBackground

-- Заполнение HP
local hpFill = Instance.new("Frame")
hpFill.Name = "HPFill"
hpFill.Size = UDim2.new(1, 0, 1, 0)
hpFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
hpFill.BorderSizePixel = 0
hpFill.Parent = hpBackground

local hpFillCorner = Instance.new("UICorner")
hpFillCorner.CornerRadius = UDim.new(0, 3)
hpFillCorner.Parent = hpFill

-- Градиент на HP (снизу светлее)
local hpGradient = Instance.new("UIGradient")
hpGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 30, 30))
})
hpGradient.Rotation = 90
hpGradient.Parent = hpFill

-- Текст HP
local hpText = Instance.new("TextLabel")
hpText.Name = "HPText"
hpText.Size = UDim2.new(1, 0, 1, 0)
hpText.BackgroundTransparency = 1
hpText.Font = Enum.Font.GothamBold
hpText.TextSize = 16
hpText.TextColor3 = Color3.fromRGB(255, 240, 220)
hpText.TextStrokeTransparency = 0.3
hpText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
hpText.Text = "100 / 100"
hpText.Parent = hpFrame

-- ============================================
-- POSTURE BAR (стойка — особенность Sekiro)
-- ============================================
local postureFrame = Instance.new("Frame")
postureFrame.Name = "PostureFrame"
postureFrame.Size = UDim2.new(1, 0, 0, 16)
postureFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
postureFrame.BorderSizePixel = 0
postureFrame.LayoutOrder = 3
postureFrame.Parent = container

local postureCorner = Instance.new("UICorner")
postureCorner.CornerRadius = UDim.new(0, 3)
postureCorner.Parent = postureFrame

local postureStroke = Instance.new("UIStroke")
postureStroke.Color = Color3.fromRGB(100, 80, 120)
postureStroke.Thickness = 1
postureStroke.Parent = postureFrame

local postureBackground = Instance.new("Frame")
postureBackground.Name = "PostureBackground"
postureBackground.Size = UDim2.new(1, -4, 1, -4)
postureBackground.Position = UDim2.new(0, 2, 0, 2)
postureBackground.BackgroundColor3 = Color3.fromRGB(30, 20, 40)
postureBackground.BorderSizePixel = 0
postureBackground.Parent = postureFrame

local postureBgCorner = Instance.new("UICorner")
postureBgCorner.CornerRadius = UDim.new(0, 2)
postureBgCorner.Parent = postureBackground

local postureFill = Instance.new("Frame")
postureFill.Name = "PostureFill"
postureFill.Size = UDim2.new(0, 0, 1, 0)
postureFill.BackgroundColor3 = Color3.fromRGB(180, 100, 220)
postureFill.BorderSizePixel = 0
postureFill.Parent = postureBackground

local postureFillCorner = Instance.new("UICorner")
postureFillCorner.CornerRadius = UDim.new(0, 2)
postureFillCorner.Parent = postureFill

local postureGradient = Instance.new("UIGradient")
postureGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 140, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 60, 180))
})
postureGradient.Rotation = 90
postureGradient.Parent = postureFill

local postureLabel = Instance.new("TextLabel")
postureLabel.Name = "PostureLabel"
postureLabel.Size = UDim2.new(0, 80, 0, 12)
postureLabel.Position = UDim2.new(0, 6, 0, 2)
postureLabel.BackgroundTransparency = 1
postureLabel.Font = Enum.Font.GothamBold
postureLabel.TextSize = 11
postureLabel.TextColor3 = Color3.fromRGB(200, 180, 220)
postureLabel.TextXAlignment = Enum.TextXAlignment.Left
postureLabel.Text = "POSTURE"
postureLabel.Parent = postureFrame

-- ============================================
-- GRAPPLING HOOK COOLDOWN INDICATOR
-- ============================================
local hookFrame = Instance.new("Frame")
hookFrame.Name = "HookCooldownFrame"
hookFrame.Size = UDim2.new(1, 0, 0, 50)
hookFrame.BackgroundColor3 = Color3.fromRGB(20, 15, 10)
hookFrame.BorderSizePixel = 0
hookFrame.LayoutOrder = 4
hookFrame.Parent = container

local hookCorner = Instance.new("UICorner")
hookCorner.CornerRadius = UDim.new(0, 4)
hookCorner.Parent = hookFrame

local hookStroke = Instance.new("UIStroke")
hookStroke.Color = Color3.fromRGB(180, 130, 50)
hookStroke.Thickness = 1.5
hookStroke.Parent = hookFrame

-- Иконка руко-хвата (простой круг с перекрестием)
local hookIcon = Instance.new("Frame")
hookIcon.Name = "HookIcon"
hookIcon.Size = UDim2.new(0, 36, 0, 36)
hookIcon.Position = UDim2.new(0, 6, 0, 7)
hookIcon.BackgroundColor3 = Color3.fromRGB(40, 30, 20)
hookIcon.BorderSizePixel = 0
hookIcon.Parent = hookFrame

local hookIconCorner = Instance.new("UICorner")
hookIconCorner.CornerRadius = UDim.new(1, 0) -- круг
hookIconCorner.Parent = hookIcon

local hookIconStroke = Instance.new("UIStroke")
hookIconStroke.Color = Color3.fromRGB(220, 170, 80)
hookIconStroke.Thickness = 2
hookIconStroke.Parent = hookIcon

-- Символ "Q" внутри (клавиша)
local hookKeyText = Instance.new("TextLabel")
hookKeyText.Name = "HookKey"
hookKeyText.Size = UDim2.new(1, 0, 1, 0)
hookKeyText.BackgroundTransparency = 1
hookKeyText.Font = Enum.Font.GothamBold
hookKeyText.TextSize = 18
hookKeyText.TextColor3 = Color3.fromRGB(255, 220, 140)
hookKeyText.Text = "Q"
hookKeyText.Parent = hookIcon

-- Тёмный оверлей поверх иконки (для отображения КД)
local hookOverlay = Instance.new("Frame")
hookOverlay.Name = "HookCooldownOverlay"
hookOverlay.Size = UDim2.new(1, 0, 1, 0)
hookOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
hookOverlay.BackgroundTransparency = 0.5
hookOverlay.BorderSizePixel = 0
hookOverlay.Visible = false
hookOverlay.Parent = hookIcon

local hookOverlayCorner = Instance.new("UICorner")
hookOverlayCorner.CornerRadius = UDim.new(1, 0)
hookOverlayCorner.Parent = hookOverlay

-- Текст КД
local hookCdText = Instance.new("TextLabel")
hookCdText.Name = "HookCooldownText"
hookCdText.Size = UDim2.new(1, 0, 1, 0)
hookCdText.BackgroundTransparency = 1
hookCdText.Font = Enum.Font.GothamBold
hookCdText.TextSize = 14
hookCdText.TextColor3 = Color3.fromRGB(255, 200, 100)
hookCdText.Text = ""
hookCdText.Parent = hookIcon

-- Название способности
local hookNameLabel = Instance.new("TextLabel")
hookNameLabel.Name = "HookName"
hookNameLabel.Size = UDim2.new(1, -52, 0, 16)
hookNameLabel.Position = UDim2.new(0, 50, 0, 6)
hookNameLabel.BackgroundTransparency = 1
hookNameLabel.Font = Enum.Font.GothamBold
hookNameLabel.TextSize = 14
hookNameLabel.TextColor3 = Color3.fromRGB(230, 200, 140)
hookNameLabel.TextXAlignment = Enum.TextXAlignment.Left
hookNameLabel.Text = "RUKO-XVAT"
hookNameLabel.Parent = hookFrame

-- Подпись: статус (готов/на кулдауне)
local hookStatusLabel = Instance.new("TextLabel")
hookStatusLabel.Name = "HookStatus"
hookStatusLabel.Size = UDim2.new(1, -52, 0, 14)
hookStatusLabel.Position = UDim2.new(0, 50, 0, 24)
hookStatusLabel.BackgroundTransparency = 1
hookStatusLabel.Font = Enum.Font.Gotham
hookStatusLabel.TextSize = 12
hookStatusLabel.TextColor3 = Color3.fromRGB(180, 220, 130)
hookStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
hookStatusLabel.Text = "● ГОТОВ"
hookStatusLabel.Parent = hookFrame

-- ============================================
-- ЛОГИКА ОБНОВЛЕНИЯ
-- ============================================
local CombatConfig = require(ReplicatedStorage:WaitForChild("CombatConfig"))

local lastHookTime = 0
local HOOK_COOLDOWN = CombatConfig.GrapplingHook.Cooldown
local MID_AIR_COST = CombatConfig.GrapplingHook.MidAirJumpCost

-- Слежение за клавишей Q для руко-хвата
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        if tick() - lastHookTime >= HOOK_COOLDOWN then
            lastHookTime = tick()
        end
    end
end)

-- Анимация обновления UI каждый кадр
RunService.RenderStepped:Connect(function(dt)
    -- HP
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local hp = humanoid.Health
            local maxHp = humanoid.MaxHealth
            local ratio = math.clamp(hp / maxHp, 0, 1)

            -- Плавное уменьшение HP
            local currentSize = hpFill.Size.X.Scale
            local targetSize = ratio
            local newSize = currentSize + (targetSize - currentSize) * 0.15
            hpFill.Size = UDim2.new(newSize, 0, 1, 0)

            hpText.Text = math.floor(hp) .. " / " .. math.floor(maxHp)

            -- Цвет меняется при низком HP
            if ratio < 0.3 then
                hpFill.BackgroundColor3 = Color3.fromRGB(255, 80, 60)
                -- Мигание при критическом HP
                if math.floor(tick() * 4) % 2 == 0 then
                    hpStroke.Color = Color3.fromRGB(255, 100, 100)
                else
                    hpStroke.Color = Color3.fromRGB(120, 90, 60)
                end
            else
                hpFill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
                hpStroke.Color = Color3.fromRGB(120, 90, 60)
            end
        end
    end

    -- Posture (стойка)
    -- В реальной игре данные приходят с сервера, тут пример
    local postureRatio = 0 -- placeholder, должен приходить с сервера
    local currentPostureSize = postureFill.Size.X.Scale
    local targetPosture = postureRatio
    local newPostureSize = currentPostureSize + (targetPosture - currentPostureSize) * 0.2
    postureFill.Size = UDim2.new(newPostureSize, 0, 1, 0)

    -- Руко-хват КД
    local elapsed = tick() - lastHookTime
    local inAir = character and character:FindFirstChild("HumanoidRootPart")
        and character.HumanoidRootPart.Position.Y > 80

    local totalCd = HOOK_COOLDOWN + (inAir and MID_AIR_COST or 0)
    local remaining = math.max(0, totalCd - elapsed)

    if remaining > 0 then
        hookOverlay.Visible = true
        local ratio = remaining / totalCd
        hookOverlay.Size = UDim2.new(1, 0, ratio, 0)
        hookOverlay.Position = UDim2.new(0, 0, 1 - ratio, 0)
        hookCdText.Text = tostring(math.ceil(remaining))
        hookStatusLabel.Text = "● ПЕРЕЗАРЯДКА"
        hookStatusLabel.TextColor3 = Color3.fromRGB(220, 150, 80)
        hookIconStroke.Color = Color3.fromRGB(120, 90, 50)

        -- В воздухе — мигание
        if inAir then
            if math.floor(tick() * 6) % 2 == 0 then
                hookStroke.Color = Color3.fromRGB(255, 100, 100)
            else
                hookStroke.Color = Color3.fromRGB(180, 130, 50)
            end
        end
    else
        hookOverlay.Visible = false
        hookCdText.Text = ""
        hookStatusLabel.Text = "● ГОТОВ"
        hookStatusLabel.TextColor3 = Color3.fromRGB(180, 220, 130)
        hookIconStroke.Color = Color3.fromRGB(220, 170, 80)
        hookStroke.Color = Color3.fromRGB(180, 130, 50)
    end
end)

-- Анимация появления UI при спавне
container.Position = UDim2.new(-0.4, 20, 0, 20) -- за экраном
local showTween = TweenService:Create(
    container,
    TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {Position = UDim2.new(0, 20, 0, 20)}
)
showTween:Play()

return screenGui
