local term = require('term')
local gpu = require('component').gpu

local colors = require('lib.colors')

local Parser = require('src.gui.browser.engine.parse')
local Layout = require('src.gui.browser.engine.layout')
local Paint = require('src.gui.browser.engine.paint')

---@type Component
local component = {
    x = 10,
    y = 1,
    style = { backgroundcolor = colors.border, width = 39 },
    {
        style = { layout = 'inline' },
        { 'Hello world 1' },
        { style = { color = colors.primary }, 'Hello world 2' },
    },
    {
        style = { layout = 'inline' },
        {
            type = 'button',
            style = { width = 20, color = colors.secondary },
            length = 16,
            'Hello world 3',
        },
    },
    {
        x = 6,
        style = { backgroundcolor = colors.disabled, width = 26 },
        {
            y = 1,
            style = { layout = 'inline', width = 10 },
            { style = { color = colors.warning, backgroundcolor = colors.white }, 'Hello world' },
            { style = { color = colors.error },                                   '4' },
        },
        {
            x = 3,
            style = { layout = 'inline' },
            { style = { color = colors.info },    'Hello' },
            { type = 'br' },
            { style = { color = colors.success }, 'world' },
            { style = { color = colors.warning }, '5' },
        },
    },
    {
        style = { backgroundcolor = 0x333399 },
        { type = 'text', style = { color = colors.disabled }, 'Hello world 6' }
    },
}
local parsedComponent = Parser.new().execute(component)
local layedOutComponent = Layout.new().execute(parsedComponent)
local paintList = Paint.new().execute(layedOutComponent)

term.clear()

gpu.setForeground(colors.success)

for _, command in ipairs(paintList) do
    gpu.setForeground(command.color)
    gpu.setBackground(command.backgroundcolor or colors.background)
    -- print(command.x, command.y, command.value, command.vertical)
    gpu.set(command.x, command.y, command.value, command.vertical)
end

term.setCursor(1, 49)

local computer = require('computer')
local memoryFreeString = math.floor(
        10000 * computer.freeMemory() /
        computer.totalMemory()
    ) / 100 ..
    '% memory free'

gpu.set(
    161 - #memoryFreeString,
    50,
    memoryFreeString
)
