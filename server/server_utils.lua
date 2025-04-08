Framework = {}
ESX = nil
QBCore = nil

local function DebugPrint(message)
    if Config.EnableDebugLogs then
        print(message)
    end
end

Citizen.CreateThread(function()
    DebugPrint("[Chat][Server] server_utils.lua yukleniyor... Framework: " .. Config.Framework)
    if Config.Framework == 'esx' then
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        print("[Chat] ESX Framework Algilandi.")
    elseif Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
        print("[Chat] QBCore Framework Algilandi.")
    else
        print("[Chat] Standalone Mod Aktif.")
    end
end)

function Framework.GetPlayerName(source)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.getName() or "Bilinmeyen"
    elseif Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and (Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname) or "Bilinmeyen"
    else
        return GetPlayerName(source) or "Bilinmeyen"
    end
end

function Framework.HasJob(source, jobName)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.job.name == jobName
    elseif Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.PlayerData.job.name == jobName
    else
        return false
    end
end

function Framework.HasGroup(source, groupName)
    if Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        return xPlayer and xPlayer.getGroup() == groupName
    elseif Config.Framework == 'qbcore' then
        local Player = QBCore.Functions.GetPlayer(source)
        return Player and Player.Functions.HasGroup(groupName)
    else
        return IsPlayerAceAllowed(source, "group." .. groupName)
    end
end

function Framework.GetPlayersWithJob(jobName)
    local playersWithJob = {}
    if Config.Framework == 'esx' then
        local players = ESX.GetPlayers()
        for i=1, #players do
            local xPlayer = ESX.GetPlayerFromId(players[i])
            if xPlayer and xPlayer.job.name == jobName then
                table.insert(playersWithJob, players[i])
            end
        end
    elseif Config.Framework == 'qbcore' then
        local players = QBCore.Functions.GetPlayers()
        for _, playerid in pairs(players) do
            local Player = QBCore.Functions.GetPlayer(playerid)
            if Player and Player.PlayerData.job.name == jobName then
                table.insert(playersWithJob, playerid)
            end
        end
    else
       playersWithJob = GetPlayers()
    end
    return playersWithJob
end

print("[Chat][Utils] server_utils.lua yuklendi. Framework tablosu turu: " .. type(Framework))