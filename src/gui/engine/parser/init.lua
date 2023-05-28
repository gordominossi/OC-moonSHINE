local Element = require('src.gui.engine.node.element')
local Text = require('src.gui.engine.node.text')

local headTags = {
    'base',
    'basefont',
    'bgsound',
    'link',
    'meta',
    'noscript',
    'script',
    'style',
    'title',
}

local selfClosingTags = {
    'area',
    'base',
    'br',
    'col',
    'embed',
    'hr',
    'img',
    'input',
    'link',
    'meta',
    'param',
    'source',
    'track',
    'wbr',
}

---@type HTMLParser
local HTMLParser = {}
function HTMLParser.new(body)
    ---@class HTMLParser
    local self = {
        body = body,
        unfinished = {},
    }

    ---@return Element
    function self.parse()
        local insideTag = false
        local text = ''

        for character in string.gmatch(self.body, '.') do
            if character == '<' then
                insideTag = true
                self.addText(text)
                text = ''
            elseif character == '>' then
                insideTag = false
                self.addTag(text)
                text = ''
            else
                text = text .. character
            end
        end

        if not insideTag then
            self.addText(text)
        end

        return self.finish()
    end

    function self.getAttributes(text)
        local tag = string.match(text, '^(/?%w+)')

        local attributes = {}

        for key, value in string.gmatch(
            string.gsub(text, '%w+%s*=%s*{.*}', ''),
            '(%w+)%s*=%s*["\']?(%w+)["\']?'
        ) do
            if string.match(value, '%d+') == value or string.match(value, '0x%w+') == value then
                value = tonumber(value)
            end
            attributes[string.lower(key)] = value
        end

        for key in string.gmatch(
            string.gsub(text, '%w+%s*=%s*{.*}', ''),
            '%w+%s+(%w+)%s*[^=%S/$]+'
        ) do
            attributes[string.lower(key)] = true
        end

        if string.match(text, '({.*})') then
            for tableKey, tableValue in string.gmatch(text, '(%w+)%s*=%s*{(.*)}') do
                attributes[string.lower(tableKey)] = {}

                for key, value in string.gmatch(tableValue, '(%w+)%s*=%s*["\']?(%w+)') do
                    if string.match(value, '%d+') == value or string.match(value, '0x%x+') == value then
                        value = tonumber(value)
                    end
                    attributes[string.lower(tableKey)][string.lower(key)] = value
                end

                for key in string.gmatch(tableValue, '%w+%s+(%w+)%s*[^=%S/$]+') do
                    attributes[string.lower(tableKey)][string.lower(key)] = true
                end
            end
        end

        return tag, attributes
    end

    function self.addText(text)
        text = string.gsub(text, '^%s+', '')
        text = string.gsub(text, '\n', '')
        if #text == 0 then
            return
        end

        self.implicitTags(nil)
        local parent = self.unfinished[#self.unfinished]
        local node = Text.new(text, parent.props)
        table.insert(parent.props.children, node)
    end

    function self.addTag(text)
        local tag, attributes = self.getAttributes(text)
        if tag[1] == '!' then
            return
        end
        self.implicitTags(tag)

        local parent = self.unfinished[#self.unfinished]

        if string.match(tag, '^/') then
            if #self.unfinished == 1 then
                return
            end

            local node = table.remove(self.unfinished)
            parent = self.unfinished[#self.unfinished]
            if parent then
                table.insert(parent.props.children, node)
            end
        else
            attributes.parent = parent
            local node = Element.new(tag, attributes)

            local isSelfClosingTag = false
            for _, selfClosingTag in ipairs(selfClosingTags) do
                if selfClosingTag == tag then
                    isSelfClosingTag = true
                    break
                end
            end

            if isSelfClosingTag then
                if parent then
                    table.insert(parent.props.children, node)
                end
            else
                table.insert(self.unfinished, node)
            end
        end
    end

    function self.implicitTags(tag)
        while true do
            local openTags = {}
            for _, node in ipairs(self.unfinished) do
                table.insert(openTags, node.type)
            end

            local isHeadTag = false
            for _, headTag in ipairs(headTags) do
                if headTag == tag then
                    isHeadTag = true
                    break
                end
            end

            if #openTags == 0 and tag == 'html' then
                self.addTag('html')
            elseif #openTags == 1 and
                openTags[1] == 'html' and
                tag ~= 'head' and
                tag ~= 'body' and
                tag ~= '/html' then
                self.addTag(isHeadTag and 'head' or 'body')
            elseif #openTags == 2 and
                openTags[1] == 'html' and
                openTags[2] == 'head' then
                if not isHeadTag and tag ~= '/head' then
                    self.addTag('/head')
                end
            else
                break
            end
        end
    end

    function self.finish()
        if #self.unfinished == 0 then
            self.addTag('html')
        end
        while #self.unfinished > 1 do
            local node = table.remove(self.unfinished)
            local parent = self.unfinished[#self.unfinished]
            table.insert(parent.props.children, node)
        end
        return table.remove(self.unfinished)
    end

    return self
end

---@param component Component
---@return Node
local function parseComponent(component)
    local props = {
        ---@type Style
        style = { layout = 'block' },
    }
    for attribute, value in pairs(component) do
        if type(attribute) == 'string' and attribute ~= 'children' then
            props[string.lower(attribute)] = value
        end
    end

    ---@type string | function
    local elementType = props.type or 'div'
    local childIndex = 1
    local child = component[childIndex]
    if type(child) == 'string' and #component == 1 then
        return Text.new(child, props)
    elseif child and type(child) ~= 'table' then
        elementType = child --[[@as string | function]]
        childIndex = 2
    end

    ---@type Node[]
    local children = {}
    while childIndex <= #component do
        ---@type text | Component
        child = component[childIndex]

        if type(child) == 'table' then
            child.style = child.style or props.style
            child.style.color = child.style.color or props.style.color
            child.style.backgroundcolor = child.style.backgroundcolor or props.style.backgroundcolor or 0x000000
            table.insert(children, parseComponent(child))
        elseif type(child) == 'string' or type(child) == 'number' then
            if childIndex == 1 and child == 'br' then
                table.insert(children, Element.new(child))
            else
                table.insert(children, Text.new(tostring(child), props))
            end
        end
        childIndex = childIndex + 1
    end

    return Element.new(elementType, props, children)
end

local Parser = {}
---@param body Component | string
function Parser.new(body)
    ---@class Parser
    local self = {
        body = body
    }

    ---@return Node
    function self.parse()
        if type(self.body) == 'string' then
            return HTMLParser.new(self.body --[[@as string]]).parse()
        elseif type(self.body) == 'table' then
            return parseComponent(self.body --[[@as Component]])
        end
        error('unsupported `body` type', 1)
    end

    return self
end

return Parser
