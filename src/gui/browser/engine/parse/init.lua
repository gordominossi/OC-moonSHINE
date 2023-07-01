local merge = require('lib.language-extensions').mergeTables

local Text = require('src.gui.browser.engine.parse.node.text')
local Element = require('src.gui.browser.engine.parse.node.element')

local function mergeStyle(parentComponent, childComponent)
    local style = merge(parentComponent.style, childComponent.style)
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

        local _children = {}
        for i = 2, #component do
            local childComponent = mergeStyle(component, component[i])
            _children[i - 1] = self.execute(childComponent)
        end

        local _props = merge({ children = _children }, component)

        if type(componentType) == 'function'
            or (getmetatable(componentType) or {}).__call
        then
            return self.execute(componentType(_props))
        end

        if type(componentType) == 'table' then
            componentType = nil
            ---@type Component
            local childComponent = mergeStyle(component, component[1])
            local child = self.execute(childComponent)
            table.insert(_children, 1, child)
        end

        if #component == 1 and type(componentType) == 'string'
            or componentType == 'text'
        then
            _props.value = component[1]
            return Text.new(_props)
        end

        return Element.new(componentType, _props)
    end

    return self
end

return Parser
