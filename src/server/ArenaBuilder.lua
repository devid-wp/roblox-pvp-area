-- ArenaBuilder.lua
-- Строитель арены: круглая, высокая, разрушенный храм с ветками
-- ВАЖНО: запускать в Roblox Studio, код создаёт Part'ы программно

local ArenaBuilder = {}
local CombatConfig = require(script.Parent.Parent.Shared.CombatConfig)

function ArenaBuilder.Build(parent)
    local arena = Instance.new("Folder", parent)
    arena.Name = "PvPArena_Sekiro"

    -- === Главный пол (круглый) ===
    ArenaBuilder.BuildMainFloor(arena)

    -- === Колонны храма (разрушенные) ===
    ArenaBuilder.BuildPillars(arena)

    -- === Ветки для руко-хвата ===
    ArenaBuilder.BuildBranches(arena)

    -- === Стены/балконы ===
    ArenaBuilder.BuildWalls(arena)

    -- === Декорации (статуи, обломки) ===
    ArenaBuilder.BuildDecor(arena)

    -- === Зона смерти (под ареной) ===
    ArenaBuilder.BuildDeathZone(arena)

    return arena
end

-- Главный круглый пол
function ArenaBuilder.BuildMainFloor(parent)
    local floor = Instance.new("Part")
    floor.Name = "ArenaFloor"
    floor.Shape = Enum.PartType.Cylinder
    floor.Size = Vector3.new(10, CombatConfig.Arena.Radius * 2, CombatConfig.Arena.Radius * 2)
    floor.CFrame = CFrame.new(0, CombatConfig.Arena.FloorHeight, 0) * CFrame.Angles(0, 0, math.rad(90))
    floor.Anchored = true
    floor.Material = Enum.Material.Slate
    floor.Color = Color3.fromRGB(80, 70, 60)
    floor.Parent = parent

    -- Текстура трещин (через Decal/Texture)
    local texture = Instance.new("Texture", floor)
    texture.Texture = "rbxassetid://0000000"  -- TODO: заменить на текстуру трещин
    texture.Face = Enum.NormalId.Top
end

-- Разрушенные колонны храма
function ArenaBuilder.BuildPillars(parent)
    for i = 1, CombatConfig.Arena.PillarCount do
        local angle = (i - 1) * (2 * math.pi / CombatConfig.Arena.PillarCount)
        local x = math.cos(angle) * (CombatConfig.Arena.Radius - 15)
        local z = math.sin(angle) * (CombatConfig.Arena.Radius - 15)

        local pillar = Instance.new("Part")
        pillar.Name = "Pillar_" .. i
        pillar.Shape = Enum.PartType.Cylinder
        pillar.Size = Vector3.new(40, 5, 5) -- высокая, тонкая
        pillar.CFrame = CFrame.new(x, CombatConfig.Arena.FloorHeight + 20, z) * CFrame.Angles(0, 0, math.rad(90))
        pillar.Anchored = true
        pillar.Material = Enum.Material.Stone
        pillar.Color = Color3.fromRGB(100, 95, 85)
        pillar.Parent = parent

        -- Некоторые колонны "разрушены" (случайная высота)
        if i % 2 == 0 then
            pillar.Size = Vector3.new(15 + math.random(0, 20), 5, 5) -- разная высота
        end
    end
end

-- Ветки для руко-хвата
function ArenaBuilder.BuildBranches(parent)
    for i = 1, CombatConfig.Arena.BranchCount do
        local angle = math.random() * 2 * math.pi
        local radius = math.random(20, CombatConfig.Arena.Radius - 10)
        local x = math.cos(angle) * radius
        local z = math.sin(angle) * radius
        local y = CombatConfig.Arena.FloorHeight + math.random(15, 60)

        local branch = Instance.new("Part")
        branch.Name = "GrappleBranch_" .. i
        branch.Size = Vector3.new(math.random(6, 12), 1, 1)
        branch.CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, math.random() * math.pi, 0)
        branch.Anchored = true
        branch.Material = Enum.Material.Wood
        branch.Color = Color3.fromRGB(60, 40, 25)
        branch.Parent = parent

        -- Визуальный маркер (светящийся) для обозначения точки захвата
        local highlight = Instance.new("SelectionBox", branch)
        highlight.Adornee = branch
        highlight.Color3 = Color3.fromRGB(255, 200, 100)
        highlight.LineThickness = 0.1
    end
end

-- Стены/балконы храма
function ArenaBuilder.BuildWalls(parent)
    for i = 1, 8 do
        local angle = (i - 1) * (2 * math.pi / 8)
        local x = math.cos(angle) * CombatConfig.Arena.Radius
        local z = math.sin(angle) * CombatConfig.Arena.Radius

        local wall = Instance.new("Part")
        wall.Name = "TempleWall_" .. i
        wall.Size = Vector3.new(30, 15, 3)
        wall.CFrame = CFrame.new(x, CombatConfig.Arena.FloorHeight + 7, z) * CFrame.Angles(0, -angle + math.pi/2, 0)
        wall.Anchored = true
        wall.Material = Enum.Material.Stone
        wall.Color = Color3.fromRGB(90, 80, 70)
        wall.Parent = parent

        -- Случайные разрушения (дыры в стене)
        if i % 3 == 0 then
            wall.Transparency = 0.4 -- полуразрушенная
        end
    end
end

-- Декорации: статуи, обломки, фонари
function ArenaBuilder.BuildDecor(parent)
    for i = 1, 4 do
        local angle = i * (2 * math.pi / 4) + math.pi/4
        local x = math.cos(angle) * 40
        local z = math.sin(angle) * 40

        -- Статуя Будды/самурая
        local statue = Instance.new("Part")
        statue.Name = "Statue_" .. i
        statue.Size = Vector3.new(4, 12, 4)
        statue.CFrame = CFrame.new(x, CombatConfig.Arena.FloorHeight + 6, z)
        statue.Anchored = true
        statue.Material = Enum.Material.Marble
        statue.Color = Color3.fromRGB(200, 195, 180)
        statue.Shape = Enum.PartType.Block
        statue.Parent = parent
    end
end

-- Зона смерти под ареной
function ArenaBuilder.BuildDeathZone(parent)
    local killPart = Instance.new("Part")
    killPart.Name = "DeathZone"
    killPart.Size = Vector3.new(CombatConfig.Arena.Radius * 3, 1, CombatConfig.Arena.Radius * 3)
    killPart.Position = Vector3.new(0, CombatConfig.Arena.DeathZoneY, 0)
    killPart.Anchored = true
    killPart.Transparency = 1 -- невидимая
    killPart.CanCollide = false
    killPart.Parent = parent

    -- Если игрок падает ниже арены — смерть
    killPart.Touched:Connect(function(hit)
        local humanoid = hit.Parent:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end)
end

return ArenaBuilder
