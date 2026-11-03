-- The library: every book, note and plaque read in the world is kept on the shelf of the account, to be read
-- again later. Quest texts and conversations are not books and are not kept.
--
-- What the client tells (see ITEM_TEXT_BEGIN / ITEM_TEXT_READY / ITEM_TEXT_CLOSED): while a readable thing is
-- open, ITEM_TEXT_READY fires for every page that is shown; ItemTextGetText() is the text of that page.
-- Pages are only read, never turned by the diary. A book read in parts is completed by the next reading.
local ADDON, WFD = ...
local L = WFD.L
local time, format = time, string.format

local MAX_BOOKS = 300           -- the shelf has room for this many
local MAX_CHARS = 30000         -- of one book; a longer text is cut
local MAX_TOTAL = 1500000       -- of the whole shelf: the saved file must not grow without limit
local STONE = { Stone = true, Marble = true, Silver = true, Bronze = true }

local cur                       -- the text that is open right now

local function call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a = pcall(fn, ...)
    if ok then return a end
end

-- the page text without markup: books of later clients arrive as little HTML documents
local function plain(text)
    text = tostring(text or "")
    text = text:gsub("<[Bb][Rr]%s*/?>", "\n"):gsub("</[Pp]>", "\n\n"):gsub("</[Hh]%d>", "\n\n")
    text = text:gsub("<[^>]*>", "")
    -- display codes (textures, links, colours) have no place in a stored text
    text = text:gsub("|T.-|t", ""):gsub("|H.-|h(.-)|h", "%1"):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    text = text:gsub("&quot;", '"'):gsub("&amp;", "&"):gsub("&lt;", "<"):gsub("&gt;", ">"):gsub("&nbsp;", " ")
    text = text:gsub("\r", ""):gsub("[ \t]+\n", "\n"):gsub("\n\n\n+", "\n\n")
    return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- a short checksum of a text, so that two books of one title are told apart
local function sum(s)
    local a, b = 1, 0
    for i = 1, math.min(#s, 400) do
        a = (a + s:byte(i)) % 65521
        b = (b + a) % 65521
    end
    return b * 65536 + a
end

local function shelf()
    local S = WFD.S
    if not S then return nil end
    S.library = S.library or {}
    return S.library
end

-- the books in the order they were first read; the demo has its own
function WFD:Library()
    local list = self.demo and self.C and self.C.demoLibrary or shelf() or {}
    local out = {}
    for id, b in pairs(list) do out[#out + 1] = { id = id, b = b } end
    table.sort(out, function(x, y)
        if (x.b.t or 0) ~= (y.b.t or 0) then return (x.b.t or 0) < (y.b.t or 0) end
        return x.id < y.id
    end)
    return out
end

function WFD:Book(id)
    local list = self.demo and self.C and self.C.demoLibrary or shelf()
    return list and list[id]
end

-- the pages of a book as one text, in the order of the pages (a missing page leaves a gap in the numbers only)
function WFD:BookText(b)
    local keys = {}
    for p in pairs(b.pages or {}) do keys[#keys + 1] = p end
    table.sort(keys)
    local out = {}
    for _, p in ipairs(keys) do out[#out + 1] = b.pages[p] end
    return table.concat(out, "\n\n")
end

-- are all pages there? The first page has to be there, none in between missing, and the last without a next one
function WFD:BookComplete(b)
    local n = 0
    for p in pairs(b.pages or {}) do n = math.max(n, p) end
    if n == 0 or b.more then return false end
    for p = 1, n do if not b.pages[p] then return false end end
    return true
end

local function kindOf(material, pages, chars)
    if material and STONE[material] then return "plaque" end
    if pages > 1 or chars > 700 then return "book" end
    return "note"
end

local function save()
    local t = cur
    cur = nil
    if not t or WFD.paused or WFD.demo then return end
    local list = shelf()
    if not list or not t.title or t.title == "" then return end
    local first
    for p = 1, 200 do if t.pages[p] then first = t.pages[p] break end end
    if not first or first == "" then return end
    local id = t.title .. "#" .. sum(first)
    local b = list[id]
    if not b then
        local n, total = 0, 0
        for _, other in pairs(list) do
            n = n + 1
            for _, text in pairs(other.pages or {}) do total = total + #text end
        end
        if n >= MAX_BOOKS or total >= MAX_TOTAL then return end
        b = { t = t.t, who = UnitName("player"), zone = t.zone, sub = t.sub, creator = t.creator, pages = {}, title = t.title }
        list[id] = b
        WFD:Log("book", t.title)
    end
    local chars, count = 0, 0
    for p, text in pairs(t.pages) do b.pages[p] = text end
    for _, text in pairs(b.pages) do chars = chars + #text; count = count + 1 end
    -- the book as a whole is cut when it is longer than any book should be
    if chars > MAX_CHARS then
        for p = count, 2, -1 do
            if chars <= MAX_CHARS then break end
            chars = chars - #(b.pages[p] or "")
            b.pages[p] = nil
        end
    end
    -- "more follows" only counts for the last page of the book as far as it is known
    local top = 0
    for p in pairs(b.pages) do top = math.max(top, p) end
    if t.lastPage and t.lastPage >= top then b.more = t.more or nil end
    b.kind = kindOf(t.material, count, chars)
    b.last = time()
    -- this character has read it (for the honours)
    local C = WFD.C
    if C then
        C.booksRead = C.booksRead or {}
        C.booksRead[id] = true
    end
    WFD.dirty = true
end

WFD:On("ITEM_TEXT_BEGIN", function()
    if WFD.paused or WFD.demo then return end
    -- a saved letter is not a book of the world. IsVisible, not IsShown: the inbox frame is "shown" even
    -- while the mail window is closed, only its parent is hidden
    local mail = (_G.MailFrame and _G.MailFrame:IsVisible()) or (_G.InboxFrame and _G.InboxFrame:IsVisible())
    if mail then cur = nil return end
    cur = {
        title = call(_G.ItemTextGetItem), creator = call(_G.ItemTextGetCreator), material = call(_G.ItemTextGetMaterial),
        pages = {}, t = time(), zone = WFD.zoneName, sub = call(_G.GetSubZoneText),
    }
end)

WFD:On("ITEM_TEXT_READY", function()
    if WFD.paused or WFD.demo or not cur then return end
    local text = plain(call(_G.ItemTextGetText))
    if text == "" then return end
    local page = tonumber(call(_G.ItemTextGetPage)) or (#cur.pages + 1)
    cur.pages[page] = text
    -- whether another page follows the one shown last
    cur.lastPage = page
    cur.more = call(_G.ItemTextHasNextPage) and true or false
end)

WFD:On("ITEM_TEXT_CLOSED", function()
    local ok, err = pcall(save)
    if not ok then cur = nil WFD:Error("library", err) end
end)

-- texts that stood on the shelf before the honours kept count: the ones this character was first to read
WFD:OnInit(function()
    local C, list = WFD.C, shelf()
    if not C or not list then return end
    C.booksRead = C.booksRead or {}
    local me = UnitName("player")
    for id, b in pairs(list) do
        if b.who == me and not C.booksRead[id] then C.booksRead[id] = true end
    end
end)
