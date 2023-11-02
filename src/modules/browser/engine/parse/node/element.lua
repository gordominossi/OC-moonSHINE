local Node = require('src.gui.browser.engine.parse.node.node')

local Element = {}

---@param type? string
---@param props? Props
---@param children? Node[]
---@return Element
function Element.new(type, props, children)
  ---@class Element : Node
  local self = Node.new(type or 'div', props, children)

  return self
end

return Element
