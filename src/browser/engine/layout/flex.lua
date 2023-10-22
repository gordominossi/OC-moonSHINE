local Flex = {}

local emptyBox = { top = 0, right = 0, bottom = 0, left = 0 }


---@param box LayoutObject
---@param node Node
---@param parent LayoutObject?
---@param parentNode Node?
---@return integer
local function getWidth(
  box,
  node,
  parent,
  parentNode
)
  if node.props.style.width then
    return node.props.style.width
  end

  if box.text then
    return #box.text
  end

  local someChildHasFlex = false
  for _, child in ipairs(parentNode and parentNode.props.children or {}) do
    if child.props.style.flex then
      someChildHasFlex = true
      break
    end
  end
  if someChildHasFlex then
    local flex = node.props.style.flex and node.props.style.flex[1] or 1
    local flexSum = 0
    for _, child in ipairs(parentNode and parentNode.props.children or {}) do
      local childFlex = child.props.style.flex and child.props.style.flex[1] or 1
      flexSum = flexSum + childFlex
    end

    return flex * (parent and parent.width or 160) / math.max(flexSum, 1)
  end

  local width = 0
  for _, child in ipairs(node.props.children) do
    width = math.max(width, child.value and #child.value or 0)
  end

  return width ~= 0 and width or 160
end

---@param node Node
---@param parent LayoutObject?
---@param parentNode Node?
---@param previousSibling LayoutObject?
---@param _ Node?
---@return LayoutObject
function Flex.execute(
  node,
  parent,
  parentNode,
  previousSibling,
  _
)
  parent = parent or {}
  local parentStyle = parentNode and parentNode.props.style or {}
  local parentPadding = parentStyle.padding or emptyBox
  local parentBorder = parentStyle.border or emptyBox

  local style = node.props.style
  local margin = style.margin or emptyBox

  local x, y


  if previousSibling then
    if parentStyle.flexdirection == 'row' then
      y = previousSibling.y + previousSibling.height + (parentStyle.gap or 0)
    else
      x = previousSibling.x + previousSibling.width + (parentStyle.gap or 0)
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

  local flexTotal = 0
  for _, child in ipairs(parentNode and parentNode.props.children or {}) do
    flexTotal = flexTotal + (child.props.style.flex or { 0 })[1]
  end

  local height = math.max(parent.height or 0, style.height or 0)
  if (node.type == 'text') then
    height = 1
  end
  local children = {}

  ---@type LayoutObject
  local layoutObject = {
    backgroundcolor = style.backgroundcolor,
    border = style.border or {},
    children = children,
    color = style.color,
    height = height,
    margin = style.margin,
    padding = style.padding,
    width = 0,
    x = x,
    y = y,
  }
  layoutObject.width = getWidth(layoutObject, node, parent, parentNode)

  if parentNode
      and parentNode.props.style.justifycontent == 'space-between'
  then
    local freeSpace = parent.width
    for _, child in ipairs(parent.children) do
      freeSpace = freeSpace - child.width
    end

    layoutObject.x = previousSibling
        and (previousSibling.x
          + previousSibling.width
          + freeSpace / #parent.children
          - layoutObject.width)
        or layoutObject.x
  end

  return layoutObject
end

return Flex
