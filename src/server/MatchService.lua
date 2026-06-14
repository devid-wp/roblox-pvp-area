-- MatchService.lua
-- Управление матчами 1v1
-- TODO: реализовать логику

local MatchService = {}

local queue = {}        -- очередь игроков
local activeMatches = {} -- активные матчи

function MatchService.AddToQueue(player)
    table.insert(queue, player)
    print(player.Name .. " добавлен в очередь")
end

function MatchService.RemoveFromQueue(player)
    for i, p in ipairs(queue) do
        if p == player then
            table.remove(queue, i)
            break
        end
    end
end

function MatchService.TryStartMatch()
    if #queue >= 2 then
        local p1 = table.remove(queue, 1)
        local p2 = table.remove(queue, 1)
        local matchId = #activeMatches + 1
        -- TODO: создать матч, телепортировать игроков на арену
        print("Матч создан: " .. p1.Name .. " vs " .. p2.Name)
    end
end

return MatchService
