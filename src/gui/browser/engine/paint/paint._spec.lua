local describe = _ENV.describe
local it = _ENV.it

local colors = require('lib.colors')

local Layout = require('src.gui.browser.engine.layout')
local Parser = require('src.gui.browser.engine.parse')
local Paint = require('src.gui.browser.engine.paint')

describe('paint', function()
    local layout = Layout.new()
    local parser = Parser.new()
    local paint = Paint.new()

    describe('text', function()
        it('Should create an element that can be send to the gpu api', function()
            local parsedComponent = parser.execute({ 'text' })
            local input = layout.execute(parsedComponent)

            local result = paint.execute(input)

            local expectedList = {
                {
                    type = 'set',
                    x = 0,
                    y = 0,
                    value = 'text',
                    vertical = false,
                    color = colors.default,
                    backgroundcolor = colors.background
                }
            }
            assert.same(expectedList, result)
        end)

        it('Should create a list that can be send to the gpu api', function()
            local parsedComponent = parser.execute({
                { 'text' },
                { 'text' },
            })
            local input = layout.execute(parsedComponent)

            local result = paint.execute(input)

            local expectedList = {
                {
                    type = 'fill',
                    x = 0,
                    y = 0,
                    width = 0,
                    height = 2,
                    backgroundcolor = colors.background,
                    color = colors.background,
                },
                {
                    type = 'set',
                    x = 0,
                    y = 0,
                    value = 'text',
                    vertical = false,
                    color = colors.default,
                    backgroundcolor = colors.background
                },
                {
                    type = 'set',
                    x = 0,
                    y = 1,
                    value = 'text',
                    vertical = false,
                    color = colors.default,
                    backgroundcolor = colors.background
                },
            }
            assert.same(expectedList, result)
        end)

        it('Should create a list from nested components', function()
            local parsedComponent = parser.execute({ {
                { 'text', style = { color = colors.primary } },
                { 'text', style = { backgroundcolor = colors.secondary } },
            } })
            local input = layout.execute(parsedComponent)

            local result = paint.execute(input)

            local expectedList = {
                {
                    type = 'fill',
                    x = 0,
                    y = 0,
                    width = 0,
                    height = 2,
                    backgroundcolor = colors.background,
                    color = colors.background,
                },
                {
                    type = 'fill',
                    x = 0,
                    y = 0,
                    width = 0,
                    height = 2,
                    backgroundcolor = colors.background,
                    color = colors.background,
                },
                {
                    type = 'set',
                    x = 0,
                    y = 0,
                    value = 'text',
                    vertical = false,
                    color = colors.primary,
                    backgroundcolor = colors.background
                },
                {
                    type = 'set',
                    x = 0,
                    y = 1,
                    value = 'text',
                    vertical = false,
                    color = colors.default,
                    backgroundcolor = colors.secondary,
                },
            }
            assert.same(expectedList, result)
        end)
    end)

    describe('block', function()
        it('should create an element to be send to the gpu api', function()
            local component = {
                type = 'div',
                height = 5,
                width = 5,
                style = {
                    backgroundcolor = colors.background,
                    color = colors.info,
                },
            }
            local parsedComponent = parser.execute(component)
            local layedOutComponent = layout.execute(parsedComponent)
            local paintList = paint.execute(layedOutComponent)

            local expectedList = {
                {
                    type = 'fill',
                    x = 0,
                    y = 0,
                    width = 5,
                    height = 5,
                    backgroundcolor = colors.background,
                    color = colors.background,
                }
            }

            assert.same(expectedList, paintList)
        end)

        it('should create a list to be send to the gpu api', function()
            local component = {
                height = 40,
                width = 80,
                { 'text' },
                { 'text' },
            }
            local parsedComponent = parser.execute(component)
            local layedOutComponent = layout.execute(parsedComponent)
            local paintList = paint.execute(layedOutComponent)

            local expectedList = {
                {
                    type = 'fill',
                    x = 0,
                    y = 0,
                    width = 80,
                    height = 42,
                    backgroundcolor = colors.background,
                    color = colors.background,
                },
                {
                    type = 'set',
                    x = 0,
                    y = 0,
                    value = 'text',
                    vertical = false,
                    backgroundcolor = colors.background,
                    color = colors.default,
                },
                {
                    type = 'set',
                    x = 0,
                    y = 1,
                    value = 'text',
                    vertical = false,
                    backgroundcolor = colors.background,
                    color = colors.default,
                },
            }

            assert.same(expectedList, paintList)
        end)
    end)
end)
