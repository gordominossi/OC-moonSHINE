local describe = _ENV.describe
local it = _ENV.it

local useState = require('src.gui.hooks.use-state')

describe('useState', function()
    it('Should store a initial state', function()
        local initialState = 0
        local state = useState(initialState)

        assert.same(initialState, state)
    end)

    it('Should keep different states for different calls', function()
        local initialState1 = 1
        local initialState2 = 2
        local state1 = useState(initialState1)
        local state2 = useState(initialState2)

        assert.not_same(state1, state2)
    end)
end)
