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
            color = colors.default,
            backgroundcolor = colors.background,
        }

        it('should layout a text node', function()
            local result = layout.execute(fakeText)

            assert.same(fakeTextLayout, result)
        end)

        it('should have a default style', function()
            local input = parser.execute({ 'text' })

            local result = layout.execute(input)

            assert.same(default.text.style, result.node.props.style)
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
            color = colors.default,
            backgroundcolor = colors.background,
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
            for index, child in ipairs(layedOutComponent.children) do
                assert.same(expectedPosition.x[index],child.x)
                assert.same(expectedPosition.y[index],child.y)
            end
        end)

        it('should list children when paddin is applied to parent', function()
            ---@type Component
            local testComponent = {
                width = screenSize.tier3.width,
                height = screenSize.tier3.height,
                padding = { 10, 10 },
                style = {
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
            for index, child in ipairs(layedOutComponent.children) do
                assert.same(expectedPosition.x[index],child.x)
                assert.same(expectedPosition.y[index],child.y)
            end
        end)

        it('should apply padding if defined', function()
            ---@type Component
            local testComponent = {
                width = screenSize.tier3.width,
                padding = { 20 },
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
                { 'text with margin', margin = { 20, 20 } }
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

        it('should have a default style', function()
            local input = parser.execute({ type = 'div' })

            local result = layout.execute(input)

            assert.same(default.block.style, result.node.props.style)
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

            assert.same(expectedStyle, result.node.props.style)
        end)

        it('should layout a node with a text node child', function()
            local result = layout.execute(fakeElement)

            local child = merge(result.children[1], { parent = result })
            assert.same(
                merge(
                    fakeBlockLayout,
                    { children = { child } }
                ),
                result
            )
        end)
    end)
end)
