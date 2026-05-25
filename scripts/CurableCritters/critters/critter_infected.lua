-- Declarations --
local self = require("openmw.self")
local types = require("openmw.types")
local core = require("openmw.core")

-- maybe relevant later
-- local commonDiseases = {
-- 	"ataxia",
-- 	"brown rot",
-- 	"chills",
-- 	"collywobbles",
-- 	"dampworm",
-- 	"droops",
-- 	"greenspore",
-- 	"helljoint",
-- 	"rattles",
-- 	"rockjoint",
-- 	"rust chancre",
-- 	"swamp fever",
-- 	"witbane",
-- 	"wither",
-- 	"yellow tick",
-- }

-- debug
local toggle = false

-- Engine Handlers --
local function onUpdate()
    if toggle then
        return
    end
    local spells = types.Actor.activeSpells(self.object)
    for spell, _ in pairs(spells) do
        if string.lower(spell) == "cure common disease other" then
            print("creature cured")
            core.sendGlobalEvent("convertCritter", self.object)
        end
    end
end

-- Return
return {
    engineHandlers = {
        onUpdate = onUpdate,
    }
}
