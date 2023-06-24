local describe = os.getenv('describe') or _ENV.describe
local it = os.getenv('it') or _ENV.it

local colors = require('lib.colors')

local Layout = require('src.gui.engine.layout')
local Parser = require('src.gui.engine.parser.parser')

local mergeTables = require('lib.language-extensions').mergeTables

describe('Layout engine', function()
    local layout = Layout.new()
    local parser = Parser.new()

    ---@type Component
    local fakeComponent = {
        style = { width = 20 },
        { 'Fake text', style = { color = colors.primary } },
    }

    local fakeElement = parser.execute(fakeComponent)

    ---@type LayoutObject
    local fakeBlockLayout = {
        node = fakeElement,
        parent = {},
        previous = {},
        children = {},
        width = 20,
        height = 1,
        x = 0,
        y = 0,
        style = { width = 20, display = 'block', color = colors.background },
    }

    describe('text', function()
        local fakeText = parser.execute({
            'Fake text',
            style = { color = colors.primary },
        })

        ---@type LayoutObject
        local fakeTextLayout = {
            node = fakeText,
            parent = {},
            previous = {},
            children = {},
            width = #'Fake text',
            height = 1,
            x = 0,
            y = 0,
            style = {
                color = colors.primary,
                display = 'inline',
            },
        }

        it('should layout a text node', function()
            local result = layout.execute(fakeText)

            assert.same(fakeTextLayout, result)
        end)
    end)

    --[[
    --  it('should nest children', function()
    --     local result = layout.execute(fakeElement)

    --     assert.same(
    --         { mergeTables(
    --             fakeTextLayout,
    --             { parent = result, width = result.width }
    --         ) },
    --         result.children
    --     )
    -- end)
    --]]

    describe('block', function()
        it('should layout a node with a text node child', function()
            local result = layout.execute(fakeElement)

            assert.same(
                mergeTables(
                    fakeBlockLayout,
                    {
                        children = {
                            mergeTables(result.children[1],
                                { parent = result })

                        }
                    }
                ),
                result
            )
        end)
    end)
end)
