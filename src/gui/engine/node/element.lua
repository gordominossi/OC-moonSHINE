-- local merge = require('lib.language-extensions').mergeTables

local Node = require('src.gui.engine.node.node')

---@type Element
local Element = {}
---@param type? string
---@param props? NodeProps
---@param children? Node[]
---@return Element
function Element.new(type, props, children)
    ---@class Element : Node
    local self = Node.new(type or 'div', props, children)

    return self
end

return Element
