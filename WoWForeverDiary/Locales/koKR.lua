-- Korean translation (English phrases are the keys)
local ADDON, WFD = ...
local L, loc = WFD:NewLocale("koKR")

local T = {
    -- chat / log
    ["Diary"] = "일기",
    ["Travel diary active - today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
        "여행 일기 활성화 - 오늘은 |cffffd100%d일째|r입니다. |cffffd100/wfd|r 명령어로 일기를 엽니다.",
    ["%d creatures slain in total"] = "총 %d마리 처치",
    ["First victory over the boss %s!"] = "우두머리 %s 첫 처치!",
    ["Rare creature slain: %s"] = "희귀 몬스터 처치: %s",
    ["Boss %s defeated again (%dx)"] = "우두머리 %s 재처치 (%dx)",
    ["Died to %s in %s"] = "사망: %s (%s)",
    ["Died in %s"] = "사망 (%s)",
    ["Met %s (%s)"] = "만남: %s (%s)",
    ["Hearthstone bound to %s"] = "귀환석 귀속: %s",
    ["Quest accepted: %s"] = "퀘스트 수락: %s",
    ["Quest abandoned: %s"] = "퀘스트 포기: %s",
    ["Quest completed: %s"] = "퀘스트 완료: %s",
    ["First quest completed: %s"] = "첫 퀘스트 완료: %s",
    ["%d quests completed"] = "퀘스트 %d개 완료",
    ["Took a flight to %s"] = "비행: %s",
    ["Wealth reached: %s"] = "재산 달성: %s",
    ["Found %s"] = "획득: %s",
    ["Epic find: %s"] = "영웅 등급 발견: %s",
    ["Rare find: %s"] = "희귀 등급 발견: %s",
    ["Discovered a new land: %s"] = "새로운 지역 발견: %s",
    ["Entered %s"] = "도착: %s",
    ["Discovered: %s (%s)"] = "발견: %s (%s)",
    ["First visit to the dungeon %s"] = "던전 첫 방문: %s",
    ["Entered the dungeon %s"] = "던전 입장: %s",
    ["Level %d reached!"] = "%d 레벨 달성!",
    ["%s increased to %d"] = "%s 숙련도 %d 달성",
    ["%s mastered up to %d"] = "%s 숙련도 최대 %d",
    ["Used the hearthstone"] = "귀환석 사용",
    ["%dh %02dm"] = "%d시간 %02d분",
    ["%dm"] = "%d분",

    -- window
    ["Travel Diary of %s"] = "%s의 여행 일기",
    ["Day %d"] = "%d일째",
    ["Level %d"] = "%d 레벨",
    ["Level %s"] = "%s 레벨",
    ["online"] = "접속",
    ["LIFELINE"] = "생애 연대표",
    ["now"] = "현재",
    ["Screenshot:"] = "스크린샷:",
    ["Click to read this day."] = "클릭하면 이 날의 기록을 봅니다.",
    ["Click to open the diary."] = "클릭하면 일기를 엽니다.",
    ["%d kills today"] = "오늘 %d마리 처치",
    ["%d quests today"] = "오늘 퀘스트 %d개",
    ["DEMO MODE - invented data"] = "데모 모드 - 가상 데이터",

    -- tabs
    ["Journal"] = "일기",
    ["World Map"] = "세계 지도",
    ["Bestiary"] = "몬스터 도감",
    ["People"] = "인물",
    ["Quest Book"] = "퀘스트 책",
    ["Statistics"] = "통계",
    ["Export"] = "내보내기",

    -- journal
    ["Today"] = "오늘",
    ["Chronicle"] = "연대기",
    ["Overview"] = "개요",
    ["Nothing recorded yet."] = "아직 기록이 없습니다.",
    ["Balance of the day"] = "오늘의 결산",
    ["Enemies slain"] = "처치한 적",
    ["Quests completed"] = "완료한 퀘스트",
    ["(done / accepted)"] = "(완료 / 수락)",
    ["People spoken to"] = "대화한 인물",
    ["Experience gained"] = "획득한 경험치",
    ["Distance travelled"] = "이동 거리",
    ["flown"] = "비행",
    ["Time online"] = "접속 시간",
    ["Deaths"] = "사망",
    ["Jumps"] = "점프",
    ["Purse"] = "지갑",
    ["Income"] = "수입",
    ["Expenses"] = "지출",
    ["Net"] = "순이익",
    ["Fallen foes"] = "쓰러뜨린 적",
    ["... and %d more kinds"] = "... 외 %d종",
    ["Completed quests"] = "완료한 퀘스트",
    ["Spoken to"] = "대화 상대",
    ["Loot (%d items)"] = "전리품 (%d개)",
    ["Loot"] = "전리품",
    ["Places"] = "장소",
    ["Special moments"] = "특별한 순간",
    ["photo"] = "사진",

    -- map
    ["Footsteps"] = "발자취",
    ["Kills"] = "처치",
    ["Quests"] = "퀘스트",
    ["No map art available for this area."] = "이 지역의 지도 이미지가 없습니다.",
    ["VISITED AREAS"] = "방문한 지역",
    ["Play"] = "재생",
    ["Stop"] = "정지",
    ["Only this day"] = "이 날만",
    ["Drag the slider through time: your footsteps grow day by day."] = "슬라이더로 시간을 거슬러 보세요. 발자취가 하루하루 늘어납니다.",
    ["Spoken to %d times"] = "대화 %d회",
    ["Quest accepted here"] = "여기서 퀘스트 수락",
    ["Quest handed in here"] = "여기서 퀘스트 완료",
    ["You died here"] = "여기서 사망",
    ["Killed by %s"] = "사망 원인: %s",
    ["Footprints: %d spots   Kills: %d   Deaths: %d"] = "발자취: %d곳   처치: %d   사망: %d",
    ["No travels recorded yet."] = "아직 여행 기록이 없습니다.",

    -- bestiary
    ["Name"] = "이름",
    ["Level"] = "레벨",
    ["Recent"] = "최근",
    ["Foes"] = "적",
    ["Nemeses"] = "숙적",
    ["Bosses and rares"] = "우두머리 및 희귀",
    ["Boss"] = "우두머리",
    ["Rare"] = "희귀",
    ["Elite"] = "정예",
    ["Normal"] = "일반",
    ["No portrait"] = "초상화 없음",
    ["KILLS PER DAY"] = "일별 처치 수",
    ["Kills: %d"] = "처치: %d",
    ["Rank: #%d of %d kinds"] = "순위: %d위 / %d종",
    ["First kill:"] = "첫 처치:",
    ["Last kill:"] = "마지막 처치:",
    ["Seen in:"] = "출현 지역:",
    ["This creature killed you %d times."] = "이 몬스터에게 %d번 사망했습니다.",
    ["Your nemesis"] = "당신의 숙적",
    ["Last seen in:"] = "마지막 목격 장소:",
    ["Last time:"] = "마지막:",
    ["You have killed it %d times."] = "이 몬스터를 %d번 처치했습니다.",
    ["Nobody has killed you yet."] = "아직 아무에게도 죽지 않았습니다.",

    -- people
    ["Talks"] = "대화",
    ["First met"] = "첫 만남",
    ["Show on map"] = "지도에 표시",
    ["QUESTS WITH THIS PERSON"] = "이 인물과 관련된 퀘스트",
    ["Conversations: %d"] = "대화: %d회",
    ["Found in:"] = "위치:",
    ["First met:"] = "첫 만남:",
    ["Last met:"] = "마지막 만남:",
    ["given and received"] = "수락 및 완료",
    ["given"] = "수락",
    ["handed in"] = "완료",
    ["No quests recorded."] = "기록된 퀘스트가 없습니다.",
    ["Role:"] = "역할:",
    ["All"] = "전체",
    ["%d of %d people"] = "%d / %d명",
    ["You have not talked to anyone yet."] = "아직 아무와도 대화하지 않았습니다.",
    ["Conversation"] = "대화",
    ["Vendor"] = "상인",
    ["Trainer"] = "상급자",
    ["Flight master"] = "비행 조련사",
    ["Banker"] = "은행원",
    ["Stable master"] = "야수 관리인",
    ["Petitions"] = "길드 청원",
    ["Auctioneer"] = "경매인",

    -- quests
    ["Completed"] = "완료",
    ["Open"] = "미완료",
    ["Abandoned"] = "포기",
    ["In progress"] = "진행 중",
    ["Received from:"] = "의뢰인:",
    ["Handed in to:"] = "보고 대상:",
    ["Accepted:"] = "수락:",
    ["Completed:"] = "완료:",
    ["Took:"] = "소요 시간:",
    ["Experience:"] = "경험치:",
    ["Gold reward:"] = "골드 보상:",
    ["Reward:"] = "보상:",
    ["Where I accepted it"] = "수락한 곳",
    ["Where I handed it in"] = "완료한 곳",
    ["%d of %d quests completed"] = "퀘스트 %d / %d개 완료",
    ["No quests recorded yet."] = "아직 기록된 퀘스트가 없습니다.",

    -- statistics
    ["Gold"] = "골드",
    ["XP"] = "경험치",
    ["Time"] = "시간",
    ["Distance"] = "거리",
    ["Nothing to chart yet."] = "아직 표시할 내용이 없습니다.",
    ["WHERE THE MONEY CAME FROM"] = "돈은 어디서 왔나",
    ["WHERE THE MONEY WENT"] = "돈은 어디로 갔나",
    ["In total: %d kills  |  %d quests  |  %s online  |  %.1f km on foot  |  %d deaths  |  %d jumps"] =
        "총계: 처치 %d  |  퀘스트 %d  |  접속 %s  |  도보 %.1fkm  |  사망 %d  |  점프 %d",

    -- money categories
    ["Quest rewards"] = "퀘스트 보상",
    ["Vendor sales"] = "상점 판매",
    ["Mail"] = "우편",
    ["Trading"] = "거래",
    ["Auction house"] = "경매장",
    ["Repairs"] = "수리",
    ["Purchases"] = "구매",
    ["Training"] = "기술 훈련",
    ["Flights"] = "비행",
    ["Bank"] = "은행",
    ["Other"] = "기타",

    -- export / settings
    ["Born:"] = "탄생:",
    ["As text"] = "텍스트로",
    ["Select all"] = "모두 선택",
    ["Ctrl+C copies the selection."] = "Ctrl+C로 선택한 내용을 복사합니다.",
    ["SETTINGS"] = "설정",
    ["Take a screenshot at milestones"] = "중요한 순간에 스크린샷 찍기",
    ["Announce milestones in chat"] = "중요한 순간을 대화창에 알리기",
    ["Show minimap button"] = "미니맵 버튼 표시",
    ["First day"] = "첫째 날",

    -- redesigned interface
    ["Travel Diary"] = "여행 일기",
    ["Day of life"] = "생애 일수",
    ["Days of life"] = "생애 일수",
    ["Memories of the day"] = "오늘의 추억",
    ["A day without great events."] = "큰 사건 없는 하루.",
    ["Ledger"] = "결산",
    ["Experience"] = "경험치",
    ["Conversations"] = "대화",
    ["On foot"] = "도보",
    ["Map of my travels"] = "나의 여행 지도",
    ["Layers"] = "레이어",
    ["%d kinds - %d kills"] = "%d종 - %d마리 처치",
    ["%d nemeses"] = "숙적 %d",
    ["No creature has fallen yet."] = "아직 쓰러진 몬스터가 없습니다.",
    ["Slain"] = "처치",
    ["Rank"] = "순위",
    ["First kill"] = "첫 처치",
    ["Last kill"] = "마지막 처치",
    ["Seen in"] = "출현 지역",
    ["Killed you"] = "나를 죽인 횟수",
    ["You slew it"] = "내가 처치한 횟수",
    ["Last seen in"] = "마지막 목격 장소",
    ["Last time"] = "마지막",
    ["\"First encountered on day %d in %s.\""] = "\"%d일째, %s에서 처음 마주쳤다.\"",
    ["\"Revenge is a dish best served cold.\""] = "\"복수는 차갑게 식혀서 먹어야 제맛이다.\"",
    ["Acquaintances"] = "아는 사람들",
    ["Found in"] = "위치",
    ["Place"] = "장소",
    ["Last met"] = "마지막 만남",
    ["Region"] = "지역",
    ["Received from"] = "의뢰인",
    ["Handed in to"] = "보고 대상",
    ["Accepted"] = "수락",
    ["Took"] = "소요 시간",
    ["Reward"] = "보상",
    ["Balance of a life"] = "한 생애의 결산",
    ["Since %s"] = "%s부터",
    ["Remarkable"] = "주목할 기록",
    ["Bloodiest day"] = "가장 피비린내 나는 날",
    ["Richest day"] = "가장 많이 번 날",
    ["Favourite prey"] = "가장 즐겨 찾는 사냥감",
    ["Arch-enemy"] = "숙적",
    ["Home of the heart"] = "마음의 고향",
    ["Closest confidant"] = "가장 가까운 벗",
    ["Day by day"] = "하루하루",
    ["Came from"] = "수입원",
    ["Went to"] = "지출처",
    ["Transcript"] = "기록 사본",
    ["Settings"] = "설정",
    ["Size of the book"] = "책 크기",
    ["Demo"] = "데모",
    ["Start demo mode"] = "데모 모드 시작",
    ["Leave demo mode"] = "데모 모드 종료",
    ["Commands"] = "명령어",
    ["open or close the diary"] = "일기 열기/닫기",
    ["explore with invented data"] = "가상 데이터로 둘러보기",
    ["screenshots on or off"] = "스크린샷 켜기/끄기",
    ["minimap button on or off"] = "미니맵 버튼 켜기/끄기",
    ["\"Screenshots are saved in the Screenshots folder of your game.\""] = "\"스크린샷은 게임의 Screenshots 폴더에 저장됩니다.\"",
}
for k, v in pairs(T) do L[k] = v end

-- dates and diary entries
loc.date = "%Y. %m. %d."
loc.dayMonth = "%m. %d."
loc.weekdays = { "일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일" }
loc.months = { "1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월" }
function loc.longDate(d)
    return string.format("%d년 %d월 %d일 %s", d.year, d.month, d.day, loc.weekdays[d.wday])
end

loc.narrator = {
    birth = {
        "1일째. 나는 %s %s. 오늘 %s에서 눈을 떴다. 앞으로 무슨 일이 있을지는 나도 모르겠다.",
        "1일째. %s %s, 막 %s에 도착. 어디로 흘러갈지 두고 보자.",
    },
    begin = {
        "1일째. 오늘부터 여행하면서 있었던 일을 적어 보기로 했다.",
    },
    open = {
        "%d일째, %s.",
        "%d일째. 오늘은 주로 %s에 있었다.",
        "%d일째. 다시 길을 나섰다. 이번엔 %s 쪽이다.",
    },
    far = "낯선 곳",
    walk = {
        "오늘 걸은 거리는 약 %s킬로미터%s.",
        "발이 말해 준다. 대략 %s킬로미터%s.",
        "걸어서 %s킬로미터쯤%s. 다리가 뻐근하다.",
    },
    via = " (%s)",
    fly = " 나머지 길은 날아서 갔다.",
    kills = {
        "오늘 적 %d명을 쓰러뜨렸다.",
        "몬스터 %d마리를 처치했다.",
        "세상에서 적이 %d마리 줄었다.",
    },
    top = {
        "제일 많이 잡은 건 %s (%dx).",
        "가장 자주 마주친 상대는 %s (%dx).",
    },
    special = "기억해 둘 것: %s.",
    deaths = {
        "오늘 %d번 죽었다.%s",
        "바닥에 %d번 드러누웠다.%s",
    },
    deathBy = " 마지막엔 %s에게 당했다.",
    noDeath = {
        "오늘은 한 번도 안 죽었다.",
        "사망 0회. 나쁘지 않다.",
    },
    questDone = {
        "퀘스트 %d개 완료: %s.",
        "목록에서 지운 것: %s.",
    },
    questAcc = {
        "대신 새 퀘스트가 %d개 생겼다.",
        "그리고 벌써 새 퀘스트 %d개가 기다린다.",
    },
    questAccOnly = {
        "새 퀘스트 %d개를 받았는데, 아직 끝낸 건 없다.",
    },
    more = "외",
    quote = {
        "%s의 말: %s",
        "%s 왈: %s",
    },
    quoteAnon = "기억에 남은 한마디: %s",
    npcs = {
        "%d명과 이야기했다. %s 등.",
        "대화 %d번. 예를 들면 %s.",
    },
    gain = {
        "주머니가 %s 두둑해졌다.",
        "결국 %s 더 벌었다.",
    },
    loss = {
        "주머니가 %s 가벼워졌다.",
        "결국 오늘 %s 썼다.",
    },
    src = " 수입은 대부분 %s (%s).",
    spent = " 지출은 대부분 %s (%s).",
    item = {
        "오늘의 수확: %s.",
        "제일 괜찮은 득템: %s.",
    },
    levels = {
        "레벨 %s 달성.",
        "드디어 %s 레벨!",
    },
    quiet = {
        "조용한 하루. 별로 쓸 게 없다.",
        "오늘은 별일 없었다.",
    },
    begun = {
        "하루가 이제 막 시작되었다.",
        "아직 이른 하루다.",
        "새로운 하루가 막 시작되는 참이다.",
    },
    ongoing = {
        "아직 하루가 끝나지 않았다.",
        "다음에 계속 ...",
        "오늘이 또 무엇을 가져다줄지 지켜보자.",
    },
    close = {
        "오늘은 여기까지.",
        "이만하면 됐다. 내일 또 가자.",
        "일단 좀 쉬자.",
        "내일은 또 뭐가 있을까.",
    },
    closeLong = {
        "%s 동안 돌아다녔다. 오늘은 이걸로 충분.",
        "%s 동안 움직였더니 완전 녹초다.",
    },
    none = "이 날의 기록은 없다.",
}

-- book interface
L["Appendix"] = "부록"
L["Begun on %s"] = "시작일: %s"
L["Bookmark"] = "책갈피"
L["Click to open today's entry."] = "클릭하면 오늘의 기록을 엽니다."
L["Click to open"] = "클릭하여 열기"
L["Contents"] = "목차"
L["Notes"] = "메모"
L["Page %d"] = "%d쪽"
L["Realm: %s"] = "서버: %s"
L["This book belongs to"] = "이 책의 주인"
L["in %s, at level %d"] = "%s에서, %d 레벨에"
L["in %s, on the first day of my life"] = "%s에서, 내 생애 첫날에"
L["of"] = "기록자"

-- book pages (diary, appendix)
L["\"Whoever wanders, gathers stories.\""] = "\"떠도는 자는 이야기를 모은다.\""
L["Arrival in %s"] = "%s 도착"
L["Days in %s"] = "%s에서의 나날"
L["Shadows over %s"] = "%s에 드리운 그림자"
L["The roads of %s"] = "%s의 길"
L["Under the skies of %s"] = "%s의 하늘 아래"
L["Awakening in %s"] = "%s에서 눈뜨다"
L["Return to %s"] = "%s 귀환"
L["Chapter"] = "챕터"
L["Level %d-%d"] = "%d-%d 레벨"
L["Days %d-%d"] = "%d-%d일째"
L["Level %d!"] = "%d 레벨!"
L["%d kills"] = "%d마리 처치"
L["%d quests"] = "퀘스트 %d개"
L["died %dx"] = "%d번 사망"
L["Kept as a memory"] = "추억으로 간직"
L["Click to read this day aloud in chat."] = "클릭하면 이 날의 기록을 대화창에 읽어 줍니다."
L["The pages are still empty. Go and live an adventure!"] = "아직 페이지가 비어 있습니다. 모험을 떠나 보세요!"
L["p. %d"] = "%d쪽"
L["Milestones"] = "이정표"
L["The great moments of a life"] = "한 생애의 위대한 순간들"
L["No milestones yet."] = "아직 이정표가 없습니다."
L["Maps"] = "지도"
L["%s spent here"] = "여기서 보낸 시간: %s"
L["Route"] = "경로"
L["Kill sites"] = "전투 장소"
L["Graves"] = "무덤"
L["First visit"] = "첫 방문"
L["Time spent"] = "머문 시간"
L["Creatures slain here"] = "여기서 처치한 몬스터"
L["Acquaintances here"] = "여기서 만난 사람들"
L["A naturalist's notes"] = "박물학자의 기록"
L["Slain %d times"] = "%d번 처치"
L["Killed you %d times"] = "나를 %d번 죽임"
L["Every creature, by number slain"] = "모든 몬스터, 처치 수 순"
L["Everyone I met on my way"] = "길 위에서 만난 모든 이들"
L["Every coin, in and out"] = "들어오고 나간 모든 동전"
L["Balance"] = "차액"
L["Day"] = "날짜"
L["Tasks taken and done"] = "받은 임무와 완수한 임무"
L["Scribe's notes"] = "필경사의 메모"
L["How this book is kept"] = "이 책을 기록하는 방법"
L["Copy the diary as text"] = "일기를 텍스트로 복사"
L["Copy the diary as JSON"] = "일기를 JSON으로 복사"
L["Ledger"] = "회계 장부"

-- own notes
L["Click here to write your own notes ..."] = "여기를 클릭해 나만의 메모를 작성하세요 ..."
L["My own thoughts:"] = "나의 생각:"
L["+ note"] = "+ 메모"
L["edit note"] = "메모 편집"
L["Save"] = "저장"
L["Cancel"] = "취소"

-- cards
L["Wanted poster"] = "현상수배 전단"
L["Acquaintance"] = "아는 사람"
L["Click for the wanted poster."] = "클릭하면 현상수배 전단을 봅니다."
L["Click for the portrait."] = "클릭하면 초상화를 봅니다."

-- collector's album
L["A collector's album of every creature slain"] = "처치한 모든 몬스터의 수집 앨범"
L["kinds collected  -  %d creatures slain"] = "종 수집  -  %d마리 처치"
L["Bronze"] = "브론즈"
L["Silver"] = "실버"
L["Mithril"] = "미스릴"
L["Legend"] = "전설"
L["Collect %d kinds of creatures."] = "몬스터 %d종을 수집하세요."
L["Reached!"] = "달성!"
L["%d still missing."] = "%d종 남음."
L["Bosses"] = "우두머리"
L["Rare creatures"] = "희귀 몬스터"
L["Album pages"] = "앨범 페이지"
L["%d kinds"] = "%d종"
L["Lv %s"] = "Lv %s"
L["NEW"] = "신규"
L["not yet found"] = "아직 발견하지 못함"

-- language switch
L["German"] = "독일어"
L["English"] = "영어"
L["French"] = "프랑스어"
L["Spanish"] = "스페인어"
L["Portuguese"] = "포르투갈어"
L["Russian"] = "러시아어"
L["Korean"] = "한국어"
L["Chinese (traditional)"] = "중국어(번체)"
L["Language"] = "언어"
L["Game language (%s)"] = "게임 언어 (%s)"
L["The diary will reload the interface to switch the language."] = "언어를 변경하기 위해 UI를 다시 불러옵니다."
L["Korean and Chinese text needs a game client with those fonts."] = "한국어와 중국어는 해당 글꼴이 있는 게임 클라이언트가 필요합니다."

-- map spreads
L["Places of note"] = "주목할 만한 장소"
L["Nobody was met here yet."] = "아직 이곳에서 만난 사람이 없습니다."
L["Grave"] = "무덤"
L["Chronicle of the region"] = "지역 연대기"
L["Visits"] = "방문 횟수"
L["Quests completed here"] = "이곳에서 완료한 퀘스트"
L["Deaths here"] = "이곳에서 사망"
L["Most hunted here"] = "이곳에서 가장 많이 사냥한 대상"
L["Places discovered"] = "발견한 장소"

-- companions, honours, treasures, memories, obituary
L["%d days of life  -  %d creatures slain  -  %d quests completed"] = "생애 %d일  -  몬스터 %d마리 처치  -  퀘스트 %d개 완료"
L["%d days"] = "%d일"
L["%d enemies fell that day."] = "그날 적 %d명이 쓰러졌다."
L["%d kills together"] = "함께 %d마리 처치"
L["%d of %d honours earned"] = "명예 %d / %d개 획득"
L["%d times grouped"] = "%d번 함께함"
L["%d treasures collected"] = "보물 %d개 수집"
L["%dx traded"] = "%d번 거래"
L["A painted memory"] = "그림으로 남긴 추억"
L["Book of honour"] = "명예의 책"
L["Companions"] = "동료"
L["Copy for forum or Discord (Markdown)"] = "포럼 또는 Discord용으로 복사 (Markdown)"
L["Fell in %s"] = "%s에서 쓰러짐"
L["Fell to %s"] = "%s에게 쓰러짐"
L["Slain by %s"] = "%s에게 살해당함"
L["Fellow adventurers"] = "함께한 모험가들"
L["Fellowship"] = "동료애"
L["Grouped with %s"] = "파티: %s"
L["In memoriam"] = "추모"
L["Loot of %s"] = "%s의 전리품"
L["No trades yet."] = "아직 거래가 없습니다."
L["No treasures found yet."] = "아직 찾은 보물이 없습니다."
L["Rested here"] = "여기서 휴식"
L["Times rested here"] = "이곳에서 휴식한 횟수"
L["The last moment"] = "마지막 순간"
L["Today, %d days ago"] = "%d일 전 오늘"
L["Trading partners"] = "거래 상대"
L["Treasures"] = "보물"
L["Who walked beside me"] = "내 곁을 걸은 이들"
L["You have not grouped with anyone yet."] = "아직 누구와도 파티를 맺지 않았습니다."
L["You were in %s."] = "당신은 %s에 있었습니다."
L["early in the morning"] = "이른 아침"
L["in the morning"] = "오전"
L["around noon"] = "정오 무렵"
L["in the afternoon"] = "오후"
L["in the evening"] = "저녁"
L["late at night"] = "늦은 밤"
L["earned"] = "획득"
L["first met %s"] = "첫 만남 %s"

-- honours
L["First Blood"] = "첫 피"
L["Slay your first creature."] = "첫 번째 몬스터를 처치하세요."
L["Slayer"] = "학살자"
L["Slay 100 creatures."] = "몬스터 100마리를 처치하세요."
L["Scourge of the Wilds"] = "야생의 재앙"
L["Slay 1000 creatures."] = "몬스터 1000마리를 처치하세요."
L["Champion"] = "챔피언"
L["Slay 5000 creatures."] = "몬스터 5000마리를 처치하세요."
L["Specialist"] = "전문가"
L["Slay 100 of a single kind."] = "같은 종류의 몬스터 100마리를 처치하세요."
L["Naturalist"] = "박물학자"
L["Collect 50 kinds of creatures."] = "몬스터 50종을 수집하세요."
L["Rare Hunter"] = "희귀 사냥꾼"
L["Slay 5 rare creatures."] = "희귀 몬스터 5마리를 처치하세요."
L["Bane of Bosses"] = "우두머리의 천적"
L["Defeat a boss."] = "우두머리를 물리치세요."
L["Giant Slayer"] = "거인 학살자"
L["Defeat 10 bosses."] = "우두머리 10명을 물리치세요."
L["Into the Depths"] = "심연 속으로"
L["Enter a dungeon."] = "던전에 입장하세요."
L["Hunter"] = "사냥꾼"
L["Helping Hand"] = "도움의 손길"
L["Complete 10 quests."] = "퀘스트 10개를 완료하세요."
L["Hero of the People"] = "민중의 영웅"
L["Complete 100 quests."] = "퀘스트 100개를 완료하세요."
L["Explorer"] = "탐험가"
L["Discover 25 places."] = "장소 25곳을 발견하세요."
L["Cartographer"] = "지도 제작자"
L["Discover 100 places."] = "장소 100곳을 발견하세요."
L["Globetrotter"] = "세계 여행자"
L["Visit 5 regions."] = "지역 5곳을 방문하세요."
L["Wanderer"] = "방랑자"
L["Walk 50 kilometres."] = "도보로 50킬로미터를 이동하세요."
L["Pathfinder"] = "개척자"
L["Walk 250 kilometres."] = "도보로 250킬로미터를 이동하세요."
L["Frequent Flyer"] = "단골 비행객"
L["Take 10 flights."] = "비행을 10번 이용하세요."
L["Thrifty"] = "알뜰한 자"
L["Own 10 gold."] = "10골드를 보유하세요."
L["Wealthy"] = "부자"
L["Own 100 gold."] = "100골드를 보유하세요."
L["Seasoned"] = "숙련자"
L["Reach level 20."] = "20 레벨에 도달하세요."
L["Veteran"] = "베테랑"
L["Reach level 40."] = "40 레벨에 도달하세요."
L["Reach level 60."] = "60 레벨에 도달하세요."
L["Untouchable"] = "불사신"
L["Play 5 days in a row without dying."] = "죽지 않고 5일 연속 플레이하세요."
L["Faithful Chronicler"] = "충실한 기록자"
L["Keep this diary for 30 days."] = "이 일기를 30일 동안 기록하세요."
L["Sociable"] = "사교가"
L["Meet 25 people."] = "25명을 만나세요."
L["Bouncy"] = "점프왕"
L["Jump 1000 times."] = "1000번 점프하세요."
L["Treasure Hunter"] = "보물 사냥꾼"
L["Find 5 rare items."] = "희귀 아이템 5개를 찾으세요."
L["Group with 5 other adventurers."] = "다른 모험가 5명과 파티를 맺으세요."

-- keepsake captions
L["Level up"] = "레벨 업"
L["Epic find"] = "영웅 발견"
L["Rare find"] = "희귀 발견"
L["Death"] = "죽음"
L["New land"] = "새로운 땅"
L["Dungeon"] = "던전"
L["Quest"] = "퀘스트"
L["Wealth"] = "재산"
L["Skill"] = "기술"
L["Hunt"] = "사냥"
L["Moment"] = "순간"

-- honour tiers, atlas, landmarks, secrets
L["%d honour points"] = "명예 점수 %d"
L["%d of %d landmarks found"] = "명소 %d / %d곳 발견"
L["%d of %d regions explored"] = "지역 %d / %d곳 탐험"
L["%d tiers earned"] = "%d단계 달성"
L["A familiar face ..."] = "낯익은 얼굴 ..."
L["A secret honour. Keep exploring!"] = "비밀 명예입니다. 계속 탐험하세요!"
L["Adventure"] = "모험"
L["Almost there"] = "거의 다 왔습니다"
L["Atlas"] = "지도첩"
L["Bad Day"] = "최악의 날"
L["Barterer"] = "물물교환꾼"
L["Be on the road before seven in the morning."] = "아침 7시 전에 길을 나서세요."
L["Be on the road between midnight and four o'clock."] = "자정부터 새벽 4시 사이에 길을 나서세요."
L["Bloodbath"] = "피바다"
L["Busy Bee"] = "부지런한 꿀벌"
L["Capital Tourist"] = "수도 관광객"
L["Capitals"] = "수도"
L["Click for all landmarks."] = "클릭하면 모든 명소를 봅니다."
L["Click for the map of this region."] = "클릭하면 이 지역의 지도를 봅니다."
L["Click to open this part of the book."] = "클릭하면 책의 이 부분을 엽니다."
L["Collection"] = "수집"
L["Combat"] = "전투"
L["Complete %d quests in a single day."] = "하루에 퀘스트 %d개를 완료하세요."
L["Complete %d quests."] = "퀘스트 %d개를 완료하세요."
L["Complete!"] = "완성!"
L["Curiosities"] = "진기한 기록"
L["Dark places, rich rewards"] = "어두운 곳, 풍성한 보상"
L["Defeat %d bosses."] = "우두머리 %d명을 물리치세요."
L["Destination of the day"] = "오늘의 목적지"
L["Devoted"] = "헌신적인 자"
L["Die %d times and rise again."] = "%d번 죽고 다시 일어서세요."
L["Die %d times in a single day."] = "하루에 %d번 죽으세요."
L["Discover %d places."] = "장소 %d곳을 발견하세요."
L["Do business with %d merchants."] = "상인 %d명과 거래하세요."
L["Dungeons"] = "던전"
L["Eager Student"] = "열성적인 학생"
L["Early Bird"] = "아침형 인간"
L["Elite Slayer"] = "정예 학살자"
L["Encounters"] = "만남"
L["Enter %d dungeons."] = "던전 %d곳에 입장하세요."
L["Epic Fortune"] = "영웅급 행운"
L["Every journey needs a pause ..."] = "모든 여행에는 쉼표가 필요하다 ..."
L["Every region of this continent is explored."] = "이 대륙의 모든 지역을 탐험했습니다."
L["Exploration"] = "탐험"
L["Explored"] = "탐험함"
L["Explorer's checklist"] = "탐험가의 체크리스트"
L["Famous places of Azeroth"] = "아제로스의 명소"
L["Find %d epic items."] = "영웅 등급 아이템 %d개를 찾으세요."
L["Find %d landmarks."] = "명소 %d곳을 찾으세요."
L["Find %d rare items."] = "희귀 아이템 %d개를 찾으세요."
L["Fortune and craft"] = "행운과 기술"
L["Globetrotter's Day"] = "세계 여행자의 하루"
L["Group with %d other adventurers."] = "다른 모험가 %d명과 파티를 맺으세요."
L["Haggler"] = "흥정꾼"
L["Hoarder"] = "수집광"
L["Homesick"] = "향수병"
L["Honour earned: %s (%s)"] = "명예 획득: %s (%s)"
L["Honour earned: %s"] = "명예 획득: %s"
L["Honour points"] = "명예 점수"
L["Honour"] = "명예"
L["Jump %d times."] = "%d번 점프하세요."
L["Just one more quest ..."] = "딱 하나만 더 ..."
L["Keep this diary for %d days."] = "이 일기를 %d일 동안 기록하세요."
L["Landmark discovered: %s"] = "명소 발견: %s"
L["Landmark"] = "명소"
L["Landmarks"] = "명소"
L["Loot %d items."] = "아이템 %d개를 획득하세요."
L["Marathon"] = "마라톤"
L["Master of a Craft"] = "기술의 달인"
L["Meet %d flight masters."] = "비행 조련사 %d명을 만나세요."
L["Meet %d people."] = "%d명을 만나세요."
L["Mouse wheel: zoom  -  drag: move  -  right click: reset"] = "마우스 휠: 확대/축소  -  드래그: 이동  -  오른쪽 클릭: 초기화"
L["Next goals"] = "다음 목표"
L["Next rank: %s"] = "다음 등급: %s"
L["Night Owl"] = "올빼미"
L["Not every day is a good day ..."] = "매일이 좋은 날일 수는 없다 ..."
L["Not yet explored"] = "아직 탐험하지 않음"
L["Own %d gold."] = "%d골드를 보유하세요."
L["People met"] = "만난 사람"
L["Phoenix"] = "불사조"
L["Play %d days in a row without dying."] = "죽지 않고 %d일 연속 플레이하세요."
L["Raids"] = "공격대"
L["Raise a skill to %d."] = "전문 기술 하나를 %d까지 올리세요."
L["Reach level %d."] = "%d 레벨에 도달하세요."
L["Regions explored"] = "탐험한 지역"
L["Regular"] = "단골"
L["Rest at %d places."] = "%d곳에서 휴식하세요."
L["Secrets"] = "비밀"
L["Sightseer"] = "구경꾼"
L["Slay %d creatures in a single day."] = "하루에 몬스터 %d마리를 처치하세요."
L["Slay %d creatures."] = "몬스터 %d마리를 처치하세요."
L["Slay %d elite creatures."] = "정예 몬스터 %d마리를 처치하세요."
L["Slay %d of a single kind."] = "같은 종류의 몬스터 %d마리를 처치하세요."
L["Slay %d rare creatures."] = "희귀 몬스터 %d마리를 처치하세요."
L["So many roads, so little time ..."] = "갈 길은 많은데 시간은 없다 ..."
L["Some honours stay hidden until you find them."] = "일부 명예는 찾기 전까지 숨겨져 있습니다."
L["Spend %d hours in the world on a single day."] = "하루에 %d시간 동안 세상을 누비세요."
L["Spend %d hours in the world."] = "%d시간 동안 세상을 누비세요."
L["Take %d flights."] = "비행을 %d번 이용하세요."
L["Talk to the same person %d times."] = "같은 사람과 %d번 대화하세요."
L["The early bird catches the worm ..."] = "일찍 일어나는 새가 벌레를 잡는다 ..."
L["The purse over the days"] = "날마다의 지갑"
L["There is no place like home ..."] = "집만 한 곳이 없다 ..."
L["This game client knows none of the landmarks."] = "이 게임 클라이언트는 명소를 하나도 알지 못합니다."
L["Towns of Kalimdor"] = "칼림도어의 장소"
L["Towns of the Eastern Kingdoms"] = "동부 왕국의 장소"
L["Trade with %d players."] = "플레이어 %d명과 거래하세요."
L["Unexplored regions"] = "미탐험 지역"
L["Up, up and away ..."] = "높이, 더 높이 ..."
L["Use your hearthstone %d times."] = "귀환석을 %d번 사용하세요."
L["Visit %d capital cities."] = "수도 %d곳을 방문하세요."
L["Visit %d regions in a single day."] = "하루에 지역 %d곳을 방문하세요."
L["Visit %d regions."] = "지역 %d곳을 방문하세요."
L["Visit %d trainers."] = "상급자 %d명을 방문하세요."
L["Walk %d kilometres."] = "도보로 %d킬로미터를 이동하세요."
L["Well Rested"] = "푹 쉰 자"
L["What is left to discover"] = "아직 발견할 것들"
L["When the moon stands highest ..."] = "달이 가장 높이 뜰 때 ..."
L["Where will the road lead tomorrow?"] = "내일은 길이 어디로 이어질까?"
L["Wings of the World"] = "세상의 날개"
L["You have not seen this place yet."] = "아직 이곳을 보지 못했습니다."
L["You have seen every landmark. Remarkable!"] = "모든 명소를 보았습니다. 대단합니다!"
L["days"] = "일"
L["done"] = "완료"
L["given up"] = "포기"
L["kills"] = "처치"
L["open"] = "진행 중"

-- treasure album, wanted posters
L["WANTED"] = "현상수배"
L["of %d kinds"] = "/ %d종"
L["Next mark: %d slain"] = "다음 목표: %d마리 처치"
L["Every mark reached"] = "모든 목표 달성"
L["Uncommon"] = "고급"
L["Epic"] = "영웅"
L["Legendary"] = "전설"

-- tasks of the day, pop-ups, week in review
L["Slay %d creatures today."] = "오늘 몬스터 %d마리를 처치하세요."
L["Complete %d quests today."] = "오늘 퀘스트 %d개를 완료하세요."
L["Meet %d new people."] = "새로운 사람 %d명을 만나세요."
L["Discover %d new places."] = "새로운 장소 %d곳을 발견하세요."
L["Walk %d kilometres today."] = "오늘 도보로 %d킬로미터를 이동하세요."
L["Find an uncommon or better item."] = "고급 이상 등급의 아이템을 찾으세요."
L["Visit the landmark %s."] = "명소를 방문하세요: %s."
L["Set foot in %s."] = "%s 지역에 발을 들이세요."
L["Task of the day done: %s"] = "오늘의 과제 완료: %s"
L["All tasks of the day done! %d days in a row."] = "오늘의 과제를 모두 완료했습니다! %d일 연속."
L["All tasks of the day done!"] = "오늘의 과제를 모두 완료했습니다!"
L["Tasks of the day"] = "오늘의 과제"
L["Task of the day"] = "오늘의 과제"
L["Dungeon Crawler"] = "던전 탐험가"
L["Finish %d dungeon runs."] = "던전 공략을 %d번 마치세요."
L["Diligent"] = "성실한 자"
L["Do all tasks of the day on %d days."] = "%d일 동안 오늘의 과제를 모두 완료하세요."
L["Dutiful"] = "책임감 있는 자"
L["Do all tasks of the day %d days in a row."] = "%d일 연속으로 오늘의 과제를 모두 완료하세요."
L["Open the diary"] = "일기 펼치기"
L["Close"] = "닫기"
L["The week in review"] = "주간 회고"
L["Creatures slain"] = "처치한 몬스터"
L["Levels"] = "레벨"
L["Kilometres"] = "킬로미터"
L["New places"] = "새로운 장소"
L["New regions"] = "새로운 지역"
L["Honours"] = "명예"
L["Best day"] = "최고의 날"
L["A quiet week"] = "조용한 한 주"
L["The book waits for new stories."] = "책이 새로운 이야기를 기다립니다."
L["Show a note for new discoveries"] = "새로운 발견 알림 표시"
L["Weekly look back at login"] = "접속 시 주간 회고 표시"

-- records, level timeline, gallery, nemeses, dungeon reports
L["Records"] = "기록"
L["The best and the worst of days"] = "최고의 날과 최악의 날"
L["Most creatures slain in a day"] = "하루 최다 처치"
L["Most quests in a day"] = "하루 최다 퀘스트"
L["Richest day"] = "가장 수입이 많은 날"
L["Most experience in a day"] = "하루 최다 경험치"
L["Longest day in the world"] = "가장 오래 머문 날"
L["Longest walk in a day"] = "하루 최장 도보 이동"
L["Most places discovered in a day"] = "하루 최다 장소 발견"
L["Most new faces in a day"] = "하루 최다 새 얼굴"
L["Fastest level"] = "가장 빠른 레벨"
L["Slowest level"] = "가장 느린 레벨"
L["Longest run without dying"] = "최장 무사망 기간"
L["Darkest day"] = "가장 암울한 날"
L["Level timeline"] = "레벨 연대기"
L["How long each level took"] = "레벨별 소요 시간"
L["Played for these levels"] = "이 레벨들의 플레이 시간"
L["Per level"] = "레벨당"
L["No level-ups recorded yet."] = "아직 기록된 레벨 업이 없습니다."
L["Still on the way."] = "아직 진행 중."
L["Reached the next level on day %d."] = "%d일째에 다음 레벨 달성."
L["Gallery"] = "화랑"
L["Moments, painted in the gear of their day"] = "그날의 장비로 그린 순간들"
L["The first painting waits for your first great moment."] = "첫 그림이 당신의 첫 위대한 순간을 기다립니다."
L["Nemeses"] = "숙적"
L["They sent me to the spirit healer"] = "나를 영혼의 치유사에게 보낸 자들"
L["Nemesis number one"] = "제1의 숙적"
L["Nobody has defeated you yet. Long may it last!"] = "아직 아무도 당신을 쓰러뜨리지 못했습니다. 계속 그러길!"
L["Killed you %d times"] = "당신을 %d번 죽임"
L["Revenge taken"] = "복수 완료"
L["Score unsettled"] = "갚아야 할 빚"
L["You slew them %d times."] = "당신은 그들을 %d번 처치했습니다."
L["Dungeon reports"] = "던전 보고서"
L["No dungeon visited yet. The depths are waiting."] = "아직 방문한 던전이 없습니다. 깊은 곳이 기다립니다."
L["Duration"] = "소요 시간"
L["Fallen"] = "쓰러짐"
L["The group"] = "파티"
L["Me"] = "나"
L["Nobody fell."] = "아무도 쓰러지지 않았습니다."

-- ledger figures, achievement pop-up, blocked functions, quotes
L["Best day: day %d"] = "최고의 날: %d일차"
L["Worst day: day %d"] = "최악의 날: %d일차"
L["Per day"] = "하루 평균"
L["Honour earned"] = "명예 획득"
L["Landmark discovered"] = "명소 발견"
L["Next tier:"] = "다음 등급:"
L["Every tier earned - complete!"] = "모든 등급 획득 - 완성!"
L["The game blocked the function %s. Please tell the author."] = "게임이 %s 기능을 차단했습니다. 제작자에게 알려 주세요."
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "이 게임 클라이언트는 애드온의 스크린샷을 허용하지 않습니다. 중요한 순간의 스크린샷이 꺼졌습니다."
L['"Here the journey ends, but not the story."'] = '"여정은 여기서 끝나지만, 이야기는 끝나지 않는다."'
L['"Whoever wanders, gathers stories."'] = '"떠도는 자는 이야기를 모은다."'

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "처음 해 본 일들"
L["First time"] = "처음"
L["%d of %d experienced"] = "%d / %d 경험함"
L["Not yet experienced."] = "아직 경험하지 못했습니다."
L["Click for all first times."] = "클릭하면 모든 '처음'을 봅니다."
L["First creature slain"] = "첫 처치"
L["First quest completed"] = "첫 퀘스트 완료"
L["First level up"] = "첫 레벨 업"
L["First uncommon item"] = "첫 고급 아이템"
L["First death"] = "첫 죽음"
L["First group"] = "첫 파티"
L["First elite slain"] = "첫 정예 처치"
L["First trade"] = "첫 거래"
L["First hearthstone"] = "첫 귀환석"
L["First landmark"] = "첫 명소"
L["First honour"] = "첫 명예"
L["First rare item"] = "첫 희귀 아이템"
L["First rare creature"] = "첫 희귀 몬스터"
L["First flight"] = "첫 비행"
L["First gold coin"] = "첫 금화"
L["First dungeon"] = "첫 던전"
L["First boss"] = "첫 우두머리"
L["First skill at 75"] = "첫 숙련도 75"
L["First mount"] = "첫 탈것"
L["First epic item"] = "첫 영웅 아이템"

L["Family book"] = "가족의 책"
L["%d characters on this account"] = "이 계정의 캐릭터 %d명"
L["you"] = "나"
L["Last seen %s"] = "마지막 접속: %s"
L["Who got there first?"] = "누가 먼저 해냈을까?"
L["Log in with your other characters once, and they will appear here."] = "다른 캐릭터로 한 번 접속하면 여기에 나타납니다."

L["Time capsule"] = "타임캡슐"
L["Letters to my future self"] = "미래의 나에게 쓰는 편지"
L["Dear me, when you read this ..."] = "이 편지를 읽을 나에게 ..."
L["Seal the letter and open it ..."] = "편지를 봉인하고 열 때는 ..."
L["in a week"] = "일주일 뒤"
L["in a month"] = "한 달 뒤"
L["at level %d"] = "%d 레벨에"
L["Until then the letter stays sealed - not even you can read it."] = "그때까지 편지는 봉인됩니다. 나도 읽을 수 없습니다."
L["No letters yet."] = "아직 편지가 없습니다."
L["Written on day %d, at level %d"] = "%d일째, %d 레벨에 씀"
L["Opened on %s"] = "%s에 열림"
L["Sealed - opens on day %d"] = "봉인됨 - %d일째에 열림"
L["Sealed - opens at level %d"] = "봉인됨 - %d 레벨에 열림"
L["in %d days"] = "%d일 남음"
L["A letter for later was sealed."] = "나중을 위한 편지를 봉인했다."
L["A letter from the past has opened."] = "과거에서 온 편지가 열렸습니다."
L["Click to read the letter."] = "클릭하면 편지를 읽습니다."

L["Gatherer's map"] = "채집 지도"
L["Where the good things grow"] = "좋은 것들이 자라는 곳"
L["Herbalism"] = "약초 채집"
L["Mining"] = "채광"
L["Skinning"] = "무두질"
L["Fishing"] = "낚시"
L["Most found here"] = "여기서 가장 많이 찾은 것"
L["Nothing gathered yet. Herbs, ore and hides show up here as soon as you gather them."] = "아직 채집한 것이 없습니다. 약초, 광석, 가죽을 모으면 여기에 표시됩니다."

L["Task of the week"] = "이번 주 과제"
L["Task of the week done: %s"] = "이번 주 과제 완료: %s"
L["Click for the next goals."] = "클릭하면 다음 목표를 봅니다."
L["Slay %d creatures this week."] = "이번 주에 몬스터 %d마리를 처치하세요."
L["Complete %d quests this week."] = "이번 주에 퀘스트 %d개를 완료하세요."
L["Walk %d kilometres this week."] = "이번 주에 %d킬로미터를 걸으세요."
L["Meet %d new people this week."] = "이번 주에 새로운 사람 %d명을 만나세요."
L["Visit %d different regions this week."] = "이번 주에 서로 다른 지역 %d곳을 방문하세요."
L["Earn %d honour tiers this week."] = "이번 주에 명예 단계 %d개를 달성하세요."
L["Finish a dungeon run this week."] = "이번 주에 던전을 한 번 공략하세요."
L["Find %d new landmarks this week."] = "이번 주에 새로운 명소 %d곳을 찾으세요."
L["Week by Week"] = "한 주 한 주"
L["Complete %d tasks of the week."] = "이번 주 과제를 %d번 완료하세요."

L["Search the diary"] = "일기 검색"
L["Days, people, creatures, quests and places."] = "날짜, 사람, 몬스터, 퀘스트, 장소."
L["Search: a name, a quest, a place ..."] = "검색: 이름, 퀘스트, 장소 ..."
L["Nothing found."] = "찾은 것이 없습니다."
L["%d more results - type a little more"] = "결과 %d개 더 - 조금 더 입력하세요"

L["The binding"] = "표지"
L["Corner studs"] = "모서리 장식"
L["none yet"] = "아직 없음"
L["Next metal at %d honour points (now %d)."] = "다음 금속: 명예 점수 %d (현재 %d)."
L["Gems"] = "보석"
L["One gem for every ten honour tiers (now %d)."] = "명예 단계 10개마다 보석 하나 (현재 %d)."
L["Gold marks on the spine"] = "책등의 금박"
L["One for every ten levels."] = "10레벨마다 하나."

-- the bookplate on the endpaper
L["FROM THE LIBRARY OF"] = "서재의 주인"

-- sayings of the day (start page)
L["SAYING OF THE DAY"] = "오늘의 한마디"
L["Whoever wanders, gathers stories."] = "떠도는 자는 이야기를 모은다."
L["Every road starts at your own door."] = "모든 길은 내 집 문 앞에서 시작된다."
L["A full pack is light when the heart is lighter."] = "마음이 가벼우면 가득 찬 배낭도 가볍다."
L["Maps show the way - only feet know it."] = "지도는 길을 보여 주지만, 길을 아는 건 발뿐이다."
L["The longest journey is the one you never write down."] = "가장 긴 여행은 끝내 적지 않은 여행이다."
L["Ink fades slower than memory."] = "잉크는 기억보다 천천히 바랜다."
L["A good campfire turns strangers into companions."] = "좋은 모닥불은 낯선 이를 동료로 만든다."
L["The mountain does not care how tired you are - just keep going."] = "산은 네가 얼마나 지쳤는지 신경 쓰지 않는다. 계속 걸으면 그만이다."
L["Today's detour is tomorrow's best story."] = "오늘 돌아간 길이 내일의 가장 좋은 이야기가 된다."
L["Gold comes and goes, the story stays."] = "금화는 오고 가지만 이야기는 남는다."
L["Count the days by friends, not by miles."] = "날들은 거리로 세지 말고 친구로 세어라."
L["Even the smallest kobold guards a candle for someone."] = "가장 작은 코볼트도 누군가를 위해 양초를 지킨다."
L["Resting is part of the road."] = "쉬는 것도 여정의 일부다."
L["Fear is a map with too many blank spots."] = "두려움은 빈칸이 너무 많은 지도다."
L["Every scar has a page in this book."] = "모든 흉터는 이 책에 한 페이지씩 있다."
L["Look back now and then - the view is part of the journey."] = "가끔은 뒤를 돌아보라. 그 풍경도 여행의 일부다."
L["The wise traveller asks the innkeeper first."] = "현명한 여행자는 여관 주인에게 먼저 묻는다."
L["Rain on the road, sunshine in the story."] = "길 위엔 비, 이야기 속엔 햇살."
L["Whoever never falls never learns to get up."] = "넘어져 보지 않은 자는 일어서는 법을 배우지 못한다."
L["A quest half done is still a step forward."] = "절반만 끝낸 퀘스트도 한 걸음 나아간 것이다."
L["The horizon travels with you - that is why it never gets dull."] = "지평선은 나와 함께 여행한다. 그래서 지루할 틈이 없다."
L["Write it down, or it never happened."] = "적어 두지 않으면 일어나지 않은 일이다."
L["Old boots know more than new maps."] = "낡은 장화가 새 지도보다 많이 안다."
L["Courage is being afraid and saddling up anyway."] = "용기란 두려워하면서도 안장을 얹는 것이다."
L["Tomorrow the road will still be there. Tonight the fire is warm."] = "내일도 길은 그대로 있다. 오늘 밤은 모닥불이 따뜻하다."
L["A traveller's purse is light, a traveller's diary is heavy."] = "여행자의 주머니는 가볍고 일기장은 무겁다."
L["The best places are on no map."] = "가장 좋은 곳들은 어느 지도에도 없다."
L["Every hero once did not know the way."] = "모든 영웅도 한때는 길을 몰랐다."
L["Share your bread, and the road shares its secrets."] = "빵을 나누면 길도 비밀을 나눠 준다."
L["The story is not over while a page is still blank."] = "빈 페이지가 남아 있는 한 이야기는 끝나지 않았다."

-- covered cards in the bestiary: kinds your other characters know
L["Not yet discovered"] = "아직 발견하지 못함"
L["Known to %s"] = "이미 아는 캐릭터: %s"
L["%d to discover"] = "%d종 미발견"
L["in the east"] = "동쪽"
L["in the south-east"] = "남동쪽"
L["in the south"] = "남쪽"
L["in the south-west"] = "남서쪽"
L["in the west"] = "서쪽"
L["in the north-west"] = "북서쪽"
L["in the north"] = "북쪽"
L["in the north-east"] = "북동쪽"
L["in the middle"] = "가운데"
L["To the contents"] = "목차로 가기"
L["Screenshots at milestones: on"] = "중요한 순간 스크린샷: 켜짐"
L["Screenshots at milestones: off"] = "중요한 순간 스크린샷: 꺼짐"
L["Demo mode is off."] = "데모 모드가 꺼졌습니다."
L["Demo mode is on. Nothing you do now is written into your diary - type /wfd demo again to leave."] = "데모 모드가 켜졌습니다. 지금 하는 일은 일기에 기록되지 않습니다. 나가려면 /wfd demo를 다시 입력하세요."
L["You have died, but who did it slipped past the diary."] = "이미 쓰러진 적이 있지만, 누구의 짓인지는 일기가 놓쳤습니다."
L["Already in the quest log"] = "일기 시작 전에 받은 퀘스트"
L["Angler"] = "낚시꾼"
L["Raise Fishing to %d."] = "낚시 숙련도를 %d까지 올리세요."
L["Big Catch"] = "대어"
L["Catch %d fish."] = "물고기를 %d마리 낚으세요."
L["Field Medic"] = "야전 의무병"
L["Raise First Aid to %d."] = "응급치료 숙련도를 %d까지 올리세요."
L["Camp Cook"] = "야영 요리사"
L["Raise Cooking to %d."] = "요리 숙련도를 %d까지 올리세요."
L["Sighted, not yet slain"] = "목격했지만 아직 처치하지 못함"
L["perhaps %s"] = "아마 %s"
L["You have been %s of this area least of all. Something may still be waiting there."] = "이 지역에서 가장 덜 가 본 곳은 %s입니다. 그곳에 아직 무언가가 기다릴지도 모릅니다."
L["Defeat a boss."] = "우두머리를 처치하세요."
L["Slay a rare creature."] = "희귀 몬스터를 처치하세요."
L["Slay an elite creature."] = "정예 몬스터를 처치하세요."
L["Visit a capital city."] = "수도를 방문하세요."
L["Enter a dungeon."] = "던전에 들어가세요."
L["Take a flight."] = "비행을 이용하세요."
L["Group with another adventurer."] = "다른 모험가와 파티를 맺으세요."
L["Visit a trainer."] = "훈련사를 찾아가세요."
L["Trade with another player."] = "다른 플레이어와 거래하세요."
L["Complete a quest."] = "퀘스트를 완료하세요."
L["Die once and rise again."] = "한 번 죽었다가 다시 일어나세요."
L["Finish a dungeon run."] = "던전 공략을 한 번 마치세요."
L["Do all tasks of the day on one day."] = "하루 동안 그날의 과제를 모두 완료하세요."
L["Complete a task of the week."] = "주간 과제를 완료하세요."
L["Find a rare item."] = "희귀 아이템을 찾으세요."
L["Find an epic item."] = "영웅 아이템을 찾으세요."
L["Dear me, if you are reading this, you made it through the first week. Did you ever find out who was stealing the candles in the mine?"] = "나에게. 이 글을 읽고 있다면 첫 주를 무사히 넘긴 거야. 광산에서 양초를 훔쳐 가던 게 누군지 알아냈니?"
L["Marker set on the map: %s (%d, %d)"] = "지도에 표시를 남겼습니다: %s (%d, %d)"
L["No marker can be set on this map."] = "이 지도에는 표시를 남길 수 없습니다."
L["Click to set a marker on the map."] = "클릭하면 지도에 표시를 남깁니다."
L["Right-click for the map of this region."] = "오른쪽 클릭: 이 지역의 지도"
L["1 kind"] = "1종"
L["Discover a new place."] = "새로운 장소를 하나 발견하세요."
L["Walk one kilometre today."] = "오늘 1킬로미터를 걸으세요."
L["WELCOME"] = "환영합니다"
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "그냥 플레이하세요. 제가 함께 기록할게요. 플레이한 하루하루가 이 책의 한 페이지가 됩니다."
L["See a sample book"] = "예시 책 보기"
L["To today's entry"] = "오늘 일기로"
L["Discover %d flight paths."] = "비행 경로를 %d개 발견하세요."
L["A sketch - %d more and it is in colour."] = "스케치 - %d마리 더 처치하면 색이 입혀집니다."
L["%d more to become a connoisseur."] = "%d마리 더 처치하면 전문가가 됩니다."
L["Connoisseur of this kind"] = "이 종의 전문가"
L["First slain on day %d"] = "%d일째에 처음 처치"
L["Best loot"] = "최고의 전리품"
L["Got you once."] = "당신을 한 번 쓰러뜨렸습니다."
L["Got you %d times."] = "당신을 %d번 쓰러뜨렸습니다."
L["CONNOISSEUR"] = "전문가"
L["Connoisseur"] = "전문가"
L["Right-click to close."] = "오른쪽 클릭하면 닫힙니다."
L["The tabs"] = "탭"
L["The tabs on the right lead to the parts of the book, one colour for each group. Point at them to read their names. A red dot shows how much is new since you last read."] = "오른쪽의 탭은 책의 각 부분으로 이어지며, 그룹마다 색이 다릅니다. 마우스를 올리면 이름이 보입니다. 빨간 점은 마지막으로 읽은 뒤 새로 생긴 것을 알려 줍니다."
L["The spyglass on the spine searches the whole book: days, people, creatures, quests, places and treasures. Ctrl + F opens it too."] = "책등의 돋보기는 책 전체를 검색합니다: 날짜, 사람, 생물, 퀘스트, 장소, 보물. Ctrl + F로도 열 수 있습니다."
L["Your own bookmarks"] = "나만의 책갈피"
L["Ctrl-click a page number to keep that page. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away."] = "페이지 번호를 Ctrl-클릭하면 그 페이지를 기억합니다. 책 위쪽에 리본이 나오며, 클릭하면 그 페이지를 펼치고 오른쪽 클릭하면 리본을 뺍니다."
L["Ctrl + click on the page number"] = "페이지 번호를 Ctrl + 클릭"
L["bookmark"] = "책갈피"
L["Goals and honour"] = "목표와 명예"
L["The world"] = "세계"
L["Hunt and loot"] = "사냥과 전리품"
L["People and household"] = "사람과 살림"
L["Keepsakes"] = "기념품"
L["Best find for every slot"] = "부위별 최고의 발견"
L["worn right now"] = "지금 착용 중"
L["Click to show only these."] = "클릭하면 이것만 보입니다."
L["Click to show all again."] = "클릭하면 다시 모두 보입니다."
L["Shown: %s only"] = "표시: %s만"
L["Show all"] = "모두 보기"
L["Ctrl-click to set or remove a bookmark here."] = "Ctrl-클릭으로 여기에 책갈피를 꽂거나 뺍니다."
L["Click to open, right-click to remove."] = "클릭하면 펼치고, 오른쪽 클릭하면 뺍니다."
L["You are here."] = "현재 위치입니다."
L["Click for the hunting grounds of this area."] = "클릭하면 이 지역의 사냥터를 봅니다."
L["Who is closest to the next stage"] = "다음 단계에 가장 가까운 것"
L["%d more, then in colour"] = "%d마리 더 잡으면 컬러"
L["%d more, then a connoisseur"] = "%d마리 더 잡으면 전문가"
L["To the album of this area"] = "이 지역의 앨범으로"
L["Every kind known here is collected."] = "이곳에서 알려진 모든 종을 수집했습니다."
L["Kinds of creatures"] = "생물 유형"
L["Who fell to your blade, by kind"] = "당신의 칼날에 쓰러진 자들, 유형별로"
L["Unknown kind"] = "알 수 없는 유형"
L["%d kinds  -  %d slain"] = "%d종  -  %d마리 처치"
L["Hunting grounds"] = "사냥터"
L["Sighted"] = "목격함"
L["Kinds slain here"] = "이곳에서 처치한 종"
L["Each pin marks where the first of its kind fell."] = "각 핀은 그 종의 첫 개체가 쓰러진 곳을 표시합니다."
L["Versatile Hunter"] = "다재다능한 사냥꾼"
L["Slay creatures of %d different types."] = "서로 다른 %d가지 유형의 생물을 처치하세요."
L["Slay 50 of each of %d kinds."] = "%d종을 각각 50마리씩 처치하세요."
L["Slay 50 of one kind."] = "한 종을 50마리 처치하세요."
L["Quick on its feet, but it never looks back."] = "발은 빠르지만 절대 뒤를 돌아보지 않는다."
L["Its pelt would fetch a fair price in town."] = "가죽은 마을에서 꽤 값이 나가겠다."
L["Talks big, fights small."] = "말만 거창하고 싸움은 시시하다."
L["Carried more coins than sense."] = "지혜보다 동전을 더 많이 지니고 있었다."
L["Smells worse than it fights."] = "싸움보다 냄새가 더 지독하다."
L["Dead once already. Twice is a habit."] = "이미 한 번 죽었다. 두 번이면 습관이다."
L["Burning eyes, burning temper."] = "불타는 눈, 불타는 성미."
L["Whoever summoned this one owes me an apology."] = "이걸 소환한 자는 내게 사과해야 한다."
L["Not alive, not dead - simply angry."] = "살아 있지도 죽지도 않았다 - 그냥 화가 나 있다."
L["Left nothing behind but a puddle of fury."] = "분노의 웅덩이 말고는 아무것도 남기지 않았다."
L["Scales like armour. Mind the tail."] = "갑옷 같은 비늘. 꼬리를 조심할 것."
L["One day I will face its big brothers."] = "언젠가 그 큰형들과 맞서게 되겠지."
L["The ground shook long after it fell."] = "쓰러진 뒤에도 한참 동안 땅이 흔들렸다."
L["Big enough to have its own weather."] = "자기만의 날씨가 있을 만큼 거대하다."
L["Gnomish work, no doubt. Loud and leaky."] = "노움의 작품이 분명하다. 시끄럽고 줄줄 샌다."
L["It sparked, it whirred, it stopped."] = "불꽃이 튀고, 윙윙거리더니, 멈췄다."
L["It never stood a chance."] = "애초에 승산이 없었다."
L["Small, harmless and now a footnote."] = "작고, 무해하며, 이제는 각주가 되었다."
L["A strange creature. I made a note, just in case."] = "이상한 생물이다. 혹시 몰라 적어 두었다."
L["Worth remembering, or at least worth writing down."] = "기억할 만하다. 적어도 적어 둘 만은 하다."
L["Back"] = "뒤로"
L["To the page you came from (Backspace)."] = "이전에 보던 페이지로 (백스페이스)"
L["Go to page (1 - %d):"] = "페이지로 이동 (1 - %d):"
L["Size: %d%%"] = "크기: %d%%"
L["The bookmarks"] = "책갈피"
L["The bookmarks on the right lead to the parts of the book. A red dot shows how much is new since you last read."] = "오른쪽 책갈피는 책의 각 부분으로 이어집니다. 빨간 점은 마지막으로 읽은 뒤 새로 생긴 항목 수를 보여 줍니다."
L["Search"] = "검색"
L["The spyglass on the spine searches the whole book: days, people, creatures, quests and places."] = "책등의 망원경으로 책 전체를 검색합니다: 날짜, 사람, 생물, 퀘스트, 장소."
L["Turning pages"] = "페이지 넘기기"
L["Turn the pages with the arrows, the mouse wheel or the arrow keys. The red ribbon below always leads to today; Backspace takes you back. Ctrl + mouse wheel changes the size of the book."] = "화살표, 마우스 휠 또는 방향키로 페이지를 넘기세요. 아래의 빨간 리본은 항상 오늘로 이어지고, 백스페이스는 이전 페이지로 돌아갑니다. Ctrl + 마우스 휠로 책 크기를 바꿉니다."
L["Almost everything can be clicked"] = "거의 모든 것을 클릭할 수 있습니다"
L["Cards, names, days and maps open more. Right-click the page number to go to any page. The settings are in the scribe's notes at the very end."] = "카드, 이름, 날짜, 지도를 누르면 더 볼 수 있습니다. 페이지 번호를 오른쪽 클릭하면 원하는 페이지로 이동합니다. 설정은 맨 끝 필경사의 메모에 있습니다."
L["Next"] = "다음"
L["Skip"] = "건너뛰기"
L["Got it"] = "알겠습니다"
L["Handling"] = "사용법"
L["Keys and comfort"] = "단축키와 편의 기능"
L["Notifications"] = "알림"
L["Important only"] = "중요한 것만"
L["Quiet"] = "조용히"
L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] = "중요한 것: 레벨, 우두머리, 희귀 생물과 발견물, 던전, 명예, 편지."
L["Keys while the mouse is over the book"] = "마우스가 책 위에 있을 때의 단축키"
L["Arrow keys, Page up / down"] = "방향키, Page Up / Down"
L["turn the page"] = "페이지 넘기기"
L["Home"] = "Home"
L["contents"] = "목차"
L["End"] = "End"
L["today's entry"] = "오늘의 기록"
L["Backspace"] = "백스페이스"
L["back"] = "뒤로"
L["Ctrl + mouse wheel"] = "Ctrl + 마우스 휠"
L["size of the book"] = "책 크기"
L["Ctrl + F"] = "Ctrl + F"
L["search the book"] = "책에서 찾기"
L["Right-click the page number"] = "페이지 번호 오른쪽 클릭"
L["go to a page"] = "페이지로 이동"
L["open or close the book"] = "책 열기 또는 닫기"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "게임의 단축키 설정에서 애드온 항목에 책을 여는 키를 지정할 수 있습니다."
L["The book"] = "책"
L["Reset the position"] = "위치 초기화"
L["Show the introduction again"] = "소개 다시 보기"
L["Open the scribe's notes"] = "필경사의 메모 열기"
L["Right-click to go to a page."] = "오른쪽 클릭으로 페이지로 이동합니다."
L["%d new since you last read"] = "마지막으로 읽은 뒤 새 항목 %d개"
L["Right-click for the settings."] = "오른쪽 클릭으로 설정을 엽니다."
L["Drag to move this button."] = "끌어서 이 버튼을 옮깁니다."
L["Click to open."] = "클릭하여 엽니다."
L["Moving code"] = "이전 코드"
L["This code holds the whole diary of this character. Copy it with Ctrl+C and keep it somewhere safe, for example in a text file. On the other computer, open the same window with \"Read a moving code\" and paste it there."] = "이 코드에는 이 캐릭터의 일지 전체가 담겨 있습니다. Ctrl+C로 복사해 텍스트 파일 등 안전한 곳에 보관하세요. 다른 컴퓨터에서 \"이전 코드 읽기\"로 창을 열고 붙여 넣으면 됩니다."
L["The code could not be made."] = "코드를 만들 수 없습니다."
L["%d days, %d characters. Now press Ctrl+C."] = "%d일, %d자. 이제 Ctrl+C를 누르세요."
L["Read a moving code"] = "이전 코드 읽기"
L["Paste the moving code of this character with Ctrl+V. The diary written on this computer is then replaced by the one from the code, and the interface is reloaded."] = "Ctrl+V로 이 캐릭터의 이전 코드를 붙여 넣으세요. 이 컴퓨터의 일지는 코드의 일지로 바뀌고 인터페이스가 다시 불러와집니다."
L["Waiting for a code ..."] = "코드를 기다리는 중 ..."
L["Replace the diary and reload"] = "일지를 교체하고 다시 불러오기"
L["This is not a moving code of the diary."] = "일지의 이전 코드가 아닙니다."
L["The code is damaged or incomplete. Copy it again, all of it."] = "코드가 손상되었거나 불완전합니다. 전체를 다시 복사하세요."
L["Diary of %s (%s), %d days, %d kinds of creatures, %d people."] = "%s (%s)의 일지, %d일, 생물 %d종, 인물 %d명."
L["Careful: this code belongs to %s, but you are playing %s."] = "주의: 이 코드는 %s의 것이지만 지금은 %s(으)로 플레이 중입니다."
L["The diary of this character on this computer will be replaced."] = "이 컴퓨터에 있는 이 캐릭터의 일지가 교체됩니다."
L["Leave demo mode first."] = "먼저 데모 모드를 끝내세요."
L["moving code of this character"] = "이 캐릭터의 이전 코드"
L["read a moving code"] = "이전 코드 읽기"
L["Moving to another computer"] = "다른 컴퓨터로 옮기기"
L["Make a moving code"] = "이전 코드 만들기"
L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."] = "또는 게임 폴더의 WTF 폴더를 그대로 가져가세요. 모든 캐릭터의 일지가 들어 있습니다."
L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."] = "오늘의 수치, 과제, 다음 단계에 가장 가까운 명예를 보여 주는 작은 창입니다. 제목을 끌어 옮기고 빼기로 접을 수 있습니다."
L["Appearance"] = "모양"
L["Both reload the interface. With bigger writing a few long lines may run close together."] = "둘 다 인터페이스를 다시 불러옵니다. 글자를 키우면 긴 줄 몇 개가 서로 붙을 수 있습니다."
L["Click to open the diary there."] = "클릭하면 일지의 해당 부분이 열립니다."
L["Companion"] = "동반 창"
L["Fold in or out"] = "접기 또는 펼치기"
L["How the book looks"] = "책의 모양"
L["Leather and gold"] = "가죽과 금장"
L["Leather and gold is the old book. Modern is flat and calm, strong contrast makes all writing brighter."] = "가죽과 금장은 기존의 책입니다. 모던은 단순하고 차분하며, 높은 대비는 모든 글자를 더 밝게 합니다."
L["Modern"] = "모던"
L["Next honours"] = "다음 명예"
L["Online"] = "접속"
L["Show the companion beside the game"] = "게임 옆에 동반 창 표시"
L["Size of the writing"] = "글자 크기"
L["Strong contrast"] = "높은 대비"
L["Style of the book"] = "책 스타일"
L["The companion can be shown again in the settings or with /wfd companion."] = "동반 창은 설정이나 /wfd companion으로 다시 표시할 수 있습니다."
L["Turn the leaves visibly"] = "페이지 넘김 보이기"
L["Turning the pages"] = "페이지 넘기기"
L["km"] = "km"
L["reloads the interface"] = "인터페이스를 다시 불러옴"
L["show or hide the companion"] = "동반 창 표시 또는 숨기기"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "이곳에 있던 일기는 같은 이름을 가진 이전 캐릭터의 것이었습니다. 그 일기는 따로 보관하고 새 일기를 시작했습니다. |cffffd100/wfd restore|r로 되돌릴 수 있습니다."
L["bring back the diary put aside"] = "따로 보관한 일기 되돌리기"
L["No diary has been put aside."] = "따로 보관한 일기가 없습니다."
L["The diary put aside is back. The interface is reloaded."] = "따로 보관한 일기를 되돌렸습니다. 인터페이스를 다시 불러옵니다."
