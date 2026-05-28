-- Declarations --
local self = require("openmw.self")
local types = require("openmw.types")
local core = require("openmw.core")

-- Engine Handlers --
local function onUpdate()
    local spells = types.Actor.activeSpells(self.object)
    for spell, _ in pairs(spells) do
        if string.lower(spell) == 'cure common disease other' then
            core.sendGlobalEvent('cureCritter', self.object)
        end
    end
end

-- Return
return {
    engineHandlers = {
        onUpdate = onUpdate,
    }
}
