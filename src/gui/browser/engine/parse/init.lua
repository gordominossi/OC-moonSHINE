local default = require('lib.default-components')

local merge = require('lib.language-extensions').mergeTables

local Text = require('src.gui.browser.engine.parse.node.text')
local Element = require('src.gui.browser.engine.parse.node.element')

local function mergeStyle(parentComponent, childComponent)
    if type(childComponent) == 'string' then
        childComponent = { childComponent }
    end

    local inheritedStyle = merge(
        parentComponent.style,
        {
            margin = default.block.margin,
            padding = default.block.padding,
        }
    )
    inheritedStyle.height, inheritedStyle.width = nil, nil

    local style = merge(inheritedStyle, childComponent.style)
    return merge(childComponent, { style = style })
end

---@type Parser
local Parser = {}

---@return Parser
function Parser.new()
    ---@class Parser
    local self = {}

    ---@param component Component
    ---@return Node
    function self.execute(component)
        component = component or {}
        local componentType = component.type or component[1]

        local children = {}
        for i = 2, #component do
            local childComponent = mergeStyle(component, component[i])
            children[i - 1] = self.execute(childComponent)
        end

        local props = merge({ children = children }, component)

        if type(componentType) == 'function'
            or (getmetatable(componentType) or {}).__call
        then
            return self.execute(componentType(props))
        end

        if type(componentType) == 'table' then
            componentType = nil
            ---@type Component
            local childComponent = mergeStyle(component, component[1])
            local child = self.execute(childComponent)
            table.insert(children, 1, child)
        end

        if componentType == 'text' or
            (#component == 1 and
                type(component[1]) == 'string')
        then
            local textProps = mergeStyle(props, { value = component[1] })
            return Text.new(textProps)
        end

        return Element.new(componentType, props)
    end

    return self
end

return Parser
