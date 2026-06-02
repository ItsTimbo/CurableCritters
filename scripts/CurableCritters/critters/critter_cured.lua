-- Declarations --
local AI = require("openmw.interfaces").AI
local nearby = require("openmw.nearby")
local self = require("openmw.self")
local types = require("openmw.types")

local function calculateHealed(isFavorite, feedQuality)
    local baseHealth = 3
    local favoriteMult = 1

    if isFavorite then
        favoriteMult = 1.1
    end

    local heal = baseHealth * favoriteMult * feedQuality

    return heal
end

-- eventHandlers
local function satisfyCritter(data)
    local health = types.Actor.stats.dynamic.health(self)
    local maxHP = health.base + health.modifier
    local healed = calculateHealed(data.isFavorite, data.feedQuality)
    health.current = math.min(maxHP, health.current + healed)
    print('current HP: '..health.current..' | maxHP: '.. maxHP .. ' | healed: ' .. maxHP - math.min(maxHP, health.current + healed) .. ' | FQ: ' .. data.feedQuality .. ' | Fav: ' .. tostring(data.isFavorite))
end

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

-- Engine Handlers
local function onActivated(actor)
    actor:sendEvent('checkFeedSuccess', self.object)
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
