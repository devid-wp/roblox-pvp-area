-- MatchService.lua
-- Управление матчами 1v1 + подключение UI/анимаций

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local MatchService = {}
local KatanaCombatService = require(script.Parent.KatanaCombatService)
local GrapplingHookService = require(script.Parent.GrapplingHookService)
local AnimationService = require(script.Parent.AnimationService)

local queue = {}
local activeMatches = {}

-- Инициализация игрока при входе
Players.PlayerAdded:Connect(function(player)
    KatanaCombatService.InitPlayer(player)
    GrapplingHookService.Init(player)
    AnimationService.InitPlayer(player)

    player.CharacterAdded:Connect(function()
        KatanaCombatService.InitPlayer(player)
        GrapplingHookService.Init(player)
        AnimationService.InitPlayer(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    KatanaCombatService.Cleanup(player)
    GrapplingHookService.Cleanup(player)
    AnimationService.Cleanup(player)
    MatchService.RemoveFromQueue(player)
end)

function MatchService.AddToQueue(player)
    if player and not table.find(queue, player) then
        table.insert(queue, player)
        print(player.Name .. " добавлен в очередь")
        MatchService.TryStartMatch()
    end
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
        local match = {
            Id = matchId,
            Player1 = p1,
            Player2 = p2,
            Player1Score = 0,
            Player2Score = 0,
            CurrentRound = 1,
            StartTime = tick(),
        }
        activeMatches[matchId] = match
        print("Матч создан: " .. p1.Name .. " vs " .. p2.Name)
        MatchService.StartRound(match)
    end
end

function MatchService.StartRound(match)
    -- TODO: телепортировать на арену, отсчёт 3-2-1
    print("Раунд " .. match.CurrentRound .. " начался!")
end

function MatchService.EndRound(match, winner)
    if winner == match.Player1 then
        match.Player1Score = match.Player1Score + 1
    else
        match.Player2Score = match.Player2Score + 1
    end
    print("Победил раунд: " .. winner.Name)
    print("Счёт: " .. match.Player1Score .. " - " .. match.Player2Score)
end

return MatchService
