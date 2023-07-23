---@meta

---@alias nodeType any

---@alias alignOptions
---| 'auto'
---| 'stretch'
---| 'center'
---| 'flvish ex-start'
---| 'flex-end'
---| 'baseline'
---| 'inherit'

---@alias displayOptions
---| 'inline'
---| 'block'
---| 'inline-block'
---| 'flex'
---| 'grid'
---| 'inherit'
---| 'none'

---@class Style
---@field aligncontent? alignOptions
---@field alignitems? alignOptions
---@field alignself? alignOptions
---@field backgroundcolor? integer
---@field color? integer
---@field display? displayOptions
---@field flexdirection? 'row' | 'column'
---@field margin { top: integer, right: integer, bottom: integer, left: integer } | { [integer]: integer }
---@field padding { top: integer, right: integer, bottom: integer, left: integer } | { [integer]: integer }
---@field width integer
---@field height integer
---@field visible? boolean

---@alias text string | number

---@class Component : table
---@field [1] text | function | Component tag or child
---@field props Props
---@field [string] any attribute
---@field [number]? text | Component child

---if positive, is relative to the start of the parent Component if negative, is relative to the end of the parent Component
---@class Coordinate2D
---@field x number
---@field y number

---@class Attributes
---@field border? boolean
---@field display? displayOptions
---@field flexdirection? 'row' | 'column'
---@field visible? boolean

---@class Props
---@field children Component[]
---@field attributes Attributes
---@field style Style
---@field type? nodeType | string

---@class Node
---@field type nodeType
---@field value? string | number | function | Component
---@field props Props

---@class LayoutObject
---@field children LayoutObject[]
---@field height integer
---@field width integer
---@field x integer
---@field y integer
---@field node Node
---@field parent LayoutObject
---@field previous LayoutObject
---@field color integer
---@field backgroundcolor integer

---@class PaintObject
---@field type string
---@field x integer
---@field y integer
---@field height integer
---@field width integer
---@field value string
---@field vertical boolean
---@field color integer
---@field backgroundcolor integer
