-- Declarations --
local world = require("openmw.world")
local util = require("openmw.util")


-- Event Handlers --
local function infectCritters(infectedCritters)
    local infectedCritterScript = "scripts/CurableCritters/critters/critter_infected.lua"
    -- add only one critter script to all infected critters
    for _, critter in pairs(infectedCritters) do
        if critter:hasScript(infectedCritterScript) then
            critter:removeScript(infectedCritterScript)
        end
        critter:addScript(infectedCritterScript)
    end
end

local function cureCritter(critter)
    local curedCritterScript = "scripts/CurableCritters/critters/critter_cured.lua"
    local critterName = string.gsub(critter.recordId, "%A[Dd]iseased.*", "")

    critter:removeScript("scripts/CurableCritters/critters/critter_infected.lua")

    -- create cured critter and move to position of infected critter
    local curedCritter = world.createObject(critterName .. '_cured', 1)
    curedCritter:addScript(curedCritterScript)
    curedCritter:teleport(
        critter.cell,
        util.vector3(critter.position.x, critter.position.y, critter.position.z), -- original position to vector3
        critter.rotation
    )
    -- remove infected critter
    critter.remove(critter)

    -- start friendly critter AI
    curedCritter:sendEvent("loadFriendlyCritterBehavior")
end

-- Return
return {
    eventHandlers = {
        infectCritters = infectCritters,
        cureCritter = cureCritter,
    }
}
