-- French translation (English phrases are the keys)
local ADDON, WFD = ...
local L, loc = WFD:NewLocale("frFR")

local T = {
    -- chat / log
    ["Diary"] = "Carnet",
    ["Travel diary active. Today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
        "Carnet de voyage actif. Aujourd'hui, c'est le |cffffd100jour %d|r. |cffffd100/wfd|r ouvre le carnet.",
    ["%d creatures slain in total"] = "%d créatures tuées au total",
    ["First victory over the boss %s!"] = "Première victoire sur le boss %s !",
    ["Rare creature slain: %s"] = "Créature rare tuée : %s",
    ["Boss %s defeated again (%dx)"] = "Boss %s vaincu à nouveau (%dx)",
    ["Died to %s in %s"] = "Mort face à %s (%s)",
    ["Died in %s"] = "Mort (%s)",
    ["Met %s (%s)"] = "Rencontre : %s (%s)",
    ["Hearthstone bound to %s"] = "Pierre de foyer liée à : %s",
    ["Quest accepted: %s"] = "Quête acceptée : %s",
    ["Quest abandoned: %s"] = "Quête abandonnée : %s",
    ["Quest completed: %s"] = "Quête terminée : %s",
    ["First quest completed: %s"] = "Première quête terminée : %s",
    ["%d quests completed"] = "%d quêtes terminées",
    ["Took a flight to %s"] = "Vol vers : %s",
    ["Wealth reached: %s"] = "Fortune atteinte : %s",
    ["Found %s"] = "Trouvé : %s",
    ["Epic find: %s"] = "Trouvaille épique : %s",
    ["Rare find: %s"] = "Trouvaille rare : %s",
    ["Discovered a new land: %s"] = "Nouvelle terre découverte : %s",
    ["Entered %s"] = "Arrivée : %s",
    ["Discovered: %s (%s)"] = "Découvert : %s (%s)",
    ["First visit to the dungeon %s"] = "Première visite du donjon : %s",
    ["Entered the dungeon %s"] = "Entrée dans le donjon : %s",
    ["Level %d reached!"] = "Niveau %d atteint !",
    ["%s increased to %d"] = "%s passe à %d",
    ["%s mastered up to %d"] = "%s maîtrisé jusqu'à %d",
    ["Used the hearthstone"] = "Pierre de foyer utilisée",
    ["%dh %02dm"] = "%d h %02d min",
    ["%dm"] = "%d min",

    -- window
    ["Travel Diary of %s"] = "Carnet de voyage de %s",
    ["Day %d"] = "Jour %d",
    ["Level %d"] = "Niveau %d",
    ["Level %s"] = "Niveau %s",
    ["online"] = "en ligne",
    ["Screenshot:"] = "Capture d'écran :",
    ["Click to read this day."] = "Cliquez pour lire ce jour.",
    ["Click to open the diary."] = "Cliquez pour ouvrir le carnet.",
    ["%d kills today"] = "%d {victime|victimes} aujourd'hui",
    ["%d quests today"] = "%d {quête|quêtes} aujourd'hui",
    ["DEMO MODE: invented data"] = "MODE DÉMO : données inventées",

    -- tabs
    ["Bestiary"] = "Bestiaire",
    ["People"] = "Personnages",
    ["Quest Book"] = "Livre de quêtes",

    -- journal
    ["Today"] = "Aujourd'hui",
    ["Chronicle"] = "Chronique",
    ["Enemies slain"] = "Ennemis tués",
    ["Quests completed"] = "Quêtes terminées",
    ["People spoken to"] = "Personnes rencontrées",
    ["Distance travelled"] = "Distance parcourue",
    ["flown"] = "en vol",
    ["Time online"] = "Temps en ligne",
    ["Deaths"] = "Morts",
    ["Income"] = "Recettes",
    ["Expenses"] = "Dépenses",
    ["Net"] = "Solde",
    ["Fallen foes"] = "Ennemis vaincus",
    ["Loot"] = "Butin",

    -- map
    ["Kills"] = "Victimes",
    ["Quests"] = "Quêtes",
    ["No map art available for this area."] = "Aucune carte disponible pour cette zone.",
    ["Play"] = "Lecture",
    ["Spoken to %d times"] = "%d {conversation|conversations}",
    ["You died here"] = "Lieu de votre mort",
    ["Killed by %s"] = "Victime de %s",
    ["No travels recorded yet."] = "Aucun voyage consigné pour l'instant.",

    -- bestiary
    ["Boss"] = "Boss",
    ["Rare"] = "Rare",
    ["Elite"] = "Élite",
    ["Normal"] = "Normal",
    ["No portrait"] = "Pas de portrait",
    ["KILLS PER DAY"] = "VICTIMES PAR JOUR",

    -- people
    ["First met"] = "Première rencontre",
    ["Show on map"] = "Afficher sur la carte",
    ["QUESTS WITH THIS PERSON"] = "QUÊTES AVEC CE PERSONNAGE",
    ["No quests recorded."] = "Aucune quête consignée.",
    ["All"] = "Tous",
    ["You have not talked to anyone yet."] = "Vous n'avez encore parlé à personne.",
    ["Conversation"] = "Conversation",
    ["Vendor"] = "Marchand",
    ["Trainer"] = "Maître",
    ["Flight master"] = "Maître de vol",
    ["Banker"] = "Banquier",
    ["Stable master"] = "Maître des écuries",
    ["Petitions"] = "Chartes",
    ["Auctioneer"] = "Commissaire-priseur",

    -- quests
    ["No quests recorded yet."] = "Aucune quête consignée pour l'instant.",

    -- statistics
    ["Gold"] = "Or",
    ["In total: %d kills  |  %d quests  |  %s online  |  %.1f km on foot  |  %d deaths  |  %d jumps"] =
        "Au total : %d victimes  |  %d quêtes  |  %s en ligne  |  %.1f km à pied  |  %d morts  |  %d sauts",

    -- money categories
    ["Quest rewards"] = "Récompenses de quête",
    ["Vendor sales"] = "Ventes aux marchands",
    ["Mail"] = "Courrier",
    ["Trading"] = "Échanges",
    ["Auction house"] = "Hôtel des ventes",
    ["Repairs"] = "Réparations",
    ["Purchases"] = "Achats",
    ["Training"] = "Apprentissage",
    ["Flights"] = "Vols",
    ["Bank"] = "Banque",
    ["Other"] = "Divers",

    -- export / settings
    ["Born:"] = "Naissance :",
    ["Select all"] = "Tout sélectionner",
    ["Ctrl+C copies the selection."] = "Ctrl+C copie la sélection.",
    ["Take a screenshot at milestones"] = "Capture d'écran aux étapes clés",
    ["Show minimap button"] = "Afficher le bouton de la minicarte",

    -- redesigned interface
    ["Travel Diary"] = "Carnet de voyage",
    ["Experience"] = "Expérience",
    ["Conversations"] = "Conversations",
    ["On foot"] = "À pied",
    ["Map of my travels"] = "Carte de mes voyages",
    ["No creature has fallen yet."] = "Aucune créature n'est encore tombée.",
    ["Slain"] = "Abattus",
    ["First kill"] = "Première victoire",
    ["Last kill"] = "Dernière victoire",
    ["Seen in"] = "Zone",
    ["Killed you"] = "Vous a tué",
    ["Found in"] = "Zone",
    ["Place"] = "Lieu",
    ["Last met"] = "Dernière rencontre",
    ["Received from"] = "Reçue de",
    ["Took"] = "Durée",
    ["Came from"] = "Provenance",
    ["Went to"] = "Destination",
    ["Transcript"] = "Transcription",
    ["Settings"] = "Paramètres",
    ["Size of the book"] = "Taille du livre",
    ["Demo"] = "Démo",
    ["Start demo mode"] = "Lancer le mode démo",
    ["Leave demo mode"] = "Quitter le mode démo",
    ["open or close the diary"] = "ouvrir ou fermer le carnet",
    ["explore with invented data"] = "explorer avec des données inventées",
    ["screenshots on or off"] = "activer ou désactiver les captures",
    ["minimap button on or off"] = "afficher ou masquer le bouton de minicarte",
}
for k, v in pairs(T) do L[k] = v end

-- dates and diary entries
loc.date = "%d/%m/%Y"
loc.decimal = ","
loc.thousands = " "
loc.listAnd = " et "
loc.dayMonth = "%d/%m"
loc.weekdays = { "dimanche", "lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi" }
loc.months = { "janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre" }
function loc.longDate(d)
    local wd = loc.weekdays[d.wday]
    return string.format("%s%s %d %s %d", wd:sub(1, 1):upper(), wd:sub(2), d.day, loc.months[d.month], d.year)
end
loc.quotes = { "« ", " »" }

loc.narrator = {
    birth = {
        "Jour 1. %s, %s. Point de départ : %s. La suite ? Aucune idée.",
        "Jour 1. Je suis %s et %s, et tout commence ici : %s. On verra bien où ça mène.",
    },
    begin = {
        "Jour 1. À partir d'aujourd'hui, je note tout ce qui m'arrive en route.",
    },
    open = {
        "Jour %d, %s.",
        "Jour %d. Aujourd'hui, c'était au tour de %s.",
        "Jour %d. De nouveau sur la route, surtout du côté de %s.",
    },
    far = "contrées inconnues",
    walk = {
        "Environ %s kilomètres à pied%s.",
        "Mes pieds disent : à peu près %s kilomètres%s.",
        "Pas loin de %s kilomètres de marche%s, et mes jambes le sentent.",
    },
    via = " (%s)",
    fly = " Le reste du trajet, je l'ai fait en vol.",
    kills = {
        "J'ai vaincu {un ennemi|%d ennemis}.",
        "J'ai abattu %d {créature|créatures}.",
        "{Un ennemi|%d ennemis} de moins sur cette terre.",
    },
    top = {
        "La plupart : %s (%dx).",
        "%s m'a barré la route plus que les autres (%dx).",
    },
    special = "À retenir : %s.",
    deaths = {
        "J'ai mordu la poussière {une fois|%d fois}.%s",
        "Petit détour chez l'esprit guérisseur : {une fois|%d fois}.%s",
    },
    deathBy = " La dernière fois, c'était la faute de %s.",
    noDeath = {
        "Pas une seule mort aujourd'hui.",
        "Zéro mort aujourd'hui. Pas mal.",
    },
    questDone = {
        "{Une quête terminée|%d quêtes terminées} : %s.",
        "Rayé de ma liste : %s.",
    },
    questAcc = {
        "Et {une nouvelle est arrivée|%d nouvelles sont arrivées}.",
        "Et déjà, {une nouvelle tâche m'attend|%d nouvelles tâches m'attendent}.",
    },
    questAccOnly = {
        "{Une nouvelle tâche acceptée, pas encore terminée.|%d nouvelles tâches acceptées, aucune terminée pour l'instant.}",
    },
    more = "et quelques autres",
    quote = {
        "%s m'a dit : %s",
        "Selon %s : %s",
    },
    quoteAnon = "Une phrase m'est restée : %s",
    npcs = {
        "{Je n'ai parlé qu'à %s.|J'ai parlé à %d personnes, dont %s.}",
        "{Une conversation, avec %s.|%d conversations, par exemple avec %s.}",
    },
    gain = {
        "Ma bourse s'est alourdie de %s.",
        "Au final, %s de plus en poche.",
    },
    loss = {
        "Ma bourse s'est allégée de %s.",
        "Au final, la journée m'a coûté %s.",
    },
    src = " L'essentiel des gains : %s (%s).",
    spent = " La plus grosse dépense : %s (%s).",
    item = {
        "Meilleure trouvaille : %s.",
        "Trouvaille du jour : %s.",
    },
    levels = {
        "Niveau %s, c'est fait.",
        "Passage au niveau %s.",
        "Et puis : niveau %s !",
    },
    quiet = {
        "Journée calme. Pas grand-chose à raconter.",
        "Il ne s'est pas passé grand-chose aujourd'hui.",
    },
    begun = {
        "La journée vient à peine de commencer.",
        "La journée est encore jeune.",
        "La nouvelle journée ne fait que commencer.",
    },
    ongoing = {
        "La journée n'est pas encore finie.",
        "À suivre …",
        "Voyons ce que la journée nous réserve encore.",
    },
    close = {
        "Fin de la journée.",
        "Assez pour aujourd'hui. On continue demain.",
        "Une petite pause s'impose.",
        "On verra ce que demain apporte.",
    },
    closeLong = {
        "%s sur la route. Ça suffira.",
        "Après %s, je suis sur les rotules.",
        "En tout, %s sur pied. La suite demain.",
    },
    none = "Aucune entrée pour ce jour.",
}

-- book interface
L["Appendix"] = "Annexe"
L["Begun on %s"] = "Commencé le %s"
L["Bookmark"] = "Marque-page"
L["Click to open today's entry."] = "Cliquez pour ouvrir l'entrée du jour."
L["Click to open"] = "Cliquez pour ouvrir"
L["Contents"] = "Sommaire"
L["Notes"] = "Notes"
L["Page %d"] = "Page %d"
L["Realm: %s"] = "Royaume : %s"
L["This book belongs to"] = "Ce livre appartient à"
L["in %s, at level %d"] = "%s, au niveau %d"
L["in %s, on the first day of my life"] = "%s, au premier jour de ma vie"
L["of"] = "de"

-- book pages (diary, appendix)
L["Arrival in %s"] = "Arrivée : %s"
L["Days in %s"] = "Les jours de %s"
L["Shadows over %s"] = "Ombres sur %s"
L["The roads of %s"] = "Les routes de %s"
L["Under the skies of %s"] = "Sous le ciel de %s"
L["Awakening in %s"] = "Éveil : %s"
L["Return to %s"] = "Retour : %s"
L["Chapter"] = "Chapitre"
L["Level %d-%d"] = "Niveau %d-%d"
L["Days %d-%d"] = "Jours %d-%d"
L["Level %d!"] = "Niveau %d !"
L["%d kills"] = "%d {victime|victimes}"
L["%d quests"] = "%d {quête|quêtes}"
L["died %dx"] = "%d {mort|morts}"
L["Kept as a memory"] = "Gardé en souvenir"
L["The pages are still empty. Go and live an adventure!"] = "Les pages sont encore vierges. En route pour l'aventure !"
L["p. %d"] = "p. %d"
L["Milestones"] = "Étapes clés"
L["The great moments of a life"] = "Les grands moments d'une vie"
L["No milestones yet."] = "Aucune étape clé pour l'instant."
L["Maps"] = "Cartes"
L["%s spent here"] = "%s passés ici"
L["Route"] = "Itinéraire"
L["Kill sites"] = "Lieux de combat"
L["First visit"] = "Première visite"
L["Time spent"] = "Temps passé"
L["Acquaintances here"] = "Connaissances ici"
L["Slain %d times"] = "Vaincue %d fois"
L["Everyone I met on my way"] = "Tous ceux que j'ai croisés en chemin"
L["Every coin, in and out"] = "Chaque pièce, en recette et en dépense"
L["Balance"] = "Solde"
L["Day"] = "Jour"
L["Tasks taken and done"] = "Tâches acceptées et accomplies"
L["How this book is kept"] = "Comment ce livre est tenu"
L["Copy the diary as text"] = "Copier le carnet en texte"
L["Copy the diary as JSON"] = "Copier le carnet en JSON"
L["Ledger"] = "Livre de comptes"

-- own notes
L["Click here to write your own notes ..."] = "Cliquez ici pour écrire vos propres notes …"
L["My own thoughts:"] = "Mes propres pensées :"
L["+ note"] = "+ note"
L["edit note"] = "modifier la note"
L["Save"] = "Enregistrer"
L["Cancel"] = "Annuler"

-- cards
L["Acquaintance"] = "Connaissance"
L["Click for the wanted poster."] = "Cliquez pour l'avis de recherche."
L["Click for the portrait."] = "Cliquez pour le portrait."

-- collector's album
L["A collector's album of every creature slain"] = "Un album de collection de toutes les créatures vaincues"
L["kinds collected, %d creatures slain"] = "espèces collectées, %d créatures tuées"
L["Bronze"] = "Bronze"
L["Silver"] = "Argent"
L["Mithril"] = "Mithril"
L["Legend"] = "Légende"
L["Collect %d kinds of creatures."] = "Collectionnez %d espèces de créatures."
L["Reached!"] = "Atteint !"
L["%d still missing."] = "Il en manque encore %d."
L["Bosses"] = "Boss"
L["Rare creatures"] = "Créatures rares"
L["Album pages"] = "Pages de l'album"
L["%d kinds"] = "%d espèces"
L["Lv %s"] = "Niv. %s"
L["NEW"] = "NOUV."
L["not yet found"] = "pas encore trouvée"

-- language switch
L["German"] = "Allemand"
L["English"] = "Anglais"
L["French"] = "Français"
L["Spanish"] = "Espagnol"
L["Portuguese"] = "Portugais"
L["Russian"] = "Russe"
L["Korean"] = "Coréen"
L["Chinese (traditional)"] = "Chinois (traditionnel)"
L["Language"] = "Langue"
L["Game language (%s)"] = "Langue du jeu (%s)"
L["The diary will reload the interface to switch the language."] = "Le carnet va recharger l'interface pour changer de langue."
L["Korean and Chinese text needs a game client with those fonts."] = "Le coréen et le chinois nécessitent un client de jeu disposant de ces polices."

-- map spreads
L["Places of note"] = "Lieux remarquables"
L["Nobody was met here yet."] = "Vous n'avez encore rencontré personne ici."
L["Grave"] = "Tombe"
L["Chronicle of the region"] = "Chronique de la région"
L["Visits"] = "Visites"
L["Deaths here"] = "Morts ici"
L["Most hunted here"] = "Proies favorites ici"
L["Places discovered"] = "Lieux découverts"

-- companions, honours, treasures, memories, obituary
L["%d days of life, %d creatures slain, %d quests completed"] = "%d {jour|jours} de vie, %d {créature tuée|créatures tuées}, %d {quête terminée|quêtes terminées}"
L["%d days"] = "%d {jour|jours}"
L["%d enemies fell that day."] = "%d {ennemi tomba|ennemis tombèrent} ce jour-là."
L["%d kills together"] = "%d {victime|victimes} ensemble"
L["%d of %d honour tiers reached"] = "%d paliers sur %d atteints"
L["%d times grouped"] = "%d fois en groupe"
L["%d treasures collected"] = "%d {trésor collecté|trésors collectés}"
L["%dx traded"] = "%d échanges"
L["A painted memory"] = "Un souvenir peint"
L["Book of honour"] = "Livre d'honneur"
L["Companions"] = "Compagnons"
L["Copy for forum or Discord (Markdown)"] = "Copier pour un forum ou Discord (Markdown)"
L["Quickest to the level"] = "Le plus rapide au niveau"
L["Fell in %s"] = "Lieu de la chute : %s"
L["Slain by %s"] = "Victime de %s"
L["Fellow adventurers"] = "Compagnons d'aventure"
L["Fellowship"] = "Communauté"
L["Grouped with %s"] = "En groupe avec %s"
L["In memoriam"] = "In memoriam"
L["No trades yet."] = "Aucun échange pour l'instant."
L["No treasures found yet."] = "Aucun trésor trouvé pour l'instant."
L["Rested here"] = "Halte ici"
L["Times rested here"] = "Haltes ici"
L["The last moment"] = "Le dernier instant"
L["Today, %d days ago"] = "Il y a %d jours, jour pour jour"
L["Trading partners"] = "Partenaires d'échange"
L["Treasures"] = "Trésors"
L["Who walked beside me"] = "Ceux qui ont marché à mes côtés"
L["You have not grouped with anyone yet."] = "Vous n'avez encore fait équipe avec personne."
L["I was in %s."] = "J'étais ici : %s."
L["early in the morning"] = "tôt le matin"
L["in the morning"] = "dans la matinée"
L["around noon"] = "vers midi"
L["in the afternoon"] = "dans l'après-midi"
L["in the evening"] = "dans la soirée"
L["late at night"] = "tard dans la nuit"
L["earned"] = "obtenu"
L["first met %s"] = "première rencontre le %s"

-- honours
L["Slayer"] = "Pourfendeur"
L["Specialist"] = "Spécialiste"
L["Naturalist"] = "Naturaliste"
L["Rare Hunter"] = "Chasseur de raretés"
L["Giant Slayer"] = "Tueur de géants"
L["Into the Depths"] = "Vers les profondeurs"
L["Hunter"] = "Chasseur"
L["Helping Hand"] = "Main secourable"
L["Explorer"] = "Explorateur"
L["Wanderer"] = "Vagabond"
L["Pathfinder"] = "Éclaireur"
L["Frequent Flyer"] = "Habitué des airs"
L["Thrifty"] = "Économe"
L["Seasoned"] = "Aguerri"
L["Untouchable"] = "Intouchable"
L["Faithful Chronicler"] = "Chroniqueur fidèle"
L["Sociable"] = "Sociable"
L["Bouncy"] = "Sauteur"
L["Treasure Hunter"] = "Chasseur de trésors"

-- keepsake captions
L["Level up"] = "Niveau"
L["Epic find"] = "Trouvaille épique"
L["Rare find"] = "Trouvaille rare"
L["Death"] = "Mort"
L["New land"] = "Nouvelle terre"
L["Dungeon"] = "Donjon"
L["Quest"] = "Quête"
L["Wealth"] = "Fortune"
L["Skill"] = "Métier"
L["Hunt"] = "Chasse"
L["Moment"] = "Moment"

-- honour tiers, atlas, landmarks, secrets
L["%d honour points"] = "%d points d'honneur"
L["%d of %d landmarks found"] = "%d curiosités trouvées sur %d"
L["%d of %d regions explored"] = "%d régions explorées sur %d"
L["%d tiers earned"] = "%d {palier obtenu|paliers obtenus}"
L["A familiar face ..."] = "Un visage familier …"
L["A secret honour. Keep exploring!"] = "Un honneur secret. Continuez d'explorer !"
L["Adventure"] = "Aventure"
L["Almost there"] = "Presque !"
L["Atlas"] = "Atlas"
L["Bad Day"] = "Jour noir"
L["Barterer"] = "Troqueur"
L["Be on the road before seven in the morning."] = "Soyez en route avant sept heures du matin."
L["Be on the road between midnight and four o'clock."] = "Soyez en route entre minuit et quatre heures."
L["Bloodbath"] = "Bain de sang"
L["Busy Bee"] = "Abeille travailleuse"
L["Capital Tourist"] = "Touriste des capitales"
L["Capitals"] = "Capitales"
L["Click for all landmarks."] = "Cliquez pour voir toutes les curiosités."
L["Click for the map of this region."] = "Cliquez pour la carte de cette région."
L["Click to open this part of the book."] = "Cliquez pour ouvrir cette partie du livre."
L["Collection"] = "Collection"
L["Combat"] = "Combat"
L["Complete %d quests in a single day."] = "Terminez %d quêtes en une seule journée."
L["Complete %d quests."] = "Terminez %d quêtes."
L["Complete!"] = "Achevé !"
L["Curiosities"] = "Curiosités"
L["Dark places, rich rewards"] = "Lieux sombres, riches butins"
L["Defeat %d bosses."] = "Vainquez %d boss."
L["Destination of the day"] = "Destination du jour"
L["Devoted"] = "Dévoué"
L["Die %d times and rise again."] = "Mourez %d fois et relevez-vous."
L["Die %d times in a single day."] = "Mourez %d fois en une seule journée."
L["Discover %d places."] = "Découvrez %d lieux."
L["Do business with %d merchants."] = "Commercez avec %d marchands."
L["Dungeons"] = "Donjons"
L["Eager Student"] = "Élève assidu"
L["Early Bird"] = "Lève-tôt"
L["Elite Slayer"] = "Tueur d'élites"
L["Encounters"] = "Rencontres"
L["Enter %d dungeons."] = "Entrez dans %d donjons."
L["Epic Fortune"] = "Chance épique"
L["Every journey needs a pause ..."] = "Tout voyage a besoin d'une pause …"
L["Every region of this continent is explored."] = "Toutes les régions de ce continent sont explorées."
L["Exploration"] = "Exploration"
L["Explored"] = "Explorée"
L["Explorer's checklist"] = "Liste de l'explorateur"
L["Famous places of Azeroth"] = "Lieux célèbres d'Azeroth"
L["Find %d epic items."] = "Trouvez %d objets épiques."
L["Find %d landmarks."] = "Trouvez %d curiosités."
L["Find %d rare items."] = "Trouvez %d objets rares."
L["Fortune and craft"] = "Fortune et artisanat"
L["Globetrotter's Day"] = "Journée globe-trotter"
L["Group with %d other adventurers."] = "Groupez-vous avec %d autres aventuriers."
L["Haggler"] = "Marchandeur"
L["Hoarder"] = "Amasseur"
L["Homesick"] = "Mal du pays"
L["Honour earned: %s (%s)"] = "Honneur obtenu : %s (%s)"
L["Honour earned: %s"] = "Honneur obtenu : %s"
L["Honour points"] = "Points d'honneur"
L["Honour"] = "Honneur"
L["Jump %d times."] = "Sautez %d fois."
L["Just one more quest ..."] = "Encore une petite quête …"
L["Keep this diary for %d days."] = "Tenez ce carnet pendant %d jours."
L["Landmark discovered: %s"] = "Curiosité découverte : %s"
L["Landmark"] = "Curiosité"
L["Landmarks"] = "Curiosités"
L["Loot %d items."] = "Ramassez %d objets."
L["Marathon"] = "Marathon"
L["Master of a Craft"] = "Maître artisan"
L["Meet %d people."] = "Rencontrez %d personnes."
L["Mouse wheel: zoom, drag: move, right click: reset"] = "Molette : zoom, glisser : déplacer, clic droit : réinitialiser"
L["Next goals"] = "Prochains objectifs"
L["Next rank: %s"] = "Rang suivant : %s"
L["Night Owl"] = "Oiseau de nuit"
L["Not every day is a good day ..."] = "Tous les jours ne sont pas de bons jours …"
L["Not yet explored"] = "Pas encore explorée"
L["Own %d gold."] = "Possédez %d pièces d'or."
L["People met"] = "Rencontres"
L["Phoenix"] = "Phénix"
L["Play %d days in a row without dying."] = "Jouez %d jours d'affilée sans mourir."
L["Raids"] = "Raids"
L["Raise a skill to %d."] = "Montez un métier à %d."
L["Reach level %d."] = "Atteignez le niveau %d."
L["Regions explored"] = "Régions explorées"
L["Regular"] = "Habitué"
L["Rest at %d places."] = "Faites halte en %d lieux."
L["Secrets"] = "Secrets"
L["Sightseer"] = "Badaud"
L["Slay %d creatures in a single day."] = "Tuez %d créatures en une seule journée."
L["Slay %d creatures."] = "Tuez %d créatures."
L["Slay %d elite creatures."] = "Tuez %d créatures d'élite."
L["Slay %d of a single kind."] = "Tuez %d créatures d'une même espèce."
L["Slay %d rare creatures."] = "Tuez %d créatures rares."
L["So many roads, so little time ..."] = "Tant de routes, si peu de temps …"
L["Some honours stay hidden until you find them."] = "Certains honneurs restent cachés jusqu'à ce que vous les trouviez."
L["Spend %d hours in the world on a single day."] = "Passez %d heures dans le monde en une seule journée."
L["Spend %d hours in the world."] = "Passez %d heures dans le monde."
L["Take %d flights."] = "Effectuez %d vols."
L["Talk to the same person %d times."] = "Parlez %d fois à la même personne."
L["The early bird catches the worm ..."] = "Le monde appartient à ceux qui se lèvent tôt …"
L["The purse over the days"] = "La bourse au fil des jours"
L["There is no place like home ..."] = "On n'est jamais mieux que chez soi …"
L["This game client knows none of the landmarks."] = "Ce client de jeu ne connaît aucune des curiosités."
L["Towns of Kalimdor"] = "Lieux de Kalimdor"
L["Towns of the Eastern Kingdoms"] = "Lieux des royaumes de l'Est"
L["Trade with %d players."] = "Échangez avec %d joueurs."
L["Unexplored regions"] = "Régions inexplorées"
L["Up, up and away ..."] = "Toujours plus haut …"
L["Use your hearthstone %d times."] = "Utilisez votre pierre de foyer %d fois."
L["Visit %d capital cities."] = "Visitez %d capitales."
L["Visit %d regions in a single day."] = "Visitez %d régions en une seule journée."
L["Visit %d regions."] = "Visitez %d régions."
L["Visit %d trainers."] = "Rendez visite à %d maîtres."
L["Walk %d kilometres."] = "Parcourez %d kilomètres à pied."
L["Well Rested"] = "Bien reposé"
L["What is left to discover"] = "Ce qu'il reste à découvrir"
L["When the moon stands highest ..."] = "Quand la lune est au plus haut …"
L["Where will the road lead tomorrow?"] = "Où la route mènera-t-elle demain ?"
L["Wings of the World"] = "Ailes du monde"
L["You have not seen this place yet."] = "Vous n'avez pas encore vu ce lieu."
L["You have seen every landmark. Remarkable!"] = "Vous avez vu toutes les curiosités. Remarquable !"
L["days"] = "jours"
L["done"] = "terminées"
L["given up"] = "abandonnées"
L["kills"] = "victimes"
L["open"] = "en cours"

-- treasure album, wanted posters
L["WANTED"] = "RECHERCHÉ"
L["of %d kinds"] = "sur %d espèces"
L["Next mark: %d slain"] = "Prochain palier : %d tués"
L["Every mark reached"] = "Tous les paliers atteints"
L["Uncommon"] = "Inhabituel"
L["Epic"] = "Épique"
L["Legendary"] = "Légendaire"

-- tasks of the day, pop-ups, week in review
L["Slay %d creatures today."] = "Tuez %d créatures aujourd'hui."
L["Complete %d quests today."] = "Terminez %d quêtes aujourd'hui."
L["Meet %d new people."] = "Rencontrez %d nouvelles personnes."
L["Discover %d new places."] = "Découvrez %d nouveaux lieux."
L["Walk %d kilometres today."] = "Parcourez %d kilomètres à pied aujourd'hui."
L["Find an uncommon or better item."] = "Trouvez un objet inhabituel ou mieux."
L["Visit the landmark %s."] = "Visitez la curiosité %s."
L["Set foot in %s."] = "Rendez-vous dans la zone %s."
L["Task of the day done: %s"] = "Tâche du jour accomplie : %s"
L["All tasks of the day done! %d days in a row."] = "Toutes les tâches du jour accomplies ! %d jours d'affilée."
L["All tasks of the day done!"] = "Toutes les tâches du jour accomplies !"
L["Tasks of the day"] = "Tâches du jour"
L["Task of the day"] = "Tâche du jour"
L["Dungeon Crawler"] = "Explorateur de donjons"
L["Finish %d dungeon runs."] = "Terminez %d expéditions en donjon."
L["Diligent"] = "Appliqué"
L["Do all tasks of the day on %d days."] = "Accomplissez toutes les tâches du jour sur %d jours."
L["Dutiful"] = "Consciencieux"
L["Do all tasks of the day %d days in a row."] = "Accomplissez toutes les tâches du jour %d jours d'affilée."
L["Open the diary"] = "Ouvrir le carnet"
L["Close"] = "Fermer"
L["The week in review"] = "La semaine en revue"
L["Creatures slain"] = "Créatures tuées"
L["Levels"] = "Niveaux"
L["Kilometres"] = "Kilomètres"
L["New places"] = "Nouveaux lieux"
L["New regions"] = "Nouvelles régions"
L["Honours"] = "Honneurs"
L["Best day"] = "Meilleur jour"
L["A quiet week"] = "Une semaine calme"
L["The book waits for new stories."] = "Le carnet attend de nouvelles histoires."
L["Show a note for new discoveries"] = "Signaler les nouvelles découvertes"
L["Weekly look back at login"] = "Bilan de la semaine à la connexion"
L["Show when an item was first found in its tooltip"] = "Indiquer dans l'infobulle quand l'objet a été trouvé pour la première fois"
L["In the diary: first found on %s"] = "Dans le journal : trouvé pour la première fois le %s"
L["from %s"] = "sur %s"

-- records, level timeline, gallery, nemeses, dungeon reports
L["Records"] = "Records"
L["The best and the worst of days"] = "Les meilleurs et les pires jours"
L["Most creatures slain in a day"] = "Le plus de victimes en un jour"
L["Most quests in a day"] = "Le plus de quêtes en un jour"
L["Richest day"] = "Jour le plus lucratif"
L["Most experience in a day"] = "Le plus d'expérience en un jour"
L["Longest day in the world"] = "Plus longue journée dans le monde"
L["Longest walk in a day"] = "Plus longue marche en un jour"
L["Most places discovered in a day"] = "Le plus de lieux découverts en un jour"
L["Most new faces in a day"] = "Le plus de nouveaux visages en un jour"
L["Fastest level"] = "Niveau le plus rapide"
L["Slowest level"] = "Niveau le plus lent"
L["Longest run without dying"] = "Plus longue période sans mourir"
L["Darkest day"] = "Jour le plus sombre"
L["Level timeline"] = "Frise des niveaux"
L["How long each level took"] = "La durée de chaque niveau"
L["Played for these levels"] = "Temps de jeu pour ces niveaux"
L["Per level"] = "Par niveau"
L["No level-ups recorded yet."] = "Aucune montée de niveau enregistrée."
L["Still on the way."] = "Encore en route."
L["Reached the next level on day %d."] = "Niveau suivant atteint le jour %d."
L["Gallery"] = "Galerie"
L["Moments, painted in the gear of their day"] = "Des moments, peints dans l'équipement du jour"
L["The first painting waits for your first great moment."] = "Le premier tableau attend votre premier grand moment."
L["Nemeses"] = "Ennemis jurés"
L["They sent me to the spirit healer"] = "Ils m'ont envoyé chez l'esprit guérisseur"
L["Nemesis number one"] = "Ennemi juré numéro un"
L["Nobody has defeated you yet. Long may it last!"] = "Personne ne vous a encore vaincu. Pourvu que ça dure !"
L["Killed you %d times"] = "Vous a tué %d fois"
L["Revenge taken"] = "Vengeance accomplie"
L["Score unsettled"] = "Compte à régler"
L["You slew them %d times."] = "Vous les avez tués %d fois."
L["Dungeon reports"] = "Rapports de donjon"
L["No dungeon visited yet. The depths are waiting."] = "Aucun donjon visité. Les profondeurs attendent."
L["Duration"] = "Durée"
L["Fallen"] = "Tombés"
L["The group"] = "Le groupe"
L["Me"] = "Moi"
L["Nobody fell."] = "Personne n'est tombé."

-- ledger figures, achievement pop-up, blocked functions, quotes
L["Best day: day %d"] = "Meilleur jour : jour %d"
L["Worst day: day %d"] = "Pire jour : jour %d"
L["Per day"] = "Par jour"
L["Honour earned"] = "Honneur obtenu"
L["Landmark discovered"] = "Curiosité découverte"
L["Next tier:"] = "Rang suivant :"
L["Every tier earned!"] = "Tous les rangs obtenus !"
L["The game blocked the function %s. Please tell the author."] = "Le jeu a bloqué la fonction %s. Merci de prévenir l'auteur."
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "Ce client de jeu n'autorise pas les addons à prendre des captures d'écran. Les captures aux grands moments sont désormais désactivées."
L['"Here the journey ends, but not the story."'] = '« Ici s’achève le voyage, mais pas l’histoire. »'

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "Premières fois"
L["First time"] = "Première fois"
L["%d of %d experienced"] = "%d sur %d vécues"
L["Not yet experienced."] = "Pas encore vécu."
L["Click for all first times."] = "Cliquez pour toutes les premières fois."
L["First creature slain"] = "Première créature abattue"
L["First quest completed"] = "Première quête terminée"
L["First level up"] = "Premier niveau gagné"
L["First uncommon item"] = "Premier objet inhabituel"
L["First death"] = "Première mort"
L["First group"] = "Premier groupe"
L["First elite slain"] = "Premier élite abattu"
L["First trade"] = "Premier échange"
L["First hearthstone"] = "Première pierre de foyer"
L["First landmark"] = "Première curiosité"
L["First honour"] = "Premier honneur"
L["First rare item"] = "Premier objet rare"
L["First rare creature"] = "Première créature rare"
L["First flight"] = "Premier vol"
L["First gold coin"] = "Première pièce d'or"
L["First dungeon"] = "Premier donjon"
L["First boss"] = "Premier boss"
L["First skill at 75"] = "Premier métier à 75"
L["First mount"] = "Première monture"
L["First epic item"] = "Premier objet épique"

L["Family book"] = "Livre de famille"
L["%d characters on this account"] = "%d {personnage|personnages} sur ce compte"
L["you"] = "vous"
L["Last seen %s"] = "Vu pour la dernière fois le %s"
L["Who got there first?"] = "Qui y est arrivé en premier ?"
L["Log in with your other characters once, and they will appear here."] = "Connectez-vous une fois avec vos autres personnages, et ils apparaîtront ici."

L["Time capsule"] = "Capsule temporelle"
L["Letters to my future self"] = "Lettres à mon moi futur"
L["Dear me, when you read this ..."] = "Cher moi, quand tu liras ceci …"
L["Seal the letter and open it ..."] = "Sceller la lettre et l'ouvrir …"
L["in a week"] = "dans une semaine"
L["in a month"] = "dans un mois"
L["at level %d"] = "au niveau %d"
L["Until then the letter stays sealed. Not even you can read it."] = "D'ici là, la lettre reste scellée. Même vous ne pouvez pas la lire."
L["No letters yet."] = "Pas encore de lettre."
L["Written on day %d, at level %d"] = "Écrite le jour %d, au niveau %d"
L["Opened on %s"] = "Ouverte le %s"
L["Sealed, opens on day %d"] = "Scellée, s'ouvre le jour %d"
L["Sealed, opens at level %d"] = "Scellée, s'ouvre au niveau %d"
L["in %d days"] = "dans %d {jour|jours}"
L["A letter for later was sealed."] = "Une lettre pour plus tard a été scellée."
L["A letter from the past has opened."] = "Une lettre du passé s'est ouverte."
L["Click to read the letter."] = "Cliquez pour lire la lettre."

L["Gatherer's map"] = "Carte du cueilleur"
L["Where the good things grow"] = "Là où poussent les bonnes choses"
L["Herbalism"] = "Herboristerie"
L["Mining"] = "Minage"
L["Skinning"] = "Dépeçage"
L["Fishing"] = "Pêche"
L["Most found here"] = "Le plus trouvé ici"
L["Nothing gathered yet. Herbs, ore and hides show up here as soon as you gather them."] = "Rien de récolté pour l'instant. Herbes, minerai et peaux apparaîtront ici dès que vous les récolterez."

L["Task of the week"] = "Tâche de la semaine"
L["Task of the week done: %s"] = "Tâche de la semaine accomplie : %s"
L["Click for the next goals."] = "Cliquez pour les prochains objectifs."
L["Slay %d creatures this week."] = "Tuez %d créatures cette semaine."
L["Complete %d quests this week."] = "Terminez %d quêtes cette semaine."
L["Walk %d kilometres this week."] = "Parcourez %d kilomètres à pied cette semaine."
L["Meet %d new people this week."] = "Rencontrez %d nouvelles personnes cette semaine."
L["Visit %d different regions this week."] = "Visitez %d régions différentes cette semaine."
L["Earn %d honour tiers this week."] = "Obtenez %d paliers d'honneur cette semaine."
L["Finish a dungeon run this week."] = "Terminez une expédition en donjon cette semaine."
L["Find %d new landmarks this week."] = "Trouvez %d nouvelles curiosités cette semaine."
L["Week by Week"] = "Semaine après semaine"
L["Complete %d tasks of the week."] = "Accomplissez %d tâches de la semaine."

L["Search the diary"] = "Chercher dans le carnet"
L["Days, people, creatures, quests, places, treasures and catches."] = "Jours, personnes, créatures, quêtes, lieux, trésors et prises."
L["Search: a name, a quest, a place ..."] = "Recherche : un nom, une quête, un lieu …"
L["Nothing found."] = "Rien trouvé."
L["%d more results, type a little more"] = "%d autres résultats, précisez un peu"

L["The binding"] = "La reliure"
L["Corner studs"] = "Coins de métal"
L["none yet"] = "aucun pour l'instant"
L["Next metal at %d honour points (now %d)."] = "Métal suivant à %d points d'honneur (actuellement %d)."
L["Gems"] = "Gemmes"
L["One gem for every ten honour tiers (now %d)."] = "Une gemme tous les dix paliers d'honneur (actuellement %d)."
L["Gold marks on the spine"] = "Dorures sur le dos"
L["One for every ten levels."] = "Une tous les dix niveaux."

-- the bookplate on the endpaper
L["FROM THE LIBRARY OF"] = "DE LA BIBLIOTHÈQUE DE"

-- sayings of the day (start page)
L["SAYING OF THE DAY"] = "MAXIME DU JOUR"
L["Whoever wanders, gathers stories."] = "Qui voyage récolte des histoires."
L["Every road starts at your own door."] = "Toute route commence devant sa propre porte."
L["A full pack is light when the heart is lighter."] = "Un sac plein est léger quand le cœur l'est encore plus."
L["Maps show the way, but only feet know it."] = "Les cartes montrent le chemin, mais seuls les pieds le connaissent."
L["The longest journey is the one you never write down."] = "Le plus long voyage est celui qu'on n'écrit jamais."
L["Ink fades slower than memory."] = "L'encre pâlit moins vite que les souvenirs."
L["A good campfire turns strangers into companions."] = "Un bon feu de camp fait des inconnus des compagnons."
L["The mountain does not care how tired you are. Just keep going."] = "La montagne se moque de ta fatigue. L'essentiel, c'est d'avancer."
L["Today's detour is tomorrow's best story."] = "Le détour d'aujourd'hui est la meilleure histoire de demain."
L["Gold comes and goes, the story stays."] = "L'or va et vient, le récit reste."
L["Count the days by friends, not by miles."] = "Compte les jours en amis, pas en lieues."
L["Even the smallest kobold guards a candle for someone."] = "Même le plus petit kobold garde une bougie pour quelqu'un."
L["Resting is part of the road."] = "Le repos fait partie du chemin."
L["Fear is a map with too many blank spots."] = "La peur est une carte avec trop de zones blanches."
L["Every scar has a page in this book."] = "Chaque cicatrice a sa page dans ce carnet."
L["Look back now and then. The view is part of the journey."] = "Retourne-toi parfois. La vue fait partie du voyage."
L["The wise traveller asks the innkeeper first."] = "Le voyageur avisé interroge d'abord l'aubergiste."
L["Rain on the road, sunshine in the story."] = "Pluie sur la route, soleil dans le récit."
L["Whoever never falls never learns to get up."] = "Qui ne tombe jamais n'apprend jamais à se relever."
L["A quest half done is still a step forward."] = "Une quête à moitié faite reste un pas en avant."
L["The horizon travels with you, which is why it never gets dull."] = "L'horizon voyage avec toi, c'est pour ça qu'on ne s'ennuie jamais."
L["Write it down, or it never happened."] = "Écris-le, sinon ça n'est jamais arrivé."
L["Old boots know more than new maps."] = "Les vieilles bottes en savent plus que les cartes neuves."
L["Courage is being afraid and saddling up anyway."] = "Le courage, c'est avoir peur et seller quand même."
L["Tomorrow the road will still be there. Tonight the fire is warm."] = "Demain, la route sera toujours là. Ce soir, le feu est chaud."
L["A traveller's purse is light, a traveller's diary is heavy."] = "Bourse légère, carnet lourd : ainsi va le voyageur."
L["The best places are on no map."] = "Les plus beaux endroits ne figurent sur aucune carte."
L["Every hero once did not know the way."] = "Chaque héros a un jour ignoré le chemin."
L["Share your bread, and the road shares its secrets."] = "Partage ton pain, et la route te livrera ses secrets."
L["The story is not over while a page is still blank."] = "L'histoire n'est pas finie tant qu'il reste une page blanche."

-- covered cards in the bestiary: kinds your other characters know
L["Not yet discovered"] = "Pas encore découvert"
L["Known to %s"] = "%s connaît déjà cette créature"
L["%d to discover"] = "%d à découvrir"
L["in the east"] = "à l'est"
L["in the south-east"] = "au sud-est"
L["in the south"] = "au sud"
L["in the south-west"] = "au sud-ouest"
L["in the west"] = "à l'ouest"
L["in the north-west"] = "au nord-ouest"
L["in the north"] = "au nord"
L["in the north-east"] = "au nord-est"
L["in the middle"] = "au centre"
L["To the contents"] = "Vers la table des matières"
L["Screenshots at milestones: on"] = "Captures aux étapes clés : activées"
L["Screenshots at milestones: off"] = "Captures aux étapes clés : désactivées"
L["Demo mode is off."] = "Mode démo désactivé."
L["Demo mode is on. Nothing you do now is written into your diary. Type /wfd demo again to leave."] = "Mode démo activé. Rien de ce que vous faites maintenant n'est écrit dans votre carnet. Tapez à nouveau /wfd demo pour en sortir."
L["You have died, but who did it slipped past the diary."] = "Vous êtes mort, mais le carnet n'a pas vu qui en était la cause."
L["Already in the quest log"] = "Acceptées avant le carnet"
L["Angler"] = "Pêcheur"
L["Raise Fishing to %d."] = "Montez la Pêche à %d."
L["Big Catch"] = "Belle prise"
L["Catch %d fish."] = "Pêchez %d poissons."
L["Field Medic"] = "Infirmier de campagne"
L["Raise First Aid to %d."] = "Montez le Secourisme à %d."
L["Camp Cook"] = "Cuisinier de camp"
L["Raise Cooking to %d."] = "Montez la Cuisine à %d."
L["Sighted, not yet slain"] = "Aperçu, pas encore vaincu"
L["perhaps %s"] = "peut-être %s"
L["You have been %s of this area least of all. Something may still be waiting there."] = "C'est %s de cette zone que vous êtes le moins allé. Quelque chose vous y attend peut-être."
L["Defeat a boss."] = "Vainquez un boss."
L["Slay a rare creature."] = "Tuez une créature rare."
L["Slay an elite creature."] = "Tuez une créature élite."
L["Visit a capital city."] = "Visitez une capitale."
L["Enter a dungeon."] = "Entrez dans un donjon."
L["Take a flight."] = "Prenez un vol."
L["Group with another adventurer."] = "Groupez-vous avec un autre aventurier."
L["Visit a trainer."] = "Rendez visite à un maître."
L["Trade with another player."] = "Commercez avec un autre joueur."
L["Complete a quest."] = "Terminez une quête."
L["Die once and rise again."] = "Mourez une fois et relevez-vous."
L["Finish a dungeon run."] = "Terminez une expédition en donjon."
L["Do all tasks of the day on one day."] = "Accomplissez toutes les tâches du jour en une journée."
L["Complete a task of the week."] = "Accomplissez une tâche de la semaine."
L["Find a rare item."] = "Trouvez un objet rare."
L["Find an epic item."] = "Trouvez un objet épique."
L["Dear me, if you are reading this, you made it through the first week. Did you ever find out who was stealing the candles in the mine?"] = "Cher moi, si tu lis ceci, c'est que tu as survécu à la première semaine. As-tu fini par découvrir qui volait les bougies dans la mine ?"
L["Marker set on the map: %s (%d, %d)"] = "Repère placé sur la carte : %s (%d, %d)"
L["No marker can be set on this map."] = "Impossible de placer un repère sur cette carte."
L["Click to set a marker on the map."] = "Cliquez pour placer un repère sur la carte."
L["Right-click for the map of this region."] = "Clic droit pour la carte de cette région."
L["1 kind"] = "1 espèce"
L["Discover a new place."] = "Découvrez un nouveau lieu."
L["Walk one kilometre today."] = "Parcourez un kilomètre à pied aujourd'hui."
L["WELCOME"] = "BIENVENUE"
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "Jouez, j'écris pour vous. Chaque jour de jeu devient une page de ce carnet."
L["See a sample book"] = "Voir un carnet d'exemple"
L["To today's entry"] = "Vers aujourd'hui"
L["Discover %d flight paths."] = "Découvrez %d trajets aériens."
L["A sketch: %d more and it is in colour."] = "Une esquisse : encore %d et elle sera en couleur."
L["%d more to become a connoisseur."] = "Encore %d pour devenir connaisseur."
L["Connoisseur of this kind"] = "Connaisseur de cette espèce"
L["First slain on day %d"] = "Abattu pour la première fois le jour %d"
L["Best loot"] = "Meilleur butin"
L["Got you once."] = "Vous a eu une fois."
L["Got you %d times."] = "Vous a eu %d fois."
L["CONNOISSEUR"] = "CONNAISSEUR"
L["Connoisseur"] = "Connaisseur"
L["Right-click to close."] = "Clic droit pour fermer."
L["The tabs"] = "Les onglets"
L["The tabs on the right lead to the parts of the book, one colour for each group. Point at them to read their names. A red dot shows how much is new since you last read."] = "Les onglets à droite mènent aux parties du livre, une couleur par groupe. Survolez-les pour lire leurs noms. Un point rouge indique ce qui est nouveau depuis votre dernière lecture."
L["The spyglass on the spine searches the whole book: days, people, creatures, quests, places, treasures and catches. Ctrl + F opens it too."] = "La loupe sur le dos cherche dans tout le livre : jours, personnes, créatures, quêtes, lieux, trésors et prises. Ctrl + F l'ouvre aussi."
L["Your own bookmarks"] = "Vos marque-pages"
L["bookmark"] = "marque-page"
L["Goals and honour"] = "Objectifs et honneur"
L["The world"] = "Le monde"
L["Hunt and loot"] = "Chasse et butin"
L["People and money"] = "Gens et argent"
L["Keepsakes"] = "Souvenirs"
L["Best find for every slot"] = "Meilleure trouvaille par emplacement"
L["worn right now"] = "porté en ce moment"
L["Click to show only these."] = "Cliquez pour n'afficher que ceux-ci."
L["Click to show all again."] = "Cliquez pour tout afficher à nouveau."
L["Shown: %s only"] = "Affiché : %s seulement"
L["Show all"] = "Tout afficher"
L["Ctrl-click to set or remove a bookmark here."] = "Ctrl-clic pour poser ou retirer un marque-page ici."
L["Click to open, right-click to remove."] = "Cliquez pour ouvrir, clic droit pour retirer."
L["You are here."] = "Vous êtes ici."
L["Click for the hunting grounds of this area."] = "Cliquez pour les terrains de chasse de cette zone."
L["Who is closest to the next stage"] = "Qui est le plus proche du prochain palier"
L["%d more, then in colour"] = "encore %d, puis en couleur"
L["%d more, then a connoisseur"] = "encore %d, puis connaisseur"
L["To the album of this area"] = "Vers l'album de cette zone"
L["Every kind known here is collected."] = "Toutes les espèces connues ici sont collectionnées."
L["Kinds of creatures"] = "Types de créatures"
L["What you have slain, by type"] = "Ce que vous avez vaincu, par type"
L["Unknown kind"] = "Type inconnu"
L["%d kinds, %d slain"] = "%d {espèce|espèces}, %d {abattu|abattus}"
L["Hunting grounds"] = "Terrains de chasse"
L["Sighted"] = "Aperçu"
L["Kinds slain here"] = "Espèces abattues ici"
L["Each pin marks where the first of its kind fell."] = "Chaque épingle marque l'endroit où tomba le premier de son espèce."
L["Versatile Hunter"] = "Chasseur polyvalent"
L["Slay creatures of %d different types."] = "Tuez des créatures de %d types différents."
L["Slay 50 of each of %d kinds."] = "Tuez 50 créatures de chacune de %d espèces."
L["Slay 50 of one kind."] = "Tuez 50 créatures d'une même espèce."
L["Quick on its feet, but it never looks back."] = "Vif sur ses pattes, mais il ne regarde jamais derrière lui."
L["Its pelt would fetch a fair price in town."] = "Sa fourrure se vendrait bien en ville."
L["Talks big, fights small."] = "Grande gueule, petit bras."
L["Carried more coins than sense."] = "Avait plus de pièces que de bon sens."
L["Smells worse than it fights."] = "Il sent plus mauvais qu'il ne se bat."
L["Dead once already. Twice is a habit."] = "Déjà mort une fois. Deux fois, c'est une habitude."
L["Burning eyes, burning temper."] = "Yeux brûlants, caractère brûlant."
L["Whoever summoned this one owes me an apology."] = "Celui qui l'a invoqué me doit des excuses."
L["Not alive, not dead, simply angry."] = "Ni vivant ni mort, simplement furieux."
L["Left nothing behind but a puddle of fury."] = "N'a laissé derrière lui qu'une flaque de fureur."
L["Scales like armour. Mind the tail."] = "Des écailles comme une armure. Attention à la queue."
L["One day I will face its big brothers."] = "Un jour, j'affronterai ses grands frères."
L["The ground shook long after it fell."] = "Le sol a tremblé longtemps après sa chute."
L["Big enough to have its own weather."] = "Assez grand pour avoir sa propre météo."
L["Gnomish work, no doubt. Loud and leaky."] = "Du travail gnome, sans aucun doute. Bruyant et qui fuit."
L["It sparked, it whirred, it stopped."] = "Ça a crépité, ça a vrombi, ça s'est arrêté."
L["It never stood a chance."] = "Il n'a jamais eu la moindre chance."
L["Small, harmless and now a footnote."] = "Petit, inoffensif et désormais une note de bas de page."
L["A strange creature. I made a note, just in case."] = "Une étrange créature. J'ai pris note, au cas où."
L["Worth remembering, or at least worth writing down."] = "Digne d'être retenu, ou du moins noté."
L["Back"] = "Retour"
L["To the page you came from (Backspace)."] = "Vers la page d'où vous venez (Retour arrière)."
L["Go to page (1-%d):"] = "Aller à la page (1-%d) :"
L["Size: %d%%"] = "Taille : %d%%"
L["Search"] = "Recherche"
L["Turning pages"] = "Tourner les pages"
L["Turn the pages with the arrows, the mouse wheel or the arrow keys. The red ribbon below always leads to today; Backspace takes you back. Ctrl + mouse wheel changes the size of the book."] = "Tournez les pages avec les flèches, la molette ou les touches fléchées. Le ruban rouge en bas mène toujours à aujourd'hui ; Retour arrière vous ramène. Ctrl + molette change la taille du livre."
L["Almost everything can be clicked"] = "Presque tout est cliquable"
L["Next"] = "Suivant"
L["Skip"] = "Passer"
L["Got it"] = "Compris"
L["Handling"] = "Utilisation"
L["Keys"] = "Touches"
L["Notifications"] = "Notifications"
L["Important only"] = "Seulement l'important"
L["Quiet"] = "Silence"
L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] = "Important : niveaux, boss, créatures et trouvailles rares, donjons, honneurs et lettres."
L["Keys while the mouse is over the book"] = "Touches quand la souris est sur le livre"
L["Arrow keys, Page up / down"] = "Flèches, Page préc. / suiv."
L["turn the page"] = "tourner la page"
L["Home"] = "Début"
L["contents"] = "sommaire"
L["End"] = "Fin"
L["today's entry"] = "page du jour"
L["Backspace"] = "Retour arrière"
L["back"] = "retour"
L["Ctrl + mouse wheel"] = "Ctrl + molette"
L["size of the book"] = "taille du livre"
L["Ctrl + F"] = "Ctrl + F"
L["search the book"] = "chercher dans le livre"
L["go to a page"] = "aller à une page"
L["open or close the book"] = "ouvrir ou fermer le livre"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "Une touche pour ouvrir le livre peut être définie dans les raccourcis du jeu, sous AddOns."
L["The book"] = "Le livre"
L["Reset the position"] = "Réinitialiser la position"
L["Show the introduction again"] = "Revoir l'introduction"
L["Open the scribe's notes"] = "Ouvrir les notes du scribe"
L["Right-click to go to a page."] = "Clic droit pour aller à une page."
L["%d new since you last read"] = "%d nouveautés depuis votre dernière lecture"
L["Right-click for the settings."] = "Clic droit pour les réglages."
L["Drag to move this button."] = "Faites glisser pour déplacer ce bouton."
L["Click to open."] = "Cliquez pour ouvrir."
L["Moving code"] = "Code de déménagement"
L["This code holds the whole diary of this character. Copy it with Ctrl+C and keep it somewhere safe, for example in a text file. On the other computer, open the same window with \"Read a moving code\" and paste it there."] = "Ce code contient tout le carnet de ce personnage. Copiez-le avec Ctrl+C et gardez-le en lieu sûr, par exemple dans un fichier texte. Sur l'autre ordinateur, ouvrez la fenêtre avec « Lire un code de déménagement » et collez-le."
L["The code could not be made."] = "Le code n'a pas pu être créé."
L["%d days, %d characters. Now press Ctrl+C."] = "%d jours, %d caractères. Appuyez maintenant sur Ctrl+C."
L["Read a moving code"] = "Lire un code de déménagement"
L["Paste the moving code of this character with Ctrl+V. The diary written on this computer is then replaced by the one from the code, and the interface is reloaded."] = "Collez le code de déménagement de ce personnage avec Ctrl+V. Le carnet de cet ordinateur sera alors remplacé par celui du code et l'interface sera rechargée."
L["Waiting for a code ..."] = "En attente d'un code …"
L["Replace the diary and reload"] = "Remplacer le carnet et recharger"
L["This is not a moving code of the diary."] = "Ce n'est pas un code de déménagement du carnet."
L["The code is damaged or incomplete. Copy it again, all of it."] = "Le code est endommagé ou incomplet. Copiez-le à nouveau, en entier."
L["Diary of %s (%s), %d days, %d kinds of creatures, %d people."] = "Carnet de %s (%s), %d jours, %d espèces de créatures, %d personnes."
L["Careful: this code belongs to %s, but you are playing %s."] = "Attention : ce code appartient à %s, mais vous jouez %s."
L["The diary of this character on this computer will be replaced."] = "Le carnet de ce personnage sur cet ordinateur sera remplacé."
L["Leave demo mode first."] = "Quittez d'abord le mode démo."
L["moving code of this character"] = "code de déménagement de ce personnage"
L["read a moving code"] = "lire un code de déménagement"
L["Moving to another computer"] = "Déménager sur un autre ordinateur"
L["Make a moving code"] = "Créer un code de déménagement"
L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."] = "Ou emportez simplement le dossier WTF du jeu : il contient les carnets de tous les personnages."
L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."] = "Une petite fenêtre avec les chiffres du jour, les tâches et les honneurs les plus proches de leur palier suivant. Déplacez-la par son titre, repliez-la avec le moins."
L["Appearance"] = "Apparence"
L["Both reload the interface. With bigger writing a few long lines may run close together."] = "Les deux rechargent l'interface. Avec une écriture plus grande, quelques longues lignes peuvent se serrer."
L["Click to open the diary there."] = "Cliquez pour ouvrir le carnet à cet endroit."
L["Companion"] = "Compagnon"
L["Fold in or out"] = "Replier ou déplier"
L["Leather and gold"] = "Cuir et or"
L["Modern"] = "Moderne"
L["Next honours"] = "Prochains honneurs"
L["Online"] = "En ligne"
L["Show the companion beside the game"] = "Afficher la fenêtre compagnon à côté du jeu"
L["Size of the writing"] = "Taille de l'écriture"
L["Strong contrast"] = "Contraste élevé"
L["Style of the book"] = "Style du livre"
L["The companion can be shown again in the settings or with /wfd companion."] = "La fenêtre compagnon peut être réaffichée dans les réglages ou avec /wfd companion."
L["Turn the leaves visibly"] = "Tourner les pages de façon visible"
L["Turning the pages"] = "Tourner les pages"
L["km"] = "km"
L["reloads the interface"] = "recharge l'interface"
L["show or hide the companion"] = "afficher ou masquer la fenêtre compagnon"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "Le carnet trouvé ici appartenait à un ancien personnage du même nom. Il a été mis de côté et un nouveau carnet a été commencé pour vous. |cffffd100/wfd restore|r le fait revenir."
L["bring back the diary put aside"] = "faire revenir le carnet mis de côté"
L["No diary has been put aside."] = "Aucun carnet n'a été mis de côté."
L["The diary put aside is back. The interface is reloaded."] = "Le carnet mis de côté est de retour. L'interface est rechargée."

-- Angler's log
L["Angler's log"] = "Carnet de pêche"
L["A collector's album of everything the line brought up"] = "Un album de collection de tout ce que la ligne a remonté"
L["catches collected, %d things landed"] = "prises collectées, %d trouvailles remontées"
L["Land %d different catches."] = "Remontez %d prises différentes."
L["Casts"] = "Lancers"
L["Fish"] = "Poisson"
L["Treasure"] = "Trésor"
L["Junk"] = "Camelote"
L["Odds and ends"] = "Divers"
L["1 catch"] = "1 prise"
L["%d catches"] = "%d prises"
L["Nothing has bitten yet."] = "Rien n'a encore mordu."
L["Waters and tackle"] = "Eaux et matériel"
L["Where it bites, and what you fished with"] = "Où ça mord, et avec quoi vous avez pêché"
L["Waters"] = "Eaux"
L["%d caught in %d casts"] = "%d {prise|prises} en %d {lancer|lancers}"
L["Tackle"] = "Matériel"
L["%d casts"] = "%d {lancer|lancers}"
L["No fishing pole seen yet."] = "Aucune canne à pêche vue pour l'instant."
L["Casts with a lure"] = "Lancers avec leurre"
L["Casts in all"] = "Lancers au total"
L["CAUGHT"] = "PÊCHÉ"
L["Mostly caught in"] = "Surtout pêché à"
L["Caught"] = "Pêché"
L["Of all catches"] = "De toutes les prises"
L["First catch"] = "Première prise"
L["Last catch"] = "Dernière prise"
L["On a lure"] = "Avec leurre"
L["WHERE IT BIT"] = "OÙ ÇA A MORDU"
L["Next mark: %d caught"] = "Prochain palier : %d pêchés"
L["New catch: %s"] = "Nouvelle prise : %s"
L["Catch"] = "Prise"
L["Fish Lore"] = "Science des poissons"
L["Fishing pole"] = "Canne à pêche"
L["Lure"] = "Leurre"
L["Fishing gear"] = "Tenue de pêche"

-- 0.1.11: the today page, group pages, dog-ears, search filters, the companion's offer
L["Click to go to a page."] = "Cliquez pour aller à une page."
L["Right-click for the contents."] = "Clic droit pour la table des matières."
L["Click to set a bookmark here."] = "Cliquez pour placer un marque-page ici."
L["Click to remove the bookmark."] = "Cliquez pour retirer le marque-page."
L["Click the folded corner of a page to keep it. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away."] = "Cliquez sur le coin corné d'une page pour la garder. Un ruban dépasse alors du haut du livre : un clic ouvre la page, un clic droit retire le ruban."
L["Cards, names, days and maps open more. Click the page number to go to any page. The settings have a tab of their own at the bottom."] = "Les cartes, noms, jours et plans en montrent davantage. Cliquez sur le numéro de page pour aller à n'importe quelle page. Les réglages ont leur propre onglet, tout en bas."
L["Click to open the settings."] = "Cliquez pour ouvrir les réglages."
L["All %d bookmarks are in use. Remove one first."] = "Les %d marque-pages sont utilisés. Retirez-en un d'abord."
L["Before the diary"] = "Avant le carnet"
L["Continue reading: %s, p. %d"] = "Reprendre la lecture : %s, p. %d"
L["open a part: today, bestiary, honour, ledger, atlas, settings ... or a day number"] = "ouvrir une partie : today, bestiary, honour, ledger, atlas, settings … ou un numéro de jour"
L["Parchment"] = "Parchemin"
L["Parchment is bright, like old quest paper."] = "Parchemin est clair, comme le papier des quêtes."
L["General"] = "Général"
L["Tasks"] = "Tâches"
L["Day, week and month"] = "Jour, semaine et mois"
L["Perfect days"] = "Jours parfaits"
L["Longest run"] = "Plus longue série"
L["Tasks done"] = "Tâches accomplies"
L["Weeks done"] = "Semaines réussies"
L["Months done"] = "Mois réussis"
L["Task of the month"] = "Tâche du mois"
L["Task of the month done: %s"] = "Tâche du mois accomplie : %s"
L["Slay %d creatures this month."] = "Tuez %d créatures ce mois-ci."
L["Complete %d quests this month."] = "Terminez %d quêtes ce mois-ci."
L["Walk %d kilometres this month."] = "Parcourez %d kilomètres à pied ce mois-ci."
L["Meet %d new people this month."] = "Rencontrez %d nouvelles personnes ce mois-ci."
L["Visit %d different regions this month."] = "Visitez %d régions différentes ce mois-ci."
L["Earn %d honour tiers this month."] = "Obtenez %d paliers d'honneur ce mois-ci."
L["Finish %d dungeon runs this month."] = "Terminez %d expéditions en donjon ce mois-ci."
L["Find %d new landmarks this month."] = "Trouvez %d nouvelles curiosités ce mois-ci."
L["Click to set a waypoint on the map."] = "Cliquez pour placer un repère sur la carte."
L["Waypoint set: %s"] = "Repère placé : %s"
L["Map controls"] = "Commandes de la carte"
L["Mouse wheel: zoom"] = "Molette : zoomer"
L["Drag: move the map"] = "Glisser : déplacer la carte"
L["Right click: reset"] = "Clic droit : réinitialiser"
L["New in the diary. Click to refresh."] = "Du nouveau dans le carnet. Cliquez pour actualiser."
L["Click the page number"] = "Clic sur le numéro de page"
L["Click the folded corner"] = "Clic sur le coin corné"
L["New since you last read"] = "Nouveau depuis votre dernière lecture"
L["Nothing new since you last read."] = "Rien de nouveau depuis votre dernière lecture."
L["Fills as soon as there is something to tell."] = "Se remplit dès qu'il y aura quelque chose à raconter."
L["Show the cover when the book is first opened"] = "Montrer la couverture à la première ouverture"
L["%d new moments"] = "%d nouveaux moments"
L["The companion"] = "Le compagnon"
L["A small window beside the game shows today's figures, the tasks and the honours closest to their next tier. You can switch it on and off in the settings."] = "Une petite fenêtre à côté du jeu montre les chiffres du jour, les tâches et les honneurs les plus proches de leur prochain palier. Vous pouvez l'activer ou la désactiver dans les réglages."
L["Show it"] = "L'afficher"
L["Names from the game (places, creatures, items) stay in the language of the game client."] = "Les noms venant du jeu (lieux, créatures, objets) restent dans la langue du client."

L["%d days, %d kills, %d quests"] = "%d {jour|jours}, %d {victime|victimes}, %d {quête|quêtes}"

-- memories and anniversaries
L["A memory"] = "Souvenir"
L["Read that day (day %d)"] = "Lire ce jour (jour %d)"
L["The diary's birthday"] = "L'anniversaire du carnet"
L["%d hours in the world"] = "%d heures dans ce monde"
L["Anniversary"] = "Anniversaire"
L["Nothing from earlier days to remember today."] = "Aucun souvenir d'un jour passé pour aujourd'hui."
L["A memory on the Today page"] = "Un souvenir sur la page Aujourd'hui"
L["A memory as a note at login"] = "Un souvenir en note à la connexion"
L["show today's memory again"] = "afficher à nouveau le souvenir du jour"
loc.narrator.memory = {
    years = "{Il y a un an jour pour jour|Il y a %d ans jour pour jour}",
    days = "Il y a %d jours",
    intro = {
        "%s, j'étais du côté de %s.",
        "%s, la route me menait du côté de %s.",
    },
    first = "Et une première fois : %s.",
}
loc.narrator.jubilee = {
    born = "Voilà {un an|%d ans} que j'ai écrit la première page de ce carnet.",
    hours = "Déjà %d heures passées dans ce monde. Ça en fait, du chemin.",
    level = "Voilà {un an|%d ans} que j'ai atteint le niveau %d.",
}

-- fate: every death
L["Fate"] = "Destin"
L["Every fall on the way"] = "Chaque chute en chemin"
L["Places of death"] = "Lieux de mort"
L["Last death"] = "Dernière mort"
L["None of the graves has a place on a map yet."] = "Aucune tombe n'a encore de place sur une carte."
L["Graves here: %d"] = "Tombes ici : %d"
L["Where you fall most"] = "Là où vous tombez le plus"
L["Who defeated you most"] = "Qui vous a vaincu le plus souvent"
L["Deaths by level"] = "Morts par niveau"
L["Foe unknown: %d"] = "Adversaire inconnu : %d"
L["Every death"] = "Toutes les morts"
L["Cause unknown"] = "Cause inconnue"
L["Group: %d"] = "Groupe : %d"
L["Stubborn"] = "Obstiné"
L["Defeat a foe that has defeated you three times."] = "Vainquez un adversaire qui vous a vaincu trois fois."

-- the journey replayed on the atlas
L["Watch the journey grow"] = "Voir le voyage grandir"
L["Day by day, from the first step to today."] = "Jour après jour, du premier pas à aujourd'hui."
L["Pause"] = "Pause"
L["Keep the picture"] = "Garder l'image"
L["Drag to go to a day."] = "Faites glisser pour aller à un jour."
L["Esc ends the replay."] = "Échap arrête la lecture."
L["This game client does not allow addons to take screenshots."] = "Ce client de jeu n'autorise pas les captures d'écran par les addons."
L["kill"] = "victime"
L["day"] = "jour"
L["%d kinds %s already knows"] = "%d espèces que %s connaît déjà"
L["%d honours earned: %s"] = "%d honneurs obtenus : %s"
L["continued"] = "suite"
L["Regions"] = "Régions"
L["Nothing slain here yet."] = "Rien abattu ici pour l'instant."
L["No places discovered here yet."] = "Aucun lieu découvert ici pour l'instant."
L["The diary could not tell who it was."] = "Le carnet n'a pas pu savoir qui c'était."
L["Every first, with its day and place"] = "Chaque première fois, avec son jour et son lieu"
L["Leather and gold is the classic book. Modern is flat and calm, strong contrast makes all writing brighter."] = "Cuir et or est le livre classique. Moderne est sobre et calme, le contraste élevé éclaircit toute l'écriture."
L["Still to come"] = "À venir"
L["%d still to find"] = "%d restent à découvrir"
L["No nemesis yet: nobody has defeated you so far."] = "Pas encore d'ennemi juré : personne ne vous a vaincu jusqu'ici."
L["At a glance"] = "En un coup d'œil"
L["Data"] = "Données"
L["Library"] = "Bibliothèque"
L["Books I read along the way"] = "Livres lus en chemin"
L["Book"] = "Livre"
L["Note"] = "Note"
L["Plaque"] = "Plaque"
L["%d books on the shelf"] = "%d {livre|livres} sur l'étagère"
L["Reading desk"] = "Pupitre de lecture"
L["Recently added"] = "Ajoutés récemment"
L["To read later"] = "À lire plus tard"
L["Nothing is kept for later."] = "Rien n'est mis de côté pour plus tard."
L["The shelf is empty. Every book, note and plaque you read will stand here."] = "L'étagère est vide. Chaque livre, note et plaque que vous lirez prendra place ici."
L["Pages are missing: read the rest to complete this book."] = "Il manque des pages : lisez le reste pour compléter ce livre."
L["Read by %s on %s"] = "Lu par %s le %s"
L["Read later"] = "Lire plus tard"
L["Bookworm"] = "Rat de bibliothèque"
L["Read %d books, notes and plaques."] = "Lisez %d livres, notes et plaques."
L["Read a book, a note or a plaque."] = "Lisez un livre, une note ou une plaque."
L["Scholar"] = "Érudit"
L["Read %d books to the last page."] = "Lisez %d livres jusqu'à la dernière page."
L["Read a book to the last page."] = "Lisez un livre jusqu'à la dernière page."
L["Your title"] = "Votre titre"
L["In the showcase"] = "Dans la vitrine"
L["Showcase"] = "Vitrine"
L["Click to make this your title."] = "Cliquez pour en faire votre titre."
L["Click to give up this title."] = "Cliquez pour abandonner ce titre."
L["Right-click to put it in the showcase."] = "Clic droit pour le mettre dans la vitrine."
L["Right-click to take it out of the showcase."] = "Clic droit pour le retirer de la vitrine."
L["Right-click an earned honour in the book of honour to show it here."] = "Faites un clic droit sur un honneur obtenu du livre d'honneur pour l'afficher ici."
L["Steel sharpened, name written down."] = "L'acier est aiguisé, le nom est inscrit."
L["The road is longer, and so is the map."] = "La route s'allonge, et la carte aussi."
L["Strangers become faces in the book."] = "Les inconnus deviennent des visages du livre."
L["Another line in the story of this life."] = "Une ligne de plus dans l'histoire de cette vie."
L["Not every treasure shines at first."] = "Tous les trésors ne brillent pas d'emblée."
L["Some pages only open for the curious."] = "Certaines pages ne s'ouvrent qu'aux curieux."
L["Hall of fame"] = "Panthéon"
L["Savings goal in gold:"] = "Objectif d'épargne en or :"
L["Goal reached"] = "Objectif atteint"
L["Savings goal"] = "Objectif d'épargne"
L["Set a savings goal"] = "Fixer un objectif d'épargne"
L["Click to change the goal."] = "Clic pour changer l'objectif."
L["Right-click to take the goal away."] = "Clic droit pour retirer l'objectif."
L["My own goals"] = "Mes propres objectifs"
L["Remove this goal"] = "Retirer cet objectif"
L["Write down what you want to do next, and tick it off when it is done."] = "Note ce que tu veux faire ensuite et coche-le une fois fait."
L["Add a goal"] = "Ajouter un objectif"
L["What do you want to do next?"] = "Que veux-tu faire ensuite ?"
L["%d days with entries"] = "%d {jour|jours} avec des entrées"
L["%d levels gained"] = "%d {niveau|niveaux} gagnés"
L["A year of travel in figures"] = "Une année de voyage en chiffres"
L["Best month: %s with %d kills"] = "Meilleur mois : %s avec %d victimes"
L["Busiest day: %s with %d kills"] = "Jour le plus actif : %s avec %d victimes"
L["Days"] = "Jours"
L["Highlights"] = "Temps forts"
L["Month by month"] = "Mois par mois"
L["The first year is still being written."] = "La première année s'écrit encore."
L["Time online: %s"] = "Temps en ligne : %s"
L["Year %d"] = "Année %d"
L["Year book"] = "Annuaire"
L["If you enjoy the diary, you can support its development:"] = "Si le carnet vous plaît, vous pouvez soutenir son développement :"
L["Support"] = "Soutien"
L["%d mounts"] = "%d {monture|montures}"
L["%d rides"] = "%d {trajet|trajets}"
L["%d factions"] = "%d {faction|factions}"
L["%d years ago today, %s brought me down in %s."] = "Il y a %d {an|ans}, jour pour jour, %s m'a terrassé à %s."
L["%d years ago today I fell in %s."] = "Il y a %d {an|ans}, jour pour jour, je suis tombé à %s."
L["First ridden on day %d"] = "Montée pour la première fois le jour %d"
L["Into the chat"] = "Dans le chat"
L["Most days were: %s (%d)"] = "La plupart des jours : %s (%d)"
L["Mounts"] = "Montures"
L["My week: %d kills, %d quests, %s km, %d levels, %d new places."] = "Ma semaine : %d victimes, %d quêtes, %s km, %d niveaux, %d nouveaux lieux."
L["Narrow down the days: z:region  lv:20-30  d:30 (the last 30 days)"] = "Filtrer les jours : z:région  lv:20-30  d:30 (les 30 derniers jours)"
L["Reputation"] = "Réputation"
L["Reputation steps up: %d"] = "Paliers de réputation gagnés : %d"
L["Seen on day %d as %s"] = "Vue le jour %d comme %s"
L["The copy from before the update to version %s is back. The interface is reloaded."] = "La copie d'avant la mise à jour vers la version %s est de retour. L'interface est rechargée."
L["The first ride is still to come."] = "La première chevauchée reste à venir."
L["There is no copy from before an update."] = "Il n'y a aucune copie d'avant une mise à jour."
L["A day of battle"] = "Un jour de bataille"
L["A day on the road"] = "Un jour sur la route"
L["A day of quests"] = "Un jour de quêtes"
L["A day of fortune"] = "Un jour de fortune"
L["A quiet day"] = "Un jour tranquille"
L["A day of mourning"] = "Un jour de deuil"
L["Every mount, and the day it was first ridden"] = "Chaque monture et le jour de sa première chevauchée"
L["How the factions came to see me"] = "Comment les factions ont appris à me connaître"
L["bring back the copy from before the last update"] = "rétablir la copie d'avant la dernière mise à jour"
L["Drag to move."] = "Faire glisser pour déplacer."
L["The notes are back at the top of the screen."] = "Les notes sont de nouveau en haut de l'écran."
L["put the notes back at the top of the screen"] = "remettre les notes en haut de l'écran"
L["Show a note to move it"] = "Afficher une note pour la déplacer"
L["Put the notes back at the top"] = "Remettre les notes en haut"
L["Pop-up notes"] = "Notes qui apparaissent"
L["Mouse wheel changes the size."] = "La molette change la taille."
