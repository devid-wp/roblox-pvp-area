-- AnimationService.lua (Server)
-- Анимации для боевой системы в стиле Sekiro
-- Управляет AnimationTracks и эффектами

local AnimationService = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Создаём Remote для синхронизации анимаций
local AnimEvent = Instance.new("RemoteEvent")
AnimEvent.Name = "AnimationEvent"
AnimEvent.Parent = ReplicatedStorage

-- Каталог анимаций (id заглушки — заменить на реальные анимации)
local ANIMATIONS = {
    -- Катана
    KatanaIdle = "rbxassetid://0",
    KatanaLightAttack1 = "rbxassetid://0",  -- 1-й удар
    KatanaLightAttack2 = "rbxassetid://0",  -- 2-й удар
    KatanaLightAttack3 = "rbxassetid://0",  -- 3-й удар
    KatanaLightAttack4 = "rbxassetid://0",  -- 4-й удар (финальный)
    KatanaHeavyAttack = "rbxassetid://0",   -- тяжёлый удар
    KatanaBlock = "rbxassetid://0",         -- блок
    KatanaParry = "rbxassetid://0",         -- парирование
    KatanaStunned = "rbxassetid://0",       -- оглушение

    -- Руко-хват
    HookFire = "rbxassetid://0",            -- выстрел руко-хвата
    HookPull = "rbxassetid://0",            -- притягивание
    HookLand = "rbxassetid://0",            -- приземление

    -- Движение
    DoubleJump = "rbxassetid://0",          -- двойной прыжок
    AirDash = "rbxassetid://0",             -- рывок в воздухе
    WallRun = "rbxassetid://0",             -- бег по стене

    -- Сюрикен
    ThrowShuriken = "rbxassetid://0",       -- бросок
}

-- Загруженные анимации
local loadedAnims = {}
local playerAnims = {}

-- Инициализация для игрока
function AnimationService.InitPlayer(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    playerAnims[player.UserId] = {
        Tracks = {},
        CurrentTrack = nil,
    }

    -- Загружаем все анимации
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator", humanoid)
    end

    for name, id in pairs(ANIMATIONS) do
        if id ~= "rbxassetid://0" then -- только если id задан
            local anim = Instance.new("Animation")
            anim.AnimationId = id
            local track = animator:LoadAnimation(anim)
            playerAnims[player.UserId].Tracks[name] = track
        end
    end
end

-- Воспроизвести анимацию
function AnimationService.Play(player, animName, options)
    options = options or {}
    local playerData = playerAnims[player.UserId]
    if not playerData then return end

    local track = playerData.Tracks[animName]
    if not track then
        -- Заглушка: выводим в консоль
        print("[Animation] " .. animName .. " (id не задан)")
        return
    end

    if options.Speed then
        track:AdjustSpeed(options.Speed)
    end
    if options.Priority then
        track.Priority = options.Priority
    end
    if options.Loop ~= nil then
        track.Looped = options.Loop
    end

    track:Play(options.FadeTime or 0.1)

    if options.Duration then
        task.delay(options.Duration, function()
            track:Stop(options.FadeTime or 0.1)
        end)
    end

    return track
end

-- Остановить анимацию
function AnimationService.Stop(player, animName, fadeTime)
    fadeTime = fadeTime or 0.1
    local playerData = playerAnims[player.UserId]
    if not playerData then return end

    local track = playerData.Tracks[animName]
    if track then
        track:Stop(fadeTime)
    end
end

-- Воспроизвести серию атак катаной (комбо)
function AnimationService.PlayKatanaCombo(player, comboStep)
    comboStep = math.clamp(comboStep, 1, 4)
    local animName = "KatanaLightAttack" .. comboStep
    AnimationService.Play(player, animName, {
        Speed = 1.0 + (comboStep - 1) * 0.05, -- каждый удар чуть быстрее
        Duration = 0.5,
        Priority = Enum.AnimationPriority.Action,
    })
end

-- Анимация парирования
function AnimationService.PlayParry(player, success)
    AnimationService.Play(player, "KatanaParry", {
        Speed = success and 1.2 or 1.0, -- успешное парирование быстрее
        Duration = 0.3,
        Priority = Enum.AnimationPriority.Action4,
    })

    -- Создаём визуальный эффект парирования
    if success then
        AnimationService.SpawnParryEffect(player)
    end
end

-- Анимация руко-хвата
function AnimationService.PlayHookFire(player)
    AnimationService.Play(player, "HookFire", {
        Speed = 1.0,
        Duration = 0.4,
        Priority = Enum.AnimationPriority.Action,
    })
end

function AnimationService.PlayHookPull(player)
    AnimationService.Play(player, "HookPull", {
        Speed = 1.5,
        Priority = Enum.AnimationPriority.Movement,
        Loop = true,
    })
end

-- Очистка
function AnimationService.Cleanup(player)
    playerAnims[player.UserId] = nil
end

-- ============================================
-- ВИЗУАЛЬНЫЕ ЭФФЕКТЫ
-- ============================================

-- Эффект вспышки при ударе катаной
function AnimationService.SpawnSlashEffect(player, targetPos, color)
    color = color or Color3.fromRGB(255, 230, 180)

    local slash = Instance.new("Part")
    slash.Name = "SlashEffect"
    slash.Size = Vector3.new(8, 0.1, 0.5)
    slash.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, 0, math.rad(45))
    slash.Anchored = true
    slash.CanCollide = false
    slash.Material = Enum.Material.Neon
    slash.Color = color
    slash.Transparency = 0.3
    slash.Parent = workspace

    -- Быстрая анимация: расширяется и исчезает
    local tween = TweenService:Create(
        slash,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(15, 0.1, 0.5),
            Transparency = 1
        }
    )
    tween:Play()
    tween.Completed:Connect(function()
        slash:Destroy()
    end)
end

-- Эффект парирования (искры)
function AnimationService.SpawnParryEffect(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart

    -- Создаём 5 искр
    for i = 1, 5 do
        local spark = Instance.new("Part")
        spark.Name = "ParrySpark"
        spark.Size = Vector3.new(0.3, 0.3, 0.3)
        spark.Shape = Enum.PartType.Ball
        spark.Material = Enum.Material.Neon
        spark.Color = Color3.fromRGB(255, 220, 100)
        spark.CFrame = root.CFrame * CFrame.new(0, 0, -2)
        spark.Anchored = false
        spark.CanCollide = false
        spark.Parent = workspace

        -- Случайное направление
        local direction = (Vector3.new(
            math.random() - 0.5,
            math.random() - 0.5,
            -1
        )).Unit * math.random(15, 30)

        spark:ApplyImpulse(direction)

        -- Исчезает за 0.4 сек
        local tween = TweenService:Create(
            spark,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad),
            {Transparency = 1, Size = Vector3.new(0.1, 0.1, 0.1)}
        )
        tween:Play()
        tween.Completed:Connect(function()
            spark:Destroy()
        end)
    end
end

-- Эффект цепи руко-хвата
function AnimationService.SpawnHookChain(origin, target, duration)
    duration = duration or 0.3

    local distance = (target - origin).Magnitude
    local chain = Instance.new("Part")
    chain.Name = "HookChain"
    chain.Size = Vector3.new(0.3, 0.3, distance)
    chain.CFrame = CFrame.lookAt(origin, target) * CFrame.new(0, 0, -distance/2)
    chain.Anchored = true
    chain.CanCollide = false
    chain.Material = Enum.Material.Fabric
    chain.Color = Color3.fromRGB(180, 130, 50)
    chain.Parent = workspace

    -- Исчезает
    local tween = TweenService:Create(
        chain,
        TweenInfo.new(duration, Enum.EasingStyle.Quad),
        {Transparency = 1}
    )
    tween:Play()
    tween.Completed:Connect(function()
        chain:Destroy()
    end)
end

-- Эффект приземления
function AnimationService.SpawnLandingEffect(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart

    local dust = Instance.new("Part")
    dust.Size = Vector3.new(6, 0.5, 6)
    dust.CFrame = CFrame.new(root.Position - Vector3.new(0, 3, 0))
    dust.Anchored = true
    dust.CanCollide = false
    dust.Material = Enum.Material.Smoke
    dust.Color = Color3.fromRGB(200, 180, 150)
    dust.Transparency = 0.3
    dust.Parent = workspace

    local tween = TweenService:Create(
        dust,
        TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = Vector3.new(12, 0.5, 12), Transparency = 1}
    )
    tween:Play()
    tween.Completed:Connect(function()
        dust:Destroy()
    end)
end

-- Эффект сюрикена
function AnimationService.SpawnShuriken(origin, direction, target)
    local shuriken = Instance.new("Part")
    shuriken.Name = "Shuriken"
    shuriken.Size = Vector3.new(0.8, 0.1, 0.8)
    shuriken.Shape = Enum.PartType.Cylinder
    shuriken.CFrame = CFrame.new(origin) * CFrame.Angles(0, 0, math.rad(90))
    shuriken.Anchored = false
    shuriken.CanCollide = false
    shuriken.Material = Enum.Material.Metal
    shuriken.Color = Color3.fromRGB(180, 180, 200)
    shuriken.Parent = workspace

    -- Скорость сюрикена
    shuriken:ApplyImpulse(direction.Unit * 50)

    -- Автоудаление через 3 сек
    game:GetService("Debris"):AddItem(shuriken, 3)

    return shuriken
end

-- Эффект оглушения
function AnimationService.SpawnStunEffect(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart

    -- Красный символ "оглушён" над головой
    local stunIcon = Instance.new("BillboardGui")
    stunIcon.Name = "StunEffect"
    stunIcon.Size = UDim2.new(2, 0, 2, 0)
    stunIcon.StudsOffset = Vector3.new(0, 3, 0)
    stunIcon.AlwaysOnTop = true
    stunIcon.Parent = root

    local stunText = Instance.new("TextLabel")
    stunText.Size = UDim2.new(1, 0, 1, 0)
    stunText.BackgroundTransparency = 1
    stunText.Font = Enum.Font.GothamBold
    stunText.TextSize = 36
    stunText.TextColor3 = Color3.fromRGB(255, 50, 50)
    stunText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    stunText.TextStrokeTransparency = 0
    stunText.Text = "💫"
    stunText.Parent = stunIcon

    -- Анимация вращения
    local RunService = game:GetService("RunService")
    local t = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        t = t + dt
        stunIcon.Rotation = math.sin(t * 5) * 15
    end)

    -- Удаляется через 2.5 сек
    game:GetService("Debris"):AddItem(stunIcon, 2.5)
    task.delay(2.5, function()
        conn:Disconnect()
    end)
end

return AnimationService
