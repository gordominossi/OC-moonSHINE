---@meta

---@class Event
---@field topic string
---@field partition string?
---@field timestamp string
---@field key string
---@field payload any
---@field headers { key: string, value: any }[]?

---@class Progress
---@field label string
---@field current number
---@field maximum number
---@field minimum number
