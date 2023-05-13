local Help = {
    name = 'help',
    description = 'Prints this help.'
}
function Help.new()
    local self = {}

    function self.execute(packages)
        local formattedPackages = {}

        for _, package in ipairs(packages or {}) do
            table.insert(
                formattedPackages,
                {
                    package.name .. '(' .. package.size .. ')' .. ':',
                    package.description,
                }
            )
        end

        return formattedPackages
    end

    return self
end

return Help
