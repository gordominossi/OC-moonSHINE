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

local function traverseBreadthFirst(tree)
    local list = tree.children and { tree } or tree

    for _, parent in ipairs(list) do
        for _, child in ipairs(parent.children or {}) do
            table.insert(list, child)
        end
    end

    return list
end

return {
    mergeTables = mergeTables,
    traverseBreadthFirst = traverseBreadthFirst,
}
