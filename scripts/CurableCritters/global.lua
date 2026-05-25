-- Declarations --



-- Event Handlers --
local function addCureHandler(infectedCritters)
    local infectedCritterScript = "scripts/CurableCritters/critters/critter_infected.lua"
    for _, critter in pairs(infectedCritters) do
        if critter:hasScript(infectedCritterScript) then
            critter:removeScript(infectedCritterScript)
        end
        critter:addScript(infectedCritterScript)
    end
end

local function convertCritter(critter)
    -- TODO: clone the critter and remove the infected one
    critter:removeScript("scripts/CurableCritters/critters/critter_infected.lua")
    print("Converting critter...")
    -- TODO: make critter pacified and non-aggressive
end

-- Return
return {
    interfaceName = "CurableCritters",
    interface = {
        version = 1,
    },
    engineHandlers = {
        -- onLoad = onLoad,
        -- onUpdate = onUpdate,
    },
    eventHandlers = {
        addCureHandler = addCureHandler,
        convertCritter = convertCritter,
    }
}
