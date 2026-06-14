-- InputService.lua (Client)
-- Клиентский скрипт: прицеливание и активация руко-хвата

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

-- Remote Event для отправки хука на сервер
local HookEvent = ReplicatedStorage:WaitForChild("HookEvent")

-- Настройки
local MAX_HOOK_RANGE = 80
local AIM_RAY_DISTANCE = 200
local isAiming = false
local lastHookTime = 0
local HOOK_COOLDOWN = 4

-- Создаём визуал прицела (точка прицеливания)
local aimMarker = Instance.new("Part")
aimMarker.Name = "AimMarker"
aimMarker.Shape = Enum.PartType.Ball
aimMarker.Size = Vector3.new(1.5, 1.5, 1.5)
aimMarker.Material = Enum.Material.Neon
aimMarker.Color = Color3.fromRGB(255, 200, 100)
aimMarker.Transparency = 0.3
aimMarker.Anchored = true
aimMarker.CanCollide = false
aimMarker.Parent = workspace

-- Луч от камеры к точке прицеливания
local hookBeam = Instance.new("Part")
hookBeam.Name = "HookBeam"
hookBeam.Size = Vector3.new(0.2, 0.2, 0.2)
hookBeam.Material = Enum.Material.Neon
hookBeam.Color = Color3.fromRGB(200, 150, 50)
hookBeam.Anchored = true
hookBeam.CanCollide = false
hookBeam.Parent = workspace

aimMarker.Transparency = 1
hookBeam.Transparency = 1

-- Включение/выключение прицеливания
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if isAiming then
            isAiming = false
            TryFireHook()
        end
    end
end)

-- Попытка выстрелить руко-хват
function TryFireHook()
    local now = tick()
    if now - lastHookTime < HOOK_COOLDOWN then
        -- На КД, показываем индикатор
        return
    end

    local targetPos = GetHookTarget()
    if targetPos then
        lastHookTime = now
        HookEvent:FireServer(targetPos)

        -- Визуал выстрела (кратковременный)
        ShowHookAnimation(targetPos)
    end
end

-- Получить точку захвата (ищет ближайшую ветку/колонну в прицеле)
function GetHookTarget()
    local origin = camera.CFrame.Position
    local direction = mouse.Hit.Position - origin
    local distance = math.min(direction.Magnitude, AIM_RAY_DISTANCE)
    direction = direction.Unit

    -- Raycast для определения, на что смотрит игрок
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character, aimMarker, hookBeam}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = workspace:Raycast(origin, direction * distance, raycastParams)

    if result and result.Instance then
        local name = result.Instance.Name
        if name:find("GrappleBranch") or name:find("Pillar") or name:find("TempleWall") then
            return result.Position
        end
    end

    return nil
end

-- Обновление прицела каждый кадр
RunService.RenderStepped:Connect(function()
    if isAiming then
        local target = GetHookTarget()
        if target then
            -- Показываем маркер на цели
            aimMarker.Position = target
            aimMarker.Transparency = 0.3

            -- Луч от игрока к цели
            local origin = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if origin then
                local dist = (target - origin.Position).Magnitude
                if dist <= MAX_HOOK_RANGE then
                    -- Зелёный — можно хватануть
                    aimMarker.Color = Color3.fromRGB(100, 255, 100)
                    hookBeam.Color = Color3.fromRGB(100, 255, 100)
                else
                    -- Красный — слишком далеко
                    aimMarker.Color = Color3.fromRGB(255, 100, 100)
                    hookBeam.Color = Color3.fromRGB(255, 100, 100)
                end

                -- Обновляем луч
                local mid = (origin.Position + target) / 2
                hookBeam.Size = Vector3.new(0.2, 0.2, dist)
                hookBeam.CFrame = CFrame.lookAt(mid, target)
                hookBeam.Transparency = 0.5
            end
        else
            aimMarker.Transparency = 1
            hookBeam.Transparency = 1
        end
    else
        aimMarker.Transparency = 1
        hookBeam.Transparency = 1
    end
end)

-- Визуал выстрела (цепь руко-хвата)
function ShowHookAnimation(targetPos)
    local origin = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not origin then return end

    local beam = Instance.new("Part")
    beam.Size = Vector3.new(0.3, 0.3, 5)
    beam.Material = Enum.Material.Neon
    beam.Color = Color3.fromRGB(200, 150, 50)
    beam.Anchored = true
    beam.CanCollide = false
    beam.Parent = workspace

    -- Анимация: луч исчезает за 0.3 сек
    local startTick = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local t = (tick() - startTick) / 0.3
        if t >= 1 then
            beam:Destroy()
            conn:Disconnect()
            return
        end
        local dist = (targetPos - origin.Position).Magnitude
        beam.Size = Vector3.new(0.3, 0.3, dist)
        beam.CFrame = CFrame.lookAt(origin.Position, targetPos)
        beam.Transparency = t
    end)
end
