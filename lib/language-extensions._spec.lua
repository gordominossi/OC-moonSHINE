local extensions = require('lib.language-extensions')
local mergeTables = extensions.mergeTables
local traverseBreadthFirst = extensions.traverseBreadthFirst

local describe = _ENV.describe
local it = _ENV.it

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

    describe('traverseBreadthFirst', function()
        it('Should traverse a tree', function()
            local tree = {
                1,
                children = { {
                    2,
                    children = { { 3 } },
                } },
            }

            local list = traverseBreadthFirst(tree)
            for index, element in ipairs(list) do
                assert.same(index, element[1])
            end
        end)

        it('Should traverse a tree by layers', function()
            local tree = {
                1,
                children = {
                    {
                        2,
                        children = { { 4 }, { 5 } },
                    },
                    {
                        3,
                        children = { { 6 } },
                    },
                },
            }

            local list = traverseBreadthFirst(tree)
            for index, element in ipairs(list) do
                assert.same(index, element[1])
            end
        end)

        it('Should accept a list of children as a parameter', function()
            local children = {
                { 1 }, { 2 }
            }

            local list = traverseBreadthFirst(children)
            for index, element in ipairs(list) do
                assert.same(index, element[1])
            end
        end)
    end)
end)
