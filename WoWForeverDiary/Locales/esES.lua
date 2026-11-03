-- Spanish translation for Spain (esES) and Latin America (esMX) (English phrases are the keys)
local ADDON, WFD = ...
local L, loc, extra = WFD:NewLocale({ "esES", "esMX" })

local T = {
    -- chat / log
    ["Diary"] = "Diario",
    ["Travel diary active - today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
        "Diario de viaje activo: hoy es el |cffffd100día %d|r. |cffffd100/wfd|r abre el diario.",
    ["%d creatures slain in total"] = "%d criaturas abatidas en total",
    ["First victory over the boss %s!"] = "¡Primera victoria sobre el jefe %s!",
    ["Rare creature slain: %s"] = "Criatura rara abatida: %s",
    ["Boss %s defeated again (%dx)"] = "Jefe %s derrotado de nuevo (%dx)",
    ["Died to %s in %s"] = "Muerte a manos de %s (%s)",
    ["Died in %s"] = "Muerte en %s",
    ["Met %s (%s)"] = "Encuentro con %s (%s)",
    ["Hearthstone bound to %s"] = "Piedra de hogar vinculada a %s",
    ["Quest accepted: %s"] = "Misión aceptada: %s",
    ["Quest abandoned: %s"] = "Misión abandonada: %s",
    ["Quest completed: %s"] = "Misión completada: %s",
    ["First quest completed: %s"] = "Primera misión completada: %s",
    ["%d quests completed"] = "%d misiones completadas",
    ["Took a flight to %s"] = "Vuelo a %s",
    ["Wealth reached: %s"] = "Fortuna alcanzada: %s",
    ["Found %s"] = "Encontrado: %s",
    ["Epic find: %s"] = "Hallazgo épico: %s",
    ["Rare find: %s"] = "Hallazgo raro: %s",
    ["Discovered a new land: %s"] = "Nueva tierra descubierta: %s",
    ["Entered %s"] = "Llegada: %s",
    ["Discovered: %s (%s)"] = "Descubierto: %s (%s)",
    ["First visit to the dungeon %s"] = "Primera visita a la mazmorra %s",
    ["Entered the dungeon %s"] = "Entrada en la mazmorra %s",
    ["Level %d reached!"] = "¡Nivel %d alcanzado!",
    ["%s increased to %d"] = "%s sube a %d",
    ["%s mastered up to %d"] = "%s dominado hasta %d",
    ["Used the hearthstone"] = "Piedra de hogar usada",
    ["%dh %02dm"] = "%d h %02d min",
    ["%dm"] = "%d min",

    -- window
    ["Travel Diary of %s"] = "Diario de viaje de %s",
    ["Day %d"] = "Día %d",
    ["Level %d"] = "Nivel %d",
    ["Level %s"] = "Nivel %s",
    ["online"] = "en línea",
    ["Screenshot:"] = "Captura de pantalla:",
    ["Click to read this day."] = "Haz clic para leer este día.",
    ["Click to open the diary."] = "Haz clic para abrir el diario.",
    ["%d kills today"] = "%d {baja|bajas} hoy",
    ["%d quests today"] = "%d {misión|misiones} hoy",
    ["DEMO MODE - invented data"] = "MODO DEMO - datos inventados",

    -- tabs
    ["Bestiary"] = "Bestiario",
    ["People"] = "Personajes",
    ["Quest Book"] = "Libro de misiones",

    -- journal
    ["Today"] = "Hoy",
    ["Chronicle"] = "Crónica",
    ["Enemies slain"] = "Enemigos abatidos",
    ["Quests completed"] = "Misiones completadas",
    ["People spoken to"] = "Personas con las que hablaste",
    ["Distance travelled"] = "Distancia recorrida",
    ["flown"] = "en vuelo",
    ["Time online"] = "Tiempo en línea",
    ["Deaths"] = "Muertes",
    ["Income"] = "Ingresos",
    ["Expenses"] = "Gastos",
    ["Net"] = "Balance",
    ["Fallen foes"] = "Enemigos caídos",
    ["Loot"] = "Botín",

    -- map
    ["Kills"] = "Bajas",
    ["Quests"] = "Misiones",
    ["No map art available for this area."] = "No hay mapa disponible para esta zona.",
    ["Play"] = "Reproducir",
    ["Spoken to %d times"] = "%d {conversación|conversaciones}",
    ["You died here"] = "Aquí moriste",
    ["Killed by %s"] = "Muerte a manos de %s",
    ["No travels recorded yet."] = "Aún no hay viajes registrados.",

    -- bestiary
    ["Boss"] = "Jefe",
    ["Rare"] = "Raro",
    ["Elite"] = "Élite",
    ["Normal"] = "Normal",
    ["No portrait"] = "Sin retrato",
    ["KILLS PER DAY"] = "BAJAS POR DÍA",

    -- people
    ["First met"] = "Primer encuentro",
    ["Show on map"] = "Mostrar en el mapa",
    ["QUESTS WITH THIS PERSON"] = "MISIONES CON ESTA PERSONA",
    ["No quests recorded."] = "No hay misiones registradas.",
    ["All"] = "Todos",
    ["You have not talked to anyone yet."] = "Aún no has hablado con nadie.",
    ["Conversation"] = "Conversación",
    ["Vendor"] = "Vendedor",
    ["Trainer"] = "Instructor",
    ["Flight master"] = "Maestro de vuelo",
    ["Banker"] = "Banquero",
    ["Stable master"] = "Maestro de establos",
    ["Petitions"] = "Peticiones",
    ["Auctioneer"] = "Subastador",

    -- quests
    ["No quests recorded yet."] = "Aún no hay misiones registradas.",

    -- statistics
    ["Gold"] = "Oro",
    ["In total: %d kills  |  %d quests  |  %s online  |  %.1f km on foot  |  %d deaths  |  %d jumps"] =
        "En total: %d bajas  |  %d misiones  |  %s en línea  |  %.1f km a pie  |  %d muertes  |  %d saltos",

    -- money categories
    ["Quest rewards"] = "Recompensas de misión",
    ["Vendor sales"] = "Ventas a vendedores",
    ["Mail"] = "Correo",
    ["Trading"] = "Comercio",
    ["Auction house"] = "Casa de subastas",
    ["Repairs"] = "Reparaciones",
    ["Purchases"] = "Compras",
    ["Training"] = "Entrenamiento",
    ["Flights"] = "Vuelos",
    ["Bank"] = "Banco",
    ["Other"] = "Otros",

    -- export / settings
    ["Born:"] = "Nacimiento:",
    ["Select all"] = "Seleccionar todo",
    ["Ctrl+C copies the selection."] = "Ctrl+C copia la selección.",
    ["Take a screenshot at milestones"] = "Hacer una captura en los hitos",
    ["Show minimap button"] = "Mostrar botón del minimapa",

    -- redesigned interface
    ["Travel Diary"] = "Diario de viaje",
    ["Experience"] = "Experiencia",
    ["Conversations"] = "Conversaciones",
    ["On foot"] = "A pie",
    ["Map of my travels"] = "Mapa de mis viajes",
    ["No creature has fallen yet."] = "Aún no ha caído ninguna criatura.",
    ["Slain"] = "Abatidos",
    ["First kill"] = "Primera baja",
    ["Last kill"] = "Última baja",
    ["Seen in"] = "Visto en",
    ["Killed you"] = "Te ha matado",
    ["Found in"] = "Se encuentra en",
    ["Place"] = "Lugar",
    ["Last met"] = "Último encuentro",
    ["Received from"] = "Recibida de",
    ["Took"] = "Duración",
    ["Came from"] = "Procedencia",
    ["Went to"] = "Destino",
    ["Transcript"] = "Transcripción",
    ["Settings"] = "Opciones",
    ["Size of the book"] = "Tamaño del libro",
    ["Demo"] = "Demo",
    ["Start demo mode"] = "Iniciar modo demo",
    ["Leave demo mode"] = "Salir del modo demo",
    ["open or close the diary"] = "abrir o cerrar el diario",
    ["explore with invented data"] = "explorar con datos inventados",
    ["screenshots on or off"] = "activar o desactivar capturas",
    ["minimap button on or off"] = "mostrar u ocultar el botón del minimapa",
}

-- Latin American Spanish uses "calabozo" instead of "mazmorra"
local mx = extra("esMX")
mx["First visit to the dungeon %s"] = "Primera visita al calabozo %s"
mx["Entered the dungeon %s"] = "Entrada al calabozo %s"
for k, v in pairs(T) do L[k] = v end

-- dates and diary entries
loc.date = "%d/%m/%Y"
loc.decimal = ","
loc.thousands = "."
loc.listAnd = " y "
loc.dayMonth = "%d/%m"
loc.weekdays = { "domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado" }
loc.months = { "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre" }
function loc.longDate(d)
    local wd = loc.weekdays[d.wday]
    return string.format("%s%s, %d de %s de %d", wd:sub(1, 1):upper(), wd:sub(2), d.day, loc.months[d.month], d.year)
end
loc.quotes = { "«", "»" }

loc.narrator = {
    birth = {
        "Día 1. %s, %s. Punto de partida: %s. ¿Qué viene ahora? Ni idea.",
        "Día 1. Soy %s y %s, y todo empieza aquí: %s. Ya veremos adónde lleva esto.",
    },
    begin = {
        "Día 1. Desde hoy apunto todo lo que me pasa por el camino.",
    },
    open = {
        "Día %d, %s.",
        "Día %d. Hoy le tocó a %s.",
        "Día %d. Otra vez en camino, sobre todo por %s.",
    },
    far = "tierras desconocidas",
    walk = {
        "Unos %s kilómetros a pie%s.",
        "Mis pies dicen: más o menos %s kilómetros%s.",
        "Cerca de %s kilómetros andando%s, y mis piernas lo notan.",
    },
    via = " (%s)",
    fly = " El resto del camino lo hice volando.",
    kills = {
        "Derroté a {un enemigo|%d enemigos}.",
        "Acabé con %d {criatura|criaturas}.",
        "{Un enemigo|%d enemigos} menos en el mundo.",
    },
    top = {
        "La mayoría: %s (%dx).",
        "%s fue lo que más se me cruzó (%dx).",
    },
    special = "Para recordar: %s.",
    deaths = {
        "Morí {una vez|%d veces}.%s",
        "Mordí el polvo {una vez|%d veces} hoy.%s",
    },
    deathBy = " La última fue cosa de %s.",
    noDeath = {
        "Hoy no he muerto ni una vez.",
        "Cero muertes hoy. Nada mal.",
    },
    questDone = {
        "{Una misión terminada|%d misiones terminadas}: %s.",
        "Tachado de mi lista: %s.",
    },
    questAcc = {
        "Y {llegó una nueva|llegaron %d nuevas}.",
        "Y ya {me espera otra tarea|me esperan %d tareas nuevas}.",
    },
    questAccOnly = {
        "{Acepté una tarea nueva, pero aún no la he terminado.|Acepté %d tareas nuevas y todavía no he terminado ninguna.}",
    },
    more = "y alguna más",
    quote = {
        "%s me dijo: %s",
        "Palabras de %s: %s",
    },
    quoteAnon = "Se me quedó grabada una frase: %s",
    npcs = {
        "{Solo hablé con %s.|Hablé con %d personas, entre ellas %s.}",
        "{Una conversación, con %s.|%d conversaciones, por ejemplo con %s.}",
    },
    gain = {
        "Mi bolsa pesa %s más.",
        "Al final, %s más en el bolsillo.",
    },
    loss = {
        "Mi bolsa pesa %s menos.",
        "Al final, el día me costó %s.",
    },
    src = " La mayor parte de los ingresos: %s (%s).",
    spent = " El mayor gasto: %s (%s).",
    item = {
        "Mejor hallazgo: %s.",
        "Hallazgo del día: %s.",
    },
    levels = {
        "¡Nivel %s!",
        "Subí al nivel %s.",
        "Y entonces: ¡nivel %s!",
    },
    quiet = {
        "Día tranquilo. Poco que contar.",
        "Hoy no pasó gran cosa.",
    },
    begun = {
        "El día acaba de empezar.",
        "El día aún es joven.",
        "El nuevo día apenas comienza.",
    },
    ongoing = {
        "El día aún no ha terminado.",
        "Continuará …",
        "A ver qué más trae el día.",
    },
    close = {
        "Hasta aquí por hoy.",
        "Suficiente por hoy. Mañana sigo.",
        "Toca descansar un rato.",
        "A ver qué trae mañana.",
    },
    closeLong = {
        "%s en camino. Ya está bien.",
        "Después de %s, no puedo más.",
        "En total, %s de pie. Mañana más.",
    },
    none = "No hay ninguna entrada para este día.",
}

-- book interface
L["Appendix"] = "Apéndice"
L["Begun on %s"] = "Comenzado el %s"
L["Bookmark"] = "Marcapáginas"
L["Click to open today's entry."] = "Haz clic para abrir la entrada de hoy."
L["Click to open"] = "Haz clic para abrir"
L["Contents"] = "Índice"
L["Notes"] = "Notas"
L["Page %d"] = "Página %d"
L["Realm: %s"] = "Reino: %s"
L["This book belongs to"] = "Este libro pertenece a"
L["in %s, at level %d"] = "%s, con nivel %d"
L["in %s, on the first day of my life"] = "%s, el primer día de mi vida"
L["of"] = "de"

-- book pages (diary, appendix)
L["Arrival in %s"] = "Llegada a %s"
L["Days in %s"] = "Días de viaje: %s"
L["Shadows over %s"] = "Sombras sobre %s"
L["The roads of %s"] = "Los caminos de %s"
L["Under the skies of %s"] = "Bajo los cielos de %s"
L["Awakening in %s"] = "Despertar: %s"
L["Return to %s"] = "Regreso: %s"
L["Chapter"] = "Capítulo"
L["Level %d-%d"] = "Nivel %d-%d"
L["Days %d-%d"] = "Días %d-%d"
L["Level %d!"] = "¡Nivel %d!"
L["%d kills"] = "%d {baja|bajas}"
L["%d quests"] = "%d {misión|misiones}"
L["died %dx"] = "%d {muerte|muertes}"
L["Kept as a memory"] = "Guardado como recuerdo"
L["Click to read this day aloud in chat."] = "Haz clic para leer este día en voz alta en el chat."
L["The pages are still empty. Go and live an adventure!"] = "Las páginas aún están en blanco. ¡Sal a vivir una aventura!"
L["p. %d"] = "p. %d"
L["Milestones"] = "Hitos"
L["The great moments of a life"] = "Los grandes momentos de una vida"
L["No milestones yet."] = "Aún no hay hitos."
L["Maps"] = "Mapas"
L["%s spent here"] = "%s pasados aquí"
L["Route"] = "Ruta"
L["Kill sites"] = "Lugares de combate"
L["First visit"] = "Primera visita"
L["Time spent"] = "Tiempo pasado"
L["Acquaintances here"] = "Conocidos aquí"
L["Slain %d times"] = "Abatida %d {vez|veces}"
L["Everyone I met on my way"] = "Todos los que encontré en mi camino"
L["Every coin, in and out"] = "Cada moneda, entrada y salida"
L["Balance"] = "Saldo"
L["Day"] = "Día"
L["Tasks taken and done"] = "Tareas aceptadas y cumplidas"
L["How this book is kept"] = "Cómo se lleva este libro"
L["Copy the diary as text"] = "Copiar el diario como texto"
L["Copy the diary as JSON"] = "Copiar el diario como JSON"
L["Ledger"] = "Libro de cuentas"

-- own notes
L["Click here to write your own notes ..."] = "Haz clic aquí para escribir tus propias notas …"
L["My own thoughts:"] = "Mis propios pensamientos:"
L["+ note"] = "+ nota"
L["edit note"] = "editar nota"
L["Save"] = "Guardar"
L["Cancel"] = "Cancelar"

-- cards
L["Acquaintance"] = "Conocido"
L["Click for the wanted poster."] = "Haz clic para ver el cartel de búsqueda."
L["Click for the portrait."] = "Haz clic para ver el retrato."

-- collector's album
L["A collector's album of every creature slain"] = "Un álbum de colección de todas las criaturas abatidas"
L["kinds collected  -  %d creatures slain"] = "especies coleccionadas  -  %d criaturas abatidas"
L["Bronze"] = "Bronce"
L["Silver"] = "Plata"
L["Mithril"] = "Mitril"
L["Legend"] = "Leyenda"
L["Collect %d kinds of creatures."] = "Colecciona %d especies de criaturas."
L["Reached!"] = "¡Conseguido!"
L["%d still missing."] = "Faltan %d."
L["Bosses"] = "Jefes"
L["Rare creatures"] = "Criaturas raras"
L["Album pages"] = "Páginas del álbum"
L["%d kinds"] = "%d especies"
L["Lv %s"] = "Nv. %s"
L["NEW"] = "NUEVO"
L["not yet found"] = "aún no encontrada"

-- language switch
L["German"] = "Alemán"
L["English"] = "Inglés"
L["French"] = "Francés"
L["Spanish"] = "Español"
L["Portuguese"] = "Portugués"
L["Russian"] = "Ruso"
L["Korean"] = "Coreano"
L["Chinese (traditional)"] = "Chino (tradicional)"
L["Language"] = "Idioma"
L["Game language (%s)"] = "Idioma del juego (%s)"
L["The diary will reload the interface to switch the language."] = "El diario recargará la interfaz para cambiar el idioma."
L["Korean and Chinese text needs a game client with those fonts."] = "El texto en coreano y chino requiere un cliente del juego con esas fuentes."

-- map spreads
L["Places of note"] = "Lugares destacados"
L["Nobody was met here yet."] = "Aún no has conocido a nadie aquí."
L["Grave"] = "Tumba"
L["Chronicle of the region"] = "Crónica de la región"
L["Visits"] = "Visitas"
L["Deaths here"] = "Muertes aquí"
L["Most hunted here"] = "Lo más cazado aquí"
L["Places discovered"] = "Lugares descubiertos"

-- companions, honours, treasures, memories, obituary
L["%d days of life  -  %d creatures slain  -  %d quests completed"] = "%d {día|días} de vida  -  %d {criatura abatida|criaturas abatidas}  -  %d {misión completada|misiones completadas}"
L["%d days"] = "%d {día|días}"
L["%d enemies fell that day."] = "Ese día {cayó|cayeron} %d {enemigo|enemigos}."
L["%d kills together"] = "%d {baja|bajas} juntos"
L["%d of %d honour tiers reached"] = "%d de %d niveles alcanzados"
L["%d times grouped"] = "%d {vez|veces} en grupo"
L["%d treasures collected"] = "%d {tesoro reunido|tesoros reunidos}"
L["%dx traded"] = "%d intercambios"
L["A painted memory"] = "Un recuerdo pintado"
L["Book of honour"] = "Libro de honor"
L["Companions"] = "Compañeros"
L["Copy for forum or Discord (Markdown)"] = "Copiar para foro o Discord (Markdown)"
L["Fell in %s"] = "Cayó en %s"
L["Slain by %s"] = "Muerte a manos de %s"
L["Fellow adventurers"] = "Compañeros de aventura"
L["Fellowship"] = "Hermandad"
L["Grouped with %s"] = "En grupo con %s"
L["In memoriam"] = "In memoriam"
L["No trades yet."] = "Aún no hay intercambios."
L["No treasures found yet."] = "Aún no se han encontrado tesoros."
L["Rested here"] = "Descanso aquí"
L["Times rested here"] = "Descansos aquí"
L["The last moment"] = "El último instante"
L["Today, %d days ago"] = "Hoy hace %d días"
L["Trading partners"] = "Socios comerciales"
L["Treasures"] = "Tesoros"
L["Who walked beside me"] = "Quienes caminaron a mi lado"
L["You have not grouped with anyone yet."] = "Aún no te has agrupado con nadie."
L["I was in %s."] = "Estuve en %s."
L["early in the morning"] = "temprano por la mañana"
L["in the morning"] = "por la mañana"
L["around noon"] = "hacia el mediodía"
L["in the afternoon"] = "por la tarde"
L["in the evening"] = "al anochecer"
L["late at night"] = "bien entrada la noche"
L["earned"] = "obtenido"
L["first met %s"] = "primer encuentro el %s"

-- honours
L["Slayer"] = "Matador"
L["Specialist"] = "Especialista"
L["Naturalist"] = "Naturalista"
L["Rare Hunter"] = "Cazador de rarezas"
L["Giant Slayer"] = "Matagigantes"
L["Into the Depths"] = "Hacia las profundidades"
L["Hunter"] = "Cazador"
L["Helping Hand"] = "Mano amiga"
L["Explorer"] = "Explorador"
L["Wanderer"] = "Caminante"
L["Pathfinder"] = "Pionero"
L["Frequent Flyer"] = "Viajero frecuente"
L["Thrifty"] = "Ahorrador"
L["Seasoned"] = "Curtido"
L["Untouchable"] = "Intocable"
L["Faithful Chronicler"] = "Cronista fiel"
L["Sociable"] = "Sociable"
L["Bouncy"] = "Saltarín"
L["Treasure Hunter"] = "Cazatesoros"
mx["Enter a dungeon."] = "Entra a un calabozo."

-- keepsake captions
L["Level up"] = "Nivel"
L["Epic find"] = "Hallazgo épico"
L["Rare find"] = "Hallazgo raro"
L["Death"] = "Muerte"
L["New land"] = "Nueva tierra"
L["Dungeon"] = "Mazmorra"
L["Quest"] = "Misión"
L["Wealth"] = "Riqueza"
L["Skill"] = "Profesión"
L["Hunt"] = "Caza"
L["Moment"] = "Momento"

-- honour tiers, atlas, landmarks, secrets
L["%d honour points"] = "%d puntos de honor"
L["%d of %d landmarks found"] = "%d de %d lugares emblemáticos encontrados"
L["%d of %d regions explored"] = "%d de %d regiones exploradas"
L["%d tiers earned"] = "%d {nivel obtenido|niveles obtenidos}"
L["A familiar face ..."] = "Una cara conocida …"
L["A secret honour. Keep exploring!"] = "Un honor secreto. ¡Sigue explorando!"
L["Adventure"] = "Aventura"
L["Almost there"] = "Casi lo tienes"
L["Atlas"] = "Atlas"
L["Bad Day"] = "Día negro"
L["Barterer"] = "Negociante"
L["Be on the road before seven in the morning."] = "Ponte en camino antes de las siete de la mañana."
L["Be on the road between midnight and four o'clock."] = "Ponte en camino entre la medianoche y las cuatro."
L["Bloodbath"] = "Baño de sangre"
L["Busy Bee"] = "Abeja obrera"
L["Capital Tourist"] = "Turista de capitales"
L["Capitals"] = "Capitales"
L["Click for all landmarks."] = "Haz clic para ver todos los lugares emblemáticos."
L["Click for the map of this region."] = "Haz clic para ver el mapa de esta región."
L["Click to open this part of the book."] = "Haz clic para abrir esta parte del libro."
L["Collection"] = "Colección"
L["Combat"] = "Combate"
L["Complete %d quests in a single day."] = "Completa %d misiones en un solo día."
L["Complete %d quests."] = "Completa %d misiones."
L["Complete!"] = "¡Completado!"
L["Curiosities"] = "Curiosidades"
L["Dark places, rich rewards"] = "Lugares oscuros, ricas recompensas"
L["Defeat %d bosses."] = "Derrota a %d jefes."
L["Destination of the day"] = "Destino del día"
L["Devoted"] = "Entregado"
L["Die %d times and rise again."] = "Muere %d veces y vuelve a levantarte."
L["Die %d times in a single day."] = "Muere %d veces en un solo día."
L["Discover %d places."] = "Descubre %d lugares."
L["Do business with %d merchants."] = "Haz negocios con %d vendedores."
L["Dungeons"] = "Mazmorras"
L["Eager Student"] = "Alumno aplicado"
L["Early Bird"] = "Madrugador"
L["Elite Slayer"] = "Cazador de élites"
L["Encounters"] = "Encuentros"
L["Enter %d dungeons."] = "Entra en %d mazmorras."
L["Epic Fortune"] = "Suerte épica"
L["Every journey needs a pause ..."] = "Todo viaje necesita una pausa …"
L["Every region of this continent is explored."] = "Todas las regiones de este continente están exploradas."
L["Exploration"] = "Exploración"
L["Explored"] = "Explorada"
L["Explorer's checklist"] = "Lista del explorador"
L["Famous places of Azeroth"] = "Lugares famosos de Azeroth"
L["Find %d epic items."] = "Encuentra %d objetos épicos."
L["Find %d landmarks."] = "Encuentra %d lugares emblemáticos."
L["Find %d rare items."] = "Encuentra %d objetos raros."
L["Fortune and craft"] = "Fortuna y oficio"
L["Globetrotter's Day"] = "Día trotamundos"
L["Group with %d other adventurers."] = "Agrúpate con otros %d aventureros."
L["Haggler"] = "Regateador"
L["Hoarder"] = "Acaparador"
L["Homesick"] = "Morriña"
L["Honour earned: %s (%s)"] = "Honor obtenido: %s (%s)"
L["Honour earned: %s"] = "Honor obtenido: %s"
L["Honour points"] = "Puntos de honor"
L["Honour"] = "Honor"
L["Jump %d times."] = "Salta %d veces."
L["Just one more quest ..."] = "Solo una misión más …"
L["Keep this diary for %d days."] = "Lleva este diario durante %d días."
L["Landmark discovered: %s"] = "Lugar emblemático descubierto: %s"
L["Landmark"] = "Lugar emblemático"
L["Landmarks"] = "Lugares emblemáticos"
L["Loot %d items."] = "Recoge %d objetos."
L["Marathon"] = "Maratón"
L["Master of a Craft"] = "Maestro artesano"
L["Meet %d people."] = "Conoce a %d personas."
L["Mouse wheel: zoom  -  drag: move  -  right click: reset"] = "Rueda: zoom  -  arrastrar: mover  -  clic derecho: restablecer"
L["Next goals"] = "Próximos objetivos"
L["Next rank: %s"] = "Siguiente rango: %s"
L["Night Owl"] = "Ave nocturna"
L["Not every day is a good day ..."] = "No todos los días son buenos …"
L["Not yet explored"] = "Aún sin explorar"
L["Own %d gold."] = "Reúne %d de oro."
L["People met"] = "Personas conocidas"
L["Phoenix"] = "Fénix"
L["Play %d days in a row without dying."] = "Juega %d días seguidos sin morir."
L["Raids"] = "Bandas"
L["Raise a skill to %d."] = "Sube una profesión a %d."
L["Reach level %d."] = "Alcanza el nivel %d."
L["Regions explored"] = "Regiones exploradas"
L["Regular"] = "Cliente habitual"
L["Rest at %d places."] = "Descansa en %d lugares."
L["Secrets"] = "Secretos"
L["Sightseer"] = "Curioso"
L["Slay %d creatures in a single day."] = "Abate %d criaturas en un solo día."
L["Slay %d creatures."] = "Abate %d criaturas."
L["Slay %d elite creatures."] = "Abate %d criaturas de élite."
L["Slay %d of a single kind."] = "Abate %d criaturas de una misma especie."
L["Slay %d rare creatures."] = "Abate %d criaturas raras."
L["So many roads, so little time ..."] = "Tantos caminos y tan poco tiempo …"
L["Some honours stay hidden until you find them."] = "Algunos honores permanecen ocultos hasta que los encuentras."
L["Spend %d hours in the world on a single day."] = "Pasa %d horas en el mundo en un solo día."
L["Spend %d hours in the world."] = "Pasa %d horas en el mundo."
L["Take %d flights."] = "Realiza %d vuelos."
L["Talk to the same person %d times."] = "Habla %d veces con la misma persona."
L["The early bird catches the worm ..."] = "A quien madruga, Dios le ayuda …"
L["The purse over the days"] = "La bolsa a lo largo de los días"
L["There is no place like home ..."] = "Como en casa no se está en ningún sitio …"
L["This game client knows none of the landmarks."] = "Este cliente del juego no conoce ninguno de los lugares emblemáticos."
L["Towns of Kalimdor"] = "Lugares de Kalimdor"
L["Towns of the Eastern Kingdoms"] = "Lugares de los Reinos del Este"
L["Trade with %d players."] = "Comercia con %d jugadores."
L["Unexplored regions"] = "Regiones sin explorar"
L["Up, up and away ..."] = "Cada vez más alto …"
L["Use your hearthstone %d times."] = "Usa tu piedra de hogar %d veces."
L["Visit %d capital cities."] = "Visita %d capitales."
L["Visit %d regions in a single day."] = "Visita %d regiones en un solo día."
L["Visit %d regions."] = "Visita %d regiones."
L["Visit %d trainers."] = "Visita a %d instructores."
L["Walk %d kilometres."] = "Recorre %d kilómetros a pie."
L["Well Rested"] = "Bien descansado"
L["What is left to discover"] = "Lo que queda por descubrir"
L["When the moon stands highest ..."] = "Cuando la luna está en lo más alto …"
L["Where will the road lead tomorrow?"] = "¿Adónde llevará el camino mañana?"
L["Wings of the World"] = "Alas del mundo"
L["You have not seen this place yet."] = "Aún no has visto este lugar."
L["You have seen every landmark. Remarkable!"] = "Has visto todos los lugares emblemáticos. ¡Notable!"
L["days"] = "días"
L["done"] = "completadas"
L["given up"] = "abandonadas"
L["kills"] = "bajas"
L["open"] = "abiertas"
mx["Dungeons"] = "Calabozos"
mx["Enter %d dungeons."] = "Entra a %d calabozos."

-- treasure album, wanted posters
L["WANTED"] = "SE BUSCA"
L["of %d kinds"] = "de %d especies"
L["Next mark: %d slain"] = "Siguiente meta: %d abatidos"
L["Every mark reached"] = "Todas las metas alcanzadas"
L["Uncommon"] = "Poco común"
L["Epic"] = "Épico"
L["Legendary"] = "Legendario"

-- tasks of the day, pop-ups, week in review
L["Slay %d creatures today."] = "Abate %d criaturas hoy."
L["Complete %d quests today."] = "Completa %d misiones hoy."
L["Meet %d new people."] = "Conoce a %d personas nuevas."
L["Discover %d new places."] = "Descubre %d lugares nuevos."
L["Walk %d kilometres today."] = "Recorre %d kilómetros a pie hoy."
L["Find an uncommon or better item."] = "Encuentra un objeto poco común o mejor."
L["Visit the landmark %s."] = "Visita el lugar emblemático %s."
L["Set foot in %s."] = "Pon un pie en %s."
L["Task of the day done: %s"] = "Tarea del día cumplida: %s"
L["All tasks of the day done! %d days in a row."] = "¡Todas las tareas del día cumplidas! %d días seguidos."
L["All tasks of the day done!"] = "¡Todas las tareas del día cumplidas!"
L["Tasks of the day"] = "Tareas del día"
L["Task of the day"] = "Tarea del día"
L["Dungeon Crawler"] = "Explorador de mazmorras"
L["Finish %d dungeon runs."] = "Completa %d incursiones en mazmorras."
L["Diligent"] = "Diligente"
L["Do all tasks of the day on %d days."] = "Cumple todas las tareas del día en %d días."
L["Dutiful"] = "Cumplidor"
L["Do all tasks of the day %d days in a row."] = "Cumple todas las tareas del día %d días seguidos."
L["Open the diary"] = "Abrir el diario"
L["Close"] = "Cerrar"
L["The week in review"] = "Resumen de la semana"
L["Creatures slain"] = "Criaturas abatidas"
L["Levels"] = "Niveles"
L["Kilometres"] = "Kilómetros"
L["New places"] = "Lugares nuevos"
L["New regions"] = "Regiones nuevas"
L["Honours"] = "Honores"
L["Best day"] = "Mejor día"
L["A quiet week"] = "Una semana tranquila"
L["The book waits for new stories."] = "El libro espera nuevas historias."
L["Show a note for new discoveries"] = "Avisar de nuevos descubrimientos"
L["Weekly look back at login"] = "Resumen semanal al conectarse"

-- records, level timeline, gallery, nemeses, dungeon reports
L["Records"] = "Récords"
L["The best and the worst of days"] = "Los mejores y los peores días"
L["Most creatures slain in a day"] = "Más bajas en un día"
L["Most quests in a day"] = "Más misiones en un día"
L["Richest day"] = "Día más lucrativo"
L["Most experience in a day"] = "Más experiencia en un día"
L["Longest day in the world"] = "Día más largo en el mundo"
L["Longest walk in a day"] = "Caminata más larga en un día"
L["Most places discovered in a day"] = "Más lugares descubiertos en un día"
L["Most new faces in a day"] = "Más caras nuevas en un día"
L["Fastest level"] = "Nivel más rápido"
L["Slowest level"] = "Nivel más lento"
L["Longest run without dying"] = "Racha más larga sin morir"
L["Darkest day"] = "Día más negro"
L["Level timeline"] = "Cronología de niveles"
L["How long each level took"] = "Cuánto duró cada nivel"
L["Played for these levels"] = "Tiempo jugado en estos niveles"
L["Per level"] = "Por nivel"
L["No level-ups recorded yet."] = "Aún no hay subidas de nivel registradas."
L["Still on the way."] = "Aún en camino."
L["Reached the next level on day %d."] = "Siguiente nivel alcanzado el día %d."
L["Gallery"] = "Galería"
L["Moments, painted in the gear of their day"] = "Momentos, pintados con el equipo de su día"
L["The first painting waits for your first great moment."] = "El primer cuadro espera tu primer gran momento."
L["Nemeses"] = "Némesis"
L["They sent me to the spirit healer"] = "Me enviaron con el ángel de la resurrección"
L["Nemesis number one"] = "Némesis número uno"
L["Nobody has defeated you yet. Long may it last!"] = "Nadie te ha derrotado aún. ¡Que siga así!"
L["Killed you %d times"] = "Te mató %d {vez|veces}"
L["Revenge taken"] = "Venganza cumplida"
L["Score unsettled"] = "Cuentas pendientes"
L["You slew them %d times."] = "Los abatiste %d {vez|veces}."
L["Dungeon reports"] = "Informes de mazmorra"
L["No dungeon visited yet. The depths are waiting."] = "Aún no has visitado ninguna mazmorra. Las profundidades esperan."
L["Duration"] = "Duración"
L["Fallen"] = "Caídos"
L["The group"] = "El grupo"
L["Me"] = "Yo"
L["Nobody fell."] = "Nadie cayó."
mx["Dungeon Crawler"] = "Explorador de calabozos"
mx["Finish %d dungeon runs."] = "Completa %d incursiones en calabozos."
mx["Dungeon reports"] = "Informes de calabozo"
mx["No dungeon visited yet. The depths are waiting."] = "Aún no has visitado ningún calabozo. Las profundidades esperan."

-- ledger figures, achievement pop-up, blocked functions, quotes
L["Best day: day %d"] = "Mejor día: día %d"
L["Worst day: day %d"] = "Peor día: día %d"
L["Per day"] = "Por día"
L["Honour earned"] = "Honor obtenido"
L["Landmark discovered"] = "Lugar emblemático descubierto"
L["Next tier:"] = "Siguiente rango:"
L["Every tier earned - complete!"] = "Todos los rangos obtenidos: ¡completado!"
L["The game blocked the function %s. Please tell the author."] = "El juego bloqueó la función %s. Por favor, avisa al autor."
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "Este cliente no permite que los addons hagan capturas de pantalla. Las capturas en los grandes momentos quedan desactivadas."
L['"Here the journey ends, but not the story."'] = '«Aquí termina el viaje, pero no la historia.»'

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "Primeras veces"
L["First time"] = "Primera vez"
L["%d of %d experienced"] = "%d de %d vividas"
L["Not yet experienced."] = "Aún no vivido."
L["Click for all first times."] = "Haz clic para ver todas las primeras veces."
L["First creature slain"] = "Primera criatura abatida"
L["First quest completed"] = "Primera misión completada"
L["First level up"] = "Primera subida de nivel"
L["First uncommon item"] = "Primer objeto poco común"
L["First death"] = "Primera muerte"
L["First group"] = "Primer grupo"
L["First elite slain"] = "Primer élite abatido"
L["First trade"] = "Primer comercio"
L["First hearthstone"] = "Primera piedra de hogar"
L["First landmark"] = "Primer lugar emblemático"
L["First honour"] = "Primer honor"
L["First rare item"] = "Primer objeto raro"
L["First rare creature"] = "Primera criatura rara"
L["First flight"] = "Primer vuelo"
L["First gold coin"] = "Primera moneda de oro"
L["First dungeon"] = "Primera mazmorra"
L["First boss"] = "Primer jefe"
L["First skill at 75"] = "Primera profesión a 75"
L["First mount"] = "Primera montura"
L["First epic item"] = "Primer objeto épico"

L["Family book"] = "Libro de familia"
L["%d characters on this account"] = "%d {personaje|personajes} en esta cuenta"
L["you"] = "tú"
L["Last seen %s"] = "Visto por última vez el %s"
L["Who got there first?"] = "¿Quién llegó primero?"
L["Log in with your other characters once, and they will appear here."] = "Entra una vez con tus otros personajes y aparecerán aquí."

L["Time capsule"] = "Cápsula del tiempo"
L["Letters to my future self"] = "Cartas a mi yo del futuro"
L["Dear me, when you read this ..."] = "Querido yo, cuando leas esto …"
L["Seal the letter and open it ..."] = "Sellar la carta y abrirla …"
L["in a week"] = "en una semana"
L["in a month"] = "en un mes"
L["at level %d"] = "al nivel %d"
L["Until then the letter stays sealed - not even you can read it."] = "Hasta entonces la carta queda sellada: ni tú puedes leerla."
L["No letters yet."] = "Todavía no hay cartas."
L["Written on day %d, at level %d"] = "Escrita el día %d, a nivel %d"
L["Opened on %s"] = "Abierta el %s"
L["Sealed - opens on day %d"] = "Sellada - se abre el día %d"
L["Sealed - opens at level %d"] = "Sellada - se abre al nivel %d"
L["in %d days"] = "en %d {día|días}"
L["A letter for later was sealed."] = "Sellé una carta para más adelante."
L["A letter from the past has opened."] = "Se ha abierto una carta del pasado."
L["Click to read the letter."] = "Haz clic para leer la carta."

L["Gatherer's map"] = "Mapa del recolector"
L["Where the good things grow"] = "Donde crecen las cosas buenas"
L["Herbalism"] = "Herboristería"
L["Mining"] = "Minería"
L["Skinning"] = "Desuello"
L["Fishing"] = "Pesca"
L["Most found here"] = "Lo más encontrado aquí"
L["Nothing gathered yet. Herbs, ore and hides show up here as soon as you gather them."] = "Aún no has recolectado nada. Hierbas, mineral y pieles aparecerán aquí en cuanto los recojas."

L["Task of the week"] = "Tarea de la semana"
L["Task of the week done: %s"] = "Tarea de la semana cumplida: %s"
L["Click for the next goals."] = "Haz clic para ver los próximos objetivos."
L["Slay %d creatures this week."] = "Abate %d criaturas esta semana."
L["Complete %d quests this week."] = "Completa %d misiones esta semana."
L["Walk %d kilometres this week."] = "Recorre %d kilómetros a pie esta semana."
L["Meet %d new people this week."] = "Conoce a %d personas nuevas esta semana."
L["Visit %d different regions this week."] = "Visita %d regiones distintas esta semana."
L["Earn %d honour tiers this week."] = "Consigue %d niveles de honor esta semana."
L["Finish a dungeon run this week."] = "Completa una incursión en mazmorra esta semana."
L["Find %d new landmarks this week."] = "Encuentra %d lugares emblemáticos nuevos esta semana."
L["Week by Week"] = "Semana a semana"
L["Complete %d tasks of the week."] = "Cumple %d tareas de la semana."

L["Search the diary"] = "Buscar en el diario"
L["Days, people, creatures, quests, places, treasures and catches."] = "Días, personas, criaturas, misiones, lugares, tesoros y capturas."
L["Search: a name, a quest, a place ..."] = "Buscar: un nombre, una misión, un lugar …"
L["Nothing found."] = "No se encontró nada."
L["%d more results - type a little more"] = "%d resultados más - escribe un poco más"

L["The binding"] = "La encuadernación"
L["Corner studs"] = "Cantoneras"
L["none yet"] = "todavía ninguna"
L["Next metal at %d honour points (now %d)."] = "Siguiente metal con %d puntos de honor (ahora %d)."
L["Gems"] = "Gemas"
L["One gem for every ten honour tiers (now %d)."] = "Una gema por cada diez niveles de honor (ahora %d)."
L["Gold marks on the spine"] = "Marcas doradas en el lomo"
L["One for every ten levels."] = "Una por cada diez niveles."

-- the bookplate on the endpaper
L["FROM THE LIBRARY OF"] = "DE LA BIBLIOTECA DE"

-- sayings of the day (start page)
L["SAYING OF THE DAY"] = "REFRÁN DEL DÍA"
L["Whoever wanders, gathers stories."] = "Quien viaja, colecciona historias."
L["Every road starts at your own door."] = "Todo camino empieza en la puerta de casa."
L["A full pack is light when the heart is lighter."] = "Una mochila llena pesa poco si el corazón pesa menos."
L["Maps show the way - only feet know it."] = "Los mapas muestran el camino; solo los pies lo conocen."
L["The longest journey is the one you never write down."] = "El viaje más largo es el que nunca se escribe."
L["Ink fades slower than memory."] = "La tinta se borra más despacio que la memoria."
L["A good campfire turns strangers into companions."] = "Una buena hoguera convierte a extraños en compañeros."
L["The mountain does not care how tired you are - just keep going."] = "A la montaña no le importa tu cansancio: lo que cuenta es seguir."
L["Today's detour is tomorrow's best story."] = "El rodeo de hoy es la mejor historia de mañana."
L["Gold comes and goes, the story stays."] = "El oro va y viene; la historia se queda."
L["Count the days by friends, not by miles."] = "Cuenta los días por amigos, no por leguas."
L["Even the smallest kobold guards a candle for someone."] = "Hasta el kobold más pequeño guarda una vela para alguien."
L["Resting is part of the road."] = "Descansar también es parte del camino."
L["Fear is a map with too many blank spots."] = "El miedo es un mapa con demasiados espacios en blanco."
L["Every scar has a page in this book."] = "Cada cicatriz tiene su página en este diario."
L["Look back now and then - the view is part of the journey."] = "Mira atrás de vez en cuando: las vistas son parte del viaje."
L["The wise traveller asks the innkeeper first."] = "El viajero sabio pregunta primero al posadero."
L["Rain on the road, sunshine in the story."] = "Lluvia en el camino, sol en la historia."
L["Whoever never falls never learns to get up."] = "Quien nunca cae, nunca aprende a levantarse."
L["A quest half done is still a step forward."] = "Una misión a medias sigue siendo un paso adelante."
L["The horizon travels with you - that is why it never gets dull."] = "El horizonte viaja contigo; por eso nunca aburre."
L["Write it down, or it never happened."] = "Escríbelo, o nunca habrá pasado."
L["Old boots know more than new maps."] = "Las botas viejas saben más que los mapas nuevos."
L["Courage is being afraid and saddling up anyway."] = "Valor es tener miedo y ensillar de todos modos."
L["Tomorrow the road will still be there. Tonight the fire is warm."] = "Mañana el camino seguirá ahí. Esta noche, el fuego calienta."
L["A traveller's purse is light, a traveller's diary is heavy."] = "Bolsa ligera, diario pesado: así es el viajero."
L["The best places are on no map."] = "Los mejores lugares no salen en ningún mapa."
L["Every hero once did not know the way."] = "Todo héroe fue alguna vez alguien que no conocía el camino."
L["Share your bread, and the road shares its secrets."] = "Comparte tu pan y el camino compartirá sus secretos."
L["The story is not over while a page is still blank."] = "La historia no termina mientras quede una página en blanco."

-- covered cards in the bestiary: kinds your other characters know
L["Not yet discovered"] = "Aún sin descubrir"
L["Known to %s"] = "%s ya conoce esta criatura"
L["%d to discover"] = "%d por descubrir"
L["in the east"] = "en el este"
L["in the south-east"] = "en el sureste"
L["in the south"] = "en el sur"
L["in the south-west"] = "en el suroeste"
L["in the west"] = "en el oeste"
L["in the north-west"] = "en el noroeste"
L["in the north"] = "en el norte"
L["in the north-east"] = "en el noreste"
L["in the middle"] = "en el centro"
L["To the contents"] = "Ir al índice"
L["Screenshots at milestones: on"] = "Capturas en los hitos: activadas"
L["Screenshots at milestones: off"] = "Capturas en los hitos: desactivadas"
L["Demo mode is off."] = "Modo demo desactivado."
L["Demo mode is on. Nothing you do now is written into your diary - type /wfd demo again to leave."] = "Modo demo activado. Lo que hagas ahora no se escribe en tu diario; escribe /wfd demo otra vez para salir."
L["You have died, but who did it slipped past the diary."] = "Ya has muerto, pero quién fue se le escapó al diario."
L["Already in the quest log"] = "Aceptadas antes del diario"
L["Angler"] = "Pescador"
L["Raise Fishing to %d."] = "Sube Pesca a %d."
L["Big Catch"] = "Buena pesca"
L["Catch %d fish."] = "Pesca %d peces."
L["Field Medic"] = "Médico de campaña"
L["Raise First Aid to %d."] = "Sube Primeros auxilios a %d."
L["Camp Cook"] = "Cocinero de campamento"
L["Raise Cooking to %d."] = "Sube Cocina a %d."
L["Sighted, not yet slain"] = "Avistado, aún sin abatir"
L["perhaps %s"] = "quizá %s"
L["You have been %s of this area least of all. Something may still be waiting there."] = "Donde menos has estado es %s de esta zona. Quizá aún te espere algo allí."
L["Defeat a boss."] = "Derrota a un jefe."
L["Slay a rare creature."] = "Abate a una criatura rara."
L["Slay an elite creature."] = "Abate a una criatura élite."
L["Visit a capital city."] = "Visita una capital."
L["Enter a dungeon."] = "Entra en una mazmorra."
L["Take a flight."] = "Toma un vuelo."
L["Group with another adventurer."] = "Agrúpate con otro aventurero."
L["Visit a trainer."] = "Visita a un instructor."
L["Trade with another player."] = "Comercia con otro jugador."
L["Complete a quest."] = "Completa una misión."
L["Die once and rise again."] = "Muere una vez y vuelve a levantarte."
L["Finish a dungeon run."] = "Termina una incursión en mazmorra."
L["Do all tasks of the day on one day."] = "Cumple todas las tareas del día en un día."
L["Complete a task of the week."] = "Cumple una tarea de la semana."
L["Find a rare item."] = "Encuentra un objeto raro."
L["Find an epic item."] = "Encuentra un objeto épico."
L["Dear me, if you are reading this, you made it through the first week. Did you ever find out who was stealing the candles in the mine?"] = "Querido yo: si lees esto, has superado la primera semana. ¿Llegaste a descubrir quién robaba las velas de la mina?"
L["Marker set on the map: %s (%d, %d)"] = "Marcador colocado en el mapa: %s (%d, %d)"
L["No marker can be set on this map."] = "No se puede colocar un marcador en este mapa."
L["Click to set a marker on the map."] = "Haz clic para colocar un marcador en el mapa."
L["Right-click for the map of this region."] = "Clic derecho para ver el mapa de esta región."
L["1 kind"] = "1 especie"
L["Discover a new place."] = "Descubre un lugar nuevo."
L["Walk one kilometre today."] = "Recorre un kilómetro a pie hoy."
L["WELCOME"] = "BIENVENIDA"
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "Tú juega, que yo voy escribiendo. Cada día que juegues se convierte en una página de este libro."
L["See a sample book"] = "Ver un libro de ejemplo"
L["To today's entry"] = "Ir al día de hoy"
L["Discover %d flight paths."] = "Descubre %d rutas de vuelo."
L["A sketch - %d more and it is in colour."] = "Un boceto: %d más y tendrá color."
L["%d more to become a connoisseur."] = "%d más para ser un experto."
L["Connoisseur of this kind"] = "Experto en esta especie"
L["First slain on day %d"] = "Abatido por primera vez el día %d"
L["Best loot"] = "Mejor botín"
L["Got you once."] = "Te venció una vez."
L["Got you %d times."] = "Te venció %d {vez|veces}."
L["CONNOISSEUR"] = "EXPERTO"
L["Connoisseur"] = "Experto"
L["Right-click to close."] = "Clic derecho para cerrar."
L["The tabs"] = "Las pestañas"
L["The tabs on the right lead to the parts of the book, one colour for each group. Point at them to read their names. A red dot shows how much is new since you last read."] = "Las pestañas de la derecha llevan a las partes del libro, un color por grupo. Pasa el ratón por encima para leer sus nombres. Un punto rojo muestra cuánto hay de nuevo desde tu última lectura."
L["The spyglass on the spine searches the whole book: days, people, creatures, quests, places, treasures and catches. Ctrl + F opens it too."] = "La lupa del lomo busca en todo el libro: días, personas, criaturas, misiones, lugares, tesoros y capturas. Ctrl + F también la abre."
L["Your own bookmarks"] = "Tus marcapáginas"
L["bookmark"] = "marcapáginas"
L["Goals and honour"] = "Metas y honor"
L["The world"] = "El mundo"
L["Hunt and loot"] = "Caza y botín"
L["People and money"] = "Gente y dinero"
L["Keepsakes"] = "Recuerdos"
L["Best find for every slot"] = "Mejor hallazgo para cada ranura"
L["worn right now"] = "equipado ahora"
L["Click to show only these."] = "Haz clic para mostrar solo estos."
L["Click to show all again."] = "Haz clic para volver a mostrar todo."
L["Shown: %s only"] = "Mostrado: solo %s"
L["Show all"] = "Mostrar todo"
L["Ctrl-click to set or remove a bookmark here."] = "Ctrl-clic para poner o quitar un marcapáginas aquí."
L["Click to open, right-click to remove."] = "Clic para abrir, clic derecho para quitar."
L["You are here."] = "Estás aquí."
L["Click for the hunting grounds of this area."] = "Haz clic para ver los cotos de caza de esta zona."
L["Who is closest to the next stage"] = "Quién está más cerca de la siguiente etapa"
L["%d more, then in colour"] = "%d más y estará en color"
L["%d more, then a connoisseur"] = "%d más y serás experto"
L["To the album of this area"] = "Al álbum de esta zona"
L["Every kind known here is collected."] = "Todas las especies conocidas aquí están en la colección."
L["Kinds of creatures"] = "Tipos de criaturas"
L["What you have slain, by type"] = "Lo que has abatido, por tipo"
L["Unknown kind"] = "Tipo desconocido"
L["%d kinds  -  %d slain"] = "%d {especie|especies}  -  %d {abatido|abatidos}"
L["Hunting grounds"] = "Cotos de caza"
L["Sighted"] = "Avistado"
L["Kinds slain here"] = "Especies abatidas aquí"
L["Each pin marks where the first of its kind fell."] = "Cada marca indica dónde cayó el primero de su especie."
L["Versatile Hunter"] = "Cazador versátil"
L["Slay creatures of %d different types."] = "Abate criaturas de %d tipos distintos."
L["Slay 50 of each of %d kinds."] = "Abate 50 de cada una de %d especies."
L["Slay 50 of one kind."] = "Abate 50 criaturas de una misma especie."
L["Quick on its feet, but it never looks back."] = "Rápido de patas, pero nunca mira atrás."
L["Its pelt would fetch a fair price in town."] = "Su piel valdría un buen precio en la ciudad."
L["Talks big, fights small."] = "Mucho hablar, poco luchar."
L["Carried more coins than sense."] = "Llevaba más monedas que sentido común."
L["Smells worse than it fights."] = "Huele peor de lo que lucha."
L["Dead once already. Twice is a habit."] = "Ya murió una vez. Dos veces es costumbre."
L["Burning eyes, burning temper."] = "Ojos ardientes, genio ardiente."
L["Whoever summoned this one owes me an apology."] = "Quien lo invocó me debe una disculpa."
L["Not alive, not dead - simply angry."] = "Ni vivo ni muerto: simplemente furioso."
L["Left nothing behind but a puddle of fury."] = "No dejó más que un charco de furia."
L["Scales like armour. Mind the tail."] = "Escamas como armadura. Cuidado con la cola."
L["One day I will face its big brothers."] = "Algún día me enfrentaré a sus hermanos mayores."
L["The ground shook long after it fell."] = "El suelo tembló mucho después de su caída."
L["Big enough to have its own weather."] = "Tan grande que tiene su propio clima."
L["Gnomish work, no doubt. Loud and leaky."] = "Obra gnómica, sin duda. Ruidosa y con fugas."
L["It sparked, it whirred, it stopped."] = "Chispeó, zumbó y se detuvo."
L["It never stood a chance."] = "Nunca tuvo ninguna oportunidad."
L["Small, harmless and now a footnote."] = "Pequeño, inofensivo y ahora una nota al pie."
L["A strange creature. I made a note, just in case."] = "Una criatura extraña. Tomé nota, por si acaso."
L["Worth remembering, or at least worth writing down."] = "Digno de recordar, o al menos de anotar."
L["Back"] = "Atrás"
L["To the page you came from (Backspace)."] = "A la página de la que venías (Retroceso)."
L["Go to page (1 - %d):"] = "Ir a la página (1 - %d):"
L["Size: %d%%"] = "Tamaño: %d%%"
L["Search"] = "Buscar"
L["Turning pages"] = "Pasar páginas"
L["Turn the pages with the arrows, the mouse wheel or the arrow keys. The red ribbon below always leads to today; Backspace takes you back. Ctrl + mouse wheel changes the size of the book."] = "Pasa las páginas con las flechas, la rueda del ratón o las teclas de flecha. La cinta roja de abajo lleva siempre a hoy; Retroceso te devuelve. Ctrl + rueda cambia el tamaño del libro."
L["Almost everything can be clicked"] = "Casi todo se puede pulsar"
L["Next"] = "Siguiente"
L["Skip"] = "Omitir"
L["Got it"] = "Entendido"
L["Handling"] = "Manejo"
L["Keys"] = "Teclas"
L["Notifications"] = "Avisos"
L["Important only"] = "Solo lo importante"
L["Quiet"] = "Silencio"
L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] = "Importante: niveles, jefes, criaturas y hallazgos raros, mazmorras, honores y cartas."
L["Keys while the mouse is over the book"] = "Teclas con el ratón sobre el libro"
L["Arrow keys, Page up / down"] = "Flechas, Re Pág / Av Pág"
L["turn the page"] = "pasar página"
L["Home"] = "Inicio"
L["contents"] = "índice"
L["End"] = "Fin"
L["today's entry"] = "entrada de hoy"
L["Backspace"] = "Retroceso"
L["back"] = "atrás"
L["Ctrl + mouse wheel"] = "Ctrl + rueda del ratón"
L["size of the book"] = "tamaño del libro"
L["Ctrl + F"] = "Ctrl + F"
L["search the book"] = "buscar en el libro"
L["go to a page"] = "ir a una página"
L["open or close the book"] = "abrir o cerrar el libro"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "Puedes asignar una tecla para abrir el libro en las asignaciones de teclas del juego, en AddOns."
L["The book"] = "El libro"
L["Reset the position"] = "Restablecer la posición"
L["Show the introduction again"] = "Mostrar de nuevo la introducción"
L["Open the scribe's notes"] = "Abrir las notas del escriba"
L["Right-click to go to a page."] = "Clic derecho para ir a una página."
L["%d new since you last read"] = "%d nuevos desde tu última lectura"
L["Right-click for the settings."] = "Clic derecho para los ajustes."
L["Drag to move this button."] = "Arrastra para mover este botón."
L["Click to open."] = "Haz clic para abrir."
L["Moving code"] = "Código de mudanza"
L["This code holds the whole diary of this character. Copy it with Ctrl+C and keep it somewhere safe, for example in a text file. On the other computer, open the same window with \"Read a moving code\" and paste it there."] = "Este código contiene todo el diario de este personaje. Cópialo con Ctrl+C y guárdalo en un lugar seguro, por ejemplo en un archivo de texto. En el otro ordenador, abre la ventana con «Leer un código de mudanza» y pégalo allí."
L["The code could not be made."] = "No se pudo crear el código."
L["%d days, %d characters. Now press Ctrl+C."] = "%d días, %d caracteres. Ahora pulsa Ctrl+C."
L["Read a moving code"] = "Leer un código de mudanza"
L["Paste the moving code of this character with Ctrl+V. The diary written on this computer is then replaced by the one from the code, and the interface is reloaded."] = "Pega el código de mudanza de este personaje con Ctrl+V. El diario de este ordenador se sustituirá por el del código y la interfaz se recargará."
L["Waiting for a code ..."] = "Esperando un código …"
L["Replace the diary and reload"] = "Sustituir el diario y recargar"
L["This is not a moving code of the diary."] = "Esto no es un código de mudanza del diario."
L["The code is damaged or incomplete. Copy it again, all of it."] = "El código está dañado o incompleto. Cópialo de nuevo, entero."
L["Diary of %s (%s), %d days, %d kinds of creatures, %d people."] = "Diario de %s (%s), %d días, %d especies de criaturas, %d personas."
L["Careful: this code belongs to %s, but you are playing %s."] = "Cuidado: este código pertenece a %s, pero estás jugando con %s."
L["The diary of this character on this computer will be replaced."] = "El diario de este personaje en este ordenador será sustituido."
L["Leave demo mode first."] = "Sal primero del modo de demostración."
L["moving code of this character"] = "código de mudanza de este personaje"
L["read a moving code"] = "leer un código de mudanza"
L["Moving to another computer"] = "Mudanza a otro ordenador"
L["Make a moving code"] = "Crear un código de mudanza"
L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."] = "O simplemente llévate la carpeta WTF del juego: contiene los diarios de todos los personajes."
L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."] = "Una ventana pequeña con las cifras de hoy, las tareas y los honores más cerca de su siguiente grado. Arrástrala por el título y pliégala con el signo menos."
L["Appearance"] = "Apariencia"
L["Both reload the interface. With bigger writing a few long lines may run close together."] = "Ambas opciones recargan la interfaz. Con letra más grande, algunas líneas largas pueden quedar muy juntas."
L["Click to open the diary there."] = "Haz clic para abrir el diario ahí."
L["Companion"] = "Acompañante"
L["Fold in or out"] = "Plegar o desplegar"
L["Leather and gold"] = "Cuero y oro"
L["Modern"] = "Moderno"
L["Next honours"] = "Próximos honores"
L["Online"] = "En línea"
L["Show the companion beside the game"] = "Mostrar la ventana acompañante junto al juego"
L["Size of the writing"] = "Tamaño de la letra"
L["Strong contrast"] = "Contraste alto"
L["Style of the book"] = "Estilo del libro"
L["The companion can be shown again in the settings or with /wfd companion."] = "La ventana acompañante se puede volver a mostrar en los ajustes o con /wfd companion."
L["Turn the leaves visibly"] = "Pasar las hojas de forma visible"
L["Turning the pages"] = "Pasar páginas"
L["km"] = "km"
L["reloads the interface"] = "recarga la interfaz"
L["show or hide the companion"] = "mostrar u ocultar la ventana acompañante"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "El diario que había aquí era de un personaje anterior con el mismo nombre. Se ha guardado aparte y se ha empezado un diario nuevo para ti. |cffffd100/wfd restore|r lo recupera."
L["bring back the diary put aside"] = "recuperar el diario guardado aparte"
L["No diary has been put aside."] = "No hay ningún diario guardado aparte."
L["The diary put aside is back. The interface is reloaded."] = "El diario guardado aparte ha vuelto. Se recarga la interfaz."

-- Angler's log
L["Angler's log"] = "Diario de pesca"
L["A collector's album of everything the line brought up"] = "Un álbum de coleccionista de todo lo que sacó el sedal"
L["catches collected  -  %d things landed"] = "capturas reunidas  -  %d piezas sacadas"
L["Land %d different catches."] = "Saca %d capturas distintas."
L["Casts"] = "Lanzamientos"
L["Fish"] = "Pez"
L["Treasure"] = "Tesoro"
L["Junk"] = "Basura"
L["Odds and ends"] = "Cosas varias"
L["1 catch"] = "1 captura"
L["%d catches"] = "%d capturas"
L["Nothing has bitten yet."] = "Todavía no ha picado nada."
L["Waters and tackle"] = "Aguas y aparejos"
L["Where it bites, and what you fished with"] = "Dónde pica y con qué pescaste"
L["Waters"] = "Aguas"
L["%d caught in %d casts"] = "%d {captura|capturas} en %d {lanzamiento|lanzamientos}"
L["Tackle"] = "Aparejos"
L["%d casts"] = "%d {lanzamiento|lanzamientos}"
L["No fishing pole seen yet."] = "Aún no se ha visto ninguna caña."
L["Casts with a lure"] = "Lanzamientos con cebo"
L["Casts in all"] = "Lanzamientos en total"
L["CAUGHT"] = "CAPTURADO"
L["Mostly caught in"] = "Se pesca sobre todo en"
L["Caught"] = "Capturado"
L["Of all catches"] = "De todas las capturas"
L["First catch"] = "Primera captura"
L["Last catch"] = "Última captura"
L["On a lure"] = "Con cebo"
L["WHERE IT BIT"] = "DÓNDE PICÓ"
L["Next mark: %d caught"] = "Próxima marca: %d capturados"
L["New catch: %s"] = "Nueva captura: %s"
L["Catch"] = "Captura"
L["Fish Lore"] = "Saber de peces"
L["Fishing pole"] = "Caña de pescar"
L["Lure"] = "Cebo"
L["Fishing gear"] = "Equipo de pesca"

-- 0.1.11: the today page, group pages, dog-ears, search filters, the companion's offer
L["Click to go to a page."] = "Haz clic para ir a una página."
L["Right-click for the contents."] = "Clic derecho para el índice."
L["Click to set a bookmark here."] = "Haz clic para poner un marcapáginas aquí."
L["Click to remove the bookmark."] = "Haz clic para quitar el marcapáginas."
L["Click the folded corner of a page to keep it. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away."] = "Haz clic en la esquina doblada de una página para guardarla. Una cinta asoma entonces por arriba del libro: un clic abre la página, un clic derecho quita la cinta."
L["Cards, names, days and maps open more. Click the page number to go to any page. The settings have a tab of their own at the bottom."] = "Las cartas, nombres, días y mapas abren más. Haz clic en el número de página para ir a cualquier página. Los ajustes tienen su propia pestaña, abajo del todo."
L["Click to open the settings."] = "Haz clic para abrir los ajustes."
L["All %d bookmarks are in use. Remove one first."] = "Los %d marcapáginas están en uso. Quita uno primero."
L["Before the diary"] = "Antes del diario"
L["Continue reading: %s, p. %d"] = "Seguir leyendo: %s, p. %d"
L["open a part: today, bestiary, honour, ledger, atlas, settings ... or a day number"] = "abrir una parte: today, bestiary, honour, ledger, atlas, settings … o un número de día"
L["Parchment"] = "Pergamino"
L["Parchment is bright, like old quest paper."] = "Pergamino es claro, como el papel de las misiones."
L["General"] = "General"
L["Tasks"] = "Tareas"
L["Day, week and month"] = "Día, semana y mes"
L["Perfect days"] = "Días perfectos"
L["Longest run"] = "Racha más larga"
L["Tasks done"] = "Tareas cumplidas"
L["Weeks done"] = "Semanas cumplidas"
L["Months done"] = "Meses cumplidos"
L["Task of the month"] = "Tarea del mes"
L["Task of the month done: %s"] = "Tarea del mes cumplida: %s"
L["Slay %d creatures this month."] = "Abate %d criaturas este mes."
L["Complete %d quests this month."] = "Completa %d misiones este mes."
L["Walk %d kilometres this month."] = "Recorre %d kilómetros a pie este mes."
L["Meet %d new people this month."] = "Conoce a %d personas nuevas este mes."
L["Visit %d different regions this month."] = "Visita %d regiones distintas este mes."
L["Earn %d honour tiers this month."] = "Consigue %d niveles de honor este mes."
L["Finish %d dungeon runs this month."] = "Completa %d incursiones en mazmorra este mes."
L["Find %d new landmarks this month."] = "Encuentra %d lugares emblemáticos nuevos este mes."
L["Click to set a waypoint on the map."] = "Haz clic para marcar un punto de ruta en el mapa."
L["Waypoint set: %s"] = "Punto de ruta marcado: %s"
L["Map controls"] = "Controles del mapa"
L["Mouse wheel: zoom"] = "Rueda del ratón: zoom"
L["Drag: move the map"] = "Arrastrar: mover el mapa"
L["Right click: reset"] = "Clic derecho: restablecer"
L["New in the diary. Click to refresh."] = "Novedades en el diario. Haz clic para actualizar."
L["Click the page number"] = "Clic en el número de página"
L["Click the folded corner"] = "Clic en la esquina doblada"
L["New since you last read"] = "Nuevo desde tu última lectura"
L["Nothing new since you last read."] = "Nada nuevo desde tu última lectura."
L["Fills as soon as there is something to tell."] = "Se llena en cuanto haya algo que contar."
L["Show the cover when the book is first opened"] = "Mostrar la portada al abrir el libro por primera vez"
L["%d new moments"] = "%d momentos nuevos"
L["The companion"] = "El acompañante"
L["A small window beside the game shows today's figures, the tasks and the honours closest to their next tier. You can switch it on and off in the settings."] = "Una pequeña ventana junto al juego muestra las cifras de hoy, las tareas y los honores más cerca de su siguiente nivel. Puedes activarla o desactivarla en los ajustes."
L["Show it"] = "Mostrarla"
L["Names from the game (places, creatures, items) stay in the language of the game client."] = "Los nombres del juego (lugares, criaturas, objetos) se quedan en el idioma del cliente."

L["%d days  -  %d kills  -  %d quests"] = "%d {día|días}  -  %d {baja|bajas}  -  %d {misión|misiones}"

-- memories and anniversaries
L["A memory"] = "Recuerdo"
L["Read that day (day %d)"] = "Leer ese día (día %d)"
L["The diary's birthday"] = "El cumpleaños del diario"
L["%d hours in the world"] = "%d horas en este mundo"
L["Anniversary"] = "Aniversario"
L["Nothing from earlier days to remember today."] = "Hoy no hay ningún recuerdo de días pasados."
L["A memory on the Today page"] = "Un recuerdo en la página Hoy"
L["A memory as a note at login"] = "Un recuerdo como aviso al conectarse"
L["show today's memory again"] = "volver a mostrar el recuerdo de hoy"
loc.narrator.memory = {
    years = "{Hoy hace un año|Hoy hace %d años}",
    days = "Hace %d días",
    intro = {
        "%s, andaba por %s.",
        "%s, mi camino pasaba por %s.",
    },
    first = "Y una primera vez: %s.",
}
loc.narrator.jubilee = {
    born = "Ya {ha pasado un año|han pasado %d años} desde que escribí la primera página de este diario.",
    hours = "Ya llevo %d horas en este mundo. Eso es mucho camino.",
    level = "Ya {ha pasado un año|han pasado %d años} desde que llegué al nivel %d.",
}

-- fate: every death
L["Fate"] = "Destino"
L["Every fall on the way"] = "Cada caída en el camino"
L["Places of death"] = "Lugares de muerte"
L["Last death"] = "Última muerte"
L["None of the graves has a place on a map yet."] = "Ninguna tumba tiene todavía un lugar en un mapa."
L["Graves here: %d"] = "Tumbas aquí: %d"
L["Where you fall most"] = "Dónde caes más"
L["Who defeated you most"] = "Quién te ha vencido más veces"
L["Deaths by level"] = "Muertes por nivel"
L["Foe unknown: %d"] = "Enemigo desconocido: %d"
L["Every death"] = "Todas las muertes"
L["Cause unknown"] = "Causa desconocida"
L["Group: %d"] = "Grupo: %d"
L["Stubborn"] = "Tenaz"
L["Defeat a foe that has defeated you three times."] = "Derrota a un enemigo que te ha vencido tres veces."

-- the journey replayed on the atlas
L["Watch the journey grow"] = "Ver crecer el viaje"
L["Day by day, from the first step to today."] = "Día a día, desde el primer paso hasta hoy."
L["Pause"] = "Pausa"
L["Keep the picture"] = "Guardar la imagen"
L["Drag to go to a day."] = "Arrastra para ir a un día."
L["Esc ends the replay."] = "Esc termina la reproducción."
L["This game client does not allow addons to take screenshots."] = "Este cliente no permite que los addons hagan capturas de pantalla."
L["kill"] = "baja"
L["day"] = "día"
L["%d kinds %s already knows"] = "%d especies que %s ya conoce"
L["%d honours earned: %s"] = "%d honores obtenidos: %s"
L["continued"] = "continuación"
L["Regions"] = "Regiones"
L["Nothing slain here yet."] = "Aquí aún no has abatido nada."
L["No places discovered here yet."] = "Aquí aún no has descubierto ningún lugar."
L["The diary could not tell who it was."] = "El diario no pudo saber quién fue."
L["Every first, with its day and place"] = "Cada primera vez, con su día y su lugar"
L["Leather and gold is the classic book. Modern is flat and calm, strong contrast makes all writing brighter."] = "Cuero y oro es el libro clásico. Moderno es sobrio y tranquilo; el contraste alto aclara todo el texto."
L["Still to come"] = "Pendientes"
L["%d still to find"] = "faltan %d por descubrir"
L["No nemesis yet: nobody has defeated you so far."] = "Aún no hay archienemigo: nadie te ha derrotado hasta ahora."
L["At a glance"] = "De un vistazo"
L["Data"] = "Datos"
L["Library"] = "Biblioteca"
L["Books I read along the way"] = "Libros que leí por el camino"
L["Book"] = "Libro"
L["Note"] = "Nota"
L["Plaque"] = "Placa"
L["%d books on the shelf"] = "%d {libro|libros} en la estantería"
L["Reading desk"] = "Atril de lectura"
L["Recently added"] = "Añadidos recientemente"
L["To read later"] = "Para leer más tarde"
L["Nothing is kept for later."] = "Nada está guardado para más tarde."
L["The shelf is empty. Every book, note and plaque you read will stand here."] = "La estantería está vacía. Cada libro, nota y placa que leas estará aquí."
L["Pages are missing: read the rest to complete this book."] = "Faltan páginas: lee el resto para completar este libro."
L["Read by %s on %s"] = "Leído por %s el %s"
L["Read later"] = "Leer más tarde"
L["Bookworm"] = "Ratón de biblioteca"
L["Read %d books, notes and plaques."] = "Lee %d libros, notas y placas."
L["Read a book, a note or a plaque."] = "Lee un libro, una nota o una placa."
L["Scholar"] = "Erudito"
L["Read %d books to the last page."] = "Lee %d libros hasta la última página."
L["Read a book to the last page."] = "Lee un libro hasta la última página."
