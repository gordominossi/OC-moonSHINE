local describe = _ENV.describe
local it = _ENV.it

local mergeTables = require('lib.language-extensions').mergeTables

describe('language extensions', function()
    describe('merge', function()
        local fakeTable = {
            'one',
            'two',
            three = 3,
        }

        it('Should create a table with the same values', function()
            local result = mergeTables(fakeTable)

            assert.same(fakeTable, result)
            assert.not_equal(fakeTable, result)
        end)

        it(
            'Should override the values of the first table with the second one',
            function()
                local result = mergeTables(fakeTable, { 'four', three = 14 })

                assert.not_same(fakeTable, result)
                assert.equal('four', result[1])
                assert.equal(14, result.three)
            end
        )
    end)
end)
