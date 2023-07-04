local term = require('term')
local gpu = require('component').gpu

local DocumentLayout = dofile('src/gui/browser/engine/layout/document.lua')
local Parser = dofile('src/gui/browser/engine/parse/init2.lua')
local Element = require('src.gui.browser.engine.parse.node.element')
local Text = require('src.gui.browser.engine.parse.node.text')

local container = require('src.gui.components.atoms.container')

---@type Element
local rawElement = {
    props = {
        x = 1,
        style = { backgroundcolor = 0x000099, width = 39, height = 50 },
        children = {
            {
                props = {
                    style = { layout = 'inline' },
                    children = {
                        {
                            props = { children = {}, style = {} },
                            text = 'Hello world 1',
                        },
                        {
                            props = { style = { color = 0x3366CC }, children = {} },
                            text = 'Hello world 2',
                        },
                    },
                },
            },
            {
                props = {
                    style = { layout = 'inline' },
                    children = {
                        {
                            type = 'button',
                            props = {
                                length = 16,
                                style = { width = 20, color = 0xCCCC66 },
                                children = {
                                    {
                                        props = { children = {}, style = {} },
                                        text = 'Hello world 3',
                                    },
                                },
                            },
                        },
                    },
                },
            },
            {
                props = {
                    x = 6,
                    style = { backgroundcolor = 0x333300, width = 26 },
                    children = {
                        {
                            props = {
                                style = { width = 10, layout = 'inline' },
                                children = {
                                    {
                                        props = { style = { color = 0xFF00CC }, children = {} },
                                        text = 'Hello world',
                                    },
                                    {
                                        props = { style = { color = 0x993300 }, children = {} },
                                        text = '4',
                                    },
                                },
                            },
                        },
                        {
                            props = {
                                x = 3,
                                style = { layout = 'inline' },
                                children = {
                                    {
                                        props = { style = { color = 0xCCCC00 }, children = {} },
                                        text = 'Hello',
                                    },
                                    { type = 'br', props = { children = {}, style = {} } },
                                    {
                                        props = { style = { color = 0x6633FF }, children = {} },
                                        text = 'world',
                                    },
                                    {
                                        props = { style = { color = 0x33FF99 }, children = {} },
                                        text = '5',
                                    },
                                },
                            },
                        },
                    },
                },
            },
            {
                props = {
                    style = { backgroundcolor = 0x333399 },
                    children = {
                        {
                            props = { children = {}, style = { color = 0xFF99CC } },
                            text = 'Hello world 6'
                        },
                    },
                },
            },
        },
    },
}

-- local element = Element.new('div', { x = 41, style = { backgroundcolor = 0x663333, width = 39 } },
--     {
--         Element.new('div', { style = { layout = 'inline' } }, {
--             Text.new('Hello world 1'),
--             Text.new('Hello world 2', { style = { color = 0x3366CC } }),
--         }),
--         Element.new('div', { style = { layout = 'inline' } }, {
--             Element.new('button', { length = 16, style = { width = 20, color = 0xCCCC66 } }, {
--                 Text.new('Hello world 3'),
--             }),
--         }),
--         Element.new('div', { x = 6, style = { backgroundcolor = 0x333300, width = 26 } }, {
--             Element.new('div', { y = 1, style = { width = 10, layout = 'inline' } }, {
--                 Text.new('Hello world', { style = { color = 0xFF00CC } }),
--                 Text.new('4', { style = { color = 0x993300 } }),
--             }),
--             Element.new('div', { x = 3, style = { layout = 'inline' } }, {
--                 Text.new('Hello', { style = { color = 0xCCCC00 } }),
--                 Element.new('br'),
--                 Text.new('world', { style = { color = 0x6633FF } }),
--                 Text.new('5', { style = { color = 0x33FF99 } }),
--             }),
--         }),
--         Element.new('div', { style = { backgroundcolor = 0x333399 } }, {
--             Text.new('Hello world 6', { style = { color = 0xFF99CC } })
--         }),
--     }
-- )

---@type Component
local component = {
    x = 81,
    style = { backgroundcolor = 0x336633, width = 39 },
    {
        style = { layout = 'inline' },
        { 'Hello world 1' },
        { style = { color = 0x9966FF }, 'Hello world 2' },
    },
    {
        style = { layout = 'inline' },
        {
            type = 'button',
            style = { width = 20, color = 0xCCCC66 },
            length = 16,
            'Hello world 3',
        },
    },
    {
        x = 6,
        style = { backgroundcolor = 0x333300, width = 26 },
        {
            y = 1,
            style = { layout = 'inline', width = 10 },
            { style = { color = 0xFF66CC, backgroundcolor = 0x663300 }, 'Hello world' },
            { style = { color = 0xCC3366 },                             '4' },
        },
        {
            x = 3,
            style = { layout = 'inline' },
            { style = { color = 0xCCCC00 }, 'Hello' },
            { type = 'br' },
            { style = { color = 0x66CCFF }, 'world' },
            { style = { color = 0x33FF99 }, '5' },
        },
    },
    {
        style = { backgroundcolor = 0x333399 },
        { type = 'text', style = { color = 0xFF99CC }, 'Hello world 6' }
    },
}
local parsedComponent = Parser.new(component).parse()

local html = [[
    <div x={121} style={{ backgroundcolor: 0x333366, width: 39 }} >
        <div style={{ layout: 'inline' }}>
            Hello world 1
            <text style={{ color: 0x3366CC }}>Hello world 2</text>
        </div>
        <div style={{ layout: 'inline' }}>
            <button style={{ layout: 'inline', color: 0xCCCC66 }} length={16} >
                Hello world 3
            </button>
        </div>
        <div x={6} style={{ backgroundcolor: 0x333300, width: 26 }}>
            <div y={1} style={{ layout: 'inline', width: 10 }}>
                <text style={{ color: 0xFF00CC, backgroundcolor: 0x663300 }}>
                    Hello world
                </text>
                <text style={{ color: 0x993300 }}>4</text>
            </div>
            <div x={3} style={{ layout: 'inline' }}>
                <text style={{ color: 0xCCCC00 }}>Hello</text>
                <br/>
                <text style={{ color: 0x6633FF }}>world</text>
                <text style={{ color: 0x33FF99 }}>5</text>
            </div>
        </div>
        <div style={{ backgroundcolor: 0x333399 }}>
            <text style={{ color: 0xFF99CC }}>Hello world 6</text>
        </div>
    </div >
]]
-- local parsedHtml = Parser.new(html).parse()

local documents = {
    DocumentLayout.new(Parser.new(container({
        title = 'Container test',
        width = 39,
        height = 50,
    })).parse()),
    -- DocumentLayout.new(rawElement),
    -- DocumentLayout.new(element),
    DocumentLayout.new(parsedComponent),
    -- DocumentLayout.new(parsedHtml),
}

term.clear()

for _, document in ipairs(documents) do
    document.layout()

    local displayList = {}
    document.paint(displayList)

    for _, command in ipairs(displayList) do
        if type(command) == 'function' then
            command()
        else
            print(command)
        end
    end
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
