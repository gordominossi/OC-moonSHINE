local describe = _ENV.describe
local it = _ENV.it
local spy = _ENV.spy
local stub = _ENV.stub

local Parser = require('src.gui.engine.parser.parser')

describe('LuaX parser', function()
    local parser = Parser.new()
    ---@type Component
    local fakeComponent = {
        'Fake text',
        key = 'fakeOCAddress',
        style = { color = 0xF00BAE, display = 'block' },
    }

    ---@type Node
    local fakeNode = {
        type = 'text',
        key = fakeComponent.key,
        value = fakeComponent[1],
        props = {
            children = {},
            style = { color = 0xF00BAE, display = 'inline' },
        }
    }

    describe('text', function()
        it('should parse a text component', function()
            local result = parser.execute(fakeComponent)

            assert.same(fakeNode, result)
        end)

        it('should have a value the same as input\'s text', function()
            local result = parser.execute(fakeComponent)

            assert.equal(fakeComponent[1], result.value)
        end)

        it('should have an inline style', function()
            local result = parser.execute(fakeComponent)

            assert.equal('inline', result.props.style.display)
        end)

        it('should infer the `text` type', function()
            local result = parser.execute({ 'textGoesHere' })

            assert.same('text', result.type)
        end)

        it('should have a default `style`', function()
            local result = parser.execute({ 'textGoesHere' })

            assert.same(
                { color = 0xFFFFFF, display = 'inline' },
                result.props.style
            )
        end)
    end)

    describe('element', function()
        it('should have the same type as the input', function()
            local fakeType = 'someType'

            local result = parser.execute({ type = fakeType })

            assert.equal(fakeType, result.type)
        end)

        it('should default to `div` type if none is given', function()
            local result = parser.execute({})

            assert.equal('div', result.type)
        end)

        it('should call the component if it is a function', function()
            local stubComponent = {
                type = function() end
            }
            stub(stubComponent, 'type')

            parser.execute(stubComponent)

            assert.stub(stubComponent.type).was_called()
        end)

        it('should call the component with arguments if it is a function',
            function()
                local spyComponent = {
                    type = function(props)
                        return { type = 'fakeType', value = props.text }
                    end,
                    text = 'Testing',
                }
                spy.on(spyComponent, 'type')

                local result = parser.execute(spyComponent)

                assert.spy(spyComponent.type).was_called()
                assert.equal('fakeType', result.type)
                assert.equal(spyComponent.text, result.value)
            end
        )
    end)

    describe('children', function()
        it('should parse children', function()
            local parentComponent = { {} }

            local result = parser.execute(parentComponent)
            local children = result.props.children

            assert.same('div', children[1].type)
        end)

        it('should inherit style from parent', function()
            local parentComponent = {
                style = { color = 0x123456 },
                { style = { visibility = 'hidden' } },
            }

            local result = parser.execute(parentComponent)
            local children = result.props.children

            assert.equal(
                parentComponent.style.color,
                children[1].props.style.color
            )
            assert.equal(
                parentComponent[1].style.visibility,
                children[1].props.style.visibility
            )
        end)

        it('should parse deeply nested children', function()
            local parentComponent = {
                {},
                { 'fakeText' },
                { fakeComponent },
            }

            local result = parser.execute(parentComponent)
            local children = result.props.children

            assert.equal('div', children[1].type)
            assert.equal('text', children[2].type)
            assert.same(fakeNode, children[3].props.children[1])
        end)
    end)
end)
