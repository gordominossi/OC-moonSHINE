local merge = require('lib.language-extensions').mergeTables

local Text = require('src.gui.engine.node.text')
local Element = require('src.gui.engine.node.element')

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
            _children[i - 1] = self.execute(component[i] --[[@as Component]])
        end
        local _props = merge({ children = _children }, component)

        if type(componentType) == 'table' then
            if (getmetatable(componentType) or {}).__call then
                local ret = self.execute(component.type(_props))
                return ret
            else
                componentType = nil
                local child = self.execute(component[1] --[[@as Component]])
                table.insert(_children, 1, child)
            end
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
