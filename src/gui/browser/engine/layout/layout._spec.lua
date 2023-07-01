local describe = _ENV.describe
local it = _ENV.it

local colors = require('lib.colors')

local Layout = require('src.gui.browser.engine.layout')
local Parser = require('src.gui.browser.engine.parse')

local mergeTables = require('lib.language-extensions').mergeTables

describe('Layout engine', function()
    local layout = Layout.new()
    local parser = Parser.new()

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

        it('should have a default style', function()
            local input = parser.execute({ 'text' })

            local result = layout.execute(input)

            local expectedStyle = { display = 'inline', color = colors.white }

            assert.same(expectedStyle, result.style)
        end)
    end)

    describe('block', function()
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
            style = {
                color = colors.background,
                display = 'block',
                width = 20,
            },
        }

        it('should have a default style', function()
            local input = parser.execute({ type = 'div' })

            local result = layout.execute(input)

            local expectedStyle = {
                display = 'block',
                color = colors.background,
            }

            assert.same(expectedStyle, result.style)
        end)

        it('should apply custom style if defined', function()
            local input = parser.execute({
                type = 'div',
                style = { color = colors.primary }
            })
            local result = layout.execute(input)

            local expectedStyle = {
                display = 'block',
                color = colors.primary,
            }

            assert.same(expectedStyle, result.style)
        end)

        it('should layout a node with a text node child', function()
            local result = layout.execute(fakeElement)

            local child = mergeTables(result.children[1], { parent = result })
            assert.same(
                mergeTables(fakeBlockLayout, { children = { child } }),
                result
            )
        end)
    end)
end)
