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

return {
    mergeTables = mergeTables
}
