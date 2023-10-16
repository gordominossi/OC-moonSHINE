local Normal = {}

local emptyBox = { top = 0, right = 0, bottom = 0, left = 0 }

---@param node Node
---@param parent LayoutObject?
---@param parentNode Node?
---@param previousSibling LayoutObject?
---@param previousNode Node?
---@return LayoutObject
function Normal.execute(
  node,
  parent,
  parentNode,
  previousSibling,
  previousNode
)
  parent = parent or {}
  local parentStyle = parentNode and parentNode.props.style or {}
  local parentPadding = parentStyle.padding or emptyBox
  local parentBorder = parentStyle.border or emptyBox

  local style = node.props.style
  local margin = style.margin or emptyBox

  local x, y

  if previousSibling then
    local previousMargin = previousNode
        and previousNode.props.style.margin
        or emptyBox
    if parentStyle.display == 'inline' then
      x = previousSibling.x
          + previousSibling.width
          + #' '
    else
      y = previousSibling.y
          + previousSibling.height
          + math.max(previousMargin.bottom, margin.top)
    end
  end

  x = x or ((parent.x or 0)
    + parentBorder.left
    + parentPadding.left
    + margin.left)

  y = y or ((parent.y or 0)
    + parentBorder.top
    + parentPadding.top
    + margin.top)

  local maxWidth = parent.width
      and (parent.width
        - (margin.left + margin.right)
        - (parentBorder.left + parentBorder.right)
        - (parentPadding.left + parentPadding.right))
      or (parentStyle.display ~= 'flex' and style.display == 'block' and 160)
  local width = style.width or maxWidth or 160
  local height = style.height or 0
  if (node.type == 'text') then
    width = #node.value
    height = 1
  end

  local notEnoughWidth = parentStyle.display == 'inline'
      and style.display == 'inline'
      and previousSibling
      and (x + width > (parent.width or 160))
  if notEnoughWidth then
    previousSibling = previousSibling or {}
    x = parent.x + style.padding.left
    y = previousSibling.y + previousSibling.height
  end

  ---@type LayoutObject
  local layoutObject = {
    backgroundcolor = style.backgroundcolor,
    border = style.border,
    children = {},
    color = style.color,
    height = height,
    margin = style.margin,
    padding = style.padding,
    text = node.type == 'text' and tostring(node.value) or nil,
    width = width,
    x = x,
    y = y,
  }

  return layoutObject
end

return Normal
