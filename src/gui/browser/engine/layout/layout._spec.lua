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
            backgroundcolor = colors.background,
            color = colors.default,
        }

        it('should layout a text node', function()
            local result = layout.execute(fakeText)

            assert.same(fakeTextLayout, result)
        end)

        it('should have default color and backgroundcolor', function()
            local input = parser.execute({ 'text' })

            local result = layout.execute(input)

            assert.same(default.text.style.color, result.color)
            assert.same(default.text.style.backgroundcolor, result.backgroundcolor)
        end)
    end)

    describe('block', function()
        local defaultBlockColor = default.block.style.color
        local defaultBlockBackgroundColor = default.block.style.backgroundcolor

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

        it('should list children', function()
            ---@type Component
            local testComponent = {
                { 'child 1' },
                { 'child 2' },
                { 'child 3' },
            }

            local testParsedComponent = parser.execute(testComponent)
            local layedOutComponent = layout.execute(testParsedComponent)

            local expectedPosition = {
                x = { 0, 0, 0 },
                y = { 0, 1, 2 },
            }
            assert.same(expectedPosition.x[1], layedOutComponent.children[1].x)
            assert.same(expectedPosition.x[2], layedOutComponent.children[2].x)
            assert.same(expectedPosition.x[3], layedOutComponent.children[3].x)
            assert.same(expectedPosition.y[1], layedOutComponent.children[1].y)
            assert.same(expectedPosition.y[2], layedOutComponent.children[2].y)
            assert.same(expectedPosition.y[3], layedOutComponent.children[3].y)
        end)

        it('should list children when paddin is applied to parent', function()
            ---@type Component
            local testComponent = {
                width = screenSize.tier3.width,
                height = screenSize.tier3.height,
                style = {
                    padding = { 10, 10 },
                    backgroundcolor = colors.border,
                },
                { 'child within padding' },
                { 'another child within padding, 1 row below' },
            }

            local testParsedComponent = parser.execute(testComponent)
            local layedOutComponent = layout.execute(testParsedComponent)

            local expectedPosition = {
                x = { 10, 10 },
                y = { 10, 11 },
            }
            assert.same(expectedPosition.x[1], layedOutComponent.children[1].x)
            assert.same(expectedPosition.x[2], layedOutComponent.children[2].x)
            assert.same(expectedPosition.y[1], layedOutComponent.children[1].y)
            assert.same(expectedPosition.y[2], layedOutComponent.children[2].y)
        end)

        it('should apply padding if defined', function()
            ---@type Component
            local testComponent = {
                width = screenSize.tier3.width,
                style = { padding = { 20 } },
                { 'child within padding' }
            }

            local testParsedComponent = parser.execute(testComponent)
            local layedOutComponent = layout.execute(testParsedComponent)

            local expectedPosition = {
                x = 20,
                y = 20,
            }

            assert.same(expectedPosition.x, layedOutComponent.children[1].x)
            assert.same(expectedPosition.y, layedOutComponent.children[1].y)
        end)

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

            assert.same(expectedPosition.x, layedOutComponent.children[1].x)
            assert.same(expectedPosition.y, layedOutComponent.children[1].y)
        end)

        it('should have default color and backgroundcolor', function()
            local input = parser.execute({ type = 'div' })

            local result = layout.execute(input)

            assert.same(defaultBlockColor, result.color)
            assert.same(defaultBlockBackgroundColor, result.backgroundcolor)
        end)

        it('should apply custom colors if defined', function()
            local input = parser.execute({
                type = 'div',
                style = { color = colors.primary }
            })
            local result = layout.execute(input)

            assert.same(colors.primary, result.color)
        end)

        it('should layout a node with a text node child', function()
            local result = layout.execute(fakeElement)

            local child = merge(result.children[1], { parent = result })
            assert.same(
                merge(
                    fakeBlockLayout,
                    {
                        color = defaultBlockColor,
                        backgroundcolor = defaultBlockBackgroundColor
                    },
                    { children = { child } }
                ),
                result
            )
        end)
    end)
end)
