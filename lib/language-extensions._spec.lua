local describe = _ENV.describe
local it = _ENV.it

local mergeTables = require('lib.language-extensions').mergeTables

describe('language extensions', function()
    describe('mergeTables', function()
        local fakeTable = {
            'one',
            'two',
            three = 3,
        }

        it('Should clone a table', function()
            local result = mergeTables(fakeTable)

            assert.same(fakeTable, result)
            assert.not_equal(fakeTable, result)
        end)

        it(
            'Should override the values of the first table with the second one',
            function()
                local result = mergeTables(fakeTable, { 'newOne', three = 14 })

                assert.not_same(fakeTable, result)
                assert.not_equal(fakeTable, result)

                assert.equal(fakeTable[2], result[2])
                assert.equal('newOne', result[1])
                assert.equal(14, result.three)
            end
        )

        it('Should merge many tables', function()
            local result = mergeTables(
                fakeTable,
                { 'newOne', three = 14 },
                { [2] = 'newTwo', five = 5 },
                { [4] = 'four' }
            )

            assert.not_same(fakeTable, result)
            assert.not_equal(fakeTable, result)

            assert.equal('newTwo', result[2])
            assert.equal('newOne', result[1])
            assert.equal(14, result.three)
            assert.equal(5, result.five)
            assert.equal('four', result[4])
        end)
    end)
end)
