local describe = _ENV.describe
local it = _ENV.it

local colors = require('lib.colors')
local default = require('lib.default-components')
local screenSize = require('lib.screen-sizes')

local Layout = require('src.gui.browser.engine.layout')
local Parser = require('src.gui.browser.engine.parse')

local merge = require('lib.language-extensions').mergeTables

describe('Layout engine', function()
    local layout = Layout.new()
    local parser = Parser.new()

    describe('text', function()
        local fakeText = parser.execute({
            'Fake text',
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
            style = default.text.style,
        }

        it('should layout a text node', function()
            local result = layout.execute(fakeText)

            assert.same(fakeTextLayout, result)
        end)

        it('should have a default style', function()
            local input = parser.execute({ 'text' })

            local result = layout.execute(input)

            assert.same(default.text.style, result.style)
        end)
    end)

    describe('block', function()
        ---@type Component
        local fakeComponent = {
            width = 20,
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
        }

        it('should apply margin if defined', function()
            ---@type Component
            local testComponent = {
                width = screenSize.tier3.width,
                { 'text with margin', style = { margin = { 20, 20 } } }
            }

            local testParsedComponent = parser.execute(testComponent)

            local layedOutComponent = layout.execute(testParsedComponent)

            local expectedPosition = {
                x = 20,
                y = 20,
            }

            local expectedSize = { width = screenSize.tier3.width - 40 }

            assert.same(expectedPosition.x, layedOutComponent.children[1].x)
            assert.same(expectedPosition.y, layedOutComponent.children[1].y)
            assert.same(expectedSize.width, layedOutComponent.children[1].width)
        end)

        it('should have a default style', function()
            local input = parser.execute({ type = 'div' })

            local result = layout.execute(input)

            assert.same(default.block.style, result.style)
        end)

        it('should apply custom style if defined', function()
            local input = parser.execute({
                type = 'div',
                style = { color = colors.primary }
            })
            local result = layout.execute(input)

            local expectedStyle = merge(
                default.block.style,
                { color = colors.primary }
            )

            assert.same(expectedStyle, result.style)
        end)

        it('should layout a node with a text node child', function()
            local result = layout.execute(fakeElement)

            local child = merge(result.children[1], { parent = result })
            assert.same(
                merge(
                    fakeBlockLayout,
                    { style = default.block.style },
                    { children = { child } }
                ),
                result
            )
        end)
    end)
end)
