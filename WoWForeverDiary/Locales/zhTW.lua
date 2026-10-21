-- Traditional Chinese translation (English phrases are the keys)
local ADDON, WFD = ...
local L, loc = WFD:NewLocale("zhTW")

local T = {
    -- chat / log
    ["Diary"] = "日記",
    ["Travel diary active - today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
        "旅行日記已啟用 - 今天是|cffffd100第%d天|r。輸入|cffffd100/wfd|r開啟日記。",
    ["%d creatures slain in total"] = "總共擊殺了%d個生物",
    ["First victory over the boss %s!"] = "首次擊敗首領%s！",
    ["Rare creature slain: %s"] = "擊殺稀有生物：%s",
    ["Boss %s defeated again (%dx)"] = "再次擊敗首領%s（%dx）",
    ["Died to %s in %s"] = "死於%s（%s）",
    ["Died in %s"] = "死亡（%s）",
    ["Met %s (%s)"] = "結識%s（%s）",
    ["Hearthstone bound to %s"] = "爐石綁定於：%s",
    ["Quest accepted: %s"] = "接受任務：%s",
    ["Quest abandoned: %s"] = "放棄任務：%s",
    ["Quest completed: %s"] = "完成任務：%s",
    ["First quest completed: %s"] = "完成第一個任務：%s",
    ["%d quests completed"] = "已完成%d個任務",
    ["Took a flight to %s"] = "飛往%s",
    ["Wealth reached: %s"] = "財富達到：%s",
    ["Found %s"] = "獲得：%s",
    ["Epic find: %s"] = "史詩級發現：%s",
    ["Rare find: %s"] = "精良發現：%s",
    ["Discovered a new land: %s"] = "發現新地區：%s",
    ["Entered %s"] = "抵達%s",
    ["Discovered: %s (%s)"] = "發現：%s（%s）",
    ["First visit to the dungeon %s"] = "首次造訪地城%s",
    ["Entered the dungeon %s"] = "進入地城%s",
    ["Level %d reached!"] = "達到%d級！",
    ["%s increased to %d"] = "%s提升至%d",
    ["%s mastered up to %d"] = "%s精通至%d",
    ["Used the hearthstone"] = "使用了爐石",
    ["%dh %02dm"] = "%d小時%02d分",
    ["%dm"] = "%d分鐘",

    -- window
    ["Travel Diary of %s"] = "%s的旅行日記",
    ["Day %d"] = "第%d天",
    ["Level %d"] = "等級%d",
    ["Level %s"] = "等級%s",
    ["online"] = "線上",
    ["LIFELINE"] = "生命軌跡",
    ["now"] = "現在",
    ["Screenshot:"] = "截圖：",
    ["Click to read this day."] = "點擊閱讀這一天。",
    ["Click to open the diary."] = "點擊開啟日記。",
    ["%d kills today"] = "今天擊殺%d",
    ["%d quests today"] = "今天%d個任務",
    ["DEMO MODE - invented data"] = "示範模式 - 虛構資料",

    -- tabs
    ["Journal"] = "日記",
    ["World Map"] = "世界地圖",
    ["Bestiary"] = "怪物圖鑑",
    ["People"] = "人物",
    ["Quest Book"] = "任務簿",
    ["Statistics"] = "統計",
    ["Export"] = "匯出",

    -- journal
    ["Today"] = "今天",
    ["Chronicle"] = "編年史",
    ["Overview"] = "總覽",
    ["Nothing recorded yet."] = "尚無任何紀錄。",
    ["Balance of the day"] = "今日結算",
    ["Enemies slain"] = "擊敗的敵人",
    ["Quests completed"] = "完成的任務",
    ["(done / accepted)"] = "（完成 / 接受）",
    ["People spoken to"] = "交談過的人",
    ["Experience gained"] = "獲得的經驗",
    ["Distance travelled"] = "移動距離",
    ["flown"] = "飛行",
    ["Time online"] = "線上時間",
    ["Deaths"] = "死亡",
    ["Jumps"] = "跳躍",
    ["Purse"] = "錢包",
    ["Income"] = "收入",
    ["Expenses"] = "支出",
    ["Net"] = "淨額",
    ["Fallen foes"] = "倒下的敵人",
    ["... and %d more kinds"] = "……另有%d種",
    ["Completed quests"] = "完成的任務",
    ["Spoken to"] = "交談對象",
    ["Loot (%d items)"] = "戰利品（%d件）",
    ["Loot"] = "戰利品",
    ["Places"] = "地點",
    ["Special moments"] = "特別時刻",
    ["photo"] = "照片",

    -- map
    ["Footsteps"] = "足跡",
    ["Kills"] = "擊殺",
    ["Quests"] = "任務",
    ["No map art available for this area."] = "此區域沒有可用的地圖圖片。",
    ["VISITED AREAS"] = "造訪過的區域",
    ["Play"] = "播放",
    ["Stop"] = "停止",
    ["Only this day"] = "只看這一天",
    ["Drag the slider through time: your footsteps grow day by day."] = "拖動滑桿穿越時間：你的足跡一天天延伸。",
    ["Spoken to %d times"] = "交談%d次",
    ["Quest accepted here"] = "在此接受任務",
    ["Quest handed in here"] = "在此交付任務",
    ["You died here"] = "你在此死亡",
    ["Killed by %s"] = "被%s擊殺",
    ["Footprints: %d spots   Kills: %d   Deaths: %d"] = "足跡：%d處   擊殺：%d   死亡：%d",
    ["No travels recorded yet."] = "尚無旅行紀錄。",

    -- bestiary
    ["Name"] = "名稱",
    ["Level"] = "等級",
    ["Recent"] = "最近",
    ["Foes"] = "敵人",
    ["Bosses and rares"] = "首領與稀有",
    ["Boss"] = "首領",
    ["Rare"] = "稀有",
    ["Elite"] = "菁英",
    ["Normal"] = "普通",
    ["No portrait"] = "無肖像",
    ["KILLS PER DAY"] = "每日擊殺",
    ["Kills: %d"] = "擊殺：%d",
    ["Rank: #%d of %d kinds"] = "排名：第%d名（共%d種）",
    ["First kill:"] = "首次擊殺：",
    ["Last kill:"] = "最後擊殺：",
    ["Seen in:"] = "出沒於：",
    ["This creature killed you %d times."] = "這個生物殺死過你%d次。",
    ["Your nemesis"] = "你的宿敵",
    ["Last seen in:"] = "最後目擊於：",
    ["Last time:"] = "上次：",
    ["You have killed it %d times."] = "你已擊殺牠%d次。",
    ["Nobody has killed you yet."] = "還沒有誰殺死過你。",

    -- people
    ["Talks"] = "交談",
    ["First met"] = "初次見面",
    ["Show on map"] = "在地圖上顯示",
    ["QUESTS WITH THIS PERSON"] = "與此人相關的任務",
    ["Conversations: %d"] = "交談：%d次",
    ["Found in:"] = "所在地：",
    ["First met:"] = "初次見面：",
    ["Last met:"] = "最後見面：",
    ["given and received"] = "發放與交付",
    ["given"] = "發放",
    ["handed in"] = "交付",
    ["No quests recorded."] = "沒有任務紀錄。",
    ["Role:"] = "職能：",
    ["All"] = "全部",
    ["%d of %d people"] = "%d / %d人",
    ["You have not talked to anyone yet."] = "你還沒有和任何人交談過。",
    ["Conversation"] = "交談",
    ["Vendor"] = "商人",
    ["Trainer"] = "訓練師",
    ["Flight master"] = "飛行管理員",
    ["Banker"] = "銀行員",
    ["Stable master"] = "獸欄管理員",
    ["Petitions"] = "公會申請",
    ["Auctioneer"] = "拍賣師",

    -- quests
    ["Completed"] = "已完成",
    ["Open"] = "未完成",
    ["Abandoned"] = "已放棄",
    ["In progress"] = "進行中",
    ["Received from:"] = "任務來源：",
    ["Handed in to:"] = "交付給：",
    ["Accepted:"] = "接受：",
    ["Completed:"] = "完成：",
    ["Took:"] = "耗時：",
    ["Experience:"] = "經驗：",
    ["Gold reward:"] = "金幣獎勵：",
    ["Reward:"] = "獎勵：",
    ["Where I accepted it"] = "接受任務的地方",
    ["Where I handed it in"] = "交付任務的地方",
    ["%d of %d quests completed"] = "已完成%d / %d個任務",
    ["No quests recorded yet."] = "尚無任務紀錄。",

    -- statistics
    ["Gold"] = "金幣",
    ["XP"] = "經驗",
    ["Time"] = "時間",
    ["Distance"] = "距離",
    ["Nothing to chart yet."] = "尚無可顯示的資料。",
    ["WHERE THE MONEY CAME FROM"] = "錢從哪裡來",
    ["WHERE THE MONEY WENT"] = "錢花到哪裡去",
    ["In total: %d kills  |  %d quests  |  %s online  |  %.1f km on foot  |  %d deaths  |  %d jumps"] =
        "總計：擊殺%d  |  任務%d  |  線上%s  |  步行%.1f公里  |  死亡%d  |  跳躍%d",

    -- money categories
    ["Quest rewards"] = "任務獎勵",
    ["Vendor sales"] = "賣給商人",
    ["Mail"] = "郵件",
    ["Trading"] = "交易",
    ["Auction house"] = "拍賣場",
    ["Repairs"] = "修理",
    ["Purchases"] = "購買",
    ["Training"] = "訓練",
    ["Flights"] = "飛行",
    ["Bank"] = "銀行",
    ["Other"] = "其他",

    -- export / settings
    ["Born:"] = "誕生：",
    ["As text"] = "純文字",
    ["Select all"] = "全選",
    ["Ctrl+C copies the selection."] = "按Ctrl+C複製選取內容。",
    ["SETTINGS"] = "設定",
    ["Take a screenshot at milestones"] = "在重要時刻自動截圖",
    ["Announce milestones in chat"] = "在聊天視窗宣告重要時刻",
    ["Show minimap button"] = "顯示小地圖按鈕",
    ["First day"] = "第一天",

    -- redesigned interface
    ["Travel Diary"] = "旅行日記",
    ["Day of life"] = "生命天數",
    ["Days of life"] = "生命天數",
    ["Memories of the day"] = "今日回憶",
    ["A day without great events."] = "平靜無大事的一天。",
    ["Experience"] = "經驗",
    ["Conversations"] = "交談",
    ["On foot"] = "步行",
    ["Map of my travels"] = "我的旅行地圖",
    ["Layers"] = "圖層",
    ["%d kinds - %d kills"] = "%d種 - 擊殺%d",
    ["%d nemeses"] = "%d個宿敵",
    ["No creature has fallen yet."] = "還沒有任何生物倒下。",
    ["Slain"] = "擊殺數",
    ["Rank"] = "排名",
    ["First kill"] = "首次擊殺",
    ["Last kill"] = "最後擊殺",
    ["Seen in"] = "出沒於",
    ["Killed you"] = "殺死你",
    ["You slew it"] = "被你擊殺",
    ["Last seen in"] = "最後目擊於",
    ["Last time"] = "上次",
    ["\"First encountered on day %d in %s.\""] = "「第%d天在%s初次相遇。」",
    ["\"Revenge is a dish best served cold.\""] = "「君子報仇，十年不晚。」",
    ["Acquaintances"] = "相識之人",
    ["Found in"] = "所在地",
    ["Place"] = "地點",
    ["Last met"] = "最後見面",
    ["Region"] = "區域",
    ["Received from"] = "任務來源",
    ["Handed in to"] = "交付給",
    ["Accepted"] = "接受",
    ["Took"] = "耗時",
    ["Reward"] = "獎勵",
    ["Balance of a life"] = "一生的總結",
    ["Since %s"] = "自%s起",
    ["Remarkable"] = "值得一提",
    ["Bloodiest day"] = "最血腥的一天",
    ["Favourite prey"] = "最愛的獵物",
    ["Arch-enemy"] = "頭號死敵",
    ["Home of the heart"] = "心靈的故鄉",
    ["Closest confidant"] = "最親密的知己",
    ["Day by day"] = "日復一日",
    ["Came from"] = "收入來源",
    ["Went to"] = "支出去向",
    ["Transcript"] = "文字紀錄",
    ["Settings"] = "設定",
    ["Size of the book"] = "書本大小",
    ["Demo"] = "示範",
    ["Start demo mode"] = "啟動示範模式",
    ["Leave demo mode"] = "離開示範模式",
    ["Commands"] = "指令",
    ["open or close the diary"] = "開啟或關閉日記",
    ["explore with invented data"] = "用虛構資料探索",
    ["screenshots on or off"] = "開啟或關閉截圖",
    ["minimap button on or off"] = "顯示或隱藏小地圖按鈕",
    ["\"Screenshots are saved in the Screenshots folder of your game.\""] = "「截圖會儲存在遊戲的 Screenshots 資料夾中。」",
}
for k, v in pairs(T) do L[k] = v end

-- dates and diary entries
loc.date = "%Y/%m/%d"
loc.dayMonth = "%m/%d"
loc.weekdays = { "星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六" }
loc.months = { "一月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "十一月", "十二月" }
function loc.longDate(d)
    return string.format("%d年%d月%d日 %s", d.year, d.month, d.day, loc.weekdays[d.wday])
end
loc.listSep = "、"
loc.sentenceSep = ""
loc.quotes = { "「", "」" }

loc.narrator = {
    birth = {
        "第1天。我是%s%s，今天在%s醒來。接下來會怎樣？完全不知道。",
        "第1天。%s%s，剛到%s。走著瞧吧。",
    },
    begin = {
        "第1天。從今天起，我把路上發生的事記下來。",
    },
    open = {
        "第%d天，%s。",
        "第%d天。今天主要在%s。",
        "第%d天。又上路了，這次大多在%s一帶。",
    },
    far = "某個不知名的地方",
    walk = {
        "今天大概走了%s公里%s。",
        "腳告訴我：差不多%s公里%s。",
        "走了%s公里左右%s，腿都酸了。",
    },
    via = "（%s）",
    fly = "剩下的路是飛過去的。",
    kills = {
        "今天打倒了%d個敵人。",
        "解決了%d隻怪。",
        "世上又少了%d個敵人。",
    },
    top = {
        "其中最多的是%s（%dx）。",
        "最常擋路的是%s（%dx）。",
    },
    special = "值得記住的：%s。",
    deaths = {
        "今天死了%d次。%s",
        "趴在地上%d次。%s",
    },
    deathBy = "最後一次是被%s幹掉的。",
    noDeath = {
        "今天一次都沒死。",
        "零死亡，不錯。",
    },
    questDone = {
        "完成了%d個任務：%s。",
        "從清單上劃掉：%s。",
    },
    questAcc = {
        "又接了%d個新任務。",
        "馬上又有%d個新任務在等著。",
    },
    questAccOnly = {
        "接了%d個新任務，還一個都沒完成。",
    },
    more = "等等",
    quote = {
        "%s說：%s",
        "%s的原話：%s",
    },
    quoteAnon = "記住了一句話：%s",
    npcs = {
        "跟%d個人聊過，包括%s。",
        "聊了%d次，比如跟%s。",
    },
    gain = {
        "錢包重了%s。",
        "算下來多賺了%s。",
    },
    loss = {
        "錢包輕了%s。",
        "算下來今天花掉%s。",
    },
    src = "收入大多來自：%s（%s）。",
    spent = "錢大多花在：%s（%s）。",
    item = {
        "今天最好的收穫：%s。",
        "今日戰利品：%s。",
    },
    levels = {
        "升到%s級了。",
        "等級%s！",
    },
    quiet = {
        "平靜的一天，沒什麼好寫的。",
        "今天沒發生什麼事。",
    },
    begun = {
        "這一天才剛開始。",
        "今天還早得很。",
        "新的一天才剛起步。",
    },
    ongoing = {
        "今天還沒結束。",
        "未完待續……",
        "看看今天還會發生什麼。",
    },
    close = {
        "今天就到這裡。",
        "夠了，明天繼續。",
        "先休息一下。",
        "看看明天會怎樣。",
    },
    closeLong = {
        "在外面跑了%s，今天夠了。",
        "跑了%s，累壞了。",
    },
    none = "這一天沒有記錄。",
}

-- book interface
L["Appendix"] = "附錄"
L["Begun on %s"] = "始於%s"
L["Bookmark"] = "書籤"
L["Click to open today's entry."] = "點擊開啟今天的日記。"
L["Click to open"] = "點擊開啟"
L["Contents"] = "目錄"
L["Notes"] = "筆記"
L["Page %d"] = "第%d頁"
L["Realm: %s"] = "伺服器：%s"
L["This book belongs to"] = "本書屬於"
L["in %s, at level %d"] = "於%s，等級%d"
L["in %s, on the first day of my life"] = "於%s，在我生命的第一天"
L["of"] = "記錄者"

-- book pages (diary, appendix)
L["\"Whoever wanders, gathers stories.\""] = "「行萬里路，拾萬般故事。」"
L["Arrival in %s"] = "抵達%s"
L["Days in %s"] = "%s的日子"
L["Shadows over %s"] = "籠罩%s的陰影"
L["The roads of %s"] = "%s之路"
L["Under the skies of %s"] = "在%s的天空下"
L["Awakening in %s"] = "於%s甦醒"
L["Return to %s"] = "重返%s"
L["Chapter"] = "篇章"
L["Level %d-%d"] = "等級%d-%d"
L["Days %d-%d"] = "第%d-%d天"
L["Level %d!"] = "等級%d！"
L["%d kills"] = "擊殺%d"
L["%d quests"] = "%d個任務"
L["died %dx"] = "死亡%d次"
L["Kept as a memory"] = "珍藏留念"
L["Click to read this day aloud in chat."] = "點擊在聊天視窗中朗讀這一天。"
L["The pages are still empty. Go and live an adventure!"] = "書頁仍是一片空白。去展開一場冒險吧！"
L["p. %d"] = "第%d頁"
L["Milestones"] = "里程碑"
L["The great moments of a life"] = "一生中的重大時刻"
L["No milestones yet."] = "尚無里程碑。"
L["Maps"] = "地圖"
L["%s spent here"] = "在此度過%s"
L["Route"] = "路線"
L["Kill sites"] = "擊殺地點"
L["Graves"] = "墳墓"
L["First visit"] = "首次造訪"
L["Time spent"] = "停留時間"
L["Creatures slain here"] = "在此擊殺的生物"
L["Acquaintances here"] = "在此結識的人"
L["A naturalist's notes"] = "博物學家的筆記"
L["Slain %d times"] = "擊殺%d次"
L["Every creature, by number slain"] = "所有生物，依擊殺數排序"
L["Everyone I met on my way"] = "旅途中遇見的每一個人"
L["Every coin, in and out"] = "每一枚錢幣的進與出"
L["Balance"] = "結餘"
L["Day"] = "日期"
L["Tasks taken and done"] = "接下與完成的任務"
L["Scribe's notes"] = "抄寫員筆記"
L["How this book is kept"] = "本書的記錄方式"
L["Copy the diary as text"] = "以文字複製日記"
L["Copy the diary as JSON"] = "以JSON複製日記"
L["Ledger"] = "帳本"

-- own notes
L["Click here to write your own notes ..."] = "點擊此處寫下你自己的筆記……"
L["My own thoughts:"] = "我的想法："
L["+ note"] = "+ 筆記"
L["edit note"] = "編輯筆記"
L["Save"] = "儲存"
L["Cancel"] = "取消"

-- cards
L["Wanted poster"] = "通緝令"
L["Acquaintance"] = "相識之人"
L["Click for the wanted poster."] = "點擊查看通緝令。"
L["Click for the portrait."] = "點擊查看肖像。"

-- collector's album
L["A collector's album of every creature slain"] = "所有擊殺生物的收藏圖鑑"
L["kinds collected  -  %d creatures slain"] = "種已收集  -  擊殺%d個生物"
L["Bronze"] = "青銅"
L["Silver"] = "白銀"
L["Mithril"] = "秘銀"
L["Legend"] = "傳說"
L["Collect %d kinds of creatures."] = "收集%d種生物。"
L["Reached!"] = "已達成！"
L["%d still missing."] = "還差%d種。"
L["Bosses"] = "首領"
L["Rare creatures"] = "稀有生物"
L["Album pages"] = "圖鑑頁"
L["%d kinds"] = "%d種"
L["Lv %s"] = "%s級"
L["NEW"] = "新"
L["not yet found"] = "尚未發現"

-- language switch
L["German"] = "德文"
L["English"] = "英文"
L["French"] = "法文"
L["Spanish"] = "西班牙文"
L["Portuguese"] = "葡萄牙文"
L["Russian"] = "俄文"
L["Korean"] = "韓文"
L["Chinese (traditional)"] = "中文（繁體）"
L["Language"] = "語言"
L["Game language (%s)"] = "遊戲語言（%s）"
L["The diary will reload the interface to switch the language."] = "日記將重新載入介面以切換語言。"
L["Korean and Chinese text needs a game client with those fonts."] = "韓文與中文需要具備對應字型的遊戲用戶端才能顯示。"

-- map spreads
L["Places of note"] = "值得一提的地點"
L["Nobody was met here yet."] = "你還沒有在這裡遇見任何人。"
L["Grave"] = "墳墓"
L["Chronicle of the region"] = "區域編年史"
L["Visits"] = "造訪次數"
L["Quests completed here"] = "在此完成的任務"
L["Deaths here"] = "在此死亡"
L["Most hunted here"] = "在此最常狩獵"
L["Places discovered"] = "已發現的地點"

-- companions, honours, treasures, memories, obituary
L["%d days of life  -  %d creatures slain  -  %d quests completed"] = "生命%d天  -  擊殺%d個生物  -  完成%d個任務"
L["%d days"] = "%d天"
L["%d enemies fell that day."] = "那天有%d個敵人倒下。"
L["%d kills together"] = "共同擊殺%d"
L["%d of %d honour tiers reached"] = "已達成%d / %d個階段"
L["%d times grouped"] = "組隊%d次"
L["%d treasures collected"] = "收集了%d件寶物"
L["%dx traded"] = "交易%d次"
L["A painted memory"] = "一幅畫下的回憶"
L["Book of honour"] = "榮譽之書"
L["Companions"] = "同伴"
L["Copy for forum or Discord (Markdown)"] = "複製到論壇或Discord（Markdown）"
L["Fell in %s"] = "倒在%s"
L["Fell to %s"] = "倒在%s手下"
L["Slain by %s"] = "被%s所殺"
L["Fellow adventurers"] = "冒險夥伴"
L["Fellowship"] = "同伴情誼"
L["Grouped with %s"] = "與%s組隊"
L["In memoriam"] = "紀念"
L["Loot of %s"] = "%s的戰利品"
L["No trades yet."] = "尚無交易。"
L["No treasures found yet."] = "尚未找到寶物。"
L["Rested here"] = "在此休息"
L["Times rested here"] = "在此休息次數"
L["The last moment"] = "最後一刻"
L["Today, %d days ago"] = "%d天前的今天"
L["Trading partners"] = "交易夥伴"
L["Treasures"] = "寶物"
L["Who walked beside me"] = "與我同行的人"
L["You have not grouped with anyone yet."] = "你還沒有和任何人組隊過。"
L["I was in %s."] = "我待在%s。"
L["early in the morning"] = "清晨"
L["in the morning"] = "上午"
L["around noon"] = "中午時分"
L["in the afternoon"] = "下午"
L["in the evening"] = "傍晚"
L["late at night"] = "深夜"
L["earned"] = "已獲得"
L["first met %s"] = "初識於%s"

-- honours
L["First Blood"] = "初次見血"
L["Slay your first creature."] = "擊殺你的第一個生物。"
L["Slayer"] = "屠戮者"
L["Slay 100 creatures."] = "擊殺100個生物。"
L["Scourge of the Wilds"] = "荒野之災"
L["Slay 1000 creatures."] = "擊殺1000個生物。"
L["Champion"] = "勇士"
L["Slay 5000 creatures."] = "擊殺5000個生物。"
L["Specialist"] = "專家"
L["Slay 100 of a single kind."] = "擊殺同一種生物100次。"
L["Naturalist"] = "博物學家"
L["Collect 50 kinds of creatures."] = "收集50種生物。"
L["Rare Hunter"] = "稀有獵人"
L["Slay 5 rare creatures."] = "擊殺5個稀有生物。"
L["Bane of Bosses"] = "首領剋星"
L["Giant Slayer"] = "巨人殺手"
L["Defeat 10 bosses."] = "擊敗10個首領。"
L["Into the Depths"] = "深入地底"
L["Hunter"] = "獵人"
L["Helping Hand"] = "援手"
L["Complete 10 quests."] = "完成10個任務。"
L["Hero of the People"] = "人民英雄"
L["Complete 100 quests."] = "完成100個任務。"
L["Explorer"] = "探險家"
L["Discover 25 places."] = "發現25個地點。"
L["Cartographer"] = "製圖師"
L["Discover 100 places."] = "發現100個地點。"
L["Globetrotter"] = "環遊世界者"
L["Visit 5 regions."] = "造訪5個區域。"
L["Wanderer"] = "漫遊者"
L["Walk 50 kilometres."] = "徒步走50公里。"
L["Pathfinder"] = "開路者"
L["Walk 250 kilometres."] = "徒步走250公里。"
L["Frequent Flyer"] = "飛行常客"
L["Take 10 flights."] = "搭乘10次飛行。"
L["Thrifty"] = "勤儉"
L["Own 10 gold."] = "擁有10枚金幣。"
L["Wealthy"] = "富有"
L["Own 100 gold."] = "擁有100枚金幣。"
L["Seasoned"] = "老練"
L["Reach level 20."] = "達到20級。"
L["Veteran"] = "老兵"
L["Reach level 40."] = "達到40級。"
L["Reach level 60."] = "達到60級。"
L["Untouchable"] = "無懈可擊"
L["Play 5 days in a row without dying."] = "連續5天遊戲而不死亡。"
L["Faithful Chronicler"] = "忠實的編年史家"
L["Keep this diary for 30 days."] = "持續記錄這本日記30天。"
L["Sociable"] = "善於交際"
L["Meet 25 people."] = "結識25個人。"
L["Bouncy"] = "跳跳客"
L["Jump 1000 times."] = "跳躍1000次。"
L["Treasure Hunter"] = "尋寶者"
L["Find 5 rare items."] = "找到5件精良物品。"
L["Group with 5 other adventurers."] = "與5位其他冒險者組隊。"

-- keepsake captions
L["Level up"] = "升級"
L["Epic find"] = "史詩發現"
L["Rare find"] = "稀有發現"
L["Death"] = "死亡"
L["New land"] = "新的土地"
L["Dungeon"] = "地城"
L["Quest"] = "任務"
L["Wealth"] = "財富"
L["Skill"] = "技能"
L["Hunt"] = "狩獵"
L["Moment"] = "時刻"

-- honour tiers, atlas, landmarks, secrets
L["%d honour points"] = "%d榮譽點數"
L["%d of %d landmarks found"] = "已找到%d / %d處名勝"
L["%d of %d regions explored"] = "已探索%d / %d個區域"
L["%d tiers earned"] = "已達成%d階"
L["A familiar face ..."] = "熟悉的面孔……"
L["A secret honour. Keep exploring!"] = "隱藏的榮譽。繼續探索吧！"
L["Adventure"] = "冒險"
L["Almost there"] = "即將達成"
L["Atlas"] = "地圖集"
L["Bad Day"] = "倒楣的一天"
L["Barterer"] = "以物易物者"
L["Be on the road before seven in the morning."] = "在早上七點前上路。"
L["Be on the road between midnight and four o'clock."] = "在午夜到凌晨四點之間上路。"
L["Bloodbath"] = "血洗"
L["Busy Bee"] = "勤勞的蜜蜂"
L["Capital Tourist"] = "首都觀光客"
L["Capitals"] = "首都"
L["Click for all landmarks."] = "點擊查看所有名勝。"
L["Click for the map of this region."] = "點擊查看此區域的地圖。"
L["Click to open this part of the book."] = "點擊翻開本書的這個部分。"
L["Collection"] = "收藏"
L["Combat"] = "戰鬥"
L["Complete %d quests in a single day."] = "在一天內完成%d個任務。"
L["Complete %d quests."] = "完成%d個任務。"
L["Complete!"] = "全部完成！"
L["Curiosities"] = "奇聞軼事"
L["Dark places, rich rewards"] = "幽暗之地，豐厚獎賞"
L["Defeat %d bosses."] = "擊敗%d個首領。"
L["Destination of the day"] = "今日目的地"
L["Devoted"] = "全心投入"
L["Die %d times and rise again."] = "死亡%d次並重新站起來。"
L["Die %d times in a single day."] = "在一天內死亡%d次。"
L["Discover %d places."] = "發現%d個地點。"
L["Do business with %d merchants."] = "與%d位商人做生意。"
L["Dungeons"] = "地城"
L["Eager Student"] = "好學不倦"
L["Early Bird"] = "早起的鳥兒"
L["Elite Slayer"] = "菁英殺手"
L["Encounters"] = "相遇"
L["Enter %d dungeons."] = "進入%d座地城。"
L["Epic Fortune"] = "史詩好運"
L["Every journey needs a pause ..."] = "每段旅程都需要停歇……"
L["Every region of this continent is explored."] = "此大陸的所有區域都已探索。"
L["Exploration"] = "探索"
L["Explored"] = "已探索"
L["Explorer's checklist"] = "探險家清單"
L["Famous places of Azeroth"] = "艾澤拉斯名勝"
L["Find %d epic items."] = "找到%d件史詩物品。"
L["Find %d landmarks."] = "找到%d處名勝。"
L["Find %d rare items."] = "找到%d件精良物品。"
L["Fortune and craft"] = "財富與技藝"
L["Globetrotter's Day"] = "環遊之日"
L["Group with %d other adventurers."] = "與%d位其他冒險者組隊。"
L["Haggler"] = "殺價高手"
L["Hoarder"] = "囤積者"
L["Homesick"] = "思鄉"
L["Honour earned: %s (%s)"] = "獲得榮譽：%s（%s）"
L["Honour earned: %s"] = "獲得榮譽：%s"
L["Honour points"] = "榮譽點數"
L["Honour"] = "榮譽"
L["Jump %d times."] = "跳躍%d次。"
L["Just one more quest ..."] = "再做一個任務就好……"
L["Keep this diary for %d days."] = "持續記錄這本日記%d天。"
L["Landmark discovered: %s"] = "發現名勝：%s"
L["Landmark"] = "名勝"
L["Landmarks"] = "名勝"
L["Loot %d items."] = "拾取%d件物品。"
L["Marathon"] = "馬拉松"
L["Master of a Craft"] = "技藝大師"
L["Meet %d flight masters."] = "結識%d位飛行管理員。"
L["Meet %d people."] = "結識%d個人。"
L["Mouse wheel: zoom  -  drag: move  -  right click: reset"] = "滑鼠滾輪：縮放  -  拖曳：移動  -  右鍵：重設"
L["Next goals"] = "下一個目標"
L["Next rank: %s"] = "下一階：%s"
L["Night Owl"] = "夜貓子"
L["Not every day is a good day ..."] = "不是每天都是好日子……"
L["Not yet explored"] = "尚未探索"
L["Own %d gold."] = "擁有%d枚金幣。"
L["People met"] = "結識的人"
L["Phoenix"] = "浴火鳳凰"
L["Play %d days in a row without dying."] = "連續%d天遊戲而不死亡。"
L["Raids"] = "團隊副本"
L["Raise a skill to %d."] = "將一項專業提升到%d。"
L["Reach level %d."] = "達到%d級。"
L["Regions explored"] = "已探索的區域"
L["Regular"] = "常客"
L["Rest at %d places."] = "在%d個地點休息。"
L["Secrets"] = "秘密"
L["Sightseer"] = "觀光客"
L["Slay %d creatures in a single day."] = "在一天內擊殺%d個生物。"
L["Slay %d creatures."] = "擊殺%d個生物。"
L["Slay %d elite creatures."] = "擊殺%d個菁英生物。"
L["Slay %d of a single kind."] = "擊殺同一種生物%d次。"
L["Slay %d rare creatures."] = "擊殺%d個稀有生物。"
L["So many roads, so little time ..."] = "路途這麼多，時間這麼少……"
L["Some honours stay hidden until you find them."] = "有些榮譽在你找到之前都是隱藏的。"
L["Spend %d hours in the world on a single day."] = "在一天內於世界中度過%d小時。"
L["Spend %d hours in the world."] = "在世界中度過%d小時。"
L["Take %d flights."] = "搭乘%d次飛行。"
L["Talk to the same person %d times."] = "與同一個人交談%d次。"
L["The early bird catches the worm ..."] = "早起的鳥兒有蟲吃……"
L["The purse over the days"] = "錢袋的每日變化"
L["There is no place like home ..."] = "金窩銀窩，不如自己的狗窩……"
L["This game client knows none of the landmarks."] = "此遊戲用戶端不認得任何名勝。"
L["Towns of Kalimdor"] = "卡林多的地點"
L["Towns of the Eastern Kingdoms"] = "東部王國的地點"
L["Trade with %d players."] = "與%d位玩家交易。"
L["Unexplored regions"] = "未探索的區域"
L["Up, up and away ..."] = "飛向高空……"
L["Use your hearthstone %d times."] = "使用爐石%d次。"
L["Visit %d capital cities."] = "造訪%d座首都。"
L["Visit %d regions in a single day."] = "在一天內造訪%d個區域。"
L["Visit %d regions."] = "造訪%d個區域。"
L["Visit %d trainers."] = "拜訪%d位訓練師。"
L["Walk %d kilometres."] = "徒步走%d公里。"
L["Well Rested"] = "精神飽滿"
L["What is left to discover"] = "仍待發現之處"
L["When the moon stands highest ..."] = "當月亮升到最高時……"
L["Where will the road lead tomorrow?"] = "明天的路會通往何方？"
L["Wings of the World"] = "世界之翼"
L["You have not seen this place yet."] = "你還沒有見過這個地方。"
L["You have seen every landmark. Remarkable!"] = "你已看遍所有名勝。了不起！"
L["days"] = "天"
L["done"] = "完成"
L["given up"] = "放棄"
L["kills"] = "擊殺"
L["open"] = "進行中"

-- treasure album, wanted posters
L["WANTED"] = "懸賞通緝"
L["of %d kinds"] = "/ %d種"
L["Next mark: %d slain"] = "下個目標：擊殺%d"
L["Every mark reached"] = "所有目標已達成"
L["Uncommon"] = "優秀"
L["Epic"] = "史詩"
L["Legendary"] = "傳說"

-- tasks of the day, pop-ups, week in review
L["Slay %d creatures today."] = "今天擊殺%d個生物。"
L["Complete %d quests today."] = "今天完成%d個任務。"
L["Meet %d new people."] = "結識%d個新朋友。"
L["Discover %d new places."] = "發現%d個新地點。"
L["Walk %d kilometres today."] = "今天徒步走%d公里。"
L["Find an uncommon or better item."] = "找到一件優秀或更好品質的物品。"
L["Visit the landmark %s."] = "造訪名勝：%s。"
L["Set foot in %s."] = "踏上%s的土地。"
L["Task of the day done: %s"] = "今日目標達成：%s"
L["All tasks of the day done! %d days in a row."] = "今日目標全部達成！連續%d天。"
L["All tasks of the day done!"] = "今日目標全部達成！"
L["Tasks of the day"] = "今日目標"
L["Task of the day"] = "今日目標"
L["Dungeon Crawler"] = "地城探險家"
L["Finish %d dungeon runs."] = "完成%d次地城探險。"
L["Diligent"] = "勤奮"
L["Do all tasks of the day on %d days."] = "累計%d天達成所有今日目標。"
L["Dutiful"] = "盡責"
L["Do all tasks of the day %d days in a row."] = "連續%d天達成所有今日目標。"
L["Open the diary"] = "翻開日記"
L["Close"] = "關閉"
L["The week in review"] = "本週回顧"
L["Creatures slain"] = "擊殺生物"
L["Levels"] = "等級"
L["Kilometres"] = "公里"
L["New places"] = "新地點"
L["New regions"] = "新區域"
L["Honours"] = "榮譽"
L["Best day"] = "最佳的一天"
L["A quiet week"] = "平靜的一週"
L["The book waits for new stories."] = "這本書等待著新的故事。"
L["Show a note for new discoveries"] = "顯示新發現提示"
L["Weekly look back at login"] = "登入時顯示本週回顧"

-- records, level timeline, gallery, nemeses, dungeon reports
L["Records"] = "紀錄"
L["The best and the worst of days"] = "最好與最壞的日子"
L["Most creatures slain in a day"] = "單日最多擊殺"
L["Most quests in a day"] = "單日最多任務"
L["Richest day"] = "收入最多的一天"
L["Most experience in a day"] = "單日最多經驗"
L["Longest day in the world"] = "在世界中最長的一天"
L["Longest walk in a day"] = "單日最長徒步"
L["Most places discovered in a day"] = "單日最多新地點"
L["Most new faces in a day"] = "單日最多新面孔"
L["Fastest level"] = "最快的等級"
L["Slowest level"] = "最慢的等級"
L["Longest run without dying"] = "最長不死紀錄"
L["Darkest day"] = "最黑暗的一天"
L["Level timeline"] = "等級時間軸"
L["How long each level took"] = "每個等級花費的時間"
L["Played for these levels"] = "這些等級的遊戲時間"
L["Per level"] = "每級"
L["No level-ups recorded yet."] = "尚未記錄任何升級。"
L["Still on the way."] = "仍在路上。"
L["Reached the next level on day %d."] = "於第%d天升到下一級。"
L["Gallery"] = "畫廊"
L["Moments, painted in the gear of their day"] = "以當日裝備描繪的時刻"
L["The first painting waits for your first great moment."] = "第一幅畫正等待你的第一個偉大時刻。"
L["Nemeses"] = "宿敵"
L["They sent me to the spirit healer"] = "讓我去見靈魂醫者的傢伙"
L["Nemesis number one"] = "頭號宿敵"
L["Nobody has defeated you yet. Long may it last!"] = "還沒有人擊敗過你。願這能持續下去！"
L["Killed you %d times"] = "殺死你%d次"
L["Revenge taken"] = "已報仇"
L["Score unsettled"] = "仇未報"
L["You slew them %d times."] = "你擊殺了他們%d次。"
L["Dungeon reports"] = "地城報告"
L["No dungeon visited yet. The depths are waiting."] = "尚未造訪任何地城。深處正等待著你。"
L["Duration"] = "時長"
L["Fallen"] = "陣亡"
L["The group"] = "隊伍"
L["Me"] = "我"
L["Nobody fell."] = "無人陣亡。"

-- ledger figures, achievement pop-up, blocked functions, quotes
L["Best day: day %d"] = "最佳的一天：第%d天"
L["Worst day: day %d"] = "最糟的一天：第%d天"
L["Per day"] = "每日平均"
L["Honour earned"] = "獲得榮譽"
L["Landmark discovered"] = "發現名勝"
L["Next tier:"] = "下一階："
L["Every tier earned - complete!"] = "所有階級均已獲得－全部完成！"
L["The game blocked the function %s. Please tell the author."] = "遊戲封鎖了函式 %s。請通知作者。"
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "此遊戲客戶端不允許插件擷取畫面。重要時刻的截圖已關閉。"
L['"Here the journey ends, but not the story."'] = '「旅程在此結束，但故事不會。」'
L['"Whoever wanders, gathers stories."'] = '「行旅之人，收集故事。」'

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "第一次"
L["First time"] = "第一次"
L["%d of %d experienced"] = "已經歷 %d / %d"
L["Not yet experienced."] = "還沒經歷過。"
L["Click for all first times."] = "點擊查看所有的第一次。"
L["First creature slain"] = "第一次擊殺"
L["First quest completed"] = "第一個完成的任務"
L["First level up"] = "第一次升級"
L["First uncommon item"] = "第一件優秀物品"
L["First death"] = "第一次死亡"
L["First group"] = "第一次組隊"
L["First elite slain"] = "第一次擊殺精英"
L["First trade"] = "第一次交易"
L["First hearthstone"] = "第一次使用爐石"
L["First landmark"] = "第一處名勝"
L["First honour"] = "第一份榮譽"
L["First rare item"] = "第一件精良物品"
L["First rare creature"] = "第一隻稀有怪"
L["First flight"] = "第一次飛行"
L["First gold coin"] = "第一枚金幣"
L["First dungeon"] = "第一個地城"
L["First boss"] = "第一個首領"
L["First skill at 75"] = "第一項技能達到75"
L["First mount"] = "第一匹坐騎"
L["First epic item"] = "第一件史詩物品"

L["Family book"] = "家族之書"
L["%d characters on this account"] = "此帳號共有%d個角色"
L["you"] = "你"
L["Last seen %s"] = "最後上線：%s"
L["Who got there first?"] = "誰先做到？"
L["Log in with your other characters once, and they will appear here."] = "用你的其他角色登入一次，他們就會出現在這裡。"

L["Time capsule"] = "時光膠囊"
L["Letters to my future self"] = "寫給未來的自己"
L["Dear me, when you read this ..."] = "親愛的我，當你讀到這封信時……"
L["Seal the letter and open it ..."] = "封好這封信，在……開啟"
L["in a week"] = "一週後"
L["in a month"] = "一個月後"
L["at level %d"] = "%d級時"
L["Until then the letter stays sealed - not even you can read it."] = "在那之前信會一直封著，連你自己也看不到。"
L["No letters yet."] = "還沒有信。"
L["Written on day %d, at level %d"] = "寫於第%d天，%d級時"
L["Opened on %s"] = "於%s開啟"
L["Sealed - opens on day %d"] = "已封存 - 第%d天開啟"
L["Sealed - opens at level %d"] = "已封存 - %d級時開啟"
L["in %d days"] = "還有%d天"
L["A letter for later was sealed."] = "封好了一封寫給以後的信。"
L["A letter from the past has opened."] = "一封來自過去的信開啟了。"
L["Click to read the letter."] = "點擊閱讀這封信。"

L["Gatherer's map"] = "採集地圖"
L["Where the good things grow"] = "好東西生長的地方"
L["Herbalism"] = "草藥學"
L["Mining"] = "採礦"
L["Skinning"] = "剝皮"
L["Fishing"] = "釣魚"
L["Most found here"] = "這裡最常找到"
L["Nothing gathered yet. Herbs, ore and hides show up here as soon as you gather them."] = "還沒採集任何東西。採集草藥、礦石和皮革後就會顯示在這裡。"

L["Task of the week"] = "本週目標"
L["Task of the week done: %s"] = "本週目標完成：%s"
L["Click for the next goals."] = "點擊查看下一個目標。"
L["Slay %d creatures this week."] = "本週擊殺%d隻怪物。"
L["Complete %d quests this week."] = "本週完成%d個任務。"
L["Walk %d kilometres this week."] = "本週步行%d公里。"
L["Meet %d new people this week."] = "本週結識%d個新朋友。"
L["Visit %d different regions this week."] = "本週造訪%d個不同的區域。"
L["Earn %d honour tiers this week."] = "本週達成%d個榮譽階段。"
L["Finish a dungeon run this week."] = "本週完成一次地城探險。"
L["Find %d new landmarks this week."] = "本週找到%d處新的名勝。"
L["Week by Week"] = "一週又一週"
L["Complete %d tasks of the week."] = "完成%d次本週目標。"

L["Search the diary"] = "搜尋日記"
L["Days, people, creatures, quests, places, treasures and catches."] = "日子、人物、怪物、任務、地點、寶物和漁獲。"
L["Search: a name, a quest, a place ..."] = "搜尋：名字、任務、地點……"
L["Nothing found."] = "沒有找到。"
L["%d more results - type a little more"] = "還有%d個結果，請再多輸入一些"

L["The binding"] = "書封"
L["Corner studs"] = "護角"
L["none yet"] = "還沒有"
L["Next metal at %d honour points (now %d)."] = "下一種金屬需要%d榮譽點數（目前%d）。"
L["Gems"] = "寶石"
L["One gem for every ten honour tiers (now %d)."] = "每十個榮譽階段一顆寶石（目前%d）。"
L["Gold marks on the spine"] = "書脊上的燙金"
L["One for every ten levels."] = "每十級一個。"

-- the bookplate on the endpaper
L["FROM THE LIBRARY OF"] = "藏書人"

-- sayings of the day (start page)
L["SAYING OF THE DAY"] = "每日一句"
L["Whoever wanders, gathers stories."] = "行旅之人，收集故事。"
L["Every road starts at your own door."] = "每條路都從自家門口開始。"
L["A full pack is light when the heart is lighter."] = "心情輕鬆，滿滿的行囊也不重。"
L["Maps show the way - only feet know it."] = "地圖指出方向，真正認得路的是雙腳。"
L["The longest journey is the one you never write down."] = "最漫長的旅程，是從未寫下的那一段。"
L["Ink fades slower than memory."] = "墨水褪色得比記憶還慢。"
L["A good campfire turns strangers into companions."] = "一堆好營火，能讓陌生人成為同伴。"
L["The mountain does not care how tired you are - just keep going."] = "山不在乎你有多累，只在乎你有沒有繼續走。"
L["Today's detour is tomorrow's best story."] = "今天繞的遠路，就是明天最好的故事。"
L["Gold comes and goes, the story stays."] = "金幣來來去去，故事會留下來。"
L["Count the days by friends, not by miles."] = "用朋友來數日子，而不是用里程。"
L["Even the smallest kobold guards a candle for someone."] = "再小的狗頭人，也在為某人守著一根蠟燭。"
L["Resting is part of the road."] = "休息也是旅程的一部分。"
L["Fear is a map with too many blank spots."] = "恐懼是一張空白太多的地圖。"
L["Every scar has a page in this book."] = "每一道傷疤，在這本書裡都有一頁。"
L["Look back now and then - the view is part of the journey."] = "偶爾回頭看看，風景也是旅程的一部分。"
L["The wise traveller asks the innkeeper first."] = "聰明的旅人，會先去問旅店老闆。"
L["Rain on the road, sunshine in the story."] = "路上下著雨，故事裡出著太陽。"
L["Whoever never falls never learns to get up."] = "從不跌倒的人，學不會站起來。"
L["A quest half done is still a step forward."] = "做到一半的任務，也是向前的一步。"
L["The horizon travels with you - that is why it never gets dull."] = "地平線跟著你旅行，所以永遠不會無聊。"
L["Write it down, or it never happened."] = "寫下來，不然就等於沒發生過。"
L["Old boots know more than new maps."] = "舊靴子懂的比新地圖還多。"
L["Courage is being afraid and saddling up anyway."] = "勇氣就是害怕，卻還是套上馬鞍。"
L["Tomorrow the road will still be there. Tonight the fire is warm."] = "明天路還在那裡，今晚的營火正暖。"
L["A traveller's purse is light, a traveller's diary is heavy."] = "旅人的錢袋很輕，日記卻很重。"
L["The best places are on no map."] = "最好的地方，都不在任何地圖上。"
L["Every hero once did not know the way."] = "每個英雄，都曾經不認得路。"
L["Share your bread, and the road shares its secrets."] = "分享你的麵包，道路就會分享它的秘密。"
L["The story is not over while a page is still blank."] = "只要還有空白的一頁，故事就沒有結束。"

-- covered cards in the bestiary: kinds your other characters know
L["Not yet discovered"] = "尚未發現"
L["Known to %s"] = "%s已經認識這種怪物"
L["%d to discover"] = "還有%d種未發現"
L["in the east"] = "東部"
L["in the south-east"] = "東南部"
L["in the south"] = "南部"
L["in the south-west"] = "西南部"
L["in the west"] = "西部"
L["in the north-west"] = "西北部"
L["in the north"] = "北部"
L["in the north-east"] = "東北部"
L["in the middle"] = "中部"
L["To the contents"] = "前往目錄"
L["Screenshots at milestones: on"] = "重要時刻截圖：開啟"
L["Screenshots at milestones: off"] = "重要時刻截圖：關閉"
L["Demo mode is off."] = "示範模式已關閉。"
L["Demo mode is on. Nothing you do now is written into your diary - type /wfd demo again to leave."] = "示範模式已開啟。現在做的事不會寫進你的日記，再輸入一次 /wfd demo 即可離開。"
L["You have died, but who did it slipped past the diary."] = "你已經倒下過，但是誰下的手，日記沒能記下。"
L["Already in the quest log"] = "日記開始前接下的任務"
L["Angler"] = "釣客"
L["Raise Fishing to %d."] = "將釣魚提升到%d。"
L["Big Catch"] = "滿載而歸"
L["Catch %d fish."] = "釣到%d條魚。"
L["Field Medic"] = "戰地醫護"
L["Raise First Aid to %d."] = "將急救提升到%d。"
L["Camp Cook"] = "營地廚師"
L["Raise Cooking to %d."] = "將烹飪提升到%d。"
L["Sighted, not yet slain"] = "已發現，尚未擊殺"
L["perhaps %s"] = "也許在%s"
L["You have been %s of this area least of all. Something may still be waiting there."] = "這一帶你最少去的是%s，那裡或許還有東西在等著你。"
L["Defeat a boss."] = "擊敗一個首領。"
L["Slay a rare creature."] = "擊殺一隻稀有怪物。"
L["Slay an elite creature."] = "擊殺一隻精英怪物。"
L["Visit a capital city."] = "造訪一座主城。"
L["Enter a dungeon."] = "進入一個地城。"
L["Take a flight."] = "搭乘一次飛行。"
L["Group with another adventurer."] = "與另一位冒險者組隊。"
L["Visit a trainer."] = "拜訪一位訓練師。"
L["Trade with another player."] = "與另一位玩家交易。"
L["Complete a quest."] = "完成一個任務。"
L["Die once and rise again."] = "死亡一次並重新站起來。"
L["Finish a dungeon run."] = "完成一次地城探索。"
L["Do all tasks of the day on one day."] = "在一天內完成當天所有任務。"
L["Complete a task of the week."] = "完成一項每週任務。"
L["Find a rare item."] = "找到一件稀有物品。"
L["Find an epic item."] = "找到一件史詩物品。"
L["Dear me, if you are reading this, you made it through the first week. Did you ever find out who was stealing the candles in the mine?"] = "親愛的我：如果你正在讀這封信，代表你撐過了第一週。你後來查出是誰在礦坑裡偷蠟燭了嗎？"
L["Marker set on the map: %s (%d, %d)"] = "已在地圖上標記：%s（%d, %d）"
L["No marker can be set on this map."] = "這張地圖無法設置標記。"
L["Click to set a marker on the map."] = "點擊以在地圖上設置標記。"
L["Right-click for the map of this region."] = "右鍵點擊：查看此區域的地圖"
L["1 kind"] = "1種"
L["Discover a new place."] = "發現一個新地點。"
L["Walk one kilometre today."] = "今天走一公里。"
L["WELCOME"] = "歡迎"
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "盡情去玩吧，我會一路記下來。你玩的每一天都會變成這本書的一頁。"
L["See a sample book"] = "查看範例日記"
L["To today's entry"] = "前往今天"
L["Discover %d flight paths."] = "發現%d條飛行路線。"
L["A sketch - %d more and it is in colour."] = "素描 - 再 %d 隻就會上色。"
L["%d more to become a connoisseur."] = "再 %d 隻就能成為行家。"
L["Connoisseur of this kind"] = "此物種的行家"
L["First slain on day %d"] = "第 %d 天首次擊殺"
L["Best loot"] = "最佳戰利品"
L["Got you once."] = "曾擊倒你一次。"
L["Got you %d times."] = "曾擊倒你 %d 次。"
L["CONNOISSEUR"] = "行家"
L["Connoisseur"] = "行家"
L["Right-click to close."] = "右鍵點擊即可關閉。"
L["The tabs"] = "索引標籤"
L["The tabs on the right lead to the parts of the book, one colour for each group. Point at them to read their names. A red dot shows how much is new since you last read."] = "右側的索引標籤通往書的各個部分，每一組有自己的顏色。將滑鼠移上去即可看到名稱。紅點表示自上次閱讀以來有多少新內容。"
L["The spyglass on the spine searches the whole book: days, people, creatures, quests, places, treasures and catches. Ctrl + F opens it too."] = "書脊上的放大鏡可搜尋整本書：日子、人物、生物、任務、地點、寶物與漁獲。Ctrl + F 也能開啟。"
L["Your own bookmarks"] = "自己的書籤"
L["Ctrl-click a page number to keep that page. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away."] = "Ctrl-點擊頁碼即可記住該頁。書的上方會露出一條緞帶：點擊翻到該頁，右鍵點擊則取下緞帶。"
L["Ctrl + click on the page number"] = "Ctrl + 點擊頁碼"
L["bookmark"] = "書籤"
L["Goals and honour"] = "目標與榮譽"
L["The world"] = "世界"
L["Hunt and loot"] = "狩獵與戰利品"
L["People and money"] = "人物與錢財"
L["Keepsakes"] = "紀念"
L["Best find for every slot"] = "每個部位的最佳發現"
L["worn right now"] = "目前穿戴中"
L["Click to show only these."] = "點擊只顯示這些。"
L["Click to show all again."] = "點擊再次顯示全部。"
L["Shown: %s only"] = "顯示：僅%s"
L["Show all"] = "顯示全部"
L["Ctrl-click to set or remove a bookmark here."] = "Ctrl-點擊在此放置或移除書籤。"
L["Click to open, right-click to remove."] = "點擊翻開，右鍵移除。"
L["You are here."] = "你在這裡。"
L["Click for the hunting grounds of this area."] = "點擊查看此地區的獵場。"
L["Who is closest to the next stage"] = "最接近下一階段的生物"
L["%d more, then in colour"] = "再 %d 隻就上色"
L["%d more, then a connoisseur"] = "再 %d 隻就成為行家"
L["To the album of this area"] = "前往此地區的圖鑑"
L["Every kind known here is collected."] = "此地已知的物種全部收集完畢。"
L["Kinds of creatures"] = "生物類型"
L["What you have slain, by type"] = "你擊敗的生物，依類型"
L["Unknown kind"] = "未知類型"
L["%d kinds  -  %d slain"] = "%d 種  -  擊殺 %d"
L["Hunting grounds"] = "狩獵場"
L["Sighted"] = "已目擊"
L["Kinds slain here"] = "在此擊殺的物種"
L["Each pin marks where the first of its kind fell."] = "每個圖釘標示該物種第一隻倒下的地點。"
L["Versatile Hunter"] = "多才多藝的獵人"
L["Slay creatures of %d different types."] = "擊殺 %d 種不同類型的生物。"
L["Slay 50 of each of %d kinds."] = "擊殺 %d 個物種各 50 隻。"
L["Slay 50 of one kind."] = "擊殺同一物種 50 隻。"
L["Quick on its feet, but it never looks back."] = "腳程飛快，卻從不回頭。"
L["Its pelt would fetch a fair price in town."] = "牠的毛皮在城裡能賣個好價錢。"
L["Talks big, fights small."] = "口氣很大，身手很小。"
L["Carried more coins than sense."] = "身上的錢幣比腦子還多。"
L["Smells worse than it fights."] = "聞起來比打起來更可怕。"
L["Dead once already. Twice is a habit."] = "早就死過一次了，兩次就成了習慣。"
L["Burning eyes, burning temper."] = "燃燒的雙眼，火爆的脾氣。"
L["Whoever summoned this one owes me an apology."] = "召喚牠的人欠我一個道歉。"
L["Not alive, not dead - simply angry."] = "不生不死，只是憤怒。"
L["Left nothing behind but a puddle of fury."] = "只留下一灘怒火。"
L["Scales like armour. Mind the tail."] = "鱗片如鎧甲，小心尾巴。"
L["One day I will face its big brothers."] = "總有一天我會面對牠的兄長們。"
L["The ground shook long after it fell."] = "牠倒下後，大地仍震動許久。"
L["Big enough to have its own weather."] = "大到有自己的天氣。"
L["Gnomish work, no doubt. Loud and leaky."] = "肯定是地精的手藝，又吵又漏。"
L["It sparked, it whirred, it stopped."] = "它冒火花，它嗡嗡作響，然後停了。"
L["It never stood a chance."] = "牠從來沒有機會。"
L["Small, harmless and now a footnote."] = "小小的、無害的，如今成了一條註腳。"
L["A strange creature. I made a note, just in case."] = "奇怪的生物，我記了下來，以防萬一。"
L["Worth remembering, or at least worth writing down."] = "值得記住，至少值得寫下來。"
L["Back"] = "返回"
L["To the page you came from (Backspace)."] = "回到你來自的頁面（Backspace）。"
L["Go to page (1 - %d):"] = "前往頁面（1 - %d）："
L["Size: %d%%"] = "大小：%d%%"
L["The bookmarks"] = "書籤"
L["The bookmarks on the right lead to the parts of the book. A red dot shows how much is new since you last read."] = "右側的書籤通往書中各個部分。紅點顯示自你上次閱讀以來新增了多少內容。"
L["Search"] = "搜尋"
L["The spyglass on the spine searches the whole book: days, people, creatures, quests and places."] = "書脊上的望遠鏡可搜尋整本書：日子、人物、生物、任務與地點。"
L["Turning pages"] = "翻頁"
L["Turn the pages with the arrows, the mouse wheel or the arrow keys. The red ribbon below always leads to today; Backspace takes you back. Ctrl + mouse wheel changes the size of the book."] = "用箭頭、滑鼠滾輪或方向鍵翻頁。下方的紅色緞帶總是通往今天；Backspace 可返回。Ctrl + 滑鼠滾輪可調整書本大小。"
L["Almost everything can be clicked"] = "幾乎所有東西都能點擊"
L["Next"] = "下一步"
L["Skip"] = "略過"
L["Got it"] = "知道了"
L["Handling"] = "操作"
L["Notifications"] = "通知"
L["Important only"] = "僅重要的"
L["Quiet"] = "靜音"
L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] = "重要事項：等級、首領、稀有生物與發現、地城、榮譽與信件。"
L["Keys while the mouse is over the book"] = "滑鼠位於書本上時的按鍵"
L["Arrow keys, Page up / down"] = "方向鍵、Page Up / Down"
L["turn the page"] = "翻頁"
L["Home"] = "Home"
L["contents"] = "目錄"
L["End"] = "End"
L["today's entry"] = "今天的記錄"
L["Backspace"] = "Backspace"
L["back"] = "返回"
L["Ctrl + mouse wheel"] = "Ctrl + 滑鼠滾輪"
L["size of the book"] = "書本大小"
L["Ctrl + F"] = "Ctrl + F"
L["search the book"] = "搜尋本書"
L["Right-click the page number"] = "右鍵點擊頁碼"
L["go to a page"] = "前往某頁"
L["open or close the book"] = "開啟或關閉書本"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "可以在遊戲的按鍵設定中「插件」分類下指定開啟書本的按鍵。"
L["The book"] = "書本"
L["Reset the position"] = "重設位置"
L["Show the introduction again"] = "再次顯示導覽"
L["Open the scribe's notes"] = "開啟抄寫員筆記"
L["Right-click to go to a page."] = "右鍵點擊以前往某頁。"
L["%d new since you last read"] = "自上次閱讀以來新增 %d 項"
L["Right-click for the settings."] = "右鍵點擊開啟設定。"
L["Drag to move this button."] = "拖曳以移動此按鈕。"
L["Click to open."] = "點擊以開啟。"
L["Moving code"] = "搬家代碼"
L["This code holds the whole diary of this character. Copy it with Ctrl+C and keep it somewhere safe, for example in a text file. On the other computer, open the same window with \"Read a moving code\" and paste it there."] = "此代碼包含這個角色的整本日誌。用 Ctrl+C 複製，並妥善保存，例如存在文字檔中。在另一台電腦上，用「讀取搬家代碼」開啟視窗並貼上。"
L["The code could not be made."] = "無法產生代碼。"
L["%d days, %d characters. Now press Ctrl+C."] = "%d 天，%d 個字元。現在按下 Ctrl+C。"
L["Read a moving code"] = "讀取搬家代碼"
L["Paste the moving code of this character with Ctrl+V. The diary written on this computer is then replaced by the one from the code, and the interface is reloaded."] = "用 Ctrl+V 貼上這個角色的搬家代碼。這台電腦上的日誌會被代碼中的日誌取代，並重新載入介面。"
L["Waiting for a code ..."] = "等待代碼 ..."
L["Replace the diary and reload"] = "取代日誌並重新載入"
L["This is not a moving code of the diary."] = "這不是日誌的搬家代碼。"
L["The code is damaged or incomplete. Copy it again, all of it."] = "代碼已損壞或不完整。請重新完整複製。"
L["Diary of %s (%s), %d days, %d kinds of creatures, %d people."] = "%s（%s）的日誌，%d 天，%d 種生物，%d 位人物。"
L["Careful: this code belongs to %s, but you are playing %s."] = "注意：此代碼屬於 %s，但你正在使用 %s。"
L["The diary of this character on this computer will be replaced."] = "這台電腦上此角色的日誌將被取代。"
L["Leave demo mode first."] = "請先離開示範模式。"
L["moving code of this character"] = "此角色的搬家代碼"
L["read a moving code"] = "讀取搬家代碼"
L["Moving to another computer"] = "搬到另一台電腦"
L["Make a moving code"] = "產生搬家代碼"
L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."] = "或者直接帶走遊戲的 WTF 資料夾：裡面有所有角色的日誌。"
L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."] = "一個小視窗，顯示今天的數字、任務，以及最接近下一階的榮譽。拖曳標題可移動，按減號可收合。"
L["Appearance"] = "外觀"
L["Both reload the interface. With bigger writing a few long lines may run close together."] = "兩者都會重新載入介面。字體放大後，少數較長的行可能會擠在一起。"
L["Click to open the diary there."] = "點擊以在該處開啟日誌。"
L["Companion"] = "隨行視窗"
L["Fold in or out"] = "收合或展開"
L["Leather and gold"] = "皮革與金飾"
L["Leather and gold is the old book. Modern is flat and calm, strong contrast makes all writing brighter."] = "皮革與金飾是原本的書。現代風格簡潔沉穩，高對比讓所有文字更亮。"
L["Modern"] = "現代"
L["Next honours"] = "下一個榮譽"
L["Online"] = "在線"
L["Show the companion beside the game"] = "在遊戲旁顯示隨行視窗"
L["Size of the writing"] = "文字大小"
L["Strong contrast"] = "高對比"
L["Style of the book"] = "書本風格"
L["The companion can be shown again in the settings or with /wfd companion."] = "可以在設定中或用 /wfd companion 再次顯示隨行視窗。"
L["Turn the leaves visibly"] = "顯示翻頁動畫"
L["Turning the pages"] = "翻頁"
L["km"] = "公里"
L["reloads the interface"] = "會重新載入介面"
L["show or hide the companion"] = "顯示或隱藏隨行視窗"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "這裡原有的日記屬於先前一個同名角色。它已另外保存，並為你開始了一本新的日記。輸入 |cffffd100/wfd restore|r 可以取回。"
L["bring back the diary put aside"] = "取回另外保存的日記"
L["No diary has been put aside."] = "沒有另外保存的日記。"
L["The diary put aside is back. The interface is reloaded."] = "另外保存的日記已取回。介面將重新載入。"

-- Angler's log
L["Angler's log"] = "釣魚日誌"
L["A collector's album of everything the line brought up"] = "釣線所釣起一切事物的收藏圖鑑"
L["catches collected  -  %d things landed"] = "已收集的漁獲  -  共釣起 %d 件"
L["Land %d different catches."] = "釣起 %d 種不同的漁獲。"
L["Casts"] = "拋竿"
L["Fish"] = "魚"
L["Treasure"] = "寶物"
L["Junk"] = "雜物"
L["Odds and ends"] = "其他"
L["1 catch"] = "1 件漁獲"
L["%d catches"] = "%d 件漁獲"
L["Nothing has bitten yet."] = "還沒有任何東西上鉤。"
L["Waters and tackle"] = "水域與釣具"
L["Where it bites, and what you fished with"] = "哪裡會上鉤，以及你用什麼釣"
L["Waters"] = "水域"
L["%d caught in %d casts"] = "拋竿 %d 次，釣到 %d 件"
L["Tackle"] = "釣具"
L["%d casts"] = "拋竿 %d 次"
L["No fishing pole seen yet."] = "還沒有看過釣竿。"
L["Casts with a lure"] = "使用魚餌的拋竿"
L["Casts in all"] = "拋竿總數"
L["CAUGHT"] = "已釣獲"
L["Mostly caught in"] = "主要釣獲於"
L["Caught"] = "已釣獲"
L["Of all catches"] = "佔所有漁獲"
L["First catch"] = "首次釣獲"
L["Last catch"] = "最近釣獲"
L["On a lure"] = "使用魚餌"
L["WHERE IT BIT"] = "上鉤地點"
L["Next mark: %d caught"] = "下一個目標：釣到 %d 件"
L["New catch: %s"] = "新的漁獲：%s"
L["Catch"] = "漁獲"
L["Fish Lore"] = "魚類通"
L["Fishing pole"] = "釣竿"
L["Lure"] = "魚餌"
L["Fishing gear"] = "釣魚裝備"

-- 0.1.11: the today page, group pages, dog-ears, search filters, the companion's offer
L["Click to go to a page."] = "點擊可跳到指定頁。"
L["Right-click for the contents."] = "右鍵點擊前往目錄。"
L["Click to set a bookmark here."] = "點擊在此放上書籤。"
L["Click to remove the bookmark."] = "點擊移除書籤。"
L["Click the folded corner of a page to keep it. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away."] = "點擊頁面的折角即可記住該頁。書頂會露出一條緞帶：點擊翻到該頁，右鍵點擊取下緞帶。"
L["Cards, names, days and maps open more. Click the page number to go to any page. The settings have a tab of their own at the bottom."] = "卡片、名字、日子和地圖都能點開看更多。點擊頁碼可跳到任何一頁。設定有自己的分頁標籤，在最下方。"
L["Click to open the settings."] = "點擊開啟設定。"
L["Continue reading: %s, p. %d"] = "繼續閱讀：%s，第 %d 頁"
L["open a part: today, bestiary, honour, ledger, atlas, settings ... or a day number"] = "開啟某個部分：today、bestiary、honour、ledger、atlas、settings ... 或日數"
L["Parchment"] = "羊皮紙"
L["Parchment is bright, like old quest paper."] = "羊皮紙明亮，如同舊任務紙張。"
L["General"] = "一般"
L["Tasks"] = "目標"
L["Day, week and month"] = "每日、每週與每月"
L["Perfect days"] = "完美的日子"
L["Longest run"] = "最長連續"
L["Tasks done"] = "完成的目標"
L["Weeks done"] = "完成的週數"
L["Months done"] = "完成的月數"
L["Task of the month"] = "本月目標"
L["Task of the month done: %s"] = "本月目標完成：%s"
L["Slay %d creatures this month."] = "本月擊殺%d隻怪物。"
L["Complete %d quests this month."] = "本月完成%d個任務。"
L["Walk %d kilometres this month."] = "本月步行%d公里。"
L["Meet %d new people this month."] = "本月結識%d個新朋友。"
L["Visit %d different regions this month."] = "本月造訪%d個不同的區域。"
L["Earn %d honour tiers this month."] = "本月達成%d個榮譽階段。"
L["Finish %d dungeon runs this month."] = "本月完成%d次地城探險。"
L["Find %d new landmarks this month."] = "本月找到%d處新的名勝。"
L["Click to set a waypoint on the map."] = "點擊以在地圖上設定路徑點。"
L["Waypoint set: %s"] = "已設定路徑點：%s"
L["Map controls"] = "地圖操作"
L["Mouse wheel: zoom"] = "滑鼠滾輪：縮放"
L["Drag: move the map"] = "拖曳：移動地圖"
L["Right click: reset"] = "右鍵點擊：重設"
L["New in the diary. Click to refresh."] = "日記有新內容。點擊更新。"
L["Click the page number"] = "點擊頁碼"
L["Click the folded corner"] = "點擊折角"
L["New since you last read"] = "上次閱讀後的新內容"
L["Nothing new since you last read."] = "上次閱讀後沒有新內容。"
L["Nothing in here yet."] = "這裡還是空的。"
L["Show the cover when the book is first opened"] = "首次開啟時顯示封面"
L["%d new moments"] = "%d個新時刻"
L["The companion"] = "隨行視窗"
L["A small window beside the game shows today's figures, the tasks and the honours closest to their next tier. You can switch it on and off in the settings."] = "遊戲旁的小視窗會顯示今天的數字、任務，以及最接近下一階段的榮譽。可在設定中開啟或關閉。"
L["Show it"] = "顯示"
L["Names from the game (places, creatures, items) stay in the language of the game client."] = "來自遊戲的名稱（地點、生物、物品）會維持遊戲用戶端的語言。"
