local describe = _ENV.describe
local it = _ENV.it

local List = require('src.modules.moonSHINE.core.list')

describe('Help cli command', function()
  local list = List.new()

  local mockPackage = {
    name = 'mock',
    size = 128,
    description = 'This is a mock'
  }
  local mockPackage2 = {
    name = 'mock2',
    size = 256,
    description = 'This is also a mock'
  }
  local allPackages = {
    mockPackage,
    mockPackage2,
  }

  local formattedPackagesList = {}
  for _, package in ipairs(allPackages) do
    table.insert(formattedPackagesList, { package.name .. '(' .. package.size .. ')' .. ':', package.description })
  end

  it('should return an empty table when called with an empty list', function()
    local result = list.execute({})
    assert.same({}, result)
  end)

  it('should return a table containing only the description table of the packages passed in', function()
    local result = list.execute({ allPackages[1] })
    assert.equals(1, #result)
    assert.same(formattedPackagesList[1], result[1])

    result = list.execute(allPackages)
    assert.same(formattedPackagesList, result)
  end)
end)
