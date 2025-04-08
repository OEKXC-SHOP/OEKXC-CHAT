SetTextChatEnabled(false)

Config = Config or {}
Config.HeadUIDuration = Config.HeadUIDuration or 7000
Config.HeadUIDistance = Config.HeadUIDistance or 15.0
Config.HeadUIOffsetY = Config.HeadUIOffsetY or 0.7
Config.HeadUITextSize = Config.HeadUITextSize or 0.35
Config.HeadUITextFont = Config.HeadUITextFont or 4
Config.EnableOOC = Config.EnableOOC == nil or Config.EnableOOC
Config.Colors = Config.Colors or {}
Config.Colors.headUIMe = Config.Colors.headUIMe or { r = 193, g = 164, b = 224 }
Config.Colors.headUIDo = Config.Colors.headUIDo or { r = 164, g = 212, b = 224 }
Config.EnableDebugLogs = Config.EnableDebugLogs == nil and false or Config.EnableDebugLogs
Config.HeadUIMaxLines = Config.HeadUIMaxLines or 3
Config.HeadUIAlphaDecay = Config.HeadUIAlphaDecay or 0.6
Config.HeadUILineSpacing = Config.HeadUILineSpacing or 0.04

local function DebugPrint(message)
    if Config.EnableDebugLogs then
        print(message)
    end
end

local chatAcik = false
local idGoster = true
local headUiElements = {}
local allServerCommands = {}

RegisterNUICallback('kapat', function(data, cb)
    DebugPrint("[Chat][DEBUG][LUA] NUI Callback: /kapat alindi")
    SetNuiFocus(false, false)
    SetChatDurumu(false)
    cb('ok')
end)

RegisterNUICallback('mesajGonder', function(data, cb)
    local mesaj = data.message
    DebugPrint("[Chat][DEBUG][LUA] NUI Callback: /mesajGonder alindi. Mesaj: '" .. (mesaj or "nil") .. "'")
    if mesaj and mesaj ~= "" then
        DebugPrint("[Chat][DEBUG][LUA] TriggerServerEvent('oekxc-chat:mesajGonder') cagiriliyor...")
        TriggerServerEvent('oekxc-chat:mesajGonder', mesaj)
    else
        DebugPrint("[Chat][DEBUG][LUA] Mesaj bos veya nil, sunucuya gonderilmedi.")
    end
    cb('ok')
end)

RegisterNetEvent('oekxc-chat:updateCommandList')
AddEventHandler('oekxc-chat:updateCommandList', function(commandList)
    DebugPrint("[Chat][DEBUG][Client] Komut listesi alindi: " .. #commandList .. " komut")
    allServerCommands = commandList
    SendNUIMessage({ type = 'updateSuggestions', commands = allServerCommands })
end)

RegisterNetEvent('oekxc-chat:mesajEkle')
AddEventHandler('oekxc-chat:mesajEkle', function(mesaj, renk)
    local gosterilecekMesaj = mesaj
    if not idGoster then
        gosterilecekMesaj = string.gsub(mesaj, "%[([%w:]-)%d+%]%s*", "")
    end
    SendNUIMessage({ type = 'mesajEkle', mesaj = gosterilecekMesaj, renk = renk or Config.Colors.default })
end)

RegisterNetEvent('oekxc-chat:etiketBildirimi')
AddEventHandler('oekxc-chat:etiketBildirimi', function()
    PlaySoundFrontend(-1, "Mention", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)

RegisterCommand('toggleid', function()
    idGoster = not idGoster
    local durumMesaji = idGoster and "gosteriliyor" or "gizleniyor"
    SendNUIMessage({ type = 'mesajEkle', mesaj = "[BILGI] Mesajlardaki ID'ler artik " .. durumMesaji .. ".", renk = "#FFFF00" })
end, false)

RegisterCommand('clear', function()
    SendNUIMessage({ type = 'chatTemizle' })
end, false)

RegisterNetEvent('oekxc-chat:executeUnknownCommand')
AddEventHandler('oekxc-chat:executeUnknownCommand', function(commandString)
    DebugPrint("[Chat][DEBUG][Client] Sunucudan bilinmeyen komut calistirma istegi alindi: '" .. commandString .. "'")
    ExecuteCommand(commandString)
end)

RegisterCommand('fontsize', function(source, args, rawCommand)
    local boyut = tonumber(args[1])
    if boyut and boyut >= 8 and boyut <= 24 then
        SendNUIMessage({ type = 'fontSizeAyarla', boyut = boyut })
        SendNUIMessage({ type = 'mesajEkle', mesaj = "[BILGI] Chat yazi tipi boyutu " .. boyut .. "px olarak ayarlandi.", renk = "#FFFF00" })
    else
        SendNUIMessage({ type = 'mesajEkle', mesaj = "[HATA] Kullanim: /fontsize [8-24 arasi sayi]", renk = "#FF0000" })
    end
end, false)

function SetChatDurumu(durum)
    if chatAcik ~= durum then
        SendNUIMessage({ type = 'chatDurumu', durum = durum })
        if durum then
            SendNUIMessage({ type = 'configUpdate', config = {
                enableOOC = Config.EnableOOC,
                enableDebugLogs = Config.EnableDebugLogs
            }})
        end
        chatAcik = durum
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsControlJustPressed(0, 249) then
            if not chatAcik then
                SetNuiFocus(true, true)
                SetChatDurumu(true)
            end
        end

        if IsControlJustPressed(0, 199) then
            if chatAcik then
                 SetNuiFocus(false, false)
            end
        end

        if IsControlJustPressed(0, 245) then
            if not chatAcik then
                 SetNuiFocus(true, true)
                 SetChatDurumu(true)
            end
        end

        if chatAcik then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 58, true)
            DisableControlAction(0, 142, true)
        end
    end
end)

local function DrawText3D(x, y, z, text, r, g, b, alpha)
    local scale = Config.HeadUITextSize
    local font = Config.HeadUITextFont
    SetTextScale(scale, scale)
    SetTextFont(font)
    SetTextProportional(1)
    SetTextColour(r, g, b, alpha)
    SetTextDropshadow(0, 0, 0, 0, alpha)
    SetTextEdge(1, 0, 0, 0, alpha)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
    local wrapWidth = 0.1
    SetTextWrap(0.0 - wrapWidth, 0.0 + wrapWidth)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

RegisterNetEvent('oekxc-chat:showHeadUI')
AddEventHandler('oekxc-chat:showHeadUI', function(senderSource, text, type)
    DebugPrint(string.format("[Chat][DEBUG][HeadUI] Event alındı. Sender: %d, Type: %s, Text: %s", senderSource, type, text))
    local senderPed = GetPlayerPed(GetPlayerFromServerId(senderSource))
    local playerPed = PlayerPedId()

    if senderPed == 0 or playerPed == 0 then
        DebugPrint("[Chat][DEBUG][HeadUI] Geçersiz ped, işlem yapılmadı.")
        return
    end

    if not headUiElements[senderSource] then
        headUiElements[senderSource] = {}
    end
    local playerLines = headUiElements[senderSource]

    local displayText = (type == "me" and "*" .. text .. "*" or text)
    local newLine = {
        text = displayText,
        type = type,
        endTime = GetGameTimer() + Config.HeadUIDuration
    }

    table.insert(playerLines, 1, newLine)

    if #playerLines > Config.HeadUIMaxLines then
        table.remove(playerLines, Config.HeadUIMaxLines + 1)
    end

    Citizen.SetTimeout(Config.HeadUIDuration, function()
        if headUiElements[senderSource] then
            for i = #headUiElements[senderSource], 1, -1 do
                if headUiElements[senderSource][i] == newLine then
                    table.remove(headUiElements[senderSource], i)
                    DebugPrint(string.format("[Chat][DEBUG][HeadUI] Süresi dolan satır kaldırıldı. Sender: %d", senderSource))
                    break
                end
            end
            if #headUiElements[senderSource] == 0 then
                headUiElements[senderSource] = nil
            end
        end
    end)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local currentTime = GetGameTimer()
        local playerPed = PlayerPedId()

        if playerPed ~= 0 then
            local playerCoords = GetEntityCoords(playerPed)

            for sourceId, lines in pairs(headUiElements) do
                if #lines > 0 then
                    local senderPed = GetPlayerPed(GetPlayerFromServerId(sourceId))
                    if DoesEntityExist(senderPed) then
                        local senderCoords = GetEntityCoords(senderPed)
                        local distance = #(playerCoords - senderCoords)

                        if distance < Config.HeadUIDistance then
                            local currentAlpha = 255

                            for i = 1, #lines do
                                local element = lines[i]
                                if currentTime < element.endTime then
                                    local r, g, b = 255, 255, 255
                                    if element.type == 'me' then
                                        local colorMe = Config.Colors.headUIMe
                                        if colorMe and colorMe.r and colorMe.g and colorMe.b then r, g, b = colorMe.r, colorMe.g, colorMe.b end
                                    elseif element.type == 'do' then
                                        local colorDo = Config.Colors.headUIDo
                                        if colorDo and colorDo.r and colorDo.g and colorDo.b then r, g, b = colorDo.r, colorDo.g, colorDo.b end
                                    end

                                    local offsetY = Config.HeadUIOffsetY + ((i - 1) * Config.HeadUILineSpacing)
                                    local alpha = math.floor(currentAlpha * (Config.HeadUIAlphaDecay ^ (i - 1)))
                                    if alpha < 0 then alpha = 0 end

                                    DrawText3D(senderCoords.x, senderCoords.y, senderCoords.z + offsetY, element.text, r, g, b, alpha)
                                end
                            end
                        end
                    else
                        headUiElements[sourceId] = nil
                    end
                else
                    headUiElements[sourceId] = nil
                end
            end
        end
    end
end) 