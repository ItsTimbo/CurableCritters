-- Declarations --
local nearby = require("openmw.nearby")
local types = require("openmw.types")
local self = require("openmw.self")
local core = require("openmw.core")
local util = require("openmw_aux.util")
local interfaces = require("openmw.interfaces")

local infectedCritters = {}

local function onLoad()
    -- find all nearby actors sorted by distance
    local critters = util.mapFilterSort(
        nearby.actors,
        function(actor)
            return actor.type == types.Creature and (self.position - actor.position):length()
        end
    )

    infectedCritters = {}
    for _, critter in ipairs(critters) do
        -- filter creatures and check if creature is infected
        if critter and critter.type == types.Creature and string.find(critter.recordId, "diseased") ~= nil then
            table.insert(infectedCritters, critter)
        end
    end
    core.sendGlobalEvent("addCureHandler", infectedCritters)
end

local function cureResult(success)
    if success then
        print("Cure successful!")
    else
        print("Cure failed.")
    end
end

return {
    engineHandlers = {
        onLoad = onLoad
    },
    eventHandlers = {
        cureResult = cureResult
    },
}
