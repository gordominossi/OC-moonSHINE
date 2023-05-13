local describe = _ENV.describe
local it = _ENV.it

local Help = require('src.modules.moonSHINE.core.help')

describe('Help cli command', function()
    local help = Help.new()

    local mockCommand = {
        name = 'mock',
        description = 'This is a mock'
    }

    local mockDescriptionTable = { mockCommand.name .. ':', mockCommand.description }
    local helpDescriptionTable = { 'help:', 'Prints this help.' }

    it('should return a table containing only the help description table when called with no arguments', function()
        local result = help.execute()
        assert.equals(1, #result)
        assert.same(helpDescriptionTable, result[1])
    end)


    it('should return a table containing only the description table of the command passed in', function()
        local result = help.execute(mockCommand)
        assert.equals(1, #result)
        assert.same(mockDescriptionTable, result[1])

        result = help.execute(Help)
        assert.equals(1, #result)
        assert.same(helpDescriptionTable, result[1])
    end)

    it('should return a table containing the help description table and the mock description', function()
        local result = help.execute({ mockCommand, Help })
        assert.equals(2, #result)
        assert.is_true(
            ((helpDescriptionTable[1] == result[2][1] and helpDescriptionTable[2] == result[2][2]) and
                ((mockDescriptionTable[1] == result[1][1] and mockDescriptionTable[2] == result[1][2]))) or
            ((helpDescriptionTable[1] == result[1][1] and helpDescriptionTable[2] == result[1][2]) and
                (mockDescriptionTable[1] == result[2][1] and mockDescriptionTable[2] == result[2][2]))
        )
    end)
end)
