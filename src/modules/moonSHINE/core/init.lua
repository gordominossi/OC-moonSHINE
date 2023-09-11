local help = require('src.modules.moonSHINE.core.help')
local list = require('src.modules.moonSHINE.core.list')

local commands = {
  help = help,
  list = list,
}

local shine = {}
function shine.execute(...)
  local args = { ... }

  local command = commands[table.remove(args, 1)]

  if command then
    command.execute(table.unpack(args))
  else
    help.execute()
  end
end

return shine
