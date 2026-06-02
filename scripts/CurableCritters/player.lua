-- Declarations --
local nearby = require("openmw.nearby")
local types = require("openmw.types")
local self = require("openmw.self")
local core = require("openmw.core")
local util = require("openmw_aux.util")
local I = require("openmw.interfaces")

local infectedCritters = {}

local feedItems = {
    mudcrab_cured = 'curablecritters_mudcrab_feed',
    scrib_cured = 'curablecritters_scrib_feed',
    -- TODO:: cliff_racer_cured = 'curablecritters_cliff_racer_feed',
}

HAND_SLOT = 16

-- Animal Handling skill
local l10n = core.l10n('CurableCritters')
local skillID = 'CurableCritters_animal_handling'
local useTypes = {
    FeedCritter = 1,
    CureCritter = 2,
}

-- register skill to player
I.SkillFramework.registerSkill(skillID, {
    name = l10n('Skill_Animal_Handling'),
    description = l10n('Skill_Animal_Handling_Desc'),
    icon = { fgr = 'icons/SkillFramework/animal_handling_option_1.dds' },
    attribute = 'willpower',
    skillGain = {
        [useTypes.FeedCritter] = 3,
        [useTypes.CureCritter] = 6,
    },
    modIntegration = {
        statsWindow = {
            subsection = I.SkillFramework.STATS_WINDOW_SUBSECTIONS.Nature
        }
    }
}
)

-- Event Handlers
local function critterCured()
    I.SkillFramework.skillUsed(skillID, {
        useType = useTypes.CureCritter
    })
end

local function critterFed()
    I.SkillFramework.skillUsed(skillID, {
        useType = useTypes.FeedCritter
    })
end

local function checkFeedSuccess(critter)
    local feedBaseDC = 10
    local feedObj = types.Actor.getEquipment(self.object)[types.Player.EQUIPMENT_SLOT.CarriedRight]

    if feedObj == nil then
        return false
    end
    local feedName = feedObj.recordId
    local feedQuality = types.Lockpick.record(feedName).quality
    local statFactor = I.SkillFramework.calcStatFactor(skillID)
    local fatigueFactor = I.SkillFramework.calcFatigueFactor()
    local isFavorite = string.find(feedName, feedItems[critter.recordId]) ~= nil

    core.sendGlobalEvent('removeFeedFromPlayer', { feedName = feedName, player = self })

    -- calculate chance of success
    local successChance = statFactor * fatigueFactor * feedQuality - feedBaseDC

    -- check chance of success against lady luck
    if math.random(0, 100) < successChance then
        critter:sendEvent('satisfyCritter', { feedName = feedName, feedQuality = feedQuality, isFavorite = isFavorite })
        critterFed()
    else
        print('feeding not successful')
    end
end

-- Engine Handlers
local function onUpdate()
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
        if critter and
            critter.type == types.Creature and
            string.find(critter.recordId, 'diseased') ~= nil
        then
            table.insert(infectedCritters, critter)
        end
    end
    core.sendGlobalEvent('infectCritters', {
        infectedCritters = infectedCritters,
        player = self.object
    })
end

return {
    eventHandlers = {
        checkFeedSuccess = checkFeedSuccess,
        critterCured = critterCured,
    },
    engineHandlers = {
        onUpdate = onUpdate,
    }
}
