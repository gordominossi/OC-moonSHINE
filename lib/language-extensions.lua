local function mergeTables(...)
  local parents = { ... }
  local copy = {}
  for _, parent in pairs(parents) do
    for key, value in pairs(parent) do
      copy[key] = value
    end
  end
  return copy
end

local function findOnPath(object, path)
  local value = object
  for key in string.gmatch(path, '[^%.]*') do
    if type(value) ~= 'table' or value[key] == nil then
      return nil
    end

    value = value[key]
  end

  return value
end

local function traverseBreadthFirst(tree, childrenPath)
  childrenPath = childrenPath or 'children'

  local children = findOnPath(tree, childrenPath)
  local list = type(children) == 'table' and { tree } or tree

  for _, parent in ipairs(list) do
    children = findOnPath(parent, childrenPath)
    for _, child in ipairs(children or {}) do
      table.insert(list, child)
    end
  end

  return list
end

return {
  findOnPath = findOnPath,
  mergeTables = mergeTables,
  traverseBreadthFirst = traverseBreadthFirst,
}
