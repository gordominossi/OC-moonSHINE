local browser = require('src.gui.browser')

local componentHooks = {}
local componentHookIndex = 1

local function useState(initialState)
    local pair = componentHooks[componentHookIndex]
    if pair then
        componentHookIndex = componentHookIndex + 1
        return pair.state, pair.setState
    end

    local function setState(newState)
        componentHookIndex = 1
        pair.state = newState
        browser.render()
    end

    pair = {
        state = initialState,
        setState = setState
    }

    componentHooks[componentHookIndex] = pair

    componentHookIndex = componentHookIndex + 1
    return pair.state, pair.setState
end

return useState
