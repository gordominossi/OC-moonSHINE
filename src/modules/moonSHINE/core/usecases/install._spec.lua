local describe = _ENV.describe
local it = _ENV.it

local Install = require('src.modules.moonSHINE.core.usecases.install')

describe('Install cli command', function()
    local install = Install.new()

    local mockPackage = {
        name = 'mock',
        size = 128,
        description = 'This is a mock'
    }
    local mockPackage2 = {
        name = 'mock2',
        size = 256,
        description = 'This is also a mock'
    }
    local allPackages = {
        mockPackage,
        mockPackage2,
    }

    local formattedPackagesList = {}
    for _, package in ipairs(allPackages) do
        table.insert(formattedPackagesList, { package.name .. '(' .. package.size .. ')' .. ':', package.description })
    end

    it('should return an empty table when called with an empty list', function()
        local result = install.execute()
        assert.same({}, result)
    end)

    it('should return a table containing only the description table of the packages passed in', function()
        local result = install.execute()
        assert.equals(1, result and #result)
        assert.same(formattedPackagesList[1], result and result[1])

        result = install.execute()
        assert.same(formattedPackagesList, result)
    end)
end)
