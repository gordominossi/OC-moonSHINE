local describe = _ENV.describe
local it = _ENV.it
local spy = _ENV.spy
local stub = _ENV.stub

local default = require('lib.default-components')
local Parser = require('src.gui.browser.engine.parse')

describe('LuaX parser', function()
    local parser = Parser.new()

    local defaultValuesNode = {
        type = 'div',
        props = {
            children = {},
            style = default.block.style,
        },
    }

    describe('text', function()
        local textComponent = { 'Fake text' }

        it('should have a value the same as input\'s text', function()
            local result = parser.execute(textComponent)

            assert.equal(textComponent[1], result.value)
        end)

        it('should have a default `style`', function()
            local result = parser.execute(textComponent)

            assert.same(default.text.style, result.props.style)
        end)
    end)

    describe('type', function()
        local customType = 'customType'
        it('Should have type `div` by default', function()
            local result = parser.execute({})
            assert.equal('div', result.type)
        end)

        it('Should accept a type from the table key `type`', function()
            local result = parser.execute({ type = customType })
            assert.same(customType, result.type)
        end)

        it(
            'Should infer the text type if the only child is a string',
            function()
                local result = parser.execute({ '' })
                assert.same('text', result.type)
            end
        )

        it('Should accept the first table element as type', function()
            local result = parser.execute({ customType, 'text' })
            assert.same(customType, result.type)
        end)

        it(
            'Should prefer the type from the key over the type from the child',
            function()
                local result = parser.execute({ type = customType, 'text' })
                assert.same(customType, result.type)
            end
        )
    end)

    describe('element', function()
        it('should default to `div` type if none is given', function()
            local result = parser.execute({})

            assert.same(defaultValuesNode, result)
        end)

        it('should call the component if it is a function', function()
            local stubComponent = { function() end }
            stub(stubComponent, 'type')

            parser.execute(stubComponent)

            assert.stub(stubComponent.type).was_called()
        end)

        it(
            'should call the component with arguments if it is a function',
            function()
                local typeFunction = function(props)
                    return { type = 'fakeType', value = props.text }
                end

                local spyComponent = {
                    typeFunction,
                    text = 'Testing',
                }
                spy.on(spyComponent, 1)

                local result = parser.execute(spyComponent)

                assert.spy(spyComponent[1]).was_called()
                assert.equal('fakeType', result.type)
                assert.equal(spyComponent.text, result.value)
            end
        )
    end)

    describe('box', function()
        local padding = 1
        it('Should not inherit padding from parent', function()
            local input = {
                style = { padding = { padding } },
                { { 'child 1' } },
            }

            local result = parser.execute(input)

            local child = result.props.children[1]
            assert.not_same(
                result.props.style.padding,
                child.props.style.padding
            )
        end)

        it('should have padding on all sides', function()
            local parentComponent = {
                style = { padding = { 1 } },
            }


            local result = parser.execute(parentComponent)

            assert.same(
                {
                    top = 1,
                    right = 1,
                    bottom = 1,
                    left = 1,
                },
                result.props.style.padding
            )
        end)

        it('should have margin on all sides', function()
            local parentComponent = {
                style = { margin = { 1 } },
            }


            local result = parser.execute(parentComponent)

            assert.same(
                {
                    top = 1,
                    right = 1,
                    bottom = 1,
                    left = 1,
                },
                result.props.style.margin
            )
        end)
    end)

    describe('children', function()
        it('should parse children', function()
            local parentComponent = { {} }

            local result = parser.execute(parentComponent)
            local children = result.props.children

            assert.same({ defaultValuesNode }, children)
        end)

        it('should inherit style from parent', function()
            local child = { style = { visible = false } }
            local parentComponent = {
                style = { color = 0x123456 },
                child,
            }

            local result = parser.execute(parentComponent)
            local children = result.props.children

            assert.equal(
                parentComponent.style.color,
                children[1].props.style.color
            )
            assert.equal(
                parentComponent[1].style.visible,
                children[1].props.style.visible
            )
        end)

        it('should parse deeply nested children', function()
            local fakeText = 'Fake Text'

            ---@type Node
            local fakeNode = {
                type = 'text',
                value = fakeText,
                props = {
                    children = {},
                    style = default.text.style,
                }
            }

            local parentComponent = {
                {},
                { fakeText },
                { { fakeText } },
            }

            local result = parser.execute(parentComponent)
            local children = result.props.children

            assert.equal('div', children[1].type)
            assert.equal('text', children[2].type)
            assert.equal('div', children[3].type)
            assert.same({ fakeNode }, children[3].props.children)
        end)
    end)
end)
