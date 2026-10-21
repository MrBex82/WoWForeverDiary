-- Russian translation (English phrases are the keys).
-- Phrased without gendered past tense, so it fits male and female characters alike.
local ADDON, WFD = ...
local L, loc = WFD:NewLocale("ruRU")

local T = {
    -- chat / log
    ["Diary"] = "Дневник",
    ["Travel diary active - today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
        "Дневник путешествий активен — сегодня |cffffd100день %d|r. |cffffd100/wfd|r открывает дневник.",
    ["%d creatures slain in total"] = "Всего убито существ: %d",
    ["First victory over the boss %s!"] = "Первая победа над боссом: %s!",
    ["Rare creature slain: %s"] = "Убито редкое существо: %s",
    ["Boss %s defeated again (%dx)"] = "Босс %s снова повержен (%dx)",
    ["Died to %s in %s"] = "Гибель: %s (%s)",
    ["Died in %s"] = "Гибель (%s)",
    ["Met %s (%s)"] = "Знакомство: %s (%s)",
    ["Hearthstone bound to %s"] = "Камень возвращения привязан: %s",
    ["Quest accepted: %s"] = "Задание принято: %s",
    ["Quest abandoned: %s"] = "Задание отменено: %s",
    ["Quest completed: %s"] = "Задание выполнено: %s",
    ["First quest completed: %s"] = "Первое выполненное задание: %s",
    ["%d quests completed"] = "Выполнено заданий: %d",
    ["Took a flight to %s"] = "Полет: %s",
    ["Wealth reached: %s"] = "Достигнуто состояние: %s",
    ["Found %s"] = "Найдено: %s",
    ["Epic find: %s"] = "Эпическая находка: %s",
    ["Rare find: %s"] = "Редкая находка: %s",
    ["Discovered a new land: %s"] = "Открыт новый край: %s",
    ["Entered %s"] = "Прибытие: %s",
    ["Discovered: %s (%s)"] = "Открыто: %s (%s)",
    ["First visit to the dungeon %s"] = "Первое посещение подземелья: %s",
    ["Entered the dungeon %s"] = "Вход в подземелье: %s",
    ["Level %d reached!"] = "Достигнут уровень %d!",
    ["%s increased to %d"] = "%s: повышено до %d",
    ["%s mastered up to %d"] = "%s: освоено до %d",
    ["Used the hearthstone"] = "Использован камень возвращения",
    ["%dh %02dm"] = "%d ч %02d мин",
    ["%dm"] = "%d мин",

    -- window
    ["Travel Diary of %s"] = "Дневник путешествий: %s",
    ["Day %d"] = "День %d",
    ["Level %d"] = "Уровень %d",
    ["Level %s"] = "Уровень %s",
    ["online"] = "в игре",
    ["LIFELINE"] = "ЛИНИЯ ЖИЗНИ",
    ["now"] = "сейчас",
    ["Screenshot:"] = "Снимок экрана:",
    ["Click to read this day."] = "Нажмите, чтобы прочитать этот день.",
    ["Click to open the diary."] = "Нажмите, чтобы открыть дневник.",
    ["%d kills today"] = "Убийств сегодня: %d",
    ["%d quests today"] = "Заданий сегодня: %d",
    ["DEMO MODE - invented data"] = "ДЕМО-РЕЖИМ — вымышленные данные",

    -- tabs
    ["Journal"] = "Дневник",
    ["World Map"] = "Карта мира",
    ["Bestiary"] = "Бестиарий",
    ["People"] = "Персонажи",
    ["Quest Book"] = "Книга заданий",
    ["Statistics"] = "Статистика",
    ["Export"] = "Экспорт",

    -- journal
    ["Today"] = "Сегодня",
    ["Chronicle"] = "Хроника",
    ["Overview"] = "Обзор",
    ["Nothing recorded yet."] = "Пока ничего не записано.",
    ["Balance of the day"] = "Итоги дня",
    ["Enemies slain"] = "Убито врагов",
    ["Quests completed"] = "Выполнено заданий",
    ["(done / accepted)"] = "(выполнено / принято)",
    ["People spoken to"] = "Собеседники",
    ["Experience gained"] = "Получено опыта",
    ["Distance travelled"] = "Пройденный путь",
    ["flown"] = "в полете",
    ["Time online"] = "Время в игре",
    ["Deaths"] = "Смерти",
    ["Jumps"] = "Прыжки",
    ["Purse"] = "Кошелек",
    ["Income"] = "Доходы",
    ["Expenses"] = "Расходы",
    ["Net"] = "Итог",
    ["Fallen foes"] = "Павшие враги",
    ["... and %d more kinds"] = "... и еще видов: %d",
    ["Completed quests"] = "Выполненные задания",
    ["Spoken to"] = "Разговоры",
    ["Loot (%d items)"] = "Добыча (предметов: %d)",
    ["Loot"] = "Добыча",
    ["Places"] = "Места",
    ["Special moments"] = "Особые моменты",
    ["photo"] = "фото",

    -- map
    ["Footsteps"] = "Следы",
    ["Kills"] = "Убийства",
    ["Quests"] = "Задания",
    ["No map art available for this area."] = "Для этой области нет карты.",
    ["VISITED AREAS"] = "ПОСЕЩЕННЫЕ МЕСТА",
    ["Play"] = "Воспроизвести",
    ["Stop"] = "Стоп",
    ["Only this day"] = "Только этот день",
    ["Drag the slider through time: your footsteps grow day by day."] = "Перемещайте ползунок во времени: ваши следы растут день за днем.",
    ["Spoken to %d times"] = "Разговоров: %d",
    ["Quest accepted here"] = "Здесь принято задание",
    ["Quest handed in here"] = "Здесь сдано задание",
    ["You died here"] = "Здесь вы погибли",
    ["Killed by %s"] = "Убийца: %s",
    ["Footprints: %d spots   Kills: %d   Deaths: %d"] = "Следы: %d   Убийства: %d   Смерти: %d",
    ["No travels recorded yet."] = "Путешествия пока не записаны.",

    -- bestiary
    ["Name"] = "Имя",
    ["Level"] = "Уровень",
    ["Recent"] = "Недавние",
    ["Foes"] = "Враги",
    ["Bosses and rares"] = "Боссы и редкие",
    ["Boss"] = "Босс",
    ["Rare"] = "Редкий",
    ["Elite"] = "Элита",
    ["Normal"] = "Обычный",
    ["No portrait"] = "Нет портрета",
    ["KILLS PER DAY"] = "УБИЙСТВА ПО ДНЯМ",
    ["Kills: %d"] = "Убийства: %d",
    ["Rank: #%d of %d kinds"] = "Место: №%d из %d",
    ["First kill:"] = "Первое убийство:",
    ["Last kill:"] = "Последнее убийство:",
    ["Seen in:"] = "Встречается:",
    ["This creature killed you %d times."] = "Смертей от этого существа: %d.",
    ["Your nemesis"] = "Ваш заклятый враг",
    ["Last seen in:"] = "Последняя встреча:",
    ["Last time:"] = "Последний раз:",
    ["You have killed it %d times."] = "Ваших побед над ним: %d.",
    ["Nobody has killed you yet."] = "Вас еще никто не убивал.",

    -- people
    ["Talks"] = "Разговоры",
    ["First met"] = "Знакомство",
    ["Show on map"] = "Показать на карте",
    ["QUESTS WITH THIS PERSON"] = "ЗАДАНИЯ ЭТОГО ПЕРСОНАЖА",
    ["Conversations: %d"] = "Разговоров: %d",
    ["Found in:"] = "Местонахождение:",
    ["First met:"] = "Знакомство:",
    ["Last met:"] = "Последняя встреча:",
    ["given and received"] = "выдача и сдача",
    ["given"] = "выдача",
    ["handed in"] = "сдача",
    ["No quests recorded."] = "Задания не записаны.",
    ["Role:"] = "Роль:",
    ["All"] = "Все",
    ["%d of %d people"] = "%d из %d персонажей",
    ["You have not talked to anyone yet."] = "Вы еще ни с кем не разговаривали.",
    ["Conversation"] = "Разговор",
    ["Vendor"] = "Торговец",
    ["Trainer"] = "Учитель",
    ["Flight master"] = "Распорядитель полетов",
    ["Banker"] = "Банкир",
    ["Stable master"] = "Смотритель стойл",
    ["Petitions"] = "Петиции",
    ["Auctioneer"] = "Аукционист",

    -- quests
    ["Completed"] = "Выполненные",
    ["Open"] = "Открытые",
    ["Abandoned"] = "Отмененные",
    ["In progress"] = "В процессе",
    ["Received from:"] = "Выдано:",
    ["Handed in to:"] = "Сдано:",
    ["Accepted:"] = "Принято:",
    ["Completed:"] = "Выполнено:",
    ["Took:"] = "Длительность:",
    ["Experience:"] = "Опыт:",
    ["Gold reward:"] = "Награда золотом:",
    ["Reward:"] = "Награда:",
    ["Where I accepted it"] = "Место получения",
    ["Where I handed it in"] = "Место сдачи",
    ["%d of %d quests completed"] = "Выполнено заданий: %d из %d",
    ["No quests recorded yet."] = "Задания пока не записаны.",

    -- statistics
    ["Gold"] = "Золото",
    ["XP"] = "Опыт",
    ["Time"] = "Время",
    ["Distance"] = "Расстояние",
    ["Nothing to chart yet."] = "Пока нечего показать.",
    ["WHERE THE MONEY CAME FROM"] = "ОТКУДА ПРИШЛИ ДЕНЬГИ",
    ["WHERE THE MONEY WENT"] = "КУДА УШЛИ ДЕНЬГИ",
    ["In total: %d kills  |  %d quests  |  %s online  |  %.1f km on foot  |  %d deaths  |  %d jumps"] =
        "Всего: убийств %d  |  заданий %d  |  в игре %s  |  пешком %.1f км  |  смертей %d  |  прыжков %d",

    -- money categories
    ["Quest rewards"] = "Награды за задания",
    ["Vendor sales"] = "Продажа торговцам",
    ["Mail"] = "Почта",
    ["Trading"] = "Обмен",
    ["Auction house"] = "Аукцион",
    ["Repairs"] = "Ремонт",
    ["Purchases"] = "Покупки",
    ["Training"] = "Обучение",
    ["Flights"] = "Полеты",
    ["Bank"] = "Банк",
    ["Other"] = "Прочее",

    -- export / settings
    ["Born:"] = "Рождение:",
    ["As text"] = "Текстом",
    ["Select all"] = "Выделить все",
    ["Ctrl+C copies the selection."] = "Ctrl+C копирует выделенное.",
    ["SETTINGS"] = "НАСТРОЙКИ",
    ["Take a screenshot at milestones"] = "Делать снимок экрана на важных этапах",
    ["Announce milestones in chat"] = "Сообщать о важных этапах в чат",
    ["Show minimap button"] = "Показывать кнопку у миникарты",
    ["First day"] = "Первый день",

    -- redesigned interface
    ["Travel Diary"] = "Дневник путешествий",
    ["Day of life"] = "День жизни",
    ["Days of life"] = "Дней жизни",
    ["Memories of the day"] = "Воспоминания дня",
    ["A day without great events."] = "День без больших событий.",
    ["Experience"] = "Опыт",
    ["Conversations"] = "Разговоры",
    ["On foot"] = "Пешком",
    ["Map of my travels"] = "Карта моих странствий",
    ["Layers"] = "Слои",
    ["%d kinds - %d kills"] = "Видов: %d — убийств: %d",
    ["%d nemeses"] = "Заклятых врагов: %d",
    ["No creature has fallen yet."] = "Еще ни одно существо не пало.",
    ["Slain"] = "Убито",
    ["Rank"] = "Место",
    ["First kill"] = "Первое убийство",
    ["Last kill"] = "Последнее убийство",
    ["Seen in"] = "Встречается",
    ["Killed you"] = "Ваших смертей",
    ["You slew it"] = "Ваших побед",
    ["Last seen in"] = "Последняя встреча",
    ["Last time"] = "Последний раз",
    ["\"First encountered on day %d in %s.\""] = "«Первая встреча — день %d, %s.»",
    ["\"Revenge is a dish best served cold.\""] = "«Месть — это блюдо, которое подают холодным.»",
    ["Acquaintances"] = "Знакомые",
    ["Found in"] = "Местонахождение",
    ["Place"] = "Место",
    ["Last met"] = "Последняя встреча",
    ["Region"] = "Регион",
    ["Received from"] = "Выдано",
    ["Handed in to"] = "Сдано",
    ["Accepted"] = "Принято",
    ["Took"] = "Длительность",
    ["Reward"] = "Награда",
    ["Balance of a life"] = "Итоги жизни",
    ["Since %s"] = "С %s",
    ["Remarkable"] = "Примечательное",
    ["Bloodiest day"] = "Самый кровавый день",
    ["Favourite prey"] = "Любимая добыча",
    ["Arch-enemy"] = "Заклятый враг",
    ["Home of the heart"] = "Родные края",
    ["Closest confidant"] = "Ближайший собеседник",
    ["Day by day"] = "День за днем",
    ["Came from"] = "Откуда",
    ["Went to"] = "Куда",
    ["Transcript"] = "Текст дневника",
    ["Settings"] = "Настройки",
    ["Size of the book"] = "Размер книги",
    ["Demo"] = "Демо",
    ["Start demo mode"] = "Включить демо-режим",
    ["Leave demo mode"] = "Выйти из демо-режима",
    ["Commands"] = "Команды",
    ["open or close the diary"] = "открыть или закрыть дневник",
    ["explore with invented data"] = "посмотреть на вымышленных данных",
    ["screenshots on or off"] = "включить или выключить снимки экрана",
    ["minimap button on or off"] = "показать или скрыть кнопку у миникарты",
    ["\"Screenshots are saved in the Screenshots folder of your game.\""] = "«Снимки экрана сохраняются в папке Screenshots вашей игры.»",
}
for k, v in pairs(T) do L[k] = v end

-- dates and diary entries
loc.date = "%d.%m.%Y"
loc.decimal = ","
loc.listAnd = " и "
loc.dayMonth = "%d.%m"
loc.weekdays = { "Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота" }
-- genitive, as used in "9 октября"
loc.months = { "января", "февраля", "марта", "апреля", "мая", "июня", "июля", "августа", "сентября", "октября", "ноября", "декабря" }
function loc.longDate(d)
    return string.format("%s, %d %s %d г.", loc.weekdays[d.wday], d.day, loc.months[d.month], d.year)
end
loc.quotes = { "«", "»" }

loc.narrator = {
    -- written without gendered past tense ("я пошёл / пошла"), since the diary does not know who writes it
    birth = {
        "День 1. Я — %s, %s. Отправная точка — %s. Что дальше? Понятия не имею.",
        "День 1. %s, %s, всё только начинается. Отправная точка — %s. Посмотрим, куда это заведёт.",
    },
    begin = {
        "День 1. С сегодняшнего дня записываю всё, что случается в пути.",
    },
    open = {
        "День %d, %s.",
        "День %d. Сегодня на очереди — %s.",
        "День %d. Снова в пути. Главное место дня — %s.",
    },
    far = "неизвестные края",
    walk = {
        "Пешком примерно %s км%s.",
        "Ноги говорят: где-то %s км%s.",
        "Около %s км на своих двоих%s, и ноги это чувствуют.",
    },
    via = " (%s)",
    fly = " Остаток пути — по воздуху.",
    kills = {
        "Повержено врагов за день: %d.",
        "Сегодня от моей руки пало врагов: %d.",
    },
    top = {
        "Чаще всего попадались: %s (%dx).",
        "Больше всех надоедали: %s (%dx).",
    },
    special = "Запомнится: %s.",
    deaths = {
        "{Умереть сегодня пришлось один раз.|Умереть сегодня пришлось не один раз: %d.}%s",
        "Смертей за день: %d.%s",
    },
    deathBy = " Последний виновник: %s.",
    noDeath = {
        "Сегодня — ни одной смерти.",
        "Целый день без единой смерти. Неплохо.",
    },
    questDone = {
        "Заданий выполнено: %d — %s.",
        "Вычеркнуто из списка: %s.",
    },
    questAcc = {
        "Зато новых добавилось: %d.",
        "И тут же ждут новые задания: %d.",
    },
    questAccOnly = {
        "Новых заданий: %d. Готового пока ничего.",
    },
    more = "и ещё несколько",
    quote = {
        "Цитата дня (%s): %s",
        "%s: %s",
    },
    quoteAnon = "Запомнилась фраза: %s",
    npcs = {
        "{Собеседник за день — %s.|Собеседников за день: %d, среди них %s.}",
        "{Один разговор: %s.|Разговоров: %d, например: %s.}",
    },
    gain = {
        "Кошелёк потяжелел на %s.",
        "В итоге в кармане на %s больше.",
    },
    loss = {
        "Кошелёк полегчал на %s.",
        "В итоге день обошёлся в %s.",
    },
    src = " Основной доход: %s (%s).",
    spent = " Основные траты: %s (%s).",
    item = {
        "Лучшая находка: %s.",
        "Находка дня: %s.",
    },
    levels = {
        "Новый уровень: %s.",
        "Есть уровень %s!",
    },
    quiet = {
        "Тихий день. Рассказывать почти нечего.",
        "Сегодня мало что случилось.",
    },
    begun = {
        "День только начался.",
        "День ещё молод.",
        "Новый день только начинается.",
    },
    ongoing = {
        "День ещё не закончился.",
        "Продолжение следует ...",
        "Посмотрим, что ещё принесёт этот день.",
    },
    close = {
        "На сегодня всё.",
        "Хватит на сегодня. Завтра продолжим.",
        "Пора передохнуть.",
        "Посмотрим, что будет завтра.",
    },
    closeLong = {
        "%s в пути. На сегодня хватит.",
        "Позади %s на ногах — сил почти не осталось.",
        "Всего %s в пути. Завтра продолжим.",
    },
    none = "Для этого дня записей нет.",
}

-- book interface
L["Appendix"] = "Приложение"
L["Begun on %s"] = "Начат: %s"
L["Bookmark"] = "Закладка"
L["Click to open today's entry."] = "Нажмите, чтобы открыть сегодняшнюю запись."
L["Click to open"] = "Нажмите, чтобы открыть"
L["Contents"] = "Содержание"
L["Notes"] = "Заметки"
L["Page %d"] = "Страница %d"
L["Realm: %s"] = "Игровой мир: %s"
L["This book belongs to"] = "Владелец книги"
L["in %s, at level %d"] = "%s, уровень %d"
L["in %s, on the first day of my life"] = "%s, в первый день моей жизни"
L["of"] = "летописец"

-- book pages (diary, appendix)
L["\"Whoever wanders, gathers stories.\""] = "«Кто странствует, тот собирает истории.»"
L["Arrival in %s"] = "Прибытие: %s"
L["Days in %s"] = "Дни странствий: %s"
L["Shadows over %s"] = "Тени над землями: %s"
L["The roads of %s"] = "Дороги: %s"
L["Under the skies of %s"] = "Под небесами: %s"
L["Awakening in %s"] = "Пробуждение: %s"
L["Return to %s"] = "Возвращение: %s"
L["Chapter"] = "Глава"
L["Level %d-%d"] = "Уровень %d–%d"
L["Days %d-%d"] = "Дни %d–%d"
L["Level %d!"] = "Уровень %d!"
L["%d kills"] = "убийств: %d"
L["%d quests"] = "заданий: %d"
L["died %dx"] = "смертей: %d"
L["Kept as a memory"] = "На память"
L["Click to read this day aloud in chat."] = "Нажмите, чтобы зачитать этот день в чат."
L["The pages are still empty. Go and live an adventure!"] = "Страницы пока пусты. Отправляйтесь навстречу приключениям!"
L["p. %d"] = "с. %d"
L["Milestones"] = "Важные вехи"
L["The great moments of a life"] = "Великие мгновения жизни"
L["No milestones yet."] = "Пока нет важных вех."
L["Maps"] = "Карты"
L["%s spent here"] = "Проведено здесь: %s"
L["Route"] = "Маршрут"
L["Kill sites"] = "Места сражений"
L["Graves"] = "Могилы"
L["First visit"] = "Первое посещение"
L["Time spent"] = "Проведено времени"
L["Creatures slain here"] = "Убито здесь"
L["Acquaintances here"] = "Знакомые здесь"
L["A naturalist's notes"] = "Записки натуралиста"
L["Slain %d times"] = "Ваших побед: %d"
L["Every creature, by number slain"] = "Все существа — по числу побед"
L["Everyone I met on my way"] = "Все встречные на моем пути"
L["Every coin, in and out"] = "Каждая монета — приход и расход"
L["Balance"] = "Итог"
L["Day"] = "День"
L["Tasks taken and done"] = "Взятые и выполненные поручения"
L["Scribe's notes"] = "Заметки писца"
L["How this book is kept"] = "Как ведется эта книга"
L["Copy the diary as text"] = "Скопировать дневник текстом"
L["Copy the diary as JSON"] = "Скопировать дневник в формате JSON"
L["Ledger"] = "Счетная книга"

-- own notes
L["Click here to write your own notes ..."] = "Нажмите здесь, чтобы написать свои заметки ..."
L["My own thoughts:"] = "Мои мысли:"
L["+ note"] = "+ заметка"
L["edit note"] = "изменить заметку"
L["Save"] = "Сохранить"
L["Cancel"] = "Отмена"

-- cards
L["Wanted poster"] = "Объявление о розыске"
L["Acquaintance"] = "Знакомство"
L["Click for the wanted poster."] = "Нажмите, чтобы открыть объявление о розыске."
L["Click for the portrait."] = "Нажмите, чтобы открыть портрет."

-- collector's album
L["A collector's album of every creature slain"] = "Коллекционный альбом всех поверженных существ"
L["kinds collected  -  %d creatures slain"] = "видов собрано  -  убито существ: %d"
L["Bronze"] = "Бронза"
L["Silver"] = "Серебро"
L["Mithril"] = "Мифрил"
L["Legend"] = "Легенда"
L["Collect %d kinds of creatures."] = "Соберите видов существ: %d."
L["Reached!"] = "Достигнуто!"
L["%d still missing."] = "Осталось: %d."
L["Bosses"] = "Боссы"
L["Rare creatures"] = "Редкие существа"
L["Album pages"] = "Страницы альбома"
L["%d kinds"] = "Видов: %d"
L["Lv %s"] = "Ур. %s"
L["NEW"] = "НОВОЕ"
L["not yet found"] = "еще не найдено"

-- language switch
L["German"] = "Немецкий"
L["English"] = "Английский"
L["French"] = "Французский"
L["Spanish"] = "Испанский"
L["Portuguese"] = "Португальский"
L["Russian"] = "Русский"
L["Korean"] = "Корейский"
L["Chinese (traditional)"] = "Китайский (традиционный)"
L["Language"] = "Язык"
L["Game language (%s)"] = "Язык игры (%s)"
L["The diary will reload the interface to switch the language."] = "Чтобы сменить язык, дневник перезагрузит интерфейс."
L["Korean and Chinese text needs a game client with those fonts."] = "Для корейского и китайского текста нужен игровой клиент с соответствующими шрифтами."

-- map spreads
L["Places of note"] = "Примечательные места"
L["Nobody was met here yet."] = "Здесь вы еще ни с кем не встречались."
L["Grave"] = "Могила"
L["Chronicle of the region"] = "Хроника края"
L["Visits"] = "Посещения"
L["Quests completed here"] = "Выполнено здесь заданий"
L["Deaths here"] = "Смертей здесь"
L["Most hunted here"] = "Чаще всего здесь добыча"
L["Places discovered"] = "Открытые места"

-- companions, honours, treasures, memories, obituary
L["%d days of life  -  %d creatures slain  -  %d quests completed"] = "Дней жизни: %d  -  убито существ: %d  -  выполнено заданий: %d"
L["%d days"] = "Дней: %d"
L["%d enemies fell that day."] = "Врагов пало в тот день: %d."
L["%d kills together"] = "Совместных убийств: %d"
L["%d of %d honour tiers reached"] = "Достигнуто ступеней: %d из %d"
L["%d times grouped"] = "Совместных походов: %d"
L["%d treasures collected"] = "Собрано сокровищ: %d"
L["%dx traded"] = "Сделок: %d"
L["A painted memory"] = "Нарисованное воспоминание"
L["Book of honour"] = "Книга почета"
L["Companions"] = "Спутники"
L["Copy for forum or Discord (Markdown)"] = "Скопировать для форума или Discord (Markdown)"
L["Fell in %s"] = "Место гибели: %s"
L["Fell to %s"] = "Последний противник: %s"
L["Slain by %s"] = "Убийца: %s"
L["Fellow adventurers"] = "Товарищи по приключениям"
L["Fellowship"] = "Братство"
L["Grouped with %s"] = "В группе с: %s"
L["In memoriam"] = "Вечная память"
L["Loot of %s"] = "Добыча: %s"
L["No trades yet."] = "Сделок пока нет."
L["No treasures found yet."] = "Сокровищ пока не найдено."
L["Rested here"] = "Привал здесь"
L["Times rested here"] = "Привалов здесь"
L["The last moment"] = "Последнее мгновение"
L["Today, %d days ago"] = "В этот день, дн. назад: %d"
L["Trading partners"] = "Торговые партнеры"
L["Treasures"] = "Сокровища"
L["Who walked beside me"] = "Те, кто шел рядом"
L["You have not grouped with anyone yet."] = "Вы еще ни с кем не объединялись в группу."
L["I was in %s."] = "Где я был: %s."
L["early in the morning"] = "рано утром"
L["in the morning"] = "утром"
L["around noon"] = "около полудня"
L["in the afternoon"] = "днем"
L["in the evening"] = "вечером"
L["late at night"] = "поздно ночью"
L["earned"] = "получено"
L["first met %s"] = "знакомство: %s"

-- honours
L["First Blood"] = "Первая кровь"
L["Slay your first creature."] = "Убейте первое существо."
L["Slayer"] = "Истребитель"
L["Slay 100 creatures."] = "Убейте 100 существ."
L["Scourge of the Wilds"] = "Бич дикой природы"
L["Slay 1000 creatures."] = "Убейте 1000 существ."
L["Champion"] = "Чемпион"
L["Slay 5000 creatures."] = "Убейте 5000 существ."
L["Specialist"] = "Специалист"
L["Slay 100 of a single kind."] = "Убейте 100 существ одного вида."
L["Naturalist"] = "Натуралист"
L["Collect 50 kinds of creatures."] = "Соберите 50 видов существ."
L["Rare Hunter"] = "Охотник за редкостями"
L["Slay 5 rare creatures."] = "Убейте 5 редких существ."
L["Bane of Bosses"] = "Гроза боссов"
L["Giant Slayer"] = "Убийца великанов"
L["Defeat 10 bosses."] = "Победите 10 боссов."
L["Into the Depths"] = "В глубины"
L["Hunter"] = "Охотник"
L["Helping Hand"] = "Рука помощи"
L["Complete 10 quests."] = "Выполните 10 заданий."
L["Hero of the People"] = "Народный герой"
L["Complete 100 quests."] = "Выполните 100 заданий."
L["Explorer"] = "Исследователь"
L["Discover 25 places."] = "Откройте 25 мест."
L["Cartographer"] = "Картограф"
L["Discover 100 places."] = "Откройте 100 мест."
L["Globetrotter"] = "Путешественник"
L["Visit 5 regions."] = "Посетите 5 регионов."
L["Wanderer"] = "Странник"
L["Walk 50 kilometres."] = "Пройдите пешком 50 км."
L["Pathfinder"] = "Первопроходец"
L["Walk 250 kilometres."] = "Пройдите пешком 250 км."
L["Frequent Flyer"] = "Завсегдатай небес"
L["Take 10 flights."] = "Совершите 10 полетов."
L["Thrifty"] = "Бережливый"
L["Own 10 gold."] = "Накопите 10 золотых."
L["Wealthy"] = "Богач"
L["Own 100 gold."] = "Накопите 100 золотых."
L["Seasoned"] = "Бывалый"
L["Reach level 20."] = "Достигните 20-го уровня."
L["Veteran"] = "Ветеран"
L["Reach level 40."] = "Достигните 40-го уровня."
L["Reach level 60."] = "Достигните 60-го уровня."
L["Untouchable"] = "Неуязвимый"
L["Play 5 days in a row without dying."] = "Играйте 5 дней подряд, ни разу не погибнув."
L["Faithful Chronicler"] = "Верный летописец"
L["Keep this diary for 30 days."] = "Ведите этот дневник 30 дней."
L["Sociable"] = "Общительный"
L["Meet 25 people."] = "Познакомьтесь с 25 персонажами."
L["Bouncy"] = "Попрыгун"
L["Jump 1000 times."] = "Прыгните 1000 раз."
L["Treasure Hunter"] = "Кладоискатель"
L["Find 5 rare items."] = "Найдите 5 редких предметов."
L["Group with 5 other adventurers."] = "Соберитесь в группу с 5 другими искателями приключений."

-- keepsake captions
L["Level up"] = "Уровень"
L["Epic find"] = "Эпическая находка"
L["Rare find"] = "Редкая находка"
L["Death"] = "Смерть"
L["New land"] = "Новые земли"
L["Dungeon"] = "Подземелье"
L["Quest"] = "Задание"
L["Wealth"] = "Богатство"
L["Skill"] = "Навык"
L["Hunt"] = "Охота"
L["Moment"] = "Момент"

-- honour tiers, atlas, landmarks, secrets
L["%d honour points"] = "Очков почета: %d"
L["%d of %d landmarks found"] = "Найдено достопримечательностей: %d из %d"
L["%d of %d regions explored"] = "Исследовано регионов: %d из %d"
L["%d tiers earned"] = "Получено ступеней: %d"
L["A familiar face ..."] = "Знакомое лицо ..."
L["A secret honour. Keep exploring!"] = "Тайная почесть. Исследуйте дальше!"
L["Adventure"] = "Приключения"
L["Almost there"] = "Почти у цели"
L["Atlas"] = "Атлас"
L["Bad Day"] = "Черный день"
L["Barterer"] = "Меняла"
L["Be on the road before seven in the morning."] = "Будьте в пути до семи утра."
L["Be on the road between midnight and four o'clock."] = "Будьте в пути между полуночью и четырьмя часами."
L["Bloodbath"] = "Кровавая баня"
L["Busy Bee"] = "Трудолюбивая пчелка"
L["Capital Tourist"] = "Столичный турист"
L["Capitals"] = "Столицы"
L["Click for all landmarks."] = "Нажмите, чтобы увидеть все достопримечательности."
L["Click for the map of this region."] = "Нажмите, чтобы открыть карту этого региона."
L["Click to open this part of the book."] = "Нажмите, чтобы открыть эту часть книги."
L["Collection"] = "Коллекция"
L["Combat"] = "Бой"
L["Complete %d quests in a single day."] = "Выполните заданий за один день: %d."
L["Complete %d quests."] = "Выполните заданий: %d."
L["Complete!"] = "Завершено!"
L["Curiosities"] = "Диковинки"
L["Dark places, rich rewards"] = "Темные места, богатая добыча"
L["Defeat %d bosses."] = "Победите боссов: %d."
L["Destination of the day"] = "Цель дня"
L["Devoted"] = "Преданный"
L["Die %d times and rise again."] = "Погибните и восстаньте снова (раз: %d)."
L["Die %d times in a single day."] = "Погибните за один день (раз: %d)."
L["Discover %d places."] = "Откройте мест: %d."
L["Do business with %d merchants."] = "Совершите сделки с торговцами: %d."
L["Dungeons"] = "Подземелья"
L["Eager Student"] = "Прилежный ученик"
L["Early Bird"] = "Ранняя пташка"
L["Elite Slayer"] = "Истребитель элиты"
L["Encounters"] = "Встречи"
L["Enter %d dungeons."] = "Посетите подземелий: %d."
L["Epic Fortune"] = "Эпическая удача"
L["Every journey needs a pause ..."] = "Любому путешествию нужен привал ..."
L["Every region of this continent is explored."] = "Все регионы этого континента исследованы."
L["Exploration"] = "Исследование"
L["Explored"] = "Исследовано"
L["Explorer's checklist"] = "Список исследователя"
L["Famous places of Azeroth"] = "Знаменитые места Азерота"
L["Find %d epic items."] = "Найдите эпических предметов: %d."
L["Find %d landmarks."] = "Найдите достопримечательностей: %d."
L["Find %d rare items."] = "Найдите редких предметов: %d."
L["Fortune and craft"] = "Удача и ремесло"
L["Globetrotter's Day"] = "День путешественника"
L["Group with %d other adventurers."] = "Соберитесь в группу с другими искателями приключений: %d."
L["Haggler"] = "Торгаш"
L["Hoarder"] = "Скопидом"
L["Homesick"] = "Тоска по дому"
L["Honour earned: %s (%s)"] = "Получена почесть: %s (%s)"
L["Honour earned: %s"] = "Получена почесть: %s"
L["Honour points"] = "Очки почета"
L["Honour"] = "Почесть"
L["Jump %d times."] = "Прыгните %d раз."
L["Just one more quest ..."] = "Еще одно задание, и все ..."
L["Keep this diary for %d days."] = "Ведите этот дневник дней: %d."
L["Landmark discovered: %s"] = "Открыта достопримечательность: %s"
L["Landmark"] = "Достопримечательность"
L["Landmarks"] = "Достопримечательности"
L["Loot %d items."] = "Добудьте предметов: %d."
L["Marathon"] = "Марафон"
L["Master of a Craft"] = "Мастер ремесла"
L["Meet %d flight masters."] = "Познакомьтесь с распорядителями полетов: %d."
L["Meet %d people."] = "Познакомьтесь с персонажами: %d."
L["Mouse wheel: zoom  -  drag: move  -  right click: reset"] = "Колесо мыши: масштаб  -  перетаскивание: сдвиг  -  правый клик: сброс"
L["Next goals"] = "Следующие цели"
L["Next rank: %s"] = "Следующий ранг: %s"
L["Night Owl"] = "Ночная сова"
L["Not every day is a good day ..."] = "Не каждый день бывает удачным ..."
L["Not yet explored"] = "Еще не исследовано"
L["Own %d gold."] = "Накопите золотых: %d."
L["People met"] = "Знакомства"
L["Phoenix"] = "Феникс"
L["Play %d days in a row without dying."] = "Играйте дней подряд, ни разу не погибнув: %d."
L["Raids"] = "Рейды"
L["Raise a skill to %d."] = "Повысьте навык до %d."
L["Reach level %d."] = "Достигните уровня %d."
L["Regions explored"] = "Исследованные регионы"
L["Regular"] = "Завсегдатай"
L["Rest at %d places."] = "Сделайте привал в разных местах: %d."
L["Secrets"] = "Тайны"
L["Sightseer"] = "Зевака"
L["Slay %d creatures in a single day."] = "Убейте существ за один день: %d."
L["Slay %d creatures."] = "Убейте существ: %d."
L["Slay %d elite creatures."] = "Убейте элитных существ: %d."
L["Slay %d of a single kind."] = "Убейте существ одного вида: %d."
L["Slay %d rare creatures."] = "Убейте редких существ: %d."
L["So many roads, so little time ..."] = "Столько дорог, так мало времени ..."
L["Some honours stay hidden until you find them."] = "Некоторые почести скрыты, пока вы их не найдете."
L["Spend %d hours in the world on a single day."] = "Проведите в мире за один день часов: %d."
L["Spend %d hours in the world."] = "Проведите в мире часов: %d."
L["Take %d flights."] = "Совершите полетов: %d."
L["Talk to the same person %d times."] = "Поговорите с одним и тем же персонажем (раз: %d)."
L["The early bird catches the worm ..."] = "Кто рано встает, тому Бог подает ..."
L["The purse over the days"] = "Кошелек день за днем"
L["There is no place like home ..."] = "В гостях хорошо, а дома лучше ..."
L["This game client knows none of the landmarks."] = "Этот игровой клиент не знает ни одной достопримечательности."
L["Towns of Kalimdor"] = "Места Калимдора"
L["Towns of the Eastern Kingdoms"] = "Места Восточных королевств"
L["Trade with %d players."] = "Совершите обмен с игроками: %d."
L["Unexplored regions"] = "Неисследованные регионы"
L["Up, up and away ..."] = "Выше, выше, в небо ..."
L["Use your hearthstone %d times."] = "Используйте камень возвращения (раз: %d)."
L["Visit %d capital cities."] = "Посетите столиц: %d."
L["Visit %d regions in a single day."] = "Посетите регионов за один день: %d."
L["Visit %d regions."] = "Посетите регионов: %d."
L["Visit %d trainers."] = "Посетите учителей: %d."
L["Walk %d kilometres."] = "Пройдите пешком %d км."
L["Well Rested"] = "Отдохнувший"
L["What is left to discover"] = "Что еще предстоит открыть"
L["When the moon stands highest ..."] = "Когда луна стоит выше всего ..."
L["Where will the road lead tomorrow?"] = "Куда приведет дорога завтра?"
L["Wings of the World"] = "Крылья мира"
L["You have not seen this place yet."] = "Вы еще не видели это место."
L["You have seen every landmark. Remarkable!"] = "Вы видели все достопримечательности. Впечатляет!"
L["days"] = "дни"
L["done"] = "выполнено"
L["given up"] = "отменено"
L["kills"] = "убийства"
L["open"] = "открыто"

-- treasure album, wanted posters
L["WANTED"] = "РАЗЫСКИВАЕТСЯ"
L["of %d kinds"] = "из %d видов"
L["Next mark: %d slain"] = "Следующая отметка: %d убито"
L["Every mark reached"] = "Все отметки достигнуты"
L["Uncommon"] = "Необычный"
L["Epic"] = "Эпический"
L["Legendary"] = "Легендарный"

-- tasks of the day, pop-ups, week in review
L["Slay %d creatures today."] = "Убейте сегодня существ: %d."
L["Complete %d quests today."] = "Выполните сегодня заданий: %d."
L["Meet %d new people."] = "Познакомьтесь с новыми персонажами: %d."
L["Discover %d new places."] = "Откройте новых мест: %d."
L["Walk %d kilometres today."] = "Пройдите сегодня пешком %d км."
L["Find an uncommon or better item."] = "Найдите необычный предмет или лучше."
L["Visit the landmark %s."] = "Посетите достопримечательность: %s."
L["Set foot in %s."] = "Побывайте в зоне: %s."
L["Task of the day done: %s"] = "Задача дня выполнена: %s"
L["All tasks of the day done! %d days in a row."] = "Все задачи дня выполнены! Дней подряд: %d."
L["All tasks of the day done!"] = "Все задачи дня выполнены!"
L["Tasks of the day"] = "Задачи дня"
L["Task of the day"] = "Задача дня"
L["Dungeon Crawler"] = "Покоритель подземелий"
L["Finish %d dungeon runs."] = "Пройдите подземелья (раз: %d)."
L["Diligent"] = "Усердный"
L["Do all tasks of the day on %d days."] = "Выполните все задачи дня (дней: %d)."
L["Dutiful"] = "Исполнительный"
L["Do all tasks of the day %d days in a row."] = "Выполняйте все задачи дня (дней подряд: %d)."
L["Open the diary"] = "Открыть дневник"
L["Close"] = "Закрыть"
L["The week in review"] = "Итоги недели"
L["Creatures slain"] = "Убито существ"
L["Levels"] = "Уровни"
L["Kilometres"] = "Километры"
L["New places"] = "Новые места"
L["New regions"] = "Новые регионы"
L["Honours"] = "Почести"
L["Best day"] = "Лучший день"
L["A quiet week"] = "Тихая неделя"
L["The book waits for new stories."] = "Книга ждет новых историй."
L["Show a note for new discoveries"] = "Сообщать о новых открытиях"
L["Weekly look back at login"] = "Итоги недели при входе"

-- records, level timeline, gallery, nemeses, dungeon reports
L["Records"] = "Рекорды"
L["The best and the worst of days"] = "Лучшие и худшие дни"
L["Most creatures slain in a day"] = "Больше всего убийств за день"
L["Most quests in a day"] = "Больше всего заданий за день"
L["Richest day"] = "Самый доходный день"
L["Most experience in a day"] = "Больше всего опыта за день"
L["Longest day in the world"] = "Самый долгий день в мире"
L["Longest walk in a day"] = "Самый длинный переход за день"
L["Most places discovered in a day"] = "Больше всего новых мест за день"
L["Most new faces in a day"] = "Больше всего новых лиц за день"
L["Fastest level"] = "Самый быстрый уровень"
L["Slowest level"] = "Самый медленный уровень"
L["Longest run without dying"] = "Дольше всего без смерти"
L["Darkest day"] = "Самый черный день"
L["Level timeline"] = "Хроника уровней"
L["How long each level took"] = "Сколько длился каждый уровень"
L["Played for these levels"] = "Время игры на эти уровни"
L["Per level"] = "За уровень"
L["No level-ups recorded yet."] = "Повышений уровня пока нет."
L["Still on the way."] = "Еще в пути."
L["Reached the next level on day %d."] = "Следующий уровень получен в день %d."
L["Gallery"] = "Галерея"
L["Moments, painted in the gear of their day"] = "Мгновения в снаряжении того дня"
L["The first painting waits for your first great moment."] = "Первая картина ждет вашего первого великого момента."
L["Nemeses"] = "Заклятые враги"
L["They sent me to the spirit healer"] = "Они отправили меня к целителю душ"
L["Nemesis number one"] = "Заклятый враг номер один"
L["Nobody has defeated you yet. Long may it last!"] = "Вас еще никто не победил. Пусть так и будет!"
L["Killed you %d times"] = "Побед над вами: %d"
L["Revenge taken"] = "Месть свершилась"
L["Score unsettled"] = "Счет не сведен"
L["You slew them %d times."] = "Ваших побед над ними: %d."
L["Dungeon reports"] = "Отчеты о подземельях"
L["No dungeon visited yet. The depths are waiting."] = "Подземелья еще не посещены. Глубины ждут."
L["Duration"] = "Длительность"
L["Fallen"] = "Павшие"
L["The group"] = "Группа"
L["Me"] = "Я"
L["Nobody fell."] = "Никто не пал."

-- ledger figures, achievement pop-up, blocked functions, quotes
L["Best day: day %d"] = "Лучший день: день %d"
L["Worst day: day %d"] = "Худший день: день %d"
L["Per day"] = "В день"
L["Honour earned"] = "Получена почесть"
L["Landmark discovered"] = "Открыта достопримечательность"
L["Next tier:"] = "Следующий ранг:"
L["Every tier earned - complete!"] = "Все ранги получены - завершено!"
L["The game blocked the function %s. Please tell the author."] = "Игра заблокировала функцию %s. Пожалуйста, сообщите автору."
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "Этот клиент игры не разрешает аддонам делать снимки экрана. Снимки в важные моменты отключены."
L['"Here the journey ends, but not the story."'] = '«Здесь заканчивается путь, но не история.»'
L['"Whoever wanders, gathers stories."'] = '«Кто странствует, тот собирает истории.»'

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "Первые разы"
L["First time"] = "Впервые"
L["%d of %d experienced"] = "Пережито: %d из %d"
L["Not yet experienced."] = "Ещё не было."
L["Click for all first times."] = "Нажмите, чтобы увидеть все первые разы."
L["First creature slain"] = "Первое убитое существо"
L["First quest completed"] = "Первое выполненное задание"
L["First level up"] = "Первый новый уровень"
L["First uncommon item"] = "Первый необычный предмет"
L["First death"] = "Первая смерть"
L["First group"] = "Первая группа"
L["First elite slain"] = "Первый убитый элитный противник"
L["First trade"] = "Первый обмен"
L["First hearthstone"] = "Первый камень возвращения"
L["First landmark"] = "Первая достопримечательность"
L["First honour"] = "Первая награда"
L["First rare item"] = "Первый редкий предмет"
L["First rare creature"] = "Первое редкое существо"
L["First flight"] = "Первый полёт"
L["First gold coin"] = "Первая золотая монета"
L["First dungeon"] = "Первое подземелье"
L["First boss"] = "Первый босс"
L["First skill at 75"] = "Первый навык на 75"
L["First mount"] = "Первое верховое животное"
L["First epic item"] = "Первый эпический предмет"

L["Family book"] = "Семейная книга"
L["%d characters on this account"] = "Персонажей на этой учётной записи: %d"
L["you"] = "вы"
L["Last seen %s"] = "В последний раз: %s"
L["Who got there first?"] = "Кто был первым?"
L["Log in with your other characters once, and they will appear here."] = "Зайдите один раз другими персонажами, и они появятся здесь."

L["Time capsule"] = "Капсула времени"
L["Letters to my future self"] = "Письма себе в будущее"
L["Dear me, when you read this ..."] = "Дорогой я, когда ты это прочтёшь ..."
L["Seal the letter and open it ..."] = "Запечатать письмо и открыть ..."
L["in a week"] = "через неделю"
L["in a month"] = "через месяц"
L["at level %d"] = "на уровне %d"
L["Until then the letter stays sealed - not even you can read it."] = "До тех пор письмо запечатано - даже вам его не прочесть."
L["No letters yet."] = "Писем пока нет."
L["Written on day %d, at level %d"] = "Написано в день %d, на уровне %d"
L["Opened on %s"] = "Открыто: %s"
L["Sealed - opens on day %d"] = "Запечатано - откроется в день %d"
L["Sealed - opens at level %d"] = "Запечатано - откроется на уровне %d"
L["in %d days"] = "дней осталось: %d"
L["A letter for later was sealed."] = "Письмо на будущее запечатано."
L["A letter from the past has opened."] = "Открылось письмо из прошлого."
L["Click to read the letter."] = "Нажмите, чтобы прочитать письмо."

L["Gatherer's map"] = "Карта собирателя"
L["Where the good things grow"] = "Где растёт всё хорошее"
L["Herbalism"] = "Травничество"
L["Mining"] = "Горное дело"
L["Skinning"] = "Снятие шкур"
L["Fishing"] = "Рыбная ловля"
L["Most found here"] = "Чаще всего здесь"
L["Nothing gathered yet. Herbs, ore and hides show up here as soon as you gather them."] = "Пока ничего не собрано. Травы, руда и шкуры появятся здесь, как только вы начнёте собирать."

L["Task of the week"] = "Задача недели"
L["Task of the week done: %s"] = "Задача недели выполнена: %s"
L["Click for the next goals."] = "Нажмите, чтобы увидеть следующие цели."
L["Slay %d creatures this week."] = "Убейте существ за эту неделю: %d."
L["Complete %d quests this week."] = "Выполните заданий за эту неделю: %d."
L["Walk %d kilometres this week."] = "Пройдите за эту неделю (км): %d."
L["Meet %d new people this week."] = "Познакомьтесь за эту неделю с новыми персонажами: %d."
L["Visit %d different regions this week."] = "Посетите за эту неделю разных регионов: %d."
L["Earn %d honour tiers this week."] = "Получите за эту неделю ступеней наград: %d."
L["Finish a dungeon run this week."] = "Пройдите на этой неделе подземелье."
L["Find %d new landmarks this week."] = "Найдите за эту неделю новых достопримечательностей: %d."
L["Week by Week"] = "Неделя за неделей"
L["Complete %d tasks of the week."] = "Выполните задачи недели (раз: %d)."

L["Search the diary"] = "Поиск по дневнику"
L["Days, people, creatures, quests, places, treasures and catches."] = "Дни, персонажи, существа, задания, места, сокровища и уловы."
L["Search: a name, a quest, a place ..."] = "Поиск: имя, задание, место ..."
L["Nothing found."] = "Ничего не найдено."
L["%d more results - type a little more"] = "Ещё результатов: %d - уточните запрос"

L["The binding"] = "Переплёт"
L["Corner studs"] = "Уголки"
L["none yet"] = "пока нет"
L["Next metal at %d honour points (now %d)."] = "Следующий металл: %d очков почета (сейчас %d)."
L["Gems"] = "Самоцветы"
L["One gem for every ten honour tiers (now %d)."] = "Один самоцвет за каждые десять ступеней наград (сейчас %d)."
L["Gold marks on the spine"] = "Золотые знаки на корешке"
L["One for every ten levels."] = "Один за каждые десять уровней."

-- the bookplate on the endpaper
L["FROM THE LIBRARY OF"] = "ИЗ БИБЛИОТЕКИ"

-- sayings of the day (start page)
L["SAYING OF THE DAY"] = "МЫСЛЬ ДНЯ"
L["Whoever wanders, gathers stories."] = "Кто странствует, тот собирает истории."
L["Every road starts at your own door."] = "Любая дорога начинается у собственного порога."
L["A full pack is light when the heart is lighter."] = "Полный мешок лёгок, когда на сердце ещё легче."
L["Maps show the way - only feet know it."] = "Карта показывает путь, но знают его только ноги."
L["The longest journey is the one you never write down."] = "Самое долгое путешествие - то, которое так и не записано."
L["Ink fades slower than memory."] = "Чернила выцветают медленнее, чем память."
L["A good campfire turns strangers into companions."] = "Хороший костёр превращает чужих в спутников."
L["The mountain does not care how tired you are - just keep going."] = "Горе нет дела до твоей усталости - главное, не останавливаться."
L["Today's detour is tomorrow's best story."] = "Сегодняшний крюк - лучшая история завтрашнего дня."
L["Gold comes and goes, the story stays."] = "Золото приходит и уходит, а история остаётся."
L["Count the days by friends, not by miles."] = "Считай дни друзьями, а не вёрстами."
L["Even the smallest kobold guards a candle for someone."] = "Даже самый маленький кобольд бережёт для кого-то свечу."
L["Resting is part of the road."] = "Отдых - тоже часть пути."
L["Fear is a map with too many blank spots."] = "Страх - это карта, на которой слишком много белых пятен."
L["Every scar has a page in this book."] = "У каждого шрама есть своя страница в этой книге."
L["Look back now and then - the view is part of the journey."] = "Иногда оглядывайся: вид - тоже часть путешествия."
L["The wise traveller asks the innkeeper first."] = "Мудрый путник сперва расспрашивает трактирщика."
L["Rain on the road, sunshine in the story."] = "Дождь в дороге - солнце в рассказе."
L["Whoever never falls never learns to get up."] = "Кто никогда не падает, тот не научится вставать."
L["A quest half done is still a step forward."] = "Задание, выполненное наполовину, - всё равно шаг вперёд."
L["The horizon travels with you - that is why it never gets dull."] = "Горизонт путешествует вместе с тобой - потому и не скучно."
L["Write it down, or it never happened."] = "Запиши, иначе этого не было."
L["Old boots know more than new maps."] = "Старые сапоги знают больше новых карт."
L["Courage is being afraid and saddling up anyway."] = "Храбрость - это бояться и всё равно седлать коня."
L["Tomorrow the road will still be there. Tonight the fire is warm."] = "Завтра дорога никуда не денется. А сегодня у костра тепло."
L["A traveller's purse is light, a traveller's diary is heavy."] = "Кошель у путника лёгок, а дневник тяжёл."
L["The best places are on no map."] = "Лучших мест нет ни на одной карте."
L["Every hero once did not know the way."] = "Каждый герой когда-то не знал дороги."
L["Share your bread, and the road shares its secrets."] = "Поделись хлебом - и дорога поделится тайнами."
L["The story is not over while a page is still blank."] = "История не кончена, пока есть пустая страница."

-- covered cards in the bestiary: kinds your other characters know
L["Not yet discovered"] = "Ещё не обнаружено"
L["Known to %s"] = "Уже знакомо персонажу: %s"
L["%d to discover"] = "Ещё не найдено: %d"
L["in the east"] = "на востоке"
L["in the south-east"] = "на юго-востоке"
L["in the south"] = "на юге"
L["in the south-west"] = "на юго-западе"
L["in the west"] = "на западе"
L["in the north-west"] = "на северо-западе"
L["in the north"] = "на севере"
L["in the north-east"] = "на северо-востоке"
L["in the middle"] = "в центре"
L["To the contents"] = "К оглавлению"
L["Screenshots at milestones: on"] = "Снимки на важных этапах: вкл."
L["Screenshots at milestones: off"] = "Снимки на важных этапах: выкл."
L["Demo mode is off."] = "Демо-режим выключен."
L["Demo mode is on. Nothing you do now is written into your diary - type /wfd demo again to leave."] = "Демо-режим включён. Всё, что вы сейчас делаете, не попадает в дневник - введите /wfd demo ещё раз, чтобы выйти."
L["You have died, but who did it slipped past the diary."] = "Вы уже погибали, но кто это сделал, дневник не заметил."
L["Already in the quest log"] = "Взяты до начала дневника"
L["Angler"] = "Рыболов"
L["Raise Fishing to %d."] = "Поднимите навык рыбной ловли до %d."
L["Big Catch"] = "Богатый улов"
L["Catch %d fish."] = "Поймайте рыбу %d раз."
L["Field Medic"] = "Полевой лекарь"
L["Raise First Aid to %d."] = "Поднимите навык первой помощи до %d."
L["Camp Cook"] = "Походный повар"
L["Raise Cooking to %d."] = "Поднимите навык кулинарии до %d."
L["Sighted, not yet slain"] = "Замечен, но ещё не побеждён"
L["perhaps %s"] = "возможно, %s"
L["You have been %s of this area least of all. Something may still be waiting there."] = "Реже всего вы бывали в этой местности %s. Возможно, там ещё что-то ждёт."
L["Defeat a boss."] = "Победите босса."
L["Slay a rare creature."] = "Убейте редкое существо."
L["Slay an elite creature."] = "Убейте элитное существо."
L["Visit a capital city."] = "Посетите столицу."
L["Enter a dungeon."] = "Войдите в подземелье."
L["Take a flight."] = "Совершите полёт."
L["Group with another adventurer."] = "Вступите в группу с другим искателем приключений."
L["Visit a trainer."] = "Посетите наставника."
L["Trade with another player."] = "Обменяйтесь с другим игроком."
L["Complete a quest."] = "Выполните задание."
L["Die once and rise again."] = "Погибните и вернитесь к жизни."
L["Finish a dungeon run."] = "Пройдите подземелье."
L["Do all tasks of the day on one day."] = "Выполните все задания дня за один день."
L["Complete a task of the week."] = "Выполните задание недели."
L["Find a rare item."] = "Найдите редкий предмет."
L["Find an epic item."] = "Найдите эпический предмет."
L["Dear me, if you are reading this, you made it through the first week. Did you ever find out who was stealing the candles in the mine?"] = "Дорогой я, если ты читаешь это, значит, первая неделя позади. Ты так и не узнал, кто воровал свечи в шахте?"
L["Marker set on the map: %s (%d, %d)"] = "Метка на карте: %s (%d, %d)"
L["No marker can be set on this map."] = "На этой карте нельзя поставить метку."
L["Click to set a marker on the map."] = "Щёлкните, чтобы поставить метку на карте."
L["Right-click for the map of this region."] = "Правый щелчок — карта этой области."
L["1 kind"] = "Видов: 1"
L["Discover a new place."] = "Откройте новое место."
L["Walk one kilometre today."] = "Пройдите сегодня один километр."
L["WELCOME"] = "ДОБРО ПОЖАЛОВАТЬ"
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "Просто играйте, а я буду записывать. Каждый игровой день станет страницей этой книги."
L["See a sample book"] = "Посмотреть пример"
L["To today's entry"] = "К сегодняшнему дню"
L["Discover %d flight paths."] = "Откройте точки полёта: %d."
L["A sketch - %d more and it is in colour."] = "Набросок - ещё %d, и он станет цветным."
L["%d more to become a connoisseur."] = "Ещё %d, и вы станете знатоком."
L["Connoisseur of this kind"] = "Знаток этого вида"
L["First slain on day %d"] = "Впервые убит в день %d"
L["Best loot"] = "Лучшая добыча"
L["Got you once."] = "Однажды одолел вас."
L["Got you %d times."] = "Одолел вас %d раз."
L["CONNOISSEUR"] = "ЗНАТОК"
L["Connoisseur"] = "Знаток"
L["Right-click to close."] = "Правый щелчок закрывает."
L["The tabs"] = "Вкладки"
L["The tabs on the right lead to the parts of the book, one colour for each group. Point at them to read their names. A red dot shows how much is new since you last read."] = "Вкладки справа ведут к разделам книги, у каждой группы свой цвет. Наведите на них мышь, чтобы прочитать названия. Красная точка показывает, сколько нового с прошлого чтения."
L["The spyglass on the spine searches the whole book: days, people, creatures, quests, places, treasures and catches. Ctrl + F opens it too."] = "Лупа на корешке ищет по всей книге: дни, люди, существа, задания, места, сокровища и уловы. Ctrl + F тоже её открывает."
L["Your own bookmarks"] = "Свои закладки"
L["Ctrl-click a page number to keep that page. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away."] = "Ctrl-щелчок по номеру страницы запоминает её. Сверху из книги выглядывает ленточка: щелчок открывает страницу, правый щелчок убирает ленточку."
L["Ctrl + click on the page number"] = "Ctrl + щелчок по номеру страницы"
L["bookmark"] = "закладка"
L["Goals and honour"] = "Цели и почёт"
L["The world"] = "Мир"
L["Hunt and loot"] = "Охота и добыча"
L["People and money"] = "Люди и деньги"
L["Keepsakes"] = "На память"
L["Best find for every slot"] = "Лучшая находка для каждой ячейки"
L["worn right now"] = "надето сейчас"
L["Click to show only these."] = "Щёлкните, чтобы показать только эти."
L["Click to show all again."] = "Щёлкните, чтобы снова показать всё."
L["Shown: %s only"] = "Показано: только %s"
L["Show all"] = "Показать всё"
L["Ctrl-click to set or remove a bookmark here."] = "Ctrl-щелчок ставит или убирает здесь закладку."
L["Click to open, right-click to remove."] = "Щелчок открывает, правый щелчок убирает."
L["You are here."] = "Вы здесь."
L["Click for the hunting grounds of this area."] = "Щёлкните, чтобы открыть охотничьи угодья этой области."
L["Who is closest to the next stage"] = "Кто ближе всех к следующей ступени"
L["%d more, then in colour"] = "ещё %d — и в цвете"
L["%d more, then a connoisseur"] = "ещё %d — и вы знаток"
L["To the album of this area"] = "К альбому этой области"
L["Every kind known here is collected."] = "Собраны все известные здесь виды."
L["Kinds of creatures"] = "Типы существ"
L["What you have slain, by type"] = "Кого вы одолели, по типам"
L["Unknown kind"] = "Неизвестный тип"
L["%d kinds  -  %d slain"] = "%d видов  -  %d убито"
L["Hunting grounds"] = "Охотничьи угодья"
L["Sighted"] = "Замечен"
L["Kinds slain here"] = "Видов убито здесь"
L["Each pin marks where the first of its kind fell."] = "Каждая метка показывает, где пал первый представитель вида."
L["Versatile Hunter"] = "Разносторонний охотник"
L["Slay creatures of %d different types."] = "Убейте существ %d разных типов."
L["Slay 50 of each of %d kinds."] = "Убейте по 50 существ %d видов."
L["Slay 50 of one kind."] = "Убейте 50 существ одного вида."
L["Quick on its feet, but it never looks back."] = "Быстр на ногу, но никогда не оглядывается."
L["Its pelt would fetch a fair price in town."] = "Его шкура неплохо продалась бы в городе."
L["Talks big, fights small."] = "Много болтает, мало умеет."
L["Carried more coins than sense."] = "Денег при себе больше, чем ума."
L["Smells worse than it fights."] = "Воняет сильнее, чем сражается."
L["Dead once already. Twice is a habit."] = "Уже умирал однажды. Дважды - это привычка."
L["Burning eyes, burning temper."] = "Горящие глаза, горячий нрав."
L["Whoever summoned this one owes me an apology."] = "Тот, кто его призвал, должен мне извинения."
L["Not alive, not dead - simply angry."] = "Ни жив ни мёртв - просто зол."
L["Left nothing behind but a puddle of fury."] = "Оставил после себя лишь лужу ярости."
L["Scales like armour. Mind the tail."] = "Чешуя как доспех. Берегись хвоста."
L["One day I will face its big brothers."] = "Однажды я встречусь с его старшими братьями."
L["The ground shook long after it fell."] = "Земля дрожала ещё долго после его падения."
L["Big enough to have its own weather."] = "Настолько велик, что у него своя погода."
L["Gnomish work, no doubt. Loud and leaky."] = "Гномья работа, без сомнения. Шумная и протекает."
L["It sparked, it whirred, it stopped."] = "Искрило, жужжало и остановилось."
L["It never stood a chance."] = "У него не было ни единого шанса."
L["Small, harmless and now a footnote."] = "Маленький, безобидный, а теперь - сноска."
L["A strange creature. I made a note, just in case."] = "Странное существо. Я на всякий случай записал."
L["Worth remembering, or at least worth writing down."] = "Стоит запомнить или хотя бы записать."
L["Back"] = "Назад"
L["To the page you came from (Backspace)."] = "К странице, с которой вы пришли (Backspace)."
L["Go to page (1 - %d):"] = "Перейти к странице (1 - %d):"
L["Size: %d%%"] = "Размер: %d%%"
L["The bookmarks"] = "Закладки"
L["The bookmarks on the right lead to the parts of the book. A red dot shows how much is new since you last read."] = "Закладки справа ведут к разделам книги. Красная точка показывает, сколько нового появилось с последнего прочтения."
L["Search"] = "Поиск"
L["The spyglass on the spine searches the whole book: days, people, creatures, quests and places."] = "Подзорная труба на корешке ищет по всей книге: дни, люди, существа, задания и места."
L["Turning pages"] = "Листание"
L["Turn the pages with the arrows, the mouse wheel or the arrow keys. The red ribbon below always leads to today; Backspace takes you back. Ctrl + mouse wheel changes the size of the book."] = "Листайте стрелками, колёсиком мыши или клавишами со стрелками. Красная ленточка внизу всегда ведёт к сегодняшнему дню, Backspace возвращает назад. Ctrl + колёсико меняет размер книги."
L["Almost everything can be clicked"] = "Почти всё кликабельно"
L["Next"] = "Далее"
L["Skip"] = "Пропустить"
L["Got it"] = "Понятно"
L["Handling"] = "Управление"
L["Keys and comfort"] = "Клавиши и удобство"
L["Notifications"] = "Уведомления"
L["Important only"] = "Только важное"
L["Quiet"] = "Тихо"
L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] = "Важное: уровни, боссы, редкие существа и находки, подземелья, почести и письма."
L["Keys while the mouse is over the book"] = "Клавиши, пока мышь над книгой"
L["Arrow keys, Page up / down"] = "Стрелки, Page Up / Down"
L["turn the page"] = "листать"
L["Home"] = "Home"
L["contents"] = "оглавление"
L["End"] = "End"
L["today's entry"] = "сегодняшняя запись"
L["Backspace"] = "Backspace"
L["back"] = "назад"
L["Ctrl + mouse wheel"] = "Ctrl + колёсико"
L["size of the book"] = "размер книги"
L["Ctrl + F"] = "Ctrl + F"
L["search the book"] = "поиск по книге"
L["Right-click the page number"] = "Правый клик по номеру страницы"
L["go to a page"] = "перейти к странице"
L["open or close the book"] = "открыть или закрыть книгу"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "Клавишу для открытия книги можно назначить в настройках клавиш игры, в разделе «Модификации»."
L["The book"] = "Книга"
L["Reset the position"] = "Сбросить положение"
L["Show the introduction again"] = "Показать введение снова"
L["Open the scribe's notes"] = "Открыть заметки писца"
L["Right-click to go to a page."] = "Правый клик - перейти к странице."
L["%d new since you last read"] = "Нового с последнего прочтения: %d"
L["Right-click for the settings."] = "Правый клик - настройки."
L["Drag to move this button."] = "Перетащите, чтобы переместить кнопку."
L["Click to open."] = "Нажмите, чтобы открыть."
L["Moving code"] = "Код переноса"
L["This code holds the whole diary of this character. Copy it with Ctrl+C and keep it somewhere safe, for example in a text file. On the other computer, open the same window with \"Read a moving code\" and paste it there."] = "Этот код содержит весь дневник персонажа. Скопируйте его клавишами Ctrl+C и сохраните в надёжном месте, например в текстовом файле. На другом компьютере откройте окно «Прочитать код переноса» и вставьте его туда."
L["The code could not be made."] = "Не удалось создать код."
L["%d days, %d characters. Now press Ctrl+C."] = "Дней: %d, символов: %d. Теперь нажмите Ctrl+C."
L["Read a moving code"] = "Прочитать код переноса"
L["Paste the moving code of this character with Ctrl+V. The diary written on this computer is then replaced by the one from the code, and the interface is reloaded."] = "Вставьте код переноса этого персонажа клавишами Ctrl+V. Дневник на этом компьютере будет заменён дневником из кода, а интерфейс перезагрузится."
L["Waiting for a code ..."] = "Ожидание кода ..."
L["Replace the diary and reload"] = "Заменить дневник и перезагрузить"
L["This is not a moving code of the diary."] = "Это не код переноса дневника."
L["The code is damaged or incomplete. Copy it again, all of it."] = "Код повреждён или неполон. Скопируйте его ещё раз целиком."
L["Diary of %s (%s), %d days, %d kinds of creatures, %d people."] = "Дневник %s (%s): дней %d, видов существ %d, людей %d."
L["Careful: this code belongs to %s, but you are playing %s."] = "Осторожно: этот код принадлежит %s, а вы играете за %s."
L["The diary of this character on this computer will be replaced."] = "Дневник этого персонажа на этом компьютере будет заменён."
L["Leave demo mode first."] = "Сначала выйдите из демо-режима."
L["moving code of this character"] = "код переноса этого персонажа"
L["read a moving code"] = "прочитать код переноса"
L["Moving to another computer"] = "Перенос на другой компьютер"
L["Make a moving code"] = "Создать код переноса"
L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."] = "Или просто возьмите с собой папку WTF из папки игры: в ней дневники всех персонажей."
L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."] = "Небольшое окно с цифрами за сегодня, заданиями и почестями, ближе всего к следующей ступени. Перетаскивайте за заголовок, сворачивайте минусом."
L["Appearance"] = "Внешний вид"
L["Both reload the interface. With bigger writing a few long lines may run close together."] = "Оба параметра перезагружают интерфейс. С крупным шрифтом некоторые длинные строки могут оказаться тесно."
L["Click to open the diary there."] = "Нажмите, чтобы открыть дневник на этом месте."
L["Companion"] = "Спутник"
L["Fold in or out"] = "Свернуть или развернуть"
L["How the book looks"] = "Как выглядит книга"
L["Leather and gold"] = "Кожа и золото"
L["Leather and gold is the old book. Modern is flat and calm, strong contrast makes all writing brighter."] = "Кожа и золото - прежняя книга. Современный - строгий и спокойный, высокий контраст делает весь текст ярче."
L["Modern"] = "Современный"
L["Next honours"] = "Ближайшие почести"
L["Online"] = "В игре"
L["Show the companion beside the game"] = "Показывать окно-спутник рядом с игрой"
L["Size of the writing"] = "Размер шрифта"
L["Strong contrast"] = "Высокий контраст"
L["Style of the book"] = "Стиль книги"
L["The companion can be shown again in the settings or with /wfd companion."] = "Окно-спутник можно снова показать в настройках или командой /wfd companion."
L["Turn the leaves visibly"] = "Показывать перелистывание"
L["Turning the pages"] = "Листание"
L["km"] = "км"
L["reloads the interface"] = "перезагружает интерфейс"
L["show or hide the companion"] = "показать или скрыть окно-спутник"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "Найденный дневник принадлежал прежнему персонажу с тем же именем. Он отложен в сторону, а для вас начат новый дневник. |cffffd100/wfd restore|r вернёт его."
L["bring back the diary put aside"] = "вернуть отложенный дневник"
L["No diary has been put aside."] = "Отложенного дневника нет."
L["The diary put aside is back. The interface is reloaded."] = "Отложенный дневник возвращён. Интерфейс перезагружается."

-- Angler's log
L["Angler's log"] = "Журнал рыболова"
L["A collector's album of everything the line brought up"] = "Коллекционный альбом всего, что вытащила леска"
L["catches collected  -  %d things landed"] = "уловов собрано  -  %d вещей вытащено"
L["Land %d different catches."] = "Вытащите %d разных уловов."
L["Casts"] = "Забросы"
L["Fish"] = "Рыба"
L["Treasure"] = "Сокровище"
L["Junk"] = "Хлам"
L["Odds and ends"] = "Всякая всячина"
L["1 catch"] = "1 улов"
L["%d catches"] = "Уловов: %d"
L["Nothing has bitten yet."] = "Пока ничего не клюнуло."
L["Waters and tackle"] = "Водоёмы и снасти"
L["Where it bites, and what you fished with"] = "Где клюёт и чем вы ловили"
L["Waters"] = "Водоёмы"
L["%d caught in %d casts"] = "Поймано %d за %d забросов"
L["Tackle"] = "Снасти"
L["%d casts"] = "Забросов: %d"
L["No fishing pole seen yet."] = "Удочка пока не встречалась."
L["Casts with a lure"] = "Забросы с наживкой"
L["Casts in all"] = "Всего забросов"
L["CAUGHT"] = "ПОЙМАНО"
L["Mostly caught in"] = "Чаще всего ловится в"
L["Caught"] = "Поймано"
L["Of all catches"] = "От всех уловов"
L["First catch"] = "Первый улов"
L["Last catch"] = "Последний улов"
L["On a lure"] = "На наживку"
L["WHERE IT BIT"] = "ГДЕ КЛЮНУЛО"
L["Next mark: %d caught"] = "Следующая отметка: поймано %d"
L["New catch: %s"] = "Новый улов: %s"
L["Catch"] = "Улов"
L["Fish Lore"] = "Знаток рыб"
L["Fishing pole"] = "Удочка"
L["Lure"] = "Наживка"
L["Fishing gear"] = "Одежда рыболова"

-- 0.1.11: the today page, group pages, dog-ears, search filters, the companion's offer
L["Click to go to a page."] = "Щёлкните, чтобы перейти на страницу."
L["Right-click for the contents."] = "Правый щелчок — к оглавлению."
L["Click to set a bookmark here."] = "Щёлкните, чтобы положить сюда закладку."
L["Click to remove the bookmark."] = "Щёлкните, чтобы убрать закладку."
L["Click the folded corner of a page to keep it. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away."] = "Щёлкните по загнутому уголку страницы, чтобы запомнить её. Сверху из книги появится ленточка: щелчок открывает страницу, правый щелчок убирает ленточку."
L["Cards, names, days and maps open more. Click the page number to go to any page. The settings have a tab of their own at the bottom."] = "Карточки, имена, дни и карты открывают больше. Щёлкните по номеру страницы, чтобы перейти на любую страницу. У настроек есть своя закладка внизу."
L["Click to open the settings."] = "Нажмите, чтобы открыть настройки."
L["Tasks"] = "Задачи"
L["Day, week and month"] = "День, неделя и месяц"
L["Perfect days"] = "Идеальные дни"
L["Longest run"] = "Лучшая серия"
L["Tasks done"] = "Выполнено задач"
L["Weeks done"] = "Недель выполнено"
L["Months done"] = "Месяцев выполнено"
L["Task of the month"] = "Задача месяца"
L["Task of the month done: %s"] = "Задача месяца выполнена: %s"
L["Slay %d creatures this month."] = "Убейте существ за этот месяц: %d."
L["Complete %d quests this month."] = "Выполните заданий за этот месяц: %d."
L["Walk %d kilometres this month."] = "Пройдите за этот месяц (км): %d."
L["Meet %d new people this month."] = "Познакомьтесь за этот месяц с новыми персонажами: %d."
L["Visit %d different regions this month."] = "Посетите за этот месяц разных регионов: %d."
L["Earn %d honour tiers this month."] = "Получите за этот месяц ступеней наград: %d."
L["Finish %d dungeon runs this month."] = "Пройдите в этом месяце подземелий: %d."
L["Find %d new landmarks this month."] = "Найдите за этот месяц новых достопримечательностей: %d."
L["Click to set a waypoint on the map."] = "Нажмите, чтобы поставить метку на карте."
L["Waypoint set: %s"] = "Метка поставлена: %s"
L["Map controls"] = "Управление картой"
L["Mouse wheel: zoom"] = "Колесо мыши: масштаб"
L["Drag: move the map"] = "Перетаскивание: сдвиг карты"
L["Right click: reset"] = "Правый клик: сброс"
L["New in the diary. Click to refresh."] = "В дневнике появились новые записи. Нажмите, чтобы обновить."
L["Click the page number"] = "Щелчок по номеру страницы"
L["Click the folded corner"] = "Щелчок по загнутому уголку"
L["New since you last read"] = "Новое с прошлого чтения"
L["Nothing new since you last read."] = "С прошлого чтения ничего нового."
L["Nothing in here yet."] = "Здесь пока пусто."
L["Show the cover when the book is first opened"] = "Показывать обложку при первом открытии"
L["%d new moments"] = "Новых моментов: %d"
L["The companion"] = "Спутник"
L["A small window beside the game shows today's figures, the tasks and the honours closest to their next tier. You can switch it on and off in the settings."] = "Небольшое окно рядом с игрой показывает цифры за сегодня, задания и почести, ближе всего к следующей ступени. Его можно включить и выключить в настройках."
L["Show it"] = "Показать"
L["Names from the game (places, creatures, items) stay in the language of the game client."] = "Названия из игры (места, существа, предметы) остаются на языке игрового клиента."
