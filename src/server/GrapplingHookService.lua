-- GrapplingHookService.lua
-- Руко-хват в стиле Sekiro: захват за ветки, столбы, края арены

local GrapplingHookService = {}
local CombatConfig = require(script.Parent.Parent.Shared.CombatConfig)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Состояние игрока
local playerState = {}

function GrapplingHookService.Init(player)
    playerState[player.UserId] = {
        LastHookTime = 0,
        IsHooking = false,
        HookTarget = nil,
        VerticalMomentum = 0,
        MidAirHooks = 0,
    }
end

-- Проверка, доступен ли руко-хват
function GrapplingHookService.CanHook(player)
    local state = playerState[player.UserId]
    if not state then return false end

    local now = tick()
    local baseCD = CombatConfig.GrapplingHook.Cooldown
    local isInAir = GrapplingHookService.IsInAir(player)

    -- В воздухе перехват стоит дороже
    local extraCD = isInAir and CombatConfig.GrapplingHook.MidAirJumpCost or 0

    return (now - state.LastHookTime) >= (baseCD + extraCD)
end

-- Выстрелить руко-хват
function GrapplingHookService.FireHook(player, targetPos)
    local state = playerState[player.UserId]
    if not state or not GrapplingHookService.CanHook(player) then return false end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end

    local rootPart = character.HumanoidRootPart
    local distance = (targetPos - rootPart.Position).Magnitude

    if distance > CombatConfig.GrapplingHook.Range then
        return false -- слишком далеко
    end

    state.IsHooking = true
    state.HookTarget = targetPos
    state.LastHookTime = tick()

    if GrapplingHookService.IsInAir(player) then
        state.MidAirHooks = state.MidAirHooks + 1
    end

    -- Запускаем анимацию притягивания
    GrapplingHookService.StartPull(player, targetPos)
    return true
end

-- Притягивание к точке
function GrapplingHookService.StartPull(player, targetPos)
    local character = player.Character
    local rootPart = character.HumanoidRootPart

    local pullConn
    pullConn = RunService.Heartbeat:Connect(function()
        if not character or not rootPart.Parent then
            pullConn:Disconnect()
            return
        end

        local direction = (targetPos - rootPart.Position).Unit
        local newPos = rootPart.Position + direction * CombatConfig.GrapplingHook.PullSpeed * 0.03
        rootPart.CFrame = CFrame.new(newPos)

        -- Достигли цели
        if (targetPos - rootPart.Position).Magnitude < 5 then
            pullConn:Disconnect()
            playerState[player.UserId].IsHooking = false
            playerState[player.UserId].HookTarget = nil
        end
    end)
end

function GrapplingHookService.IsInAir(player)
    local character = player.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    return rootPart.Position.Y > CombatConfig.Arena.FloorHeight + 2
end

function GrapplingHookService.GetRemainingCooldown(player)
    local state = playerState[player.UserId]
    if not state then return 0 end
    local now = tick()
    local elapsed = now - state.LastHookTime
    return math.max(0, CombatConfig.GrapplingHook.Cooldown - elapsed)
end

function GrapplingHookService.Cleanup(player)
    playerState[player.UserId] = nil
end

return GrapplingHookService
