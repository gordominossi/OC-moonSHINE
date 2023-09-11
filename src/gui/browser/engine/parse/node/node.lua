local default = require('lib.default-components')
local merge = require('lib.language-extensions').mergeTables

local function getBoxSides(box)
  box = box or {}

  if type(box) == 'number' then
    box = { box }
  end

  return {
    top = box.top or box[1] or 0,
    right = box.right or box[2] or box[1] or 0,
    bottom = box.bottom or box[3] or box[1] or 0,
    left = box.left or box[4] or box[2] or box[1] or 0,
  }
end

local Node = {}

---@param type string
---@param props? Props
---@param children? Node[]
---@return Node
function Node.new(type, props, children)
  props = props or {}
  local propsStyle = props.style or {}
  local margin = getBoxSides(propsStyle.margin)
  local padding = getBoxSides(propsStyle.padding)
  local border = getBoxSides(propsStyle.border)

  local style = merge(
    default.block.style,
    propsStyle,
    { padding = padding, margin = margin, border = border }
  )

  ---@type Props
  local nodeProps = merge(
    { children = children or {} },
    props,
    { style = style }
  )
  nodeProps.type = nil
  for i = 1, #nodeProps do
    nodeProps[i] = nil
  end

  local value
  value, nodeProps.value = nodeProps.value, nil

  ---@type Node
  local self = {
    type = type,
    value = value,
    props = nodeProps,
  }

  return self
end

return Node
