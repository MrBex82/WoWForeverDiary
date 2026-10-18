-- German translation (English phrases are the keys)
local ADDON, WFD = ...
local L, loc = WFD:NewLocale("deDE")

local T = {
    -- chat / log
    ["Diary"] = "Tagebuch",
    ["%d creatures slain in total"] = "Insgesamt %d Kreaturen erschlagen",
    ["First victory over the boss %s!"] = "Erster Sieg über den Boss %s!",
    ["Rare creature slain: %s"] = "Seltene Kreatur erlegt: %s",
    ["Boss %s defeated again (%dx)"] = "Boss %s erneut besiegt (%dx)",
    ["Died to %s in %s"] = "Getötet von %s in %s",
    ["Died in %s"] = "Gestorben in %s",
    ["Met %s (%s)"] = "%s kennengelernt (%s)",
    ["Hearthstone bound to %s"] = "Ruhestein an %s gebunden",
    ["Quest accepted: %s"] = "Quest angenommen: %s",
    ["Quest abandoned: %s"] = "Quest abgebrochen: %s",
    ["Quest completed: %s"] = "Quest abgeschlossen: %s",
    ["First quest completed: %s"] = "Erste Quest abgeschlossen: %s",
    ["%d quests completed"] = "%d Quests abgeschlossen",
    ["Took a flight to %s"] = "Nach %s geflogen",
    ["Wealth reached: %s"] = "Zum ersten Mal %s im Beutel",
    ["Found %s"] = "Gefunden: %s",
    ["Epic find: %s"] = "Epischer Fund: %s",
    ["Rare find: %s"] = "Seltener Fund: %s",
    ["Discovered a new land: %s"] = "Neues Land entdeckt: %s",
    ["Entered %s"] = "%s betreten",
    ["Discovered: %s (%s)"] = "Entdeckt: %s (%s)",
    ["First visit to the dungeon %s"] = "Zum ersten Mal im Dungeon %s",
    ["Entered the dungeon %s"] = "Dungeon %s betreten",
    ["Level %d reached!"] = "Stufe %d erreicht!",
    ["%s increased to %d"] = "%s auf %d gestiegen",
    ["%s mastered up to %d"] = "%s auf %d gebracht",
    ["Used the hearthstone"] = "Ruhestein benutzt",

    -- window
    ["Travel Diary of %s"] = "Reisetagebuch von %s",
    ["Day %d"] = "Tag %d",
    ["Level %d"] = "Stufe %d",
    ["Level %s"] = "Stufe %s",
    ["online"] = "online",
    ["LIFELINE"] = "LEBENSLINIE",
    ["now"] = "jetzt",
    ["Screenshot:"] = "Screenshot:",
    ["Click to read this day."] = "Klicken, um diesen Tag zu lesen.",
    ["Click to open the diary."] = "Klicken, um das Tagebuch zu öffnen.",
    ["%d kills today"] = "%d Kills heute",
    ["%d quests today"] = "%d Quests heute",
    ["DEMO MODE - invented data"] = "DEMO-MODUS - erfundene Daten",

    -- tabs
    ["Journal"] = "Tagebuch",
    ["World Map"] = "Weltkarte",
    ["Bestiary"] = "Bestiarium",
    ["People"] = "Personen",
    ["Quest Book"] = "Questbuch",
    ["Statistics"] = "Statistik",
    ["Export"] = "Export",

    -- journal
    ["Today"] = "Heute",
    ["Chronicle"] = "Chronik",
    ["Overview"] = "Übersicht",
    ["Nothing recorded yet."] = "Noch nichts aufgezeichnet.",
    ["Balance of the day"] = "Bilanz des Tages",
    ["Enemies slain"] = "Gegner besiegt",
    ["Quests completed"] = "Quests abgeschlossen",
    ["(done / accepted)"] = "(fertig / angenommen)",
    ["People spoken to"] = "Gesprochen mit",
    ["Experience gained"] = "Erfahrung gesammelt",
    ["Distance travelled"] = "Zurückgelegte Strecke",
    ["flown"] = "geflogen",
    ["Time online"] = "Zeit online",
    ["Deaths"] = "Tode",
    ["Jumps"] = "Sprünge",
    ["Purse"] = "Börse",
    ["Income"] = "Einnahmen",
    ["Expenses"] = "Ausgaben",
    ["Net"] = "Bilanz",
    ["Fallen foes"] = "Gefallene Gegner",
    ["... and %d more kinds"] = "... und %d weitere Arten",
    ["Completed quests"] = "Abgeschlossene Quests",
    ["Spoken to"] = "Gesprochen mit",
    ["Loot (%d items)"] = "Beute (%d Gegenstände)",
    ["Loot"] = "Beute",
    ["Places"] = "Orte",
    ["Special moments"] = "Besondere Momente",
    ["photo"] = "Foto",

    -- map
    ["Footsteps"] = "Fußspuren",
    ["Kills"] = "Kills",
    ["Quests"] = "Quests",
    ["No map art available for this area."] = "Für dieses Gebiet gibt es keine Karte.",
    ["VISITED AREAS"] = "BESUCHTE GEBIETE",
    ["Play"] = "Abspielen",
    ["Stop"] = "Stopp",
    ["Only this day"] = "Nur dieser Tag",
    ["Drag the slider through time: your footsteps grow day by day."] = "Zieh den Regler durch die Zeit: Deine Fußspuren wachsen Tag für Tag.",
    ["Spoken to %d times"] = "%d-mal angesprochen",
    ["Quest accepted here"] = "Hier angenommen",
    ["Quest handed in here"] = "Hier abgegeben",
    ["You died here"] = "Hier bist du gestorben",
    ["Killed by %s"] = "Getötet von %s",
    ["Footprints: %d spots   Kills: %d   Deaths: %d"] = "Fußspuren: %d Orte   Kills: %d   Tode: %d",
    ["No travels recorded yet."] = "Noch keine Reisen aufgezeichnet.",

    -- bestiary
    ["Name"] = "Name",
    ["Level"] = "Stufe",
    ["Recent"] = "Zuletzt",
    ["Foes"] = "Gegner",
    ["Nemeses"] = "Erzfeinde",
    ["Bosses and rares"] = "Bosse und Seltene",
    ["Boss"] = "Boss",
    ["Rare"] = "Selten",
    ["Elite"] = "Elite",
    ["Normal"] = "Normal",
    ["No portrait"] = "Kein Porträt",
    ["KILLS PER DAY"] = "KILLS PRO TAG",
    ["Kills: %d"] = "Kills: %d",
    ["Rank: #%d of %d kinds"] = "Rang: #%d von %d Arten",
    ["First kill:"] = "Erster Kill:",
    ["Last kill:"] = "Letzter Kill:",
    ["Seen in:"] = "Gesehen in:",
    ["This creature killed you %d times."] = "Dieses Wesen hat dich %d-mal getötet.",
    ["Your nemesis"] = "Dein Erzfeind",
    ["Last seen in:"] = "Zuletzt gesehen in:",
    ["Last time:"] = "Zuletzt:",
    ["You have killed it %d times."] = "Du hast es %d-mal besiegt.",
    ["Nobody has killed you yet."] = "Bisher hat dich niemand getötet.",

    -- people
    ["Talks"] = "Gespräche",
    ["First met"] = "Erstes Treffen",
    ["Show on map"] = "Auf Karte zeigen",
    ["QUESTS WITH THIS PERSON"] = "QUESTS MIT DIESER PERSON",
    ["Conversations: %d"] = "Gespräche: %d",
    ["Found in:"] = "Zu finden in:",
    ["First met:"] = "Erstes Treffen:",
    ["Last met:"] = "Letztes Treffen:",
    ["given and received"] = "gegeben und abgenommen",
    ["given"] = "gegeben",
    ["handed in"] = "abgegeben",
    ["No quests recorded."] = "Keine Quests aufgezeichnet.",
    ["Role:"] = "Rolle:",
    ["All"] = "Alle",
    ["%d of %d people"] = "%d von %d Personen",
    ["You have not talked to anyone yet."] = "Du hast noch mit niemandem gesprochen.",
    ["Conversation"] = "Gespräch",
    ["Vendor"] = "Händler",
    ["Trainer"] = "Lehrer",
    ["Flight master"] = "Flugmeister",
    ["Banker"] = "Bankier",
    ["Stable master"] = "Stallmeister",
    ["Petitions"] = "Gildenurkunden",
    ["Auctioneer"] = "Auktionator",

    -- quests
    ["Completed"] = "Abgeschlossen",
    ["Open"] = "Offen",
    ["Abandoned"] = "Abgebrochen",
    ["In progress"] = "In Arbeit",
    ["Received from:"] = "Erhalten von:",
    ["Handed in to:"] = "Abgegeben bei:",
    ["Accepted:"] = "Angenommen:",
    ["Completed:"] = "Abgeschlossen:",
    ["Took:"] = "Dauer:",
    ["Experience:"] = "Erfahrung:",
    ["Gold reward:"] = "Goldbelohnung:",
    ["Reward:"] = "Belohnung:",
    ["Where I accepted it"] = "Hier angenommen",
    ["Where I handed it in"] = "Hier abgegeben",
    ["%d of %d quests completed"] = "%d von %d Quests abgeschlossen",
    ["No quests recorded yet."] = "Noch keine Quests aufgezeichnet.",

    -- statistics
    ["Gold"] = "Gold",
    ["XP"] = "XP",
    ["Time"] = "Zeit",
    ["Distance"] = "Strecke",
    ["Nothing to chart yet."] = "Noch zu wenig für ein Diagramm.",
    ["WHERE THE MONEY CAME FROM"] = "WOHER DAS GELD KAM",
    ["WHERE THE MONEY WENT"] = "WOHIN DAS GELD FLOSS",
    ["In total: %d kills  |  %d quests  |  %s online  |  %.1f km on foot  |  %d deaths  |  %d jumps"] =
        "Insgesamt: %d Kills  |  %d Quests  |  %s online  |  %.1f km zu Fuß  |  %d Tode  |  %d Sprünge",

    -- money categories
    ["Quest rewards"] = "Questbelohnungen",
    ["Vendor sales"] = "Verkäufe an Händler",
    ["Mail"] = "Post",
    ["Trading"] = "Handel",
    ["Auction house"] = "Auktionshaus",
    ["Repairs"] = "Reparaturen",
    ["Purchases"] = "Einkäufe",
    ["Training"] = "Training",
    ["Flights"] = "Flüge",
    ["Bank"] = "Bank",
    ["Other"] = "Sonstiges",

    -- export / settings
    ["Born:"] = "Geboren:",
    ["As text"] = "Als Text",
    ["Select all"] = "Alles markieren",
    ["Ctrl+C copies the selection."] = "Strg+C kopiert die Auswahl.",
    ["SETTINGS"] = "EINSTELLUNGEN",
    ["Take a screenshot at milestones"] = "Bei Meilensteinen Screenshot aufnehmen",
    ["Announce milestones in chat"] = "Meilensteine im Chat melden",
    ["Show minimap button"] = "Minimap-Button anzeigen",
}

for k, v in pairs(T) do L[k] = v end
L["First day"] = "Erster Tag"

-- redesigned interface
local T2 = {
    ["Travel Diary"] = "Reisetagebuch",
    ["Day of life"] = "Lebenstag",
    ["Days of life"] = "Lebenstage",
    ["Memories of the day"] = "Erinnerungen des Tages",
    ["A day without great events."] = "Ein Tag ohne große Ereignisse.",
    ["Ledger"] = "Bilanz",
    ["Experience"] = "Erfahrung",
    ["Conversations"] = "Gespräche",
    ["On foot"] = "Zu Fuß",
    ["Map of my travels"] = "Karte meiner Reisen",
    ["Layers"] = "Ebenen",
    ["%d kinds - %d kills"] = "%d Arten - %d Kills",
    ["%d nemeses"] = "%d Erzfeinde",
    ["No creature has fallen yet."] = "Noch ist keine Kreatur gefallen.",
    ["Slain"] = "Erschlagen",
    ["Rank"] = "Rang",
    ["First kill"] = "Erster Kill",
    ["Last kill"] = "Letzter Kill",
    ["Seen in"] = "Gesehen",
    ["Killed you"] = "Hat dich getötet",
    ["You slew it"] = "Von dir erschlagen",
    ["Last seen in"] = "Zuletzt gesehen in",
    ["Last time"] = "Zuletzt",
    ["\"First encountered on day %d in %s.\""] = "\"Zum ersten Mal begegnet: Tag %d, %s.\"",
    ["\"Revenge is a dish best served cold.\""] = "\"Rache ist ein Gericht, das man am besten kalt serviert.\"",
    ["Acquaintances"] = "Bekanntschaften",
    ["Found in"] = "Zu finden in",
    ["Place"] = "Ort",
    ["Last met"] = "Zuletzt getroffen",
    ["Region"] = "Gebiet",
    ["Received from"] = "Erhalten von",
    ["Handed in to"] = "Abgegeben bei",
    ["Accepted"] = "Angenommen",
    ["Took"] = "Dauer",
    ["Reward"] = "Belohnung",
    ["Balance of a life"] = "Bilanz eines Lebens",
    ["Since %s"] = "Seit %s",
    ["Remarkable"] = "Bemerkenswertes",
    ["Bloodiest day"] = "Blutigster Tag",
    ["Richest day"] = "Reichster Tag",
    ["Favourite prey"] = "Liebste Beute",
    ["Arch-enemy"] = "Erzfeind",
    ["Home of the heart"] = "Herzensheimat",
    ["Closest confidant"] = "Engster Vertrauter",
    ["Day by day"] = "Tag für Tag",
    ["Came from"] = "Woher",
    ["Went to"] = "Wohin",
    ["Transcript"] = "Abschrift",
    ["Settings"] = "Einstellungen",
    ["Size of the book"] = "Größe des Buches",
    ["Demo"] = "Demo",
    ["Start demo mode"] = "Demo-Modus starten",
    ["Leave demo mode"] = "Demo-Modus beenden",
    ["Commands"] = "Befehle",
    ["open or close the diary"] = "Tagebuch öffnen oder schließen",
    ["explore with invented data"] = "mit erfundenen Daten erkunden",
    ["screenshots on or off"] = "Screenshots an oder aus",
    ["minimap button on or off"] = "Minimap-Button an oder aus",
    ["\"Screenshots are saved in the Screenshots folder of your game.\""] = "\"Die Bilder landen im Ordner Screenshots deines Spiels.\"",
}
for k, v in pairs(T2) do L[k] = v end

L["Travel diary active - today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
    "Reisetagebuch bereit - heute ist |cffffd100Tag %d|r. Mit |cffffd100/wfd|r schlägst du es auf."

-- dates and diary entries
loc.date = "%d.%m.%Y"
loc.decimal = ","
loc.listAnd = " und "
loc.nounCase = true   -- nouns keep their capital letter inside a sentence

-- "im Wald von Elwynn", "in der Sengenden Schlucht", "in den Östlichen Pestländern", "nach Westfall":
-- the zone names of the game with the article German wants. m/n = masculine/neuter, f = feminine, p = plural
local ZONES = {
    ["Wald von Elwynn"] = "m", ["Dämmerwald"] = "m", ["Silberwald"] = "m", ["Teufelswald"] = "m",
    ["Krater von Un'Goro"] = "m", ["Gebirgspass der Totenwinde"] = "m",
    ["Rotkammgebirge"] = "n", ["Alteracgebirge"] = "n", ["Steinkrallengebirge"] = "n", ["Arathihochland"] = "n",
    ["Ödland"] = "n", ["Sumpfland"] = "n", ["Hinterland"] = "n", ["Brachland"] = "n", ["Schlingendorntal"] = "n",
    ["Eschental"] = "n", ["Vorgebirge des Hügellands"] = "n",
    ["Sengende Schlucht"] = "f", ["Brennende Steppe"] = "f", ["Dunkelküste"] = "f", ["Mondlichtung"] = "f",
    ["Unterstadt"] = "f", ["Tiefenbahn"] = "f",
    ["Verwüstete Lande"] = "p", ["Westliche Pestländer"] = "p", ["Östliche Pestländer"] = "p",
    ["Sümpfe des Elends"] = "p", ["Düstermarschen"] = "p", ["Tausend Nadeln"] = "p",
}
local SUFFIX = {
    { "wald$", "m" }, { "krater$", "m" }, { "pass$", "m" }, { "forst$", "m" },
    { "gebirge$", "n" }, { "hochland$", "n" }, { "land$", "n" }, { "tal$", "n" }, { "moor$", "n" },
    { "schlucht$", "f" }, { "steppe$", "f" }, { "küste$", "f" }, { "lichtung$", "f" }, { "stadt$", "f" }, { "bahn$", "f" },
    { "lande$", "p" }, { "länder$", "p" }, { "marschen$", "p" }, { "sümpfe", "p" },
}
local PREP = {
    ["in"]   = { m = "im", n = "im", f = "in der", p = "in den", x = "in" },
    ["to"]   = { m = "in den", n = "ins", f = "in die", p = "in die", x = "nach" },
    ["over"] = { m = "über dem", n = "über dem", f = "über der", p = "über den", x = "über" },
}
-- plural zones: after "in den / über den" (dative) and after "in die" (accusative)
local PLURAL = {
    ["Verwüstete Lande"] = { "Verwüsteten Landen", "Verwüsteten Lande" },
    ["Westliche Pestländer"] = { "Westlichen Pestländern", "Westlichen Pestländer" },
    ["Östliche Pestländer"] = { "Östlichen Pestländern", "Östlichen Pestländer" },
    ["Sümpfe des Elends"] = { "Sümpfen des Elends", "Sümpfe des Elends" },
}
-- an adjective before a feminine noun takes an ending after "der": "Sengende" -> "Sengenden"
local function decline(name, g, case)
    if g == "p" then
        local forms = PLURAL[name]
        return forms and forms[case == "to" and 2 or 1] or name
    end
    if g == "f" and case ~= "to" then return (name:gsub("^(%S+e) ", "%1n ")) end
    return name
end
function loc.place(name, case)
    if name == "unbekanntes Land" then return case == "to" and "in unbekanntes Land" or "in unbekanntem Land" end
    local bare = name:gsub("^Die ", ""):gsub("^Der ", ""):gsub("^Das ", "")
    local g = ZONES[bare]
    if not g then
        local head = bare:match("^(%S+) von ") or bare:match("^(%S+) des ") or bare:match("^(%S+) der ") or bare
        head = head:lower()
        for _, s in ipairs(SUFFIX) do
            if head:find(s[1]) then g = s[2] break end
        end
    end
    g = g or (bare ~= name and "f") or "x"
    local p = PREP[case] or PREP["in"]
    return p[g] .. " " .. decline(bare, g, case)
end
loc.dayMonth = "%d.%m."
loc.weekdays = { "Sonntag", "Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag" }
loc.months = { "Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember" }
function loc.longDate(d)
    return string.format("%s, %d. %s %d", loc.weekdays[d.wday], d.day, loc.months[d.month], d.year)
end

loc.narrator = {
    birth = {
        "Tag 1. Ich bin %s und %s, und heute bin ich %s aufgewacht. Was jetzt kommt? Keine Ahnung.",
        "Tag 1. %s, %s, gerade erst angekommen %s. Mal sehen, wohin das führt.",
    },
    begin = {
        "Tag 1. Ab heute schreibe ich auf, was mir unterwegs so passiert.",
    },
    open = {
        "Tag %d, %s.",
        "Tag %d. Heute ging es <in> weiter.",
        "Tag %d. Wieder unterwegs, diesmal vor allem <in>.",
    },
    far = "unbekanntes Land",
    walk = {
        "Bin heute etwa %s Kilometer gelaufen%s.",
        "Meine Füße sagen: gut %s Kilometer%s.",
        "Rund %s Kilometer zu Fuß%s, und das merke ich in den Beinen.",
    },
    via = " (%s)",
    fly = " Den Rest bin ich geflogen.",
    kills = {
        "{Ein Gegner ist|%d Gegner sind} durch meine Hand gefallen.",
        "Ich habe %d {Kreatur|Kreaturen} erledigt.",
        "{Ein Gegner|%d Gegner} weniger auf der Welt.",
    },
    top = {
        "Die meisten davon: %s (%dx).",
        "%s ist mir dabei am häufigsten über den Weg gelaufen (%dx).",
    },
    special = "Nicht vergessen will ich: %s.",
    deaths = {
        "Gestorben bin ich {einmal|%d-mal}.%s",
        "{Einmal|%d-mal} lag ich heute im Dreck.%s",
    },
    deathBy = " Zuletzt hat mich %s erwischt.",
    noDeath = {
        "Heute bin ich kein einziges Mal gestorben.",
        "Kein einziger Tod heute. Läuft.",
    },
    questDone = {
        "{Eine Quest erledigt|%d Quests erledigt}: %s.",
        "Von meiner Liste gestrichen: %s.",
    },
    questAcc = {
        "Dafür {ist eine neue dazugekommen|sind %d neue dazugekommen}.",
        "Und schon {wartet die nächste Aufgabe|warten %d neue Aufgaben}.",
    },
    questAccOnly = {
        "{Eine neue Aufgabe angenommen, aber noch nicht erledigt.|%d neue Aufgaben angenommen, erledigt ist noch keine.}",
    },
    more = "und noch ein paar",
    quote = {
        "%s meinte: %s",
        "O-Ton %s: %s",
    },
    quoteAnon = "Ein Satz ist hängen geblieben: %s",
    npcs = {
        "{Geredet habe ich nur mit %s.|Ich habe mit %d Leuten geredet, unter anderem mit %s.}",
        "{Ein Gespräch, und zwar mit %s.|%d Gespräche, zum Beispiel mit %s.}",
    },
    gain = {
        "Mein Beutel ist um %s schwerer.",
        "Unterm Strich %s mehr in der Tasche.",
    },
    loss = {
        "Mein Beutel ist um %s leichter.",
        "Unterm Strich hat mich der Tag %s gekostet.",
    },
    src = " Die meisten Einnahmen: %s (%s).",
    spent = " Das meiste ging für %s drauf (%s).",
    item = {
        "Bester Fund: %s.",
        "Fund des Tages: %s.",
    },
    levels = {
        "Stufe %s erreicht.",
        "Aufgestiegen auf Stufe %s.",
        "Und dann: Stufe %s!",
    },
    quiet = {
        "Ruhiger Tag. Viel zu erzählen gibt es nicht.",
        "Heute ist nicht viel passiert.",
    },
    begun = {
        "Der Tag hat gerade erst begonnen.",
        "Der Tag ist noch jung.",
        "Der neue Tag fängt gerade erst an.",
    },
    ongoing = {
        "Der Tag ist noch nicht vorbei.",
        "Fortsetzung folgt ...",
        "Mal sehen, was der Tag noch bringt.",
    },
    close = {
        "Feierabend.",
        "Genug für heute. Morgen geht's weiter.",
        "Jetzt erst mal Pause.",
        "Mal sehen, was morgen kommt.",
    },
    closeLong = {
        "%s unterwegs gewesen. Jetzt reicht's.",
        "Nach %s bin ich ziemlich platt.",
        "Alles in allem %s auf den Beinen. Morgen geht's weiter.",
    },
    none = "Für diesen Tag gibt es keinen Eintrag.",
}

-- book interface
L["Appendix"] = "Anhang"
L["Begun on %s"] = "Begonnen am %s"
L["Bookmark"] = "Lesezeichen"
L["Click to open today's entry."] = "Klicken, um den heutigen Eintrag zu öffnen."
L["Click to open"] = "Zum Öffnen klicken"
L["Contents"] = "Inhalt"
L["Notes"] = "Notizen"
L["Page %d"] = "Seite %d"
L["Realm: %s"] = "Realm: %s"
L["This book belongs to"] = "Dieses Buch gehört"
L["in %s, at level %d"] = "%s, auf Stufe %d"
L["in %s, on the first day of my life"] = "%s, am ersten Tag meines Lebens"
L["of"] = "von"

-- book pages (diary, appendix)
L["\"Whoever wanders, gathers stories.\""] = "\"Wer wandert, sammelt Geschichten.\""
L["Arrival in %s"] = "Ankunft %s"
L["Days in %s"] = "Tage %s"
L["Shadows over %s"] = "Schatten %s"
L["The roads of %s"] = "Unterwegs %s"
L["Under the skies of %s"] = "Unter dem Himmel %s"
L["Awakening in %s"] = "Erwachen %s"
L["Return to %s"] = "Rückkehr %s"
L["Chapter"] = "Kapitel"
L["Level %d-%d"] = "Stufe %d-%d"
L["Days %d-%d"] = "Tag %d-%d"
L["Level %d!"] = "Stufe %d!"
L["%d kills"] = "%d Kills"
L["%d quests"] = "%d Quests"
L["died %dx"] = "%dx gestorben"
L["Kept as a memory"] = "Als Andenken eingeklebt"
L["Click to read this day aloud in chat."] = "Klicken, um diesen Tag im Chat vorzulesen."
L["The pages are still empty. Go and live an adventure!"] = "Die Seiten sind noch leer. Zeit für ein Abenteuer!"
L["p. %d"] = "S. %d"
L["Milestones"] = "Meilensteine"
L["The great moments of a life"] = "Die großen Momente eines Lebens"
L["No milestones yet."] = "Noch keine Meilensteine."
L["Maps"] = "Karten"
L["%s spent here"] = "%s hier verbracht"
L["Route"] = "Route"
L["Kill sites"] = "Kampfplätze"
L["Graves"] = "Gräber"
L["First visit"] = "Erster Besuch"
L["Time spent"] = "Verbrachte Zeit"
L["Creatures slain here"] = "Hier erschlagen"
L["Acquaintances here"] = "Bekanntschaften hier"
L["A naturalist's notes"] = "Notizen eines Naturkundlers"
L["Slain %d times"] = "%d-mal erschlagen"
L["Killed you %d times"] = "Hat dich %d-mal getötet"
L["Every creature, by number slain"] = "Alle Kreaturen, die häufigsten zuerst"
L["Everyone I met on my way"] = "Alle, die mir unterwegs begegnet sind"
L["Every coin, in and out"] = "Jede Münze, rein wie raus"
L["Balance"] = "Saldo"
L["Day"] = "Tag"
L["Tasks taken and done"] = "Angenommene und erledigte Aufgaben"
L["Scribe's notes"] = "Notizen des Schreibers"
L["How this book is kept"] = "Wie dieses Buch geführt wird"
L["Copy the diary as text"] = "Tagebuch als Text kopieren"
L["Copy the diary as JSON"] = "Tagebuch als JSON kopieren"
L["Ledger"] = "Kassenbuch"

-- own notes
L["Click here to write your own notes ..."] = "Hier klicken, um eigene Notizen zu schreiben ..."
L["My own thoughts:"] = "Eigene Gedanken:"
L["+ note"] = "+ Notiz"
L["edit note"] = "Notiz bearbeiten"
L["Save"] = "Speichern"
L["Cancel"] = "Abbrechen"

-- cards
L["Wanted poster"] = "Steckbrief"
L["Acquaintance"] = "Bekanntschaft"
L["Click for the wanted poster."] = "Klicken für den Steckbrief."
L["Click for the portrait."] = "Klicken für das Porträt."

-- collector's album
L["A collector's album of every creature slain"] = "Ein Sammelalbum aller erlegten Kreaturen"
L["kinds collected  -  %d creatures slain"] = "Arten gesammelt  -  %d Kreaturen erlegt"
L["Bronze"] = "Bronze"
L["Silver"] = "Silber"
L["Mithril"] = "Mithril"
L["Legend"] = "Legende"
L["Collect %d kinds of creatures."] = "Sammle %d Kreaturenarten."
L["Reached!"] = "Erreicht!"
L["%d still missing."] = "Es fehlen noch %d."
L["Bosses"] = "Bosse"
L["Rare creatures"] = "Seltene Kreaturen"
L["Album pages"] = "Albumseiten"
L["%d kinds"] = "%d Arten"
L["Lv %s"] = "St. %s"
L["NEW"] = "NEU"
L["not yet found"] = "noch nicht gefunden"

-- language switch
L["Language"] = "Sprache"
L["Game language (%s)"] = "Spielsprache (%s)"
L["German"] = "Deutsch"
L["English"] = "Englisch"
L["French"] = "Französisch"
L["Spanish"] = "Spanisch"
L["Portuguese"] = "Portugiesisch"
L["Russian"] = "Russisch"
L["Korean"] = "Koreanisch"
L["Chinese (traditional)"] = "Chinesisch (traditionell)"
L["The diary will reload the interface to switch the language."] = "Zum Wechseln der Sprache lädt das Tagebuch die Oberfläche neu."
L["Korean and Chinese text needs a game client with those fonts."] = "Koreanisch und Chinesisch brauchen einen Spielclient mit diesen Schriften."

-- map spreads
L["Places of note"] = "Besondere Orte"
L["Nobody was met here yet."] = "Hier hast du noch niemanden getroffen."
L["Grave"] = "Grab"
L["Chronicle of the region"] = "Gebietschronik"
L["Visits"] = "Besuche"
L["Quests completed here"] = "Hier erledigte Quests"
L["Deaths here"] = "Tode hier"
L["Most hunted here"] = "Hier am häufigsten gejagt"
L["Places discovered"] = "Entdeckte Orte"

-- companions, honours, treasures, memories, obituary
L["%d days of life  -  %d creatures slain  -  %d quests completed"] = "%d Lebenstage  -  %d Kreaturen erlegt  -  %d Quests erledigt"
L["%d days"] = "%d Tage"
L["%d enemies fell that day."] = "An diesem Tag fielen %d Gegner."
L["%d kills together"] = "%d gemeinsame Kills"
L["%d of %d honours earned"] = "%d von %d Ehren errungen"
L["%d times grouped"] = "%d-mal gemeinsam unterwegs"
L["%d treasures collected"] = "%d Schätze gesammelt"
L["%dx traded"] = "%dx gehandelt"
L["A painted memory"] = "Ein gemaltes Andenken"
L["Book of honour"] = "Ehrenbuch"
L["Companions"] = "Gefährten"
L["Copy for forum or Discord (Markdown)"] = "Für Forum oder Discord kopieren (Markdown)"
L["Fell in %s"] = "Gefallen: %s"
L["Fell to %s"] = "Gefallen durch %s"
L["Fellow adventurers"] = "Weggefährten"
L["Grouped with %s"] = "Gemeinsam unterwegs mit %s"
L["In memoriam"] = "In Gedenken"
L["Loot of %s"] = "Beute von %s"
L["No trades yet."] = "Noch kein Handel."
L["No treasures found yet."] = "Noch keine Schätze gefunden."
L["Rested here"] = "Hier gerastet"
L["Slain by %s"] = "Erschlagen von %s"
L["The last moment"] = "Der letzte Augenblick"
L["Times rested here"] = "Hier gerastet"
L["Today, %d days ago"] = "Heute vor %d Tagen"
L["Trading partners"] = "Handelspartner"
L["Treasures"] = "Schätze"
L["Who walked beside me"] = "Wer mit mir unterwegs war"
L["You have not grouped with anyone yet."] = "Du warst noch mit niemandem in einer Gruppe."
L["You were in %s."] = "Du warst %s."
L["earned"] = "errungen"
L["first met %s"] = "kennengelernt %s"
L["early in the morning"] = "früh am Morgen"
L["in the morning"] = "am Vormittag"
L["around noon"] = "um die Mittagszeit"
L["in the afternoon"] = "am Nachmittag"
L["in the evening"] = "am Abend"
L["late at night"] = "spät in der Nacht"
L["\"Here the journey ends, but not the story.\""] = "\"Hier endet die Reise, aber nicht die Geschichte.\""
-- honours
L["First Blood"] = "Erstes Blut"
L["Slay your first creature."] = "Erlege deine erste Kreatur."
L["Hunter"] = "Jäger"
L["Slay 100 creatures."] = "Erlege 100 Kreaturen."
L["Slayer"] = "Schlächter"
L["Slay 1000 creatures."] = "Erlege 1000 Kreaturen."
L["Scourge of the Wilds"] = "Geißel der Wildnis"
L["Slay 5000 creatures."] = "Erlege 5000 Kreaturen."
L["Specialist"] = "Spezialist"
L["Slay 100 of a single kind."] = "Erlege 100 Kreaturen derselben Art."
L["Naturalist"] = "Naturkundler"
L["Collect 50 kinds of creatures."] = "Sammle 50 Kreaturenarten."
L["Giant Slayer"] = "Riesentöter"
L["Defeat a boss."] = "Besiege einen Boss."
L["Bane of Bosses"] = "Schrecken der Bosse"
L["Defeat 10 bosses."] = "Besiege 10 Bosse."
L["Rare Hunter"] = "Raritätenjäger"
L["Slay 5 rare creatures."] = "Erlege 5 seltene Kreaturen."
L["Helping Hand"] = "Helfende Hand"
L["Complete 10 quests."] = "Erledige 10 Quests."
L["Hero of the People"] = "Held des Volkes"
L["Complete 100 quests."] = "Erledige 100 Quests."
L["Explorer"] = "Entdecker"
L["Discover 25 places."] = "Entdecke 25 Orte."
L["Cartographer"] = "Kartograf"
L["Discover 100 places."] = "Entdecke 100 Orte."
L["Wanderer"] = "Wanderer"
L["Visit 5 regions."] = "Bereise 5 Gebiete."
L["Pathfinder"] = "Pfadfinder"
L["Walk 50 kilometres."] = "Lege 50 Kilometer zu Fuß zurück."
L["Globetrotter"] = "Weltenbummler"
L["Walk 250 kilometres."] = "Lege 250 Kilometer zu Fuß zurück."
L["Frequent Flyer"] = "Vielflieger"
L["Take 10 flights."] = "Unternimm 10 Flüge."
L["Into the Depths"] = "In die Tiefe"
L["Enter a dungeon."] = "Betritt einen Dungeon."
L["Treasure Hunter"] = "Schatzsucher"
L["Find 5 rare items."] = "Finde 5 seltene Gegenstände."
L["Thrifty"] = "Sparsam"
L["Own 10 gold."] = "Besitze 10 Gold."
L["Wealthy"] = "Wohlhabend"
L["Own 100 gold."] = "Besitze 100 Gold."
L["Sociable"] = "Gesellig"
L["Meet 25 people."] = "Triff 25 Personen."
L["Fellowship"] = "Gemeinschaft"
L["Group with 5 other adventurers."] = "Sei mit 5 verschiedenen Abenteurern in einer Gruppe."
L["Untouchable"] = "Unantastbar"
L["Play 5 days in a row without dying."] = "Spiele 5 Tage am Stück, ohne zu sterben."
L["Seasoned"] = "Erfahren"
L["Reach level 20."] = "Erreiche Stufe 20."
L["Veteran"] = "Veteran"
L["Reach level 40."] = "Erreiche Stufe 40."
L["Champion"] = "Champion"
L["Reach level 60."] = "Erreiche Stufe 60."
L["Faithful Chronicler"] = "Treuer Chronist"
L["Keep this diary for 30 days."] = "Führe dieses Tagebuch 30 Tage lang."
L["Bouncy"] = "Springinsfeld"
L["Jump 1000 times."] = "Springe 1000-mal."

-- keepsake captions
L["Level up"] = "Stufenaufstieg"
L["Epic find"] = "Epischer Fund"
L["Rare find"] = "Seltener Fund"
L["Death"] = "Tod"
L["New land"] = "Neues Land"
L["Dungeon"] = "Dungeon"
L["Quest"] = "Quest"
L["Wealth"] = "Vermögen"
L["Skill"] = "Fertigkeit"
L["Hunt"] = "Jagd"
L["Moment"] = "Moment"

-- book of honour: tiers, categories, secrets, landmarks
L["Combat"] = "Kampf"
L["Exploration"] = "Entdeckung"
L["Encounters"] = "Begegnungen"
L["Adventure"] = "Abenteuer"
L["Fortune and craft"] = "Glück und Handwerk"
L["Curiosities"] = "Kuriositäten"
L["Honour points"] = "Ehrenpunkte"
L["Almost there"] = "Fast geschafft"
L["Complete!"] = "Vollendet!"
L["A secret honour. Keep exploring!"] = "Noch geheim. Such weiter!"
L["%d tiers earned"] = "%d Stufen errungen"
L["Honour earned: %s"] = "Ehre errungen: %s"
L["Honour earned: %s (%s)"] = "Ehre errungen: %s (%s)"
L["Landmark discovered: %s"] = "Sehenswürdigkeit entdeckt: %s"
L["Landmarks"] = "Sehenswürdigkeiten"
L["%d of %d landmarks found"] = "%d von %d Sehenswürdigkeiten gefunden"
L["This game client knows none of the landmarks."] = "Dieser Spielclient kennt keine der Sehenswürdigkeiten."
L["Honour"] = "Ehre"
L["Landmark"] = "Sehenswürdigkeit"
L["Capitals"] = "Hauptstädte"
L["Towns of the Eastern Kingdoms"] = "Orte der Östlichen Königreiche"
L["Towns of Kalimdor"] = "Orte Kalimdors"
L["Dungeons"] = "Dungeons"
L["Raids"] = "Schlachtzüge"
L["Elite Slayer"] = "Elitejäger"
L["Bloodbath"] = "Blutbad"
L["Sightseer"] = "Ausflügler"
L["Capital Tourist"] = "Hauptstadttourist"
L["Wings of the World"] = "Schwingen der Welt"
L["Haggler"] = "Feilscher"
L["Eager Student"] = "Wissbegierig"
L["Barterer"] = "Tauschhändler"
L["Busy Bee"] = "Fleißiges Bienchen"
L["Devoted"] = "Hingebungsvoll"
L["Phoenix"] = "Phönix"
L["Epic Fortune"] = "Episches Glück"
L["Hoarder"] = "Hamsterer"
L["Master of a Craft"] = "Meister eines Handwerks"
L["Night Owl"] = "Nachteule"
L["Early Bird"] = "Frühaufsteher"
L["Regular"] = "Stammgast"
L["Homesick"] = "Heimweh"
L["Bad Day"] = "Rabenschwarzer Tag"
L["Marathon"] = "Marathon"
L["Well Rested"] = "Ausgeschlafen"
L["Globetrotter's Day"] = "Weltenbummlertag"
L["Slay %d creatures."] = "Erschlage %d Kreaturen."
L["Slay %d of a single kind."] = "Erschlage %d Kreaturen derselben Art."
L["Defeat %d bosses."] = "Besiege %d Bosse."
L["Slay %d rare creatures."] = "Erlege %d seltene Kreaturen."
L["Slay %d elite creatures."] = "Erschlage %d Elitekreaturen."
L["Slay %d creatures in a single day."] = "Erschlage %d Kreaturen an einem einzigen Tag."
L["Play %d days in a row without dying."] = "Spiele %d Tage am Stück, ohne zu sterben."
L["Visit %d regions."] = "Besuche %d Regionen."
L["Discover %d places."] = "Entdecke %d Orte."
L["Find %d landmarks."] = "Finde %d Sehenswürdigkeiten."
L["Visit %d capital cities."] = "Besuche %d Hauptstädte."
L["Enter %d dungeons."] = "Betritt %d Dungeons."
L["Walk %d kilometres."] = "Wandere %d Kilometer."
L["Take %d flights."] = "Unternimm %d Flüge."
L["Meet %d flight masters."] = "Lerne %d Flugmeister kennen."
L["Meet %d people."] = "Triff %d Personen."
L["Group with %d other adventurers."] = "Sei mit %d verschiedenen Abenteurern in einer Gruppe."
L["Do business with %d merchants."] = "Mach mit %d Händlern Geschäfte."
L["Visit %d trainers."] = "Besuche %d Lehrer."
L["Trade with %d players."] = "Handle mit %d Spielern."
L["Complete %d quests."] = "Schließe %d Quests ab."
L["Complete %d quests in a single day."] = "Schließe %d Quests an einem einzigen Tag ab."
L["Reach level %d."] = "Erreiche Stufe %d."
L["Keep this diary for %d days."] = "Führe dieses Tagebuch %d Tage lang."
L["Spend %d hours in the world."] = "Verbringe %d Stunden in der Welt."
L["Die %d times and rise again."] = "Stirb %d-mal und steh jedes Mal wieder auf."
L["Own %d gold."] = "Besitze %d Gold."
L["Find %d rare items."] = "Finde %d seltene Gegenstände."
L["Find %d epic items."] = "Finde %d epische Gegenstände."
L["Loot %d items."] = "Plündere %d Gegenstände."
L["Raise a skill to %d."] = "Bring eine Fertigkeit auf %d."
L["Jump %d times."] = "Springe %d-mal."
L["Be on the road between midnight and four o'clock."] = "Sei zwischen Mitternacht und vier Uhr unterwegs."
L["Be on the road before seven in the morning."] = "Sei vor sieben Uhr morgens unterwegs."
L["Talk to the same person %d times."] = "Sprich %d-mal mit derselben Person."
L["Use your hearthstone %d times."] = "Benutze deinen Ruhestein %d-mal."
L["Die %d times in a single day."] = "Stirb %d-mal an einem einzigen Tag."
L["Spend %d hours in the world on a single day."] = "Verbringe an einem einzigen Tag %d Stunden in der Welt."
L["Rest at %d places."] = "Raste an %d Orten."
L["Visit %d regions in a single day."] = "Besuche %d Regionen an einem einzigen Tag."
L["Up, up and away ..."] = "Hoch hinaus ..."
L["When the moon stands highest ..."] = "Wenn der Mond am höchsten steht ..."
L["The early bird catches the worm ..."] = "Der frühe Vogel fängt den Wurm ..."
L["A familiar face ..."] = "Ein vertrautes Gesicht ..."
L["There is no place like home ..."] = "Daheim ist es doch am schönsten ..."
L["Not every day is a good day ..."] = "Nicht jeder Tag ist ein guter Tag ..."
L["Just one more quest ..."] = "Nur noch eine Quest ..."
L["Every journey needs a pause ..."] = "Jede Reise braucht eine Pause ..."
L["So many roads, so little time ..."] = "So viele Wege, so wenig Zeit ..."

-- ledger, quest book, collection, atlas
L["done"] = "erledigt"
L["open"] = "offen"
L["given up"] = "abgebrochen"
L["The purse over the days"] = "Der Geldbeutel im Lauf der Tage"
L["Collection"] = "Sammelalbum"
L["What is left to discover"] = "Was es noch zu entdecken gibt"
L["%d honour points"] = "%d Ehrenpunkte"
L["Famous places of Azeroth"] = "Berühmte Orte Azeroths"
L["Atlas"] = "Atlas"
L["Regions explored"] = "Erkundete Regionen"
L["Next rank: %s"] = "Nächster Rang: %s"
L["Dark places, rich rewards"] = "Finstere Orte, reiche Beute"
L["Secrets"] = "Geheimnisse"
L["Some honours stay hidden until you find them."] = "Manche Ehren bleiben verborgen, bis du sie findest."
L["Click to open this part of the book."] = "Klicken, um diesen Teil des Buches aufzuschlagen."
L["Next goals"] = "Nächste Ziele"
L["Where will the road lead tomorrow?"] = "Wohin führt der Weg morgen?"
L["Destination of the day"] = "Reiseziel des Tages"
L["You have not seen this place yet."] = "Diesen Ort hast du noch nicht gesehen."
L["Click for all landmarks."] = "Klicken für alle Sehenswürdigkeiten."
L["You have seen every landmark. Remarkable!"] = "Du hast wirklich alles gesehen. Respekt!"
L["Unexplored regions"] = "Unerforschte Regionen"
L["Every region of this continent is explored."] = "Jede Region dieses Kontinents ist erkundet."
L["%d of %d regions explored"] = "%d von %d Regionen erkundet"
L["Not yet explored"] = "Noch nicht erkundet"
L["Explored"] = "Erkundet"
L["Mouse wheel: zoom  -  drag: move  -  right click: reset"] = "Mausrad: zoomen  -  ziehen: verschieben  -  Rechtsklick: zurücksetzen"
L["Explorer's checklist"] = "Entdecker-Checkliste"
L["Click for the map of this region."] = "Klicken für die Karte dieser Region."

-- people register, companions
L["People met"] = "Bekanntschaften"
L["kills"] = "Kills"
L["days"] = "Tage"

-- treasure album, wanted posters
L["WANTED"] = "GESUCHT"
L["of %d kinds"] = "von %d Arten"
L["Next mark: %d slain"] = "Nächste Marke: %d erlegt"
L["Every mark reached"] = "Alle Marken erreicht"
L["Uncommon"] = "Ungewöhnlich"
L["Epic"] = "Episch"
L["Legendary"] = "Legendär"

-- tasks of the day, pop-ups, week in review
L["Slay %d creatures today."] = "Erlege heute %d Kreaturen."
L["Complete %d quests today."] = "Schließe heute %d Quests ab."
L["Meet %d new people."] = "Lerne %d neue Leute kennen."
L["Discover %d new places."] = "Entdecke %d neue Orte."
L["Walk %d kilometres today."] = "Wandere heute %d Kilometer."
L["Find an uncommon or better item."] = "Finde einen grünen Gegenstand oder etwas Besseres."
L["Visit the landmark %s."] = "Besuche die Sehenswürdigkeit %s."
L["Set foot in %s."] = "Betritt %s."
L["Task of the day done: %s"] = "Tagesaufgabe erfüllt: %s"
L["All tasks of the day done! %d days in a row."] = "Alle Tagesaufgaben erfüllt! %d Tage in Folge."
L["All tasks of the day done!"] = "Alle Tagesaufgaben erfüllt!"
L["Tasks of the day"] = "Aufgaben des Tages"
L["Task of the day"] = "Tagesaufgabe"
L["Dungeon Crawler"] = "Dungeonläufer"
L["Finish %d dungeon runs."] = "Schließe %d Dungeondurchläufe ab."
L["Diligent"] = "Fleißig"
L["Do all tasks of the day on %d days."] = "Erfülle an %d Tagen alle Tagesaufgaben."
L["Dutiful"] = "Pflichtbewusst"
L["Do all tasks of the day %d days in a row."] = "Erfülle %d Tage in Folge alle Tagesaufgaben."
L["Open the diary"] = "Tagebuch aufschlagen"
L["Close"] = "Schließen"
L["The week in review"] = "Wochenrückblick"
L["Creatures slain"] = "Kreaturen erlegt"
L["Levels"] = "Stufen"
L["Kilometres"] = "Kilometer"
L["New places"] = "Neue Orte"
L["New regions"] = "Neue Regionen"
L["Honours"] = "Ehren"
L["Best day"] = "Bester Tag"
L["A quiet week"] = "Eine ruhige Woche"
L["The book waits for new stories."] = "Das Buch wartet auf neue Geschichten."
L["Show a note for new discoveries"] = "Hinweis bei neuen Entdeckungen zeigen"
L["Weekly look back at login"] = "Wochenrückblick beim Einloggen"

-- records, level timeline, gallery, nemeses, dungeon reports
L["Records"] = "Rekordbuch"
L["The best and the worst of days"] = "Die besten und die schlimmsten Tage"
L["Most creatures slain in a day"] = "Meiste Kills an einem Tag"
L["Most quests in a day"] = "Meiste Quests an einem Tag"
L["Richest day"] = "Einträglichster Tag"
L["Most experience in a day"] = "Meiste Erfahrung an einem Tag"
L["Longest day in the world"] = "Längster Spieltag"
L["Longest walk in a day"] = "Weiteste Wanderung an einem Tag"
L["Most places discovered in a day"] = "Meiste neue Orte an einem Tag"
L["Most new faces in a day"] = "Meiste neue Gesichter an einem Tag"
L["Fastest level"] = "Schnellste Stufe"
L["Slowest level"] = "Langsamste Stufe"
L["Longest run without dying"] = "Längste Zeit ohne Tod"
L["Darkest day"] = "Schwärzester Tag"
L["Level timeline"] = "Stufen-Zeitstrahl"
L["How long each level took"] = "Wie lange jede Stufe gedauert hat"
L["Played for these levels"] = "Spielzeit dafür"
L["Per level"] = "Pro Stufe"
L["No level-ups recorded yet."] = "Noch kein Stufenaufstieg aufgezeichnet."
L["Still on the way."] = "Noch unterwegs."
L["Reached the next level on day %d."] = "Nächste Stufe an Tag %d erreicht."
L["Gallery"] = "Galerie"
L["Moments, painted in the gear of their day"] = "Große Momente, gemalt in der Ausrüstung von damals"
L["The first painting waits for your first great moment."] = "Das erste Gemälde wartet auf deinen ersten großen Moment."
L["Nemeses"] = "Erzfeinde"
L["They sent me to the spirit healer"] = "Sie schickten mich zum Geistheiler"
L["Nemesis number one"] = "Erzfeind Nummer eins"
L["Nobody has defeated you yet. Long may it last!"] = "Noch hat dich niemand erwischt. Hoffentlich bleibt das so!"
L["Killed you %d times"] = "Hat dich %d-mal getötet"
L["Revenge taken"] = "Rache vollzogen"
L["Score unsettled"] = "Rechnung offen"
L["You slew them %d times."] = "Du hast sie %d-mal erschlagen."
L["Dungeon reports"] = "Dungeon-Berichte"
L["No dungeon visited yet. The depths are waiting."] = "Noch keinen Dungeon von innen gesehen. Die Tiefen warten."
L["Duration"] = "Dauer"
L["Fallen"] = "Gefallen"
L["The group"] = "Die Gruppe"
L["Me"] = "Ich"
L["Nobody fell."] = "Niemand ist gefallen."

-- blocked functions
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "Dieser Spielclient erlaubt Addons keine Bildschirmfotos. Fotos bei Meilensteinen sind jetzt abgeschaltet."
L["The game blocked the function %s. Please tell the author."] = "Das Spiel hat die Funktion %s gesperrt. Sag dem Autor bitte Bescheid."

-- achievement pop-up
L["Honour earned"] = "Ehre errungen"
L["Landmark discovered"] = "Sehenswürdigkeit entdeckt"
L["Next tier:"] = "Nächste Stufe:"
L["Every tier earned - complete!"] = "Alle Stufen geschafft!"

-- ledger figures
L["Best day: day %d"] = "Bester Tag: Tag %d"
L["Worst day: day %d"] = "Schlechtester Tag: Tag %d"
L["Per day"] = "Pro Tag"

-- durations
L["%dh %02dm"] = "%d Std. %02d Min."
L["%dm"] = "%d Min."

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "Erste Male"
L["First time"] = "Erstes Mal"
L["%d of %d experienced"] = "%d von %d erlebt"
L["Not yet experienced."] = "Noch nicht erlebt."
L["Click for all first times."] = "Klicken für alle ersten Male."
L["First creature slain"] = "Erste erlegte Kreatur"
L["First quest completed"] = "Erste erledigte Quest"
L["First level up"] = "Erster Stufenaufstieg"
L["First uncommon item"] = "Erster grüner Gegenstand"
L["First death"] = "Erster Tod"
L["First group"] = "Erste Gruppe"
L["First elite slain"] = "Erster Elitegegner"
L["First trade"] = "Erster Handel"
L["First hearthstone"] = "Erster Ruhestein"
L["First landmark"] = "Erste Sehenswürdigkeit"
L["First honour"] = "Erste Ehre"
L["First rare item"] = "Erster blauer Gegenstand"
L["First rare creature"] = "Erste seltene Kreatur"
L["First flight"] = "Erster Flug"
L["First gold coin"] = "Erste Goldmünze"
L["First dungeon"] = "Erster Dungeon"
L["First boss"] = "Erster Boss"
L["First skill at 75"] = "Erste Fertigkeit auf 75"
L["First mount"] = "Erstes Reittier"
L["First epic item"] = "Erster epischer Gegenstand"

L["Family book"] = "Familienbuch"
L["%d characters on this account"] = "%d Charaktere auf diesem Account"
L["you"] = "du"
L["Last seen %s"] = "Zuletzt gesehen am %s"
L["Who got there first?"] = "Wer war zuerst da?"
L["Log in with your other characters once, and they will appear here."] = "Logg dich einmal mit deinen anderen Charakteren ein, dann tauchen sie hier auf."

L["Time capsule"] = "Zeitkapsel"
L["Letters to my future self"] = "Briefe an mein zukünftiges Ich"
L["Dear me, when you read this ..."] = "Liebes Ich, wenn du das hier liest ..."
L["Seal the letter and open it ..."] = "Brief versiegeln und öffnen ..."
L["in a week"] = "in einer Woche"
L["in a month"] = "in einem Monat"
L["at level %d"] = "auf Stufe %d"
L["Until then the letter stays sealed - not even you can read it."] = "Bis dahin bleibt der Brief zu - nicht mal du kannst ihn lesen."
L["No letters yet."] = "Noch keine Briefe."
L["Written on day %d, at level %d"] = "Geschrieben an Tag %d, auf Stufe %d"
L["Opened on %s"] = "Geöffnet am %s"
L["Sealed - opens on day %d"] = "Versiegelt - geht an Tag %d auf"
L["Sealed - opens at level %d"] = "Versiegelt - geht auf Stufe %d auf"
L["in %d days"] = "in %d Tagen"
L["A letter for later was sealed."] = "Einen Brief für später versiegelt."
L["A letter from the past has opened."] = "Ein Brief aus der Vergangenheit ist aufgegangen."
L["Click to read the letter."] = "Klicken, um den Brief zu lesen."

L["Gatherer's map"] = "Fundorte"
L["Where the good things grow"] = "Wo die guten Sachen wachsen"
L["Herbalism"] = "Kräuterkunde"
L["Mining"] = "Bergbau"
L["Skinning"] = "Kürschnerei"
L["Fishing"] = "Angeln"
L["Most found here"] = "Hier am häufigsten gefunden"
L["Nothing gathered yet. Herbs, ore and hides show up here as soon as you gather them."] = "Noch nichts gesammelt. Kräuter, Erz und Felle tauchen hier auf, sobald du sie sammelst."

L["Task of the week"] = "Wochenaufgabe"
L["Task of the week done: %s"] = "Wochenaufgabe erfüllt: %s"
L["Click for the next goals."] = "Klicken für die nächsten Ziele."
L["Slay %d creatures this week."] = "Erlege diese Woche %d Kreaturen."
L["Complete %d quests this week."] = "Schließe diese Woche %d Quests ab."
L["Walk %d kilometres this week."] = "Wandere diese Woche %d Kilometer."
L["Meet %d new people this week."] = "Lerne diese Woche %d neue Leute kennen."
L["Visit %d different regions this week."] = "Besuche diese Woche %d verschiedene Regionen."
L["Earn %d honour tiers this week."] = "Erringe diese Woche %d Ehrenstufen."
L["Finish a dungeon run this week."] = "Bring diese Woche einen Dungeon zu Ende."
L["Find %d new landmarks this week."] = "Finde diese Woche %d neue Sehenswürdigkeiten."
L["Week by Week"] = "Woche für Woche"
L["Complete %d tasks of the week."] = "Erfülle %d Wochenaufgaben."

L["Search the diary"] = "Tagebuch durchsuchen"
L["Days, people, creatures, quests and places."] = "Tage, Personen, Kreaturen, Quests und Orte."
L["Search: a name, a quest, a place ..."] = "Suche: ein Name, eine Quest, ein Ort ..."
L["Nothing found."] = "Nichts gefunden."
L["%d more results - type a little more"] = "%d weitere Treffer - tipp noch etwas mehr"

L["The binding"] = "Der Einband"
L["Corner studs"] = "Eckbeschläge"
L["none yet"] = "noch keine"
L["Next metal at %d honour points (now %d)."] = "Nächstes Metall ab %d Ehrenpunkten (jetzt %d)."
L["Gems"] = "Edelsteine"
L["One gem for every ten honour tiers (now %d)."] = "Ein Edelstein für je zehn Ehrenstufen (jetzt %d)."
L["Gold marks on the spine"] = "Goldprägungen am Rücken"
L["One for every ten levels."] = "Eine für je zehn Stufen."

-- the bookplate on the endpaper
L["FROM THE LIBRARY OF"] = "AUS DER BIBLIOTHEK VON"

-- sayings of the day (start page)
L["SAYING OF THE DAY"] = "SPRUCH DES TAGES"
L["Whoever wanders, gathers stories."] = "Wer wandert, sammelt Geschichten."
L["Every road starts at your own door."] = "Jeder Weg beginnt vor der eigenen Tür."
L["A full pack is light when the heart is lighter."] = "Ein voller Rucksack ist leicht, wenn das Herz noch leichter ist."
L["Maps show the way - only feet know it."] = "Karten zeigen den Weg - kennen tun ihn nur die Füße."
L["The longest journey is the one you never write down."] = "Die längste Reise ist die, die man nie aufschreibt."
L["Ink fades slower than memory."] = "Tinte verblasst langsamer als Erinnerung."
L["A good campfire turns strangers into companions."] = "Ein gutes Lagerfeuer macht aus Fremden Gefährten."
L["The mountain does not care how tired you are - just keep going."] = "Dem Berg ist egal, wie müde du bist - Hauptsache, du gehst weiter."
L["Today's detour is tomorrow's best story."] = "Der Umweg von heute ist die beste Geschichte von morgen."
L["Gold comes and goes, the story stays."] = "Gold kommt und geht, die Geschichte bleibt."
L["Count the days by friends, not by miles."] = "Zähl die Tage nach Freunden, nicht nach Meilen."
L["Even the smallest kobold guards a candle for someone."] = "Auch der kleinste Kobold hütet für irgendwen eine Kerze."
L["Resting is part of the road."] = "Rasten gehört zum Weg."
L["Fear is a map with too many blank spots."] = "Angst ist eine Karte mit zu vielen weißen Flecken."
L["Every scar has a page in this book."] = "Jede Narbe hat eine Seite in diesem Buch."
L["Look back now and then - the view is part of the journey."] = "Schau ab und zu zurück - die Aussicht gehört zur Reise."
L["The wise traveller asks the innkeeper first."] = "Der kluge Reisende fragt zuerst den Wirt."
L["Rain on the road, sunshine in the story."] = "Regen auf dem Weg, Sonne in der Geschichte."
L["Whoever never falls never learns to get up."] = "Wer nie fällt, lernt nie aufzustehen."
L["A quest half done is still a step forward."] = "Eine halbe Quest ist immer noch ein Schritt nach vorn."
L["The horizon travels with you - that is why it never gets dull."] = "Der Horizont wandert mit - darum wird es nie langweilig."
L["Write it down, or it never happened."] = "Schreib es auf, sonst ist es nie passiert."
L["Old boots know more than new maps."] = "Alte Stiefel wissen mehr als neue Karten."
L["Courage is being afraid and saddling up anyway."] = "Mut heißt, Angst zu haben und trotzdem aufzusatteln."
L["Tomorrow the road will still be there. Tonight the fire is warm."] = "Morgen ist der Weg noch da. Heute Nacht ist das Feuer warm."
L["A traveller's purse is light, a traveller's diary is heavy."] = "Leicht ist der Beutel des Reisenden, schwer sein Tagebuch."
L["The best places are on no map."] = "Die schönsten Orte stehen auf keiner Karte."
L["Every hero once did not know the way."] = "Jeder Held kannte einmal den Weg nicht."
L["Share your bread, and the road shares its secrets."] = "Teil dein Brot, und der Weg teilt seine Geheimnisse."
L["The story is not over while a page is still blank."] = "Die Geschichte ist nicht zu Ende, solange noch eine Seite leer ist."

-- covered cards in the bestiary: kinds your other characters know
L["Not yet discovered"] = "Noch nicht entdeckt"
L["Known to %s"] = "%s kennt diese Kreatur schon"
L["%d to discover"] = "%d zu entdecken"
L["in the east"] = "im Osten"
L["in the south-east"] = "im Südosten"
L["in the south"] = "im Süden"
L["in the south-west"] = "im Südwesten"
L["in the west"] = "im Westen"
L["in the north-west"] = "im Nordwesten"
L["in the north"] = "im Norden"
L["in the north-east"] = "im Nordosten"
L["in the middle"] = "in der Mitte"
L["To the contents"] = "Zum Inhaltsverzeichnis"
L["Screenshots at milestones: on"] = "Screenshots bei Meilensteinen: an"
L["Screenshots at milestones: off"] = "Screenshots bei Meilensteinen: aus"
L["Demo mode is off."] = "Demo-Modus ist aus."
L["Demo mode is on. Nothing you do now is written into your diary - type /wfd demo again to leave."] = "Demo-Modus ist an. Was du jetzt tust, landet nicht in deinem Tagebuch - mit /wfd demo kommst du wieder heraus."
L["You have died, but who did it slipped past the diary."] = "Gestorben bist du schon, aber wer es war, ist dem Tagebuch entgangen."
L["Already in the quest log"] = "Vor dem Tagebuch angenommen"
L["Angler"] = "Angler"
L["Raise Fishing to %d."] = "Bring Angeln auf %d."
L["Big Catch"] = "Petri Heil"
L["Catch %d fish."] = "Fang %d Fische."
L["Field Medic"] = "Feldsanitäter"
L["Raise First Aid to %d."] = "Bring Erste Hilfe auf %d."
L["Camp Cook"] = "Lagerkoch"
L["Raise Cooking to %d."] = "Bring Kochkunst auf %d."
L["Sighted, not yet slain"] = "Gesichtet, noch nicht erlegt"
L["perhaps %s"] = "vielleicht %s"
L["You have been %s of this area least of all. Something may still be waiting there."] = "Am seltensten warst du hier %s unterwegs. Vielleicht wartet dort noch etwas."
L["Defeat a boss."] = "Besiege einen Boss."
L["Slay a rare creature."] = "Erlege eine seltene Kreatur."
L["Slay an elite creature."] = "Erlege eine Elite-Kreatur."
L["Visit a capital city."] = "Besuche eine Hauptstadt."
L["Enter a dungeon."] = "Betritt einen Dungeon."
L["Take a flight."] = "Nimm einen Flug."
L["Group with another adventurer."] = "Geh mit jemandem in eine Gruppe."
L["Visit a trainer."] = "Besuche einen Lehrer."
L["Trade with another player."] = "Handle mit einem Spieler."
L["Complete a quest."] = "Schließe eine Quest ab."
L["Die once and rise again."] = "Stirb einmal und steh wieder auf."
L["Finish a dungeon run."] = "Schließe einen Dungeondurchlauf ab."
L["Do all tasks of the day on one day."] = "Erfülle an einem Tag alle Tagesaufgaben."
L["Complete a task of the week."] = "Erfülle eine Wochenaufgabe."
L["Find a rare item."] = "Finde einen seltenen Gegenstand."
L["Find an epic item."] = "Finde einen epischen Gegenstand."
L["Dear me, if you are reading this, you made it through the first week. Did you ever find out who was stealing the candles in the mine?"] = "Liebes Ich, wenn du das liest, hast du die erste Woche überstanden. Hast du je herausgefunden, wer die Kerzen in der Mine gestohlen hat?"
L["Marker set on the map: %s (%d, %d)"] = "Markierung auf der Karte gesetzt: %s (%d, %d)"
L["No marker can be set on this map."] = "Auf dieser Karte lässt sich keine Markierung setzen."
L["Click to set a marker on the map."] = "Klicken, um eine Markierung auf der Karte zu setzen."
L["Right-click for the map of this region."] = "Rechtsklick für die Karte dieser Region."
L["1 kind"] = "1 Art"
L["Discover a new place."] = "Entdecke einen neuen Ort."
L["Walk one kilometre today."] = "Lauf heute einen Kilometer."
L["WELCOME"] = "WILLKOMMEN"
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "Spiel einfach los, ich schreibe mit. Aus jedem Tag, den du spielst, wird eine Seite in diesem Buch."
L["See a sample book"] = "Beispielbuch ansehen"
L["To today's entry"] = "Zum heutigen Tag"
L["Discover %d flight paths."] = "Entdecke %d Flugrouten."
L["A sketch - %d more and it is in colour."] = "Eine Skizze - noch %d, dann ist sie farbig."
L["%d more to become a connoisseur."] = "Noch %d, dann bist du Kenner."
L["Connoisseur of this kind"] = "Kenner dieser Art"
L["First slain on day %d"] = "Zuerst erlegt an Tag %d"
L["Best loot"] = "Beste Beute"
L["Got you once."] = "Hat dich einmal erwischt."
L["Got you %d times."] = "Hat dich %d-mal erwischt."
L["CONNOISSEUR"] = "KENNER"
L["Connoisseur"] = "Kenner"
L["Right-click to close."] = "Rechtsklick schließt."
L["The tabs"] = "Die Reiter"
L["The tabs on the right lead to the parts of the book, one colour for each group. Point at them to read their names. A red dot shows how much is new since you last read."] = "Die Reiter rechts führen zu den Teilen des Buches, jede Gruppe in ihrer eigenen Farbe. Zeig mit der Maus darauf, dann stehen ihre Namen daneben. Ein roter Punkt zeigt, wie viel neu ist, seit du zuletzt gelesen hast."
L["The spyglass on the spine searches the whole book: days, people, creatures, quests, places, treasures and catches. Ctrl + F opens it too."] = "Die Lupe am Buchrücken durchsucht das ganze Buch: Tage, Personen, Kreaturen, Quests, Orte, Schätze und Fänge. Strg + F öffnet sie auch."
L["Your own bookmarks"] = "Eigene Lesezeichen"
L["Ctrl-click a page number to keep that page. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away."] = "Strg-Klick auf eine Seitenzahl merkt dir die Seite. Oben aus dem Buch ragt dann ein Bändchen: Ein Klick schlägt die Seite auf, ein Rechtsklick nimmt das Bändchen wieder weg."
L["Ctrl + click on the page number"] = "Strg + Klick auf die Seitenzahl"
L["bookmark"] = "Lesezeichen"
L["Goals and honour"] = "Ziele & Ruhm"
L["The world"] = "Die Welt"
L["Hunt and loot"] = "Jagd & Beute"
L["People and household"] = "Menschen & Haushalt"
L["Keepsakes"] = "Andenken"
L["Best find for every slot"] = "Bester Fund für jeden Platz"
L["worn right now"] = "gerade angelegt"
L["Click to show only these."] = "Klicken zeigt nur diese."
L["Click to show all again."] = "Klicken zeigt wieder alle."
L["Shown: %s only"] = "Gezeigt: nur %s"
L["Show all"] = "Alle zeigen"
L["Ctrl-click to set or remove a bookmark here."] = "Strg-Klick setzt hier ein Lesezeichen oder nimmt es weg."
L["Click to open, right-click to remove."] = "Klicken schlägt auf, Rechtsklick entfernt."
L["You are here."] = "Du bist hier."
L["Click for the hunting grounds of this area."] = "Klicken für die Jagdgründe dieses Gebiets."
L["Who is closest to the next stage"] = "Wer als Nächstes eine Stufe aufsteigt"
L["%d more, then in colour"] = "noch %d, dann in Farbe"
L["%d more, then a connoisseur"] = "noch %d, dann Kenner"
L["To the album of this area"] = "Zum Album dieses Gebiets"
L["Every kind known here is collected."] = "Jede hier bekannte Art ist gesammelt."
L["Kinds of creatures"] = "Kreaturentypen"
L["Who fell to your blade, by kind"] = "Wer deiner Klinge erlag, nach Art"
L["Unknown kind"] = "Unbekannte Art"
L["%d kinds  -  %d slain"] = "%d Arten  -  %d erlegt"
L["Hunting grounds"] = "Jagdgründe"
L["Sighted"] = "Gesichtet"
L["Kinds slain here"] = "Hier erlegte Arten"
L["Each pin marks where the first of its kind fell."] = "Jede Nadel zeigt, wo das erste Tier seiner Art fiel."
L["Versatile Hunter"] = "Vielseitiger Jäger"
L["Slay creatures of %d different types."] = "Erlege Kreaturen von %d verschiedenen Typen."
L["Slay 50 of each of %d kinds."] = "Erlege von %d Arten je 50."
L["Slay 50 of one kind."] = "Erlege 50 einer Art."
L["Quick on its feet, but it never looks back."] = "Flink auf den Beinen, aber es schaut nie zurück."
L["Its pelt would fetch a fair price in town."] = "Sein Fell brächte in der Stadt einen guten Preis."
L["Talks big, fights small."] = "Große Klappe, wenig dahinter."
L["Carried more coins than sense."] = "Hatte mehr Münzen als Verstand dabei."
L["Smells worse than it fights."] = "Riecht schlimmer, als es kämpft."
L["Dead once already. Twice is a habit."] = "Schon einmal tot gewesen. Zweimal ist Gewohnheit."
L["Burning eyes, burning temper."] = "Glühende Augen, glühendes Gemüt."
L["Whoever summoned this one owes me an apology."] = "Wer den beschworen hat, schuldet mir eine Entschuldigung."
L["Not alive, not dead - simply angry."] = "Nicht lebendig, nicht tot - einfach wütend."
L["Left nothing behind but a puddle of fury."] = "Hinterließ nichts als eine Pfütze voller Zorn."
L["Scales like armour. Mind the tail."] = "Schuppen wie eine Rüstung. Vorsicht vor dem Schwanz."
L["One day I will face its big brothers."] = "Eines Tages stelle ich mich seinen großen Brüdern."
L["The ground shook long after it fell."] = "Der Boden bebte noch lange, nachdem er gefallen war."
L["Big enough to have its own weather."] = "Groß genug für ein eigenes Wetter."
L["Gnomish work, no doubt. Loud and leaky."] = "Gnomenarbeit, ohne Zweifel. Laut und undicht."
L["It sparked, it whirred, it stopped."] = "Es funkte, es surrte, es blieb stehen."
L["It never stood a chance."] = "Es hatte nie eine Chance."
L["Small, harmless and now a footnote."] = "Klein, harmlos und jetzt eine Fußnote."
L["A strange creature. I made a note, just in case."] = "Ein seltsames Wesen. Ich habe es mir notiert, nur für den Fall."
L["Worth remembering, or at least worth writing down."] = "Einer Erinnerung wert, oder wenigstens einer Notiz."
L["Back"] = "Zurück"
L["To the page you came from (Backspace)."] = "Zur Seite, von der du kamst (Rücktaste)."
L["Go to page (1 - %d):"] = "Gehe zu Seite (1 - %d):"
L["Size: %d%%"] = "Größe: %d%%"
L["The bookmarks"] = "Die Lesezeichen"
L["The bookmarks on the right lead to the parts of the book. A red dot shows how much is new since you last read."] = "Die Lesezeichen rechts führen zu den Teilen des Buches. Ein roter Punkt zeigt, wie viel seit dem letzten Lesen neu ist."
L["Search"] = "Suche"
L["The spyglass on the spine searches the whole book: days, people, creatures, quests and places."] = "Das Fernrohr am Buchrücken durchsucht das ganze Buch: Tage, Leute, Kreaturen, Quests und Orte."
L["Turning pages"] = "Blättern"
L["Turn the pages with the arrows, the mouse wheel or the arrow keys. The red ribbon below always leads to today; Backspace takes you back. Ctrl + mouse wheel changes the size of the book."] = "Blättere mit den Pfeilen, dem Mausrad oder den Pfeiltasten. Das rote Bändchen unten führt immer zum heutigen Tag, die Rücktaste bringt dich zurück. Strg + Mausrad ändert die Größe des Buches."
L["Almost everything can be clicked"] = "Fast alles ist anklickbar"
L["Cards, names, days and maps open more. Right-click the page number to go to any page. The settings are in the scribe's notes at the very end."] = "Karten, Namen, Tage und Landkarten öffnen mehr. Ein Rechtsklick auf die Seitenzahl springt zu jeder Seite. Die Einstellungen stehen ganz hinten bei den Notizen des Schreibers."
L["Next"] = "Weiter"
L["Skip"] = "Überspringen"
L["Got it"] = "Verstanden"
L["Handling"] = "Bedienung"
L["Keys and comfort"] = "Tasten und Komfort"
L["Notifications"] = "Meldungen"
L["Important only"] = "Nur Wichtiges"
L["Quiet"] = "Still"
L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] = "Wichtig: Stufen, Bosse, seltene Kreaturen und Funde, Dungeons, Ehren und Briefe."
L["Keys while the mouse is over the book"] = "Tasten, solange die Maus über dem Buch ist"
L["Arrow keys, Page up / down"] = "Pfeiltasten, Bild auf / ab"
L["turn the page"] = "blättern"
L["Home"] = "Pos1"
L["contents"] = "Inhaltsverzeichnis"
L["End"] = "Ende"
L["today's entry"] = "heutiger Tag"
L["Backspace"] = "Rücktaste"
L["back"] = "zurück"
L["Ctrl + mouse wheel"] = "Strg + Mausrad"
L["size of the book"] = "Buchgröße"
L["Ctrl + F"] = "Strg + F"
L["search the book"] = "im Buch suchen"
L["Right-click the page number"] = "Rechtsklick auf die Seitenzahl"
L["go to a page"] = "zu einer Seite springen"
L["open or close the book"] = "Buch öffnen oder schließen"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "Eine Taste zum Öffnen des Buches kannst du in der Tastaturbelegung des Spiels unter AddOns festlegen."
L["The book"] = "Das Buch"
L["Reset the position"] = "Position zurücksetzen"
L["Show the introduction again"] = "Einführung erneut zeigen"
L["Open the scribe's notes"] = "Notizen des Schreibers öffnen"
L["Right-click to go to a page."] = "Rechtsklick, um zu einer Seite zu springen."
L["%d new since you last read"] = "%d neu seit dem letzten Lesen"
L["Right-click for the settings."] = "Rechtsklick für die Einstellungen."
L["Drag to move this button."] = "Ziehen, um diesen Knopf zu verschieben."
L["Click to open."] = "Klicken zum Öffnen."
L["Moving code"] = "Umzugs-Code"
L["This code holds the whole diary of this character. Copy it with Ctrl+C and keep it somewhere safe, for example in a text file. On the other computer, open the same window with \"Read a moving code\" and paste it there."] = "Dieser Code enthält das ganze Tagebuch dieses Charakters. Kopiere ihn mit Strg+C und bewahre ihn sicher auf, zum Beispiel in einer Textdatei. Auf dem anderen PC öffnest du mit „Umzugs-Code einlesen“ das passende Fenster und fügst ihn dort ein."
L["The code could not be made."] = "Der Code konnte nicht erstellt werden."
L["%d days, %d characters. Now press Ctrl+C."] = "%d Tage, %d Zeichen. Jetzt Strg+C drücken."
L["Read a moving code"] = "Umzugs-Code einlesen"
L["Paste the moving code of this character with Ctrl+V. The diary written on this computer is then replaced by the one from the code, and the interface is reloaded."] = "Füge den Umzugs-Code dieses Charakters mit Strg+V ein. Das Tagebuch auf diesem PC wird dann durch das aus dem Code ersetzt und die Oberfläche neu geladen."
L["Waiting for a code ..."] = "Warte auf einen Code ..."
L["Replace the diary and reload"] = "Tagebuch ersetzen und neu laden"
L["This is not a moving code of the diary."] = "Das ist kein Umzugs-Code des Tagebuchs."
L["The code is damaged or incomplete. Copy it again, all of it."] = "Der Code ist beschädigt oder unvollständig. Kopiere ihn noch einmal, und zwar ganz."
L["Diary of %s (%s), %d days, %d kinds of creatures, %d people."] = "Tagebuch von %s (%s), %d Tage, %d Kreaturenarten, %d Leute."
L["Careful: this code belongs to %s, but you are playing %s."] = "Achtung: Dieser Code gehört zu %s, du spielst aber %s."
L["The diary of this character on this computer will be replaced."] = "Das Tagebuch dieses Charakters auf diesem PC wird ersetzt."
L["Leave demo mode first."] = "Verlasse zuerst den Demo-Modus."
L["moving code of this character"] = "Umzugs-Code dieses Charakters"
L["read a moving code"] = "Umzugs-Code einlesen"
L["Moving to another computer"] = "Umzug auf einen anderen PC"
L["Make a moving code"] = "Umzugs-Code erstellen"
L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."] = "Oder nimm einfach den Ordner WTF aus dem Spielordner mit: Darin stecken die Tagebücher aller Charaktere."
L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."] = "Ein kleines Fenster mit den Zahlen von heute, den Aufgaben und den Ehren, die ihrer nächsten Stufe am nächsten sind. Am Titel verschieben, mit dem Minus einklappen."
L["Appearance"] = "Aussehen"
L["Both reload the interface. With bigger writing a few long lines may run close together."] = "Beides lädt die Oberfläche neu. Mit größerer Schrift können einzelne lange Zeilen eng zusammenrücken."
L["Click to open the diary there."] = "Klicken, um das Tagebuch dort aufzuschlagen."
L["Companion"] = "Begleiter"
L["Fold in or out"] = "Ein- oder ausklappen"
L["How the book looks"] = "Wie das Buch aussieht"
L["Leather and gold"] = "Leder und Gold"
L["Leather and gold is the old book. Modern is flat and calm, strong contrast makes all writing brighter."] = "Leder und Gold ist das bisherige Buch. Modern ist schlicht und ruhig, starker Kontrast macht alle Schrift heller."
L["Modern"] = "Modern"
L["Next honours"] = "Nächste Ehren"
L["Online"] = "Online"
L["Show the companion beside the game"] = "Begleitfenster neben dem Spiel zeigen"
L["Size of the writing"] = "Schriftgröße"
L["Strong contrast"] = "Starker Kontrast"
L["Style of the book"] = "Stil des Buches"
L["The companion can be shown again in the settings or with /wfd companion."] = "Das Begleitfenster lässt sich in den Einstellungen oder mit /wfd companion wieder einblenden."
L["Turn the leaves visibly"] = "Seiten sichtbar umblättern"
L["Turning the pages"] = "Blättern"
L["km"] = "km"
L["reloads the interface"] = "lädt die Oberfläche neu"
L["show or hide the companion"] = "Begleitfenster ein- oder ausblenden"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "Das vorhandene Tagebuch gehörte einem früheren Charakter mit demselben Namen. Es wurde beiseitegelegt und für dich ein neues begonnen. |cffffd100/wfd restore|r holt es zurück."
L["bring back the diary put aside"] = "das beiseitegelegte Tagebuch zurückholen"
L["No diary has been put aside."] = "Es wurde kein Tagebuch beiseitegelegt."
L["The diary put aside is back. The interface is reloaded."] = "Das beiseitegelegte Tagebuch ist zurück. Die Oberfläche wird neu geladen."

-- Angler's log
L["Angler's log"] = "Anglerbuch"
L["A collector's album of everything the line brought up"] = "Ein Sammelalbum von allem, was die Angel heraufgeholt hat"
L["catches collected  -  %d things landed"] = "Fänge gesammelt  -  %d Dinge an Land gezogen"
L["Land %d different catches."] = "Zieh %d verschiedene Fänge an Land."
L["Casts"] = "Würfe"
L["Fish"] = "Fisch"
L["Treasure"] = "Schatz"
L["Junk"] = "Plunder"
L["Odds and ends"] = "Allerlei"
L["1 catch"] = "1 Fang"
L["%d catches"] = "%d Fänge"
L["Nothing has bitten yet."] = "Noch hat nichts angebissen."
L["Waters and tackle"] = "Gewässer und Angelzeug"
L["Where it bites, and what you fished with"] = "Wo es beißt, und womit du geangelt hast"
L["Waters"] = "Gewässer"
L["%d caught in %d casts"] = "%d gefangen in %d Würfen"
L["Tackle"] = "Angelzeug"
L["%d casts"] = "%d Würfe"
L["No fishing pole seen yet."] = "Noch keine Angelrute gesehen."
L["Casts with a lure"] = "Würfe mit Köder"
L["Casts in all"] = "Würfe insgesamt"
L["CAUGHT"] = "GEFANGEN"
L["Mostly caught in"] = "Meist gefangen in"
L["Caught"] = "Gefangen"
L["Of all catches"] = "Aller Fänge"
L["First catch"] = "Erster Fang"
L["Last catch"] = "Letzter Fang"
L["On a lure"] = "Mit Köder"
L["WHERE IT BIT"] = "WO ES ANBISS"
L["Next mark: %d caught"] = "Nächste Marke: %d gefangen"
L["New catch: %s"] = "Neuer Fang: %s"
L["Catch"] = "Fang"
L["Fish Lore"] = "Fischkunde"
L["Fishing pole"] = "Angelrute"
L["Lure"] = "Köder"
L["Fishing gear"] = "Angelkleidung"
