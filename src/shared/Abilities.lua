-- Abilities.lua
-- Модуль способностей/перков

local Abilities = {}

-- Список всех способностей
Abilities.List = {
    {
        Id = "Dash",
        Name = "Рывок",
        Description = "Мгновенный рывок вперёд на 30 стадов",
        Cooldown = 5,
        Type = "Movement",
    },
    {
        Id = "Heal",
        Name = "Регенерация",
        Description = "Восстанавливает 30 HP",
        Cooldown = 15,
        Type = "Support",
    },
    {
        Id = "DoubleJump",
        Name = "Двойной прыжок",
        Description = "Дополнительный прыжок в воздухе",
        Cooldown = 0,
        Type = "Movement",
    },
    {
        Id = "Shield",
        Name = "Щит",
        Description = "Поглощает 50% урона на 3 секунды",
        Cooldown = 20,
        Type = "Defense",
    },
}

function Abilities.GetById(id)
    for _, ability in ipairs(Abilities.List) do
        if ability.Id == id then
            return ability
        end
    end
    return nil
end

return Abilities
