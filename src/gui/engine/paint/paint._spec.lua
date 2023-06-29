local describe = _ENV.describe
local it = _ENV.it

local colors = require('lib.colors')

local Layout = require('src.gui.engine.layout')
local Parser = require('src.gui.engine.parse')
local Paint = require('src.gui.engine.paint')

---@class PaintObject
---@field x integer
---@field y integer
---@field value string
---@field vertical boolean

describe('paint', function()
    local layout = Layout.new()
    local parser = Parser.new()
    local paint = Paint.new()

    it('Should create a list that can be send to the gpu api', function()
        local parsedComponent = parser.execute({'text'})
        local input = layout.execute(parsedComponent)

        local result = paint.execute(input)

        local expectedList = {
            {
                x = 0,
                y = 0,
                value = 'text',
                vertical = false,
            }
        }
        assert.same(expectedList, result)
    end)

    it('Should create a list that can be send to the gpu api2', function()
        local parsedComponent = parser.execute({
            {'text'},
            {'text'},
        })
        local input = layout.execute(parsedComponent)

        local result = paint.execute(input)

        local expectedList = {
            {
                x = 0,
                y = 0,
                value = 'text',
                vertical = false,
            },
            {
                x = 0,
                y = 0,
                value = 'text',
                vertical = false,
            },
        }
        assert.same(expectedList, result)
    end)

    it('Should create a list from nested components', function ()
        local parsedComponent = parser.execute({{
            {'text'},
            {'text'},
        }})
        local input = layout.execute(parsedComponent)

        local result = paint.execute(input)

        local expectedList = {
            {
                x = 0,
                y = 0,
                value = 'text',
                vertical = false,
            },
            {
                x = 0,
                y = 0,
                value = 'text',
                vertical = false,
            },
        }
        assert.same(expectedList, result)
    end)
end)
