local extensions = require('lib.language-extensions')
local mergeTables = extensions.mergeTables
local traverseBreadthFirst = extensions.traverseBreadthFirst
local findOnPath = extensions.findOnPath

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

    describe('findOnPath', function()
        it('Should get the property named from the parameter', function()
            local object = { a = 'a' }

            local result = findOnPath(object, 'a')

            assert.same('a', result)
        end)

        it('Should get a nested property', function()
            local object = { a = { b = { c = 'c' } } }

            local result = findOnPath(object, 'a.b.c')

            assert.same('c', result)
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
            for index = 1, 3 do
                assert.same(index, list[index][1])
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
            for index = 1, 6 do
                assert.same(index, list[index][1])
            end
        end)

        it('Should accept a list of children as a parameter', function()
            local children = {
                { 1 }, { 2 }
            }

            local list = traverseBreadthFirst(children)
            for index = 1, 2 do
                assert.same(index, list[index][1])
            end
        end)

        it('Should accept an optional path of its nested children', function()
            local tree = {
                1,
                props = {
                    children = {
                        { 2 },
                        { 3 },
                        { 4, props = { children = { { 6 } } } },
                        {
                            5,
                            props = {
                                children = {
                                    { 7 },
                                    { 8, props = { children = { { 9 } } } },
                                },
                            }
                        }
                    }
                }
            }

            local list = traverseBreadthFirst(tree, 'props.children')
            for index = 1, 9 do
                assert.same(index, list[index][1])
            end
        end)
    end)
end)
