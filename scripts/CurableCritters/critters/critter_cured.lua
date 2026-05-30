-- Declarations --
local AI = require("openmw.interfaces").AI
local nearby = require("openmw.nearby")
local self = require("openmw.self")
local core = require("openmw.core")
local types = require("openmw.types")

-- start follower AI
local function loadFriendlyCritterBehavior()
    AI.startPackage({
        type = 'Follow',
        cancelOther = true,
        target = nearby.players[1],
        duration = 60,
        isRepeat = true
    })
end

local function onActivated(actor)
    core.sendGlobalEvent('checkFeed', {
        critter = self.object,
        player = actor
    })
end

local function calculateHealed(isFavorite, feedQuality)
    local baseHealth = 3
    local favoriteMult = 1

    if isFavorite then
        favoriteMult = 1.1
    end

    local heal = baseHealth * favoriteMult * feedQuality

    return heal
end

local function satisfyCritter(data)
    local health = types.Actor.stats.dynamic.health(self)
    local maxHP = health.base + health.modifier
    local healed = calculateHealed(data.isFavorite, data.feedQuality)
    health.current = math.min(maxHP, health.current + healed)
    print('current HP: '..health.current..' | maxHP: '.. maxHP .. ' | healed: ' .. healed)
end

return {
    eventHandlers = {
        loadFriendlyCritterBehavior = loadFriendlyCritterBehavior,
        satisfyCritter = satisfyCritter,
    },
    engineHandlers = {
        onActivated = onActivated
    }
}
