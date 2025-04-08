Citizen.Wait(500)

print("[Chat][Server] server.lua yukleniyor... Framework turu: " .. type(Framework))

local function DebugPrint(message)
    if Config.EnableDebugLogs then
        print(message)
    end
end

local QBCore = exports['qb-core']:GetCoreObject()

local registeredCommands = {}

local function RefreshCommandList()
    registeredCommands = GetRegisteredCommands()
    DebugPrint("[Chat][DEBUG] Kayitli komut listesi yenilendi (" .. #registeredCommands .. " komut).")
    TriggerClientEvent('oekxc-chat:updateCommandList', -1, registeredCommands)
end

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    RefreshCommandList()
end)

Config = Config or {}
Config.OOCPrefix = "[OOC]"
Config.MePrefix = "*"
Config.DoPrefix = "*"
Config.DefaultPrefix = ""
Config.Colors = Config.Colors or {}
Config.Colors.default = Config.Colors.default or "white"
Config.Colors.ooc = Config.Colors.ooc or "red"
Config.Colors.me = Config.Colors.me or "green"
Config.Colors.doCmd = Config.Colors.doCmd or "blue"
Config.Colors.error = Config.Colors.error or "red"
Config.Colors.mention = Config.Colors.mention or "yellow"
Config.PmHataPrefix = Config.PmHataPrefix or "[HATA]"
Config.EnableProfanityFilter = Config.EnableProfanityFilter == nil or Config.EnableProfanityFilter
Config.BlockedWords = Config.BlockedWords or {}
Config.ProfanityReplacement = Config.ProfanityReplacement or "***"
Config.MaxMessageLength = Config.MaxMessageLength or 128
Config.EnableHeadUI = Config.EnableHeadUI == nil or Config.EnableHeadUI
Config.HeadUIDuration = Config.HeadUIDuration or 7000
Config.HeadUIDistance = Config.HeadUIDistance or 15.0
Config.HeadUIOffsetY = Config.HeadUIOffsetY or 0.7
Config.EnableOOC = Config.EnableOOC == nil or Config.EnableOOC
Config.AllowNormalChat = Config.AllowNormalChat == nil and false or Config.AllowNormalChat
Config.PoliceCommand = Config.PoliceCommand or "p"
Config.DuyuruCommand = Config.DuyuruCommand or "duyuru"

local function SendClientMessage(target, message, color)
    TriggerClientEvent('oekxc-chat:mesajEkle', target, message, color)
end

RegisterServerEvent('oekxc-chat:mesajGonder')
AddEventHandler('oekxc-chat:mesajGonder', function(mesaj)
    local source = source
    local playerName = Framework.GetPlayerName(source)
    if playerName == "Bilinmeyen" then
       DebugPrint("[Chat][Server][HATA] Oyuncu adi alinamadi. Source: " .. source)
       return
    end
    local originalMesaj = mesaj

    DebugPrint("[Chat][DEBUG] Mesaj Alindi - Kaynak: " .. source .. " Mesaj: '" .. mesaj .. "'")

    if Config.MaxMessageLength > 0 and string.len(mesaj) > Config.MaxMessageLength then
        SendClientMessage(source, Config.PmHataPrefix .. " Mesajınız çok uzun! (Maks: " .. Config.MaxMessageLength .. " karakter)", Config.Colors.error)
        return
    end

    DebugPrint("[Chat][DEBUG][Filter] Filtreleme Başlıyor. EnableProfanityFilter: " .. tostring(Config.EnableProfanityFilter))
    if Config.EnableProfanityFilter then
        DebugPrint("[Chat][DEBUG][Filter] BlockedWords içeriği: " .. table.concat(Config.BlockedWords or {}, ", "))
        local originalMesajForFilter = mesaj
        for i, word in ipairs(Config.BlockedWords) do
            local beforeReplace = mesaj
            mesaj = string.gsub(mesaj, "(?i)" .. word, Config.ProfanityReplacement)
            if beforeReplace ~= mesaj then
                 DebugPrint(string.format("[Chat][DEBUG][Filter] Kelime '%s' değiştirildi. Önce: '%s' Sonra: '%s'", word, beforeReplace, mesaj))
            end
        end
        if originalMesajForFilter == mesaj then
             DebugPrint("[Chat][DEBUG][Filter] Mesajda engellenen kelime bulunamadı veya değiştirilemedi.")
        end
    end

    local prefix = Config.DefaultPrefix
    local formatliMesaj = ""
    local renk = Config.Colors.default
    local komutBuScriptteIsledi = false

    if string.sub(mesaj, 1, 5) == "/ooc " then
        if not Config.EnableOOC then
            SendClientMessage(source, Config.PmHataPrefix .. " OOC chat su anda devre disi.", Config.Colors.error)
            return
        end
        komutBuScriptteIsledi = true
        DebugPrint("[Chat][DEBUG] /ooc komutu algilandi.")
        prefix = Config.OOCPrefix
        mesaj = string.sub(mesaj, 6)
        renk = Config.Colors.ooc
        formatliMesaj = prefix .. " [" .. source .. "] " .. playerName .. ": " .. mesaj
    elseif string.sub(mesaj, 1, 4) == "/me " then
        komutBuScriptteIsledi = true
        DebugPrint("[Chat][DEBUG] /me komutu algilandi.")
        prefix = Config.MePrefix
        mesaj = string.sub(mesaj, 5)
        renk = Config.Colors.me

        local mesajEtiketli3D = mesaj:gsub("@(%d+)", function(etiketId)
            etiketId = tonumber(etiketId)
            if etiketId then
                local etiketlenenOyuncuAdi = Framework.GetPlayerName(etiketId)
                if etiketlenenOyuncuAdi ~= "Bilinmeyen" then
                    return "@" .. etiketlenenOyuncuAdi
                end
            end
            return "@" .. (etiketId or "?")
        end)
        DebugPrint(string.format("[Chat][DEBUG] /me - Orijinal mesaj: '%s', 3D için etiketli: '%s'", mesaj or "NIL", mesajEtiketli3D or "NIL"))

        formatliMesaj = "[ME] " .. prefix .. " " .. playerName .. " " .. mesaj .. "."
        if Config.EnableHeadUI then
            DebugPrint(string.format("[Chat][DEBUG] /me - showHeadUI eventine gönderilen text: '%s'", mesajEtiketli3D or "NIL"))
            TriggerClientEvent('oekxc-chat:showHeadUI', -1, source, mesajEtiketli3D, "me")
        end
    elseif string.sub(mesaj, 1, 4) == "/do " then
        komutBuScriptteIsledi = true
        DebugPrint("[Chat][DEBUG] /do komutu algilandi.")
        prefix = Config.DoPrefix
        mesaj = string.sub(mesaj, 5)
        renk = Config.Colors.doCmd

        local mesajEtiketli3D = mesaj:gsub("@(%d+)", function(etiketId)
             etiketId = tonumber(etiketId)
            if etiketId then
                local etiketlenenOyuncuAdi = Framework.GetPlayerName(etiketId)
                if etiketlenenOyuncuAdi ~= "Bilinmeyen" then
                    return "@" .. etiketlenenOyuncuAdi
                end
            end
            return "@" .. (etiketId or "?")
        end)
        DebugPrint(string.format("[Chat][DEBUG] /do - Orijinal mesaj: '%s', 3D için etiketli: '%s'", mesaj or "NIL", mesajEtiketli3D or "NIL"))

        formatliMesaj = "[DO] " .. prefix .. " " .. playerName .. " " .. mesaj .. "."
        if Config.EnableHeadUI then
            DebugPrint(string.format("[Chat][DEBUG] /do - showHeadUI eventine gönderilen text: '%s'", mesajEtiketli3D or "NIL"))
            TriggerClientEvent('oekxc-chat:showHeadUI', -1, source, mesajEtiketli3D, "do")
        end
    elseif Config.DuyuruCommand and Config.DuyuruCommand ~= "" and string.sub(mesaj, 1, string.len(Config.DuyuruCommand) + 2) == "/" .. Config.DuyuruCommand .. " " then
        komutBuScriptteIsledi = true
        DebugPrint("[Chat][DEBUG] /" .. Config.DuyuruCommand .. " komutu algilandi.")
        if not Framework.HasGroup(source, Config.AdminGroupName) then
             SendClientMessage(source, Config.PmHataPrefix .. " Bu komutu kullanma yetkiniz yok.", Config.Colors.error)
             return
        end

        prefix = Config.DuyuruPrefix or "[DUYURU]"
        mesaj = string.sub(mesaj, string.len(Config.DuyuruCommand) + 3)
        renk = Config.Colors.admin
        formatliMesaj = prefix .. " " .. mesaj

        SendClientMessage(-1, formatliMesaj, renk)
        DebugPrint("DUYURU: " .. source .. ": " .. mesaj)
        return
    end

    if not komutBuScriptteIsledi then
        if string.sub(originalMesaj, 1, 1) == "/" then
            DebugPrint("[Chat][DEBUG] Bilinmeyen komut algilandi: " .. originalMesaj .. " - İstemciye calistirmasi icin gonderiliyor.")
            local komutString = string.sub(originalMesaj, 2)
            TriggerClientEvent('oekxc-chat:executeUnknownCommand', source, komutString)
            return
        else
            if not Config.AllowNormalChat then
                SendClientMessage(source, Config.PmHataPrefix .. " Komutsuz mesaj gonderemezsiniz. Gecerli bir komut kullanin.", Config.Colors.error)
                return
            else
                DebugPrint("[Chat][DEBUG] Normal mesaj algilandi (izinli).")
                renk = Config.Colors.default
                formatliMesaj = "[" .. source .. "] " .. playerName .. ": " .. mesaj
                komutBuScriptteIsledi = true
            end
        end
    end

    if not komutBuScriptteIsledi then
       return
    end

    if mesaj == "" or mesaj == nil then
        DebugPrint("[Chat][DEBUG] Mesaj içerigi bos, gonderilmiyor.")
        return
    end

    local etiketlenenler = {}
    local etiketliMesajNUI = formatliMesaj:gsub("@(%d+)", function(etiketId)
        etiketId = tonumber(etiketId)
        if etiketId then
            local etiketlenenOyuncuAdi = Framework.GetPlayerName(etiketId)
            if etiketlenenOyuncuAdi ~= "Bilinmeyen" then
                if not etiketlenenler[etiketId] then
                    table.insert(etiketlenenler, etiketId)
                    etiketlenenler[etiketId] = true
                end
                return "<span style='color:" .. Config.Colors.mention .. ";'>@" .. etiketlenenOyuncuAdi .. "</span>"
            else
                return "@" .. etiketId
            end
        end
        return "@" .. etiketId
    end)

    DebugPrint("[Chat][DEBUG] Gonderilecek Mesaj (NUI): '" .. etiketliMesajNUI .. "' Renk: " .. renk)
    TriggerClientEvent('oekxc-chat:mesajEkle', -1, etiketliMesajNUI, renk)

    for _, etiketlenenId in pairs(etiketlenenler) do
        if etiketlenenId ~= source then
            DebugPrint("[Chat][DEBUG] Etiket bildirimi gönderiliyor: ID " .. etiketlenenId)
            TriggerClientEvent('oekxc-chat:etiketBildirimi', etiketlenenId, playerName)
        end
    end

    DebugPrint(formatliMesaj)
end)

RegisterServerEvent('oekxc-chat:getConfig')
AddEventHandler('oekxc-chat:getConfig', function()
    local source = source
    DebugPrint("[Chat][DEBUG] getConfig istegi alindi: " .. source)
    TriggerClientEvent('oekxc-chat:configUpdate', source, Config)
end)

RegisterServerEvent('oekxc-chat:getCommands')
AddEventHandler('oekxc-chat:getCommands', function()
    local source = source
    DebugPrint("[Chat][DEBUG] getCommands istegi alindi: " .. source)
    TriggerClientEvent('oekxc-chat:updateCommandList', source, registeredCommands)
end)

RegisterServerEvent('oekxc-chat:debugMessage')
AddEventHandler('oekxc-chat:debugMessage', function(message)
    DebugPrint("[Chat][Client][DEBUG] " .. message)
end)