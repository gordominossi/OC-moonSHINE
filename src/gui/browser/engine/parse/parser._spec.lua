local describe = _ENV.describe
local it = _ENV.it
local spy = _ENV.spy
local stub = _ENV.stub

local default = require('lib.default-components')
local Parser = require('src.gui.browser.engine.parse')

describe('LuaX parser', function()
    local parser = Parser.new()

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

            assert.same('div', result.type)
        end)

        it('should call the component if it is a function', function()
            local stubComponent = { function() end }
            stub(stubComponent, 1)

            parser.execute(stubComponent)

            assert.stub(stubComponent[1]).was_called()
        end)

        it('should call the type if it is a function', function()
            local stubComponent = { type = function() end }
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
        it('Should have the same amount of children as the component',
            function()
                local result = parser.execute({ children = { 1, 2, 3 } })
                assert.same(3, #result.props.children)
            end
        )

        it('Should take a list of tables as a list of children', function()
            local result = parser.execute({ nil, 1, 2, 3 })
            assert.same(3, #result.props.children)
        end)

        it('Should nest children', function()
            local result = parser.execute({ '', 1, { 2 }, { 3 } })
            assert.same(3, #result.props.children)
        end)

        it('Should nest children deeply', function()
            local result = parser.execute({
                type = '',
                1,
                { 2 },
                { children = { 3, { 4 } } },
            })
            assert.same(3, #result.props.children)
            assert.same(2, #result.props.children[3].props.children)
        end)
    end)
end)
