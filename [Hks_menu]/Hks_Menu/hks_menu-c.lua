
local HksQore = exports['qb-core']:GetCoreObject()
local entityType = 0
local toIgnore = 0
local flags = 30
local raycastLength = 50.0
local abs = math.abs
local cos = math.cos
local sin = math.sin
local pi = math.pi
local player
local playerCoords
local display = false
local z_key = 305
local startRaycast = false
local tooFarAway = "~r~Estas demasiado lejos"
local isAdmin = true --Allows for the Export option which write entity data to a txt file.



myJob = "unemployed"
entity =
{
    target, --Entity itself
    type, --Type: Ped, vehicle, object, 0 1 2 3
    hash, --Hash of the object
    modelName, --model name
    isPlayer, --if the entity is a player = true else = false
    coords, --In world coords
    heading, --Which way the entity is Heading/facing
    rotation,-- Entity rotation
    isSelf -- click on self
}

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
    myJob = playerData.job.name
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
     myJob = job.name
end)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SetNuiFocusKeepInput(bool)
    SendNUIMessage({
        type = "ui",
        status = bool,
    })
end

-- temporal mientras no preparamos las notificaciones globales---

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
    --SetTextCentre(true)
end


--------fin del temporal----------



function SendObjectData()
    startRaycast = false 
    if entity.type == 0 then
        ShowNotification("~r~El objeto seleccionado no tiene acciones disponibles...")
        return
    end
    print(entity.modelName, entity.hash, entity.coords, entity.target, entity.type)
    --Aqui vamos a recoger las acciones de por el config para mandarlas a la nui (solo relacionadas con la entidad clicada)
    local success, entityActionList = getActionList()
    if success then
        SendNUIMessage({
            type = "objectData",
            objectType = entity.type,
            admin = isAdmin,
            entityActionList = entityActionList,
        })
    end
end

function getActionList()
    if entity.type == 1 then -- peds
        if entity.isPlayer then 
            return print "en desarollo"
            
        else
            return getNpcActionList()
        end
    elseif entity.type == 2 then -- Coches
        print "en desarrollo"
    elseif entity.type == 3 then -- props
        return getObjectsActionList()
    end
end

function getObjectsActionList()
    local objectActions = {}
    local tooFar = false
    local objectActionsList = getActionListFromConfigList(Config.possibleActionsObjects)
    if #objectActionsList.actions > 0 and not objectActionsList.tooFar and not objectActionsList.foundBlockedAction then
        local ret = getSubMenusAndButtonsFromActionList(objectActionsList.actions)
        return true, ret

    elseif(objectActionsList.tooFar) then
        ShowNotification(tooFarAway)
        return false, nil    
        
    end
end

function getSubMenusAndButtonsFromActionList(actionList)
    local ret = {}
    ret.subMenus = {}
    ret.singleButtons = {}
    for k, v in pairs(actionList) do
        if v.subMenu then
            local subMenuAlreadyCreated = false
            for i = 1, #ret.subMenus do
                if v.subMenu == ret.subMenus[i].subName then
                    table.insert(ret.subMenus[i].actions, {label = v.label, action = v.action})
                    subMenuAlreadyCreated = true
                end
            end
            if not subMenuAlreadyCreated then
                local newSubMenuActions = {}
                table.insert(newSubMenuActions, {label = v.label, action = v.action})
                table.insert(ret.subMenus, {
                            subName = v.subMenu, 
                            subLabel = Config.subMenuInfo[v.subMenu].label, 
                            subColor = Config.subMenuInfo[v.subMenu].color,
                            actions = newSubMenuActions
                        })
            end
        else
            table.insert(ret.singleButtons, {label = v.label, action = v.action})
        end
    end
    return ret
end

function getActionListFromConfigList(configList)
    local actions = {}
    local tooFar = false
    local foundBlockedAction = false
    for k,v in pairs(configList) do
        if v.hashes then
            for j,y in pairs(v.hashes) do
                if type(y) == "string" then
                    y = GetHashKey(y)
                end
                if entity.hash == y then
                    if not v.restrictedJobs or (v.restrictedJobs and currentJobAllowAction(v.restrictedJobs)) then
                        if not v.whiteListedJobs or (v.whiteListedJobs and currentWhiteListedJobs(v.whiteListedJobs)) then
                            if not v.entityCoords or (v.entityCoords and v.entityMaxDistanceRadius and #(entity.coords - v.entityCoords) < v.entityMaxDistanceRadius) then
                                if not v.actionDistance or #(entity.coords - playerCoords) < v.actionDistance then
                                    table.insert(actions, {label = v.label, action = k, subMenu = v.subMenu})
                                else
                                    tooFar = true
                                    foundBlockedAction = true
                                end
                            else
                                foundBlockedAction = true
                            end
                        else
                            foundBlockedAction = true
                        end
                    else
                        foundBlockedAction = true   
                    end
                end
            end
        else
            if not v.restrictedJobs or (v.restrictedJobs and currentJobAllowAction(v.restrictedJobs)) then
                if not v.whiteListedJobs or (v.whiteListedJobs and currentWhiteListedJobs(v.whiteListedJobs)) then
                    if not v.entityCoords or (v.entityCoords and v.entityMaxDistanceRadius and #(entity.coords - v.entityCoords) < v.entityMaxDistanceRadius) then
                        if not v.actionDistance or #(entity.coords - playerCoords) < v.actionDistance then
                            table.insert(actions, {label = v.label, action = k, subMenu = v.subMenu})
                        else
                            tooFar = true
                            foundBlockedAction = true
                        end
                    else
                        foundBlockedAction = true
                    end
                else
                    foundBlockedAction = true
                end
            else
                foundBlockedAction = true   
            end
        end        
    end
    if #actions > 0 then
        foundBlockedAction = false
    end
    return {tooFar = tooFar, foundBlockedAction = foundBlockedAction, actions = actions}
end



function getNpcActionList()
    local npcActions = {}
    local npcActionsList = getActionListFromConfigList(Config.possibleActionsNpc)
    
    if #npcActionsList.actions > 0 then
        npcActions = getSubMenusAndButtonsFromActionList(npcActionsList.actions)
        return true, npcActions
    else
        if not npcActionsList.foundBlockedAction and not npcActionsList.tooFar then
            local genericNpcActions = getGenericNpcActions()
            if genericNpcActions then
                npcActions = getSubMenusAndButtonsFromActionList(genericNpcActions)
                return true, npcActions
            else
                return false, nil
            end
        else
            if npcActionsList.tooFar then
                ShowNotification(tooFarAway)
                return false, nil
            elseif npcActionsList.foundBlockedAction then
                ShowNotification("~r~No puedes interactuar con esa persona!")
                return false, nil
            end
        end
    end
end

function getGenericNpcActions()
    local genericNpcActions = {}
    local tooFar = false
    local foundBlockedAction
    for k,v in pairs(Config.genericNpcActions) do
        if not v.restrictedJobs or (v.restrictedJobs and currentJobAllowAction(v.restrictedJobs)) then
            if #(entity.coords - playerCoords) < v.actionDistance then
                table.insert(genericNpcActions, {label = v.label, action = k, subMenu = v.subMenu})
            else
                tooFar = true
            end
        else
            foundBlockedAction = true
        end
    end
    if #genericNpcActions > 0 then
        return genericNpcActions
    end
    if tooFar then
        ShowNotification(tooFarAway)
        return nil
    end
    ShowNotification("~r~No puedes interactuar con esa persona!")
    return nil
end

function currentWhiteListedJobs(whiteListedJobs)
    for i = 1, #whiteListedJobs do
        if whiteListedJobs[i] == myJob then
            return true
        end
    end
    return false
end

function currentJobAllowAction(restrictedJobs)
    for i = 1, #restrictedJobs do
        if restrictedJobs[i] == myJob then
            return false
        end
    end
    return true
end

RegisterNUICallback("rightclick", function(data)
    startRaycast = true
    
end)

RegisterNUICallback("action", function(data)
    SetDisplay(false)
    local actionDone = checkForSpecificOptions(data.action);
    if not actionDone then
        checkForGenericOptions(data.action); 
    end 
    clearEntityData()
    
end)

function checkForSpecificOptions(action)
   --- print "user"
    if entity.type == 1 then
        if entity.isPlayer then
            if entity.isSelf then
                print "en desarrollo"
              --  print "dentro"
                if Config.selfActions[action] then
                    Config.selfActions[action].action(entity, action)
                    return true
                end    
            else
                if Config.playerActions[action] then
                    Config.playerActions[action].action(entity, action)
                    return true
                end
            end
        else
            if Config.possibleActionsNpc[action] then
                print "en desarrollo"
                --Config.possibleActionsNpc[action].action(entity, action)
                return true
            end  
        end
   
    elseif entity.type == 3 and Config.possibleActionsObjects[action] then
        Config.possibleActionsObjects[action].action(entity, action)
        return true
    end
    return false
end

function checkForGenericOptions(action)

    for k,v in pairs(Config.genericNpcActions) do
        if k == action then
            v.action(entity, action)
            return
        end
    end
    for k,v in pairs(Config.genericAdminActions) do
        if k == action then
            v(entity, action)
            return
        end
    end
   
end

function examine()
    print(entity.modelName, entity.hash, entity.coords, entity.target)
    clearEntityData()
    SetDisplay(false)
end

function getCurrentShop() --obtiene el concesionario actual para los cardealers (hay que pasarlo al handler algun dia xD)
    local shop
    if #(playerCoords - vector3(-43.96, -1096.86, 26.42)) < 15.0 then
        shop = 'mid'
    end
    if #(playerCoords - vector3(-38.07, -1672.82, 29.49)) < 15.0 then
        shop = 'low'
    end
    if #(playerCoords - vector3(-148.75, -595.33, 167.0)) < 15.0 then
        shop = 'high'
    end
    return shop
end

--very important cb 
RegisterNUICallback("exit", function(data)
    clearEntityData()
    SetDisplay(false)
    startRaycast = false
end)


Citizen.CreateThread(function()
    while true do

        Wait(0)
        player = GetPlayerPed(-1, false)
        playerCoords = GetEntityCoords(player, 1)
            
        if display then
           disableControls()
        end

        if startRaycast then
            local hit, endCoords, surfaceNormal, entityHit, entityType, direction = ScreenToWorld(flags, toIgnore)
            if entityHit == 0 then
                entityType = 0
            end
            entity.target = entityHit
            entity.type = entityType
            entity.hash = GetEntityModel(entityHit)
            entity.coords = GetEntityCoords(entityHit, 1)
            entity.heading = GetEntityHeading(entityHit)
            entity.rotation = GetEntityRotation(entityHit)
            entity.modelName = exports["hashtoname"]:objectNameFromHash(entity.hash)
            
            if IsPedAPlayer(entityHit) then --IsPedAPlayer returns false or 1 NOT true or false .. weirdly
                print (IsPedAPlayer(entityHit))
                if entityHit == PlayerPedId() then--- eres tu mismo
                    print (PlayerPedId())
                    entity.isSelf = true
                end
                entity.isPlayer = true
            else
                entity.isPlayer = false
            end
            SendObjectData()
        end
    end
end)

--- Activa el menu al pulsar la tecla seleccionada
RegisterCommand('+puntero', function()

    display = not display
    SetDisplay(display)
    print (display)

end)

--- desactiva el menu al soltar la tecla selecionada
RegisterCommand('-puntero', function()
  
    display = false
    SetDisplay(display)

end)

-- metemos el valor en las opciones de gta para que los usuarios elijan la tecla
RegisterKeyMapping('+puntero', 'ver ratón', 'keyboard', 'LMENU') 

-- Desactivamos parte de las bunciones para que se pueda mover el puntero libremente pero nos podamos desplazar igual

function disableControls()
    DisableControlAction(0, 1, display) -- LookLeftRight
    DisableControlAction(0, 2, display) -- LookUpDown
    DisableControlAction(0, 142, display) -- MeleeAttackAlternate
    DisableControlAction(0, 18, display) -- Enter
    DisableControlAction(0, 322, display) -- ESC
    DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    DisableControlAction(0, 114, display)
    DisableControlAction(0, 176, display)
    DisableControlAction(0, 177, display)
    DisableControlAction(0, 222, display)
    DisableControlAction(0, 223, display)
    DisableControlAction(0, 225, display)
    DisableControlAction(0, 257, display)
    DisableControlAction(0, 24, display)
    DisableControlAction(0, 25, display)
    DisableControlAction(0, 192, display)
    DisableControlAction(0, 37, display)
    DisableControlAction(0, 289, display)
    DisableControlAction(0, 288, display)
    DisableControlAction(0, 45, display)
    DisableControlAction(0, 140, display)
    DisableControlAction(0, 141, display)
    DisableControlAction(0, 44, display)
    DisableControlAction(0, 23, display)
    DisableControlAction(0, 47, display)
end

function clearEntityData()
    entity.target = nil
    entity.type = nil
    entity.hash = nil
    entity.coords = nil
    entity.heading = nil
    entity.rotation = nil
    entity.isPlayer = nil
    entity.isSelf = nil
end

function ScreenToWorld(flags, toIgnore)
    local camRot = GetGameplayCamRot(0)
    local camPos = GetGameplayCamCoord()
    local posX = GetControlNormal(0, 239)
    local posY = GetControlNormal(0, 240)
    local cursor = vector2(posX, posY)
    local cam3DPos, forwardDir = ScreenRelToWorld(camPos, camRot, cursor)
    local direction = camPos + forwardDir * raycastLength
    local rayHandle = StartShapeTestRay(cam3DPos, direction, flags, toIgnore, 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    if entityHit >= 1 then
        entityType = GetEntityType(entityHit)
    end
    return hit, endCoords, surfaceNormal, entityHit, entityType, direction
end
 
function ScreenRelToWorld(camPos, camRot, cursor)
    local camForward = RotationToDirection(camRot)
    local rotUp = vector3(camRot.x + 1.0, camRot.y, camRot.z)
    local rotDown = vector3(camRot.x - 1.0, camRot.y, camRot.z)
    local rotLeft = vector3(camRot.x, camRot.y, camRot.z - 1.0)
    local rotRight = vector3(camRot.x, camRot.y, camRot.z + 1.0)
    local camRight = RotationToDirection(rotRight) - RotationToDirection(rotLeft)
    local camUp = RotationToDirection(rotUp) - RotationToDirection(rotDown)
    local rollRad = -(camRot.y * pi / 180.0)
    local camRightRoll = camRight * cos(rollRad) - camUp * sin(rollRad)
    local camUpRoll = camRight * sin(rollRad) + camUp * cos(rollRad)
    local point3DZero = camPos + camForward * 1.0
    local point3D = point3DZero + camRightRoll + camUpRoll
    local point2D = World3DToScreen2D(point3D)
    local point2DZero = World3DToScreen2D(point3DZero)
    local scaleX = (cursor.x - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (cursor.y - point2DZero.y) / (point2D.y - point2DZero.y)
    local point3Dret = point3DZero + camRightRoll * scaleX + camUpRoll * scaleY
    local forwardDir = camForward + camRightRoll * scaleX + camUpRoll * scaleY
    return point3Dret, forwardDir
end
 
function RotationToDirection(rotation)
    local x = rotation.x * pi / 180.0
    --local y = rotation.y * pi / 180.0
    local z = rotation.z * pi / 180.0
    local num = abs(cos(x))
    return vector3((-sin(z) * num), (cos(z) * num), sin(x))
end
 
function World3DToScreen2D(pos)
    local _, sX, sY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
    return vector2(sX, sY)
end