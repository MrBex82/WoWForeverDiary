-- Quest book: accepted, completed, abandoned
local ADDON, WFD = ...
local L = WFD.L
local time, format = time, string.format

local snapshot = {}      -- questID -> true (currently visible in the log)
local titles = {}        -- questID -> title
local detailTitle, completeTitle
local detailText, detailNpc       -- what the quest giver said, for a quote in the diary
local pendingReward

local QUEST_STEPS = { [1] = true, [10] = true, [25] = true, [50] = true, [100] = true, [200] = true, [300] = true }

local function record(id, title, level)
    local C = WFD.C
    local q = C.quests[id]
    if not q then
        q = { title = title }
        C.quests[id] = q
    end
    if title and title ~= "" then q.title = title end
    if level and level > 0 then q.level = level end
    return q
end

-- the opening words of a quest text: one or two sentences, never more than about 160 letters
function WFD:QuoteOf(text)
    if not text or text == "" then return nil end
    text = text:gsub("[\r\n]+", " "):gsub("%s+", " "):gsub("^%s+", "")
    local out = ""
    for sentence in text:gmatch("[^%.!%?]+[%.!%?]+[\"']?") do
        local try = (out == "") and sentence:gsub("^%s+", "") or (out .. sentence)
        if #out >= 40 or #try > 160 then break end
        out = try
    end
    if out == "" then out = text end
    if #out > 160 then
        out = out:sub(1, 157):gsub("[%z\128-\191]*$", ""):gsub("[\192-\255][\128-\191]*$", ""):gsub("%s+%S*$", "") .. " ..."
    end
    return out
end

-- The game's event and the look at the quest log both report a new quest: noted[id] keeps it to once
-- per session. A quest that turns up in the log without the event was accepted in an earlier session
-- (q.open, or for older diaries: accepted and neither done nor abandoned) and is not noted again.
-- The event itself always counts, so a q.open left over from a turn-in the diary missed (demo mode)
-- cannot swallow the next time a repeatable quest is taken.
local noted = {}
local function accepted(id, title, byEvent)
    if WFD.paused or not id or noted[id] then return end
    noted[id] = true
    local C = WFD.C
    local q = C.quests[id]
    if not byEvent and q and (q.open or (q.acc and not q.done and not q.abandoned)) then
        q.open = true
        return
    end
    q = record(id, title or titles[id])
    q.acc = time()
    q.open = true
    q.abandoned = nil
    q.zone = WFD.zoneName
    local npc = WFD.lastNPC
    if npc and time() - npc.t < 30 then q.giver = npc.key end
    if detailText and (q.title == detailTitle) then
        q.quote = WFD:QuoteOf(detailText)
        q.giverName = detailNpc
    end
    local map, x, y = WFD:PlayerPos()
    if map then q.map, q.x, q.y = map, x, y end
    local d = WFD:Day()
    d.qa[#d.qa + 1] = id
    WFD:Log("quest", format(L["Quest accepted: %s"], q.title or ("#" .. id)))
end

local function scan(initial)
    local seen = {}
    local num = 0
    if GetNumQuestLogEntries then
        num = GetNumQuestLogEntries()
    elseif C_QuestLog and C_QuestLog.GetNumQuestLogEntries then
        num = C_QuestLog.GetNumQuestLogEntries()
    end
    for i = 1, num do
        -- "_" must stay local: writing the global "_" taints Blizzard's own code and gets the addon blocked
        local title, level, isHeader, qid, _
        if GetQuestLogTitle then
            title, level, _, isHeader, _, _, _, qid = GetQuestLogTitle(i)
        elseif C_QuestLog and C_QuestLog.GetInfo then
            local info = C_QuestLog.GetInfo(i)
            if info then title, level, isHeader, qid = info.title, info.level, info.isHeader, info.questID end
        end
        if not isHeader and qid and qid > 0 then
            seen[qid] = true
            titles[qid] = title
            if not snapshot[qid] then
                if initial then
                    record(qid, title, level).open = true
                else
                    record(qid, title, level)
                    accepted(qid, title)
                end
            end
        end
    end
    -- removed from log: turned in or abandoned
    for qid in pairs(snapshot) do
        if not seen[qid] then
            local stillOn = C_QuestLog and C_QuestLog.IsOnQuest and C_QuestLog.IsOnQuest(qid)
            if stillOn then
                seen[qid] = true        -- merely hidden by a collapsed header
            else
                noted[qid] = nil        -- taken again later, it counts again
                C_Timer.After(1.5, function()
                    local q = WFD.C and WFD.C.quests[qid]
                    if q and q.open and not WFD.paused then
                        q.open = nil
                        q.abandoned = time()
                        WFD:Log("quest", format(L["Quest abandoned: %s"], q.title or ("#" .. qid)))
                    end
                end)
            end
        end
    end
    snapshot = seen
end

WFD:OnInit(function() scan(true) end)

WFD:On("QUEST_DETAIL", function()
    detailTitle = GetTitleText()
    detailText = GetQuestText and GetQuestText() or nil
    detailNpc = UnitName("questnpc") or UnitName("npc")
end)
WFD:On("QUEST_COMPLETE", function() completeTitle = GetTitleText() end)
WFD:On("QUEST_PROGRESS", function() completeTitle = GetTitleText() end)

WFD:On("QUEST_ACCEPTED", function(_, a, b)
    local qid = b or a
    if type(qid) == "number" and qid > 0 and detailTitle and not titles[qid] then
        titles[qid] = detailTitle
    end
    if type(qid) == "number" and qid > 0 then accepted(qid, titles[qid], true) end
    scan(false)
end)
WFD:On("QUEST_LOG_UPDATE", function() scan(false) end)

-- remember which reward the player picked
if hooksecurefunc then
    pcall(hooksecurefunc, "GetQuestReward", function(choice)
        local link
        if choice and choice > 0 and GetQuestItemLink then
            link = GetQuestItemLink("choice", choice)
        end
        if not link and GetNumQuestRewards and GetNumQuestRewards() > 0 then
            link = GetQuestItemLink("reward", 1)
        end
        pendingReward = link
    end)
end

WFD:On("QUEST_TURNED_IN", function(_, id, xp, money)
    if WFD.paused or not WFD.C or not id then return end
    local C = WFD.C
    local q = record(id, titles[id] or completeTitle)
    q.done = time()
    q.open = nil
    q.abandoned = nil
    q.xp = xp
    q.money = money
    q.reward = pendingReward
    pendingReward = nil
    local npc = WFD.lastNPC
    if npc and time() - npc.t < 60 then q.turnin = npc.key end
    local map, x, y = WFD:PlayerPos()
    if map then q.dmap, q.dx, q.dy = map, x, y end
    q.zone = q.zone or WFD.zoneName

    local d = WFD:Day()
    d.qd[#d.qd + 1] = id
    C.questTotal = (C.questTotal or 0) + 1
    WFD:Log("quest", format(L["Quest completed: %s"], q.title or ("#" .. id)))
    if QUEST_STEPS[C.questTotal] then
        if C.questTotal == 1 then
            WFD:Milestone("quest", format(L["First quest completed: %s"], q.title or "?"), true)
        else
            WFD:Milestone("quest", format(L["%d quests completed"], C.questTotal), false)
        end
    end
    WFD.dirty = true
end)
