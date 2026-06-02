-- Declarations --
local world = require("openmw.world")
local util = require("openmw.util")
local types = require("openmw.types")

local infectedCritterScript = 'scripts/CurableCritters/critters/critter_infected.lua'
local curedCritterScript = 'scripts/CurableCritters/critters/critter_cured.lua'

local player = nil

-- Event Handlers --
local function infectCritters(data)
    -- add only one critter script to all infected critters
    for _, critter in pairs(data.infectedCritters) do
        if critter:hasScript(infectedCritterScript) then
            critter:removeScript(infectedCritterScript)
        end
        critter:addScript(infectedCritterScript)
    end
    player = data.player
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

    if player then
        player:sendEvent('critterCured')
    end

    -- start friendly critter AI
    curedCritter:sendEvent('loadFriendlyCritterBehavior')
end

local function removeFeedFromPlayer(data)
    local inventory = types.Player.inventory(data.player)
    local feedName = data.feedName
    local feedList = inventory:findAll(feedName)

    if not feedList[2] then
        -- if not enough feed for auto stocking remains remove equiped item
        feedList[1]:remove()
    else
        -- delete 1 from non-equiped stack
        feedList[2]:remove(1)
    end
end

-- Return
return {
    eventHandlers = {
        infectCritters = infectCritters,
        cureCritter = cureCritter,
        removeFeedFromPlayer = removeFeedFromPlayer,
    }
}
