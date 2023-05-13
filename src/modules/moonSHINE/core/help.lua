local Help = {
    name = 'help',
    description = 'Prints this help.'
}
function Help.new()
    local self = {}

    function self.execute(commands)
        local commandList
        if not commands then
            commandList = { Help }
        elseif type(commands) == 'table' then
            if type(commands[1]) == 'table' then
                commandList = commands
            else
                commandList = { commands }
            end
        else
            error()
        end


        local commandDescriptions = {
        }
        for _, command in ipairs(commandList) do
            commandDescriptions[command.name] = command.description
        end

        local result = {}
        for command, description in pairs(commandDescriptions) do
            table.insert(result, { command .. ':', description })
        end

        return result
    end

    return self
end

return Help
