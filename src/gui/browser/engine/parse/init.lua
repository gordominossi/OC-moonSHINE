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
            margin = { 0 },
            padding = { 0 },
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

    local function getProps(component)
        local children = {}
        for i = 2, #component do
            local childComponent = mergeStyle(component, component[i])
            children[i - 1] = self.execute(childComponent)
        end

        return merge({ children = children }, component)
    end

    ---@param component Component
    ---@return Node
    function self.execute(component)
        component = component or {}
        local props = getProps(component)

        if component.type == 'text'
            or (not component.type
                and #component == 1
                and type(component[1]) == 'string')
        then
            local textProps = merge(props, { value = component[1] })
            return Text.new(textProps)
        end

        local componentType = component.type or component[1]

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
            table.insert(props.children, 1, child)
        end

        return Element.new(componentType, props)
    end

    return self
end

return Parser
