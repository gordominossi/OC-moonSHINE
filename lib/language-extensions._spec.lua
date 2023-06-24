local mergeTables = require('lib.language-extensions').mergeTables

local describe = os.getenv('describe') or _ENV.describe
local it = os.getenv('it') or _ENV.it

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

                assert.same(
                    {
                        'newOne',
                        fakeTable[2],
                        three = 14
                    },
                    result
                )
            end
        )

        it('Should merge many tables', function()
            local result = mergeTables(
                fakeTable,
                { 'newOne', 'overridenTwo', three = 14 },
                { [2] = 'newTwo', five = 5 },
                { [4] = 'four' }
            )

            assert.not_same(fakeTable, result)
            assert.not_equal(fakeTable, result)

            assert.same(
                {
                    'newOne',
                    'newTwo',
                    three = 14,
                    nil,
                    'four',
                    five = 5,
                },
                result
            )
        end)
    end)
end)
