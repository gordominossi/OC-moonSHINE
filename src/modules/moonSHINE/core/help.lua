---@type HelpCommand
local Help = {
  name = 'help',
  description = 'Prints this help.'
}

function Help.new()
  ---@class HelpCommand
  local self = {}

  ---@param commands? table[]
  ---@return string[]
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

    local result = {}
    for _, command in pairs(commandList) do
      table.insert(result, { command.name .. ':', command.description })
    end

    return result
  end

  return self
end

return Help
