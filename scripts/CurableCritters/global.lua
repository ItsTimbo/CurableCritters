-- Declarations --
local world = require("openmw.world")
local util = require("openmw.util")
local types = require("openmw.types")

local infectedCritterScript = 'scripts/CurableCritters/critters/critter_infected.lua'
local curedCritterScript = 'scripts/CurableCritters/critters/critter_cured.lua'

local feedItems = {
    mudcrab_cured = 'curablecritters_mudcrab_feed',
    scrib_cured = 'curablecritters_scrib_feed',
    -- TODO:: cliff_racer_cured = 'curablecritters_cliff_racer_feed', 
}

-- Event Handlers --
local function infectCritters(infectedCritters)
    -- add only one critter script to all infected critters
    for _, critter in pairs(infectedCritters) do
        if critter:hasScript(infectedCritterScript) then
            critter:removeScript(infectedCritterScript)
        end
        critter:addScript(infectedCritterScript)
    end
end

local function cureCritter(critter)
    local critterName = string.gsub(critter.recordId, '%A[Dd]iseased.*', '')

    if critter:hasScript(infectedCritterScript) then
        critter:remove()
        critter:removeScript(infectedCritterScript)
    end

    -- create cured critter and move to position of infected critter
    local curedCritter = world.createObject(critterName .. '_cured', 1)
    curedCritter:addScript(curedCritterScript)
    curedCritter:teleport(
        critter.cell,
        util.vector3(critter.position.x, critter.position.y, critter.position.z), -- original position to vector3
        critter.rotation
    )

    -- start friendly critter AI
    curedCritter:sendEvent('loadFriendlyCritterBehavior')
end

local function checkFeed(data)
    for _, item in pairs(types.Actor.getEquipment(data.player)) do
        for feedType, itemName in pairs(feedItems) do
            -- check if Player is holding feed when interacting
            -- and check if feed is favorite for critter
            if string.find(item.recordId, itemName) ~= nil then
                data.critter:sendEvent('satisfyCritter', {
                    isFavorite = feedType == data.critter.recordId,
                    feedQuality = types.Lockpick.records[item.recordId].quality,
                })
            end
        end
    end
end

-- Return
return {
    eventHandlers = {
        infectCritters = infectCritters,
        cureCritter = cureCritter,
        checkFeed = checkFeed,
    }
}
