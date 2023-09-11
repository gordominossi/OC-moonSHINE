local default = require('lib.default-components')
local merge = require('lib.language-extensions').mergeTables

local Node = require('src.gui.browser.engine.parse.node.node')

---@type Text
local Text = {}
---@param props? Props
---@return Text
function Text.new(props)
  props = props or {}
  local _style = merge(default.text.style, props.style)
  local _props = merge(props, { style = _style })

  ---@class Text : Node
  local self = Node.new('text', _props)

  return self
end

return Text
