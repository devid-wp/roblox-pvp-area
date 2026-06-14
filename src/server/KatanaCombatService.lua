-- KatanaCombatService.lua
-- Боевая система с катаной в стиле Sekiro
-- Акцент на парировании, стойке (posture), контратаках

local KatanaCombatService = {}
local CombatConfig = require(script.Parent.Parent.Shared.CombatConfig)

-- Состояние боя для каждого игрока
local combatState = {}

function KatanaCombatService.InitPlayer(player)
    combatState[player.UserId] = {
        Health = CombatConfig.MaxHealth,
        Posture = 0,                              -- стойка (0-100, при 100 — оглушение)
        ComboCount = 0,
        LastAttackTime = 0,
        IsBlocking = false,
        IsParrying = false,                       -- окно парирования
        LastBlockTime = 0,
        LastParrySuccess = 0,
        StunnedUntil = 0,                         -- время оглушения
    }
end

-- Лёгкий удар
function KatanaCombatService.LightAttack(player, targetPlayer)
    local state = combatState[player.UserId]
    if not state then return end

    local now = tick()
    if now - state.LastAttackTime < CombatConfig.Katana.AttackCooldown then return end
    if now < state.StunnedUntil then return end -- оглушён, бить нельзя

    state.ComboCount = math.min(state.ComboCount + 1, CombatConfig.Katana.MaxCombo)
    state.LastAttackTime = now

    local damage = CombatConfig.Katana.LightDamage * (1 + (state.ComboCount - 1) * (CombatConfig.Katana.ComboMultiplier - 1))

    if targetPlayer and KatanaCombatService.IsInRange(player, targetPlayer) then
        KatanaCombatService.ApplyDamage(targetPlayer, damage, "Light")
    end

    return damage
end

-- Тяжёлый удар
function KatanaCombatService.HeavyAttack(player, targetPlayer)
    local state = combatState[player.UserId]
    if not state then return end
    if tick() < state.StunnedUntil then return end

    state.ComboCount = 0 -- тяжёлый удар сбрасывает комбо
    state.LastAttackTime = tick()

    if targetPlayer and KatanaCombatService.IsInRange(player, targetPlayer) then
        KatanaCombatService.ApplyDamage(targetPlayer, CombatConfig.Katana.HeavyDamage, "Heavy")
    end
end

-- Блок
function KatanaCombatService.StartBlock(player)
    local state = combatState[player.UserId]
    if state then state.IsBlocking = true end
end

function KatanaCombatService.StopBlock(player)
    local state = combatState[player.UserId]
    if state then
        state.IsBlocking = false
        state.LastBlockTime = tick()
    end
end

-- Парирование (как в Sekiro — точно в момент удара)
function KatanaCombatService.TryParry(player, incomingAttackTime)
    local state = combatState[player.UserId]
    if not state then return false end

    -- Время реакции: удар должен попасть в окно парирования
    local diff = math.abs(incomingAttackTime - tick())
    if diff <= CombatConfig.Katana.ParryWindow and state.IsBlocking then
        state.LastParrySuccess = tick()
        state.Posture = 0 -- парирование сбрасывает свою стойку
        return true
    end
    return false
end

-- Получение урона с учётом блока/парирования
function KatanaCombatService.ApplyDamage(targetPlayer, damage, attackType)
    local state = combatState[targetPlayer.UserId]
    if not state then return end

    local finalDamage = damage
    local postureDamage = CombatConfig.Katana.PostureDamage

    if state.IsBlocking then
        finalDamage = damage * (1 - CombatConfig.Katana.BlockReduction)
        postureDamage = postureDamage * 1.5 -- блок повышает стойку самого блокирующего
    end

    state.Health = math.max(0, state.Health - finalDamage)
    state.Posture = math.min(CombatConfig.Katana.MaxPosture, state.Posture + postureDamage)

    -- Стойка переполнена — оглушение
    if state.Posture >= CombatConfig.Katana.MaxPosture then
        state.StunnedUntil = tick() + 2.5 -- 2.5 сек оглушения, как в Sekiro
        state.Posture = 0
    end
end

function KatanaCombatService.IsInRange(player, targetPlayer, range)
    range = range or 10 -- ближняя дистанция катаны
    if not player.Character or not targetPlayer.Character then return false end
    local p1 = player.Character:FindFirstChild("HumanoidRootPart")
    local p2 = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not p1 or not p2 then return false end
    return (p1.Position - p2.Position).Magnitude <= range
end

function KatanaCombatService.GetState(player)
    return combatState[player.UserId]
end

function KatanaCombatService.Cleanup(player)
    combatState[player.UserId] = nil
end

return KatanaCombatService
