-- Constants.lua
-- Общие константы проекта

local Constants = {}

-- Игра
Constants.GameName = "PvP Arena 1v1"
Constants.Version = "0.1.0"

-- Игроки
Constants.MaxPlayersPerServer = 20
Constants.QueueUpdateInterval = 1  -- секунды

-- Матч
Constants.RoundCountdown = 3        -- отсчёт перед раундом
Constants.MaxRoundTime = 120        -- макс. время раунда (2 мин)
Constants.WinScoreToWin = 3         -- сколько побед нужно для победы в матче

-- Elo рейтинг
Constants.StartingElo = 1000
Constants.EloKFactor = 32

return Constants
