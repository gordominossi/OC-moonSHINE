local default = require('lib.default-components')
local merge = require('lib.language-extensions').mergeTables

local Node = require('src.gui.browser.engine.parse.node.node')

local Text = {}

---@param props? Props
---@return Text
function Text.new(props)
  props = props or {}
  local style = merge(default.text.style, props.style)

  ---@class Text : Node
  local self = Node.new('text', merge(props, { style = style }))

  return self
end

return Text
