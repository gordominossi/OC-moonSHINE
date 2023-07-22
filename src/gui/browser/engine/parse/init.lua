local merge = require('lib.language-extensions').mergeTables

local Text = require('src.gui.browser.engine.parse.node.text')
local Element = require('src.gui.browser.engine.parse.node.element')

---@param component Component
---@return nodeType
local function getType(component)
    if type(component) == 'string' or type(component) == 'number' then
        return 'text'
    end

    if component.type then
        return component.type
    end

    if #component == 1 and type(component[1]) == 'string' then
        return 'text'
    end

    if type(component[1]) == 'string'
        or type(component[1]) == 'function'
        or (getmetatable(component[1]) or {}).__call
    then
        return component[1]
    end

    return 'div'
end

---@param component Component
---@return Props
local function getProps(component, componentType)
    local children = {}
    local value = ''

    if type(component) == 'string' or type(component) == 'number' then
        value = tostring(component)
        return { children = children, value = value }
    end

    if componentType == 'text' then
        value = table.concat(component, ' ')
    else
        local firstChildIsNotJustType = component.type
            or type(component[1]) == 'table'
        local firstChildIndex = firstChildIsNotJustType and 1 or 2
        children = { table.unpack(component, firstChildIndex) }
    end

    return merge(
        { children = children, value = value },
        component
    )
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
        local componentType = getType(component)
        local props = getProps(component, componentType)

        if type(componentType) == 'function'
            or (getmetatable(componentType) or {}).__call
        then
            return self.execute(componentType(props))
        end

        if componentType == 'text' then
            return Text.new(props)
        end

        local children = {}
        if props.children then
            for index, child in ipairs(props.children) do
                children[index] = self.execute(child)
            end
        end

        return Element.new(
            componentType,
            merge(props, { children = children })
        )
    end

    return self
end

return Parser
