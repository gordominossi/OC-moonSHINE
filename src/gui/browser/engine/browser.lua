local DocumentLayout = require('src.gui.browser.engine.layout')
local Parser = require('src.gui.browser.engine.parser')

local Tab = {}
function Tab.new(browser)
    local self = {
        history = {},
        scroll = 0,
        scrollChangedInTab = false,
        needsLayout = false,
        needsPaint = false,
        browser = browser
    }

    function self.load(url, body)
        self.scroll = 0
        self.scrollChangedInTab = true

        body = request(url, self.url, body)
        self.url = url
        table.insert(self.history, url)

        self.node = Parser.new(body).parse()
        self.browser.setNeedsAnimationFrame(self)
    end

    function self.runAnimationFrame(scroll)
        if not self.scrollChangedInTab then
            self.scrollChangedInTab = scroll
        end

        self.render()

        local clampedScroll = math.max(0, math.min(self.scroll, self.document.height))
        if clampedScroll ~= scroll then
            self.scrollChangedInTab = true
        end
        self.scroll = clampedScroll
        scroll = self.scrollChangedInTab and self.scroll or nil

        self.browser.commit(
            self,
            table.unpack({
                self.url,
                scroll,
                self.document.height,
                self.displayList
            })
        )

        self.displayList = nil
        self.scrollChangedInTab = false
    end

    function self.render()
        if self.needsLayout then
            self.document = DocumentLayout.new(self.node --[[@as Element]])
            self.document.layout()
            self.needsPaint = true
            self.needsLayout = false
        end

        if self.needsPaint then
            self.displayList = {}
            self.document.paint(self.displayList)
            self.needsPaint = false
        end
    end

    return self
end

local Browser = {}
function Browser.new()
    local self = {
        tabs = {},
        scroll = 0,
        needsDraw = false,
        needsAnimationFrame = false,
        activeTabHeight = 0,
        drawList = {}
    }

    function self.render()
        self.tabs[self.activeTab].render(self.scroll)
    end

    function self.commit(tab, url, scroll, documentHeight, displayList)
        if tab == self.activeTab then
            self.url = url
        end
        if scroll then
            self.scroll = scroll
        end
        self.activeTabHeight = documentHeight
        if displayList then
            self.activeTabDisplayList = displayList
        end
        self.needsDraw = true
    end

    function self.setNeedsAnimationFrame(tab)
        if tab and tab == self.tabs[self.activeTab] then
            self.needsAnimationFrame = true
        end
    end

    return self
end

return Browser
