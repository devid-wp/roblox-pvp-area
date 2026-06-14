-- CombatConfig.lua
-- Настройки боевой системы в стиле Sekiro

local CombatConfig = {}

-- Здоровье
CombatConfig.MaxHealth = 100
CombatConfig.RegenPerSecond = 1  -- медленная регенерация, как в секиро

-- Катана (ближний бой — основа игры)
CombatConfig.Katana = {
    LightDamage = 18,           -- лёгкий удар
    HeavyDamage = 35,           -- тяжёлый удар
    ComboMultiplier = 1.15,     -- множитель за каждый комбо-удар
    MaxCombo = 4,
    AttackCooldown = 0.35,      -- секунды между ударами
    BlockReduction = 0.7,       -- 70% урона блокируется
    ParryWindow = 0.25,         -- окно парирования (timing как в Sekiro)
    PostureDamage = 10,         -- урон по стойке/позе
    MaxPosture = 100,           -- при заполнении — оглушение
}

-- Дальний бой (второстепенный — метательные сюрикены/ножи)
CombatConfig.Ranged = {
    ShurikenDamage = 12,
    ShurikenCount = 5,          -- кол-во за раунд
    ShurikenCooldown = 1.0,
    HeadshotMultiplier = 1.5,
}

-- Руко-хват (главная фишка в стиле Sekiro)
CombatConfig.GrapplingHook = {
    Range = 80,                 -- дальность (стады)
    PullSpeed = 60,             -- скорость притягивания
    VerticalBoost = 40,         -- подъём вверх за один hook
    Cooldown = 4,               -- КД в секундах
    MaxRangeUp = 120,           -- макс. высота подъёма
    RegrabWindow = 0.5,         -- окно повторного захвата в воздухе
    MidAirJumpCost = 2,         -- доп. кулдаун за перехват в воздухе
}

-- Способности (паркур + боевые приёмы)
CombatConfig.Abilities = {
    DoubleJump = {Cooldown = 0},              -- бесплатный двойной прыжок
    WallRun = {Cooldown = 0, Duration = 1.5}, -- бег по стене
    AirDash = {Cooldown = 3, Distance = 25},  -- рывок в воздухе
    MikiriCounter = {Cooldown = 8},           -- контратака против тяжёлого удара
}

-- Арена
CombatConfig.Arena = {
    Radius = 150,                 -- радиус круглой арены
    FloorHeight = 80,             -- высота над "пропастью"
    BranchCount = 25,             -- кол-во веток для руко-хвата
    PillarCount = 6,              -- кол-во колонн храма
    DeathZoneY = -20,             -- ниже этой высоты — проигрыш
}

return CombatConfig
