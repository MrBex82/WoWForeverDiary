-- Spanish translation for Spain (esES) and Latin America (esMX) (English phrases are the keys)
local ADDON, WFD = ...
local L, loc, extra = WFD:NewLocale({ "esES", "esMX" })

local T = {
    -- chat / log
    ["Diary"] = "Diario",
    ["Travel diary active. Today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
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
    ["DEMO MODE: invented data"] = "MODO DEMO: datos inventados",

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

    -- people
    ["First met"] = "Primer encuentro",
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
    ["Slain"] = "Abatidos",
    ["First kill"] = "Primera baja",
    ["Last kill"] = "Última baja",
    ["Seen in"] = "Visto en",
    ["Killed you"] = "Te ha matado",
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
L["Begun on %s"] = "Comenzado el %s"
L["Bookmark"] = "Marcapáginas"
L["Click to open today's entry."] = "Haz clic para abrir la entrada de hoy."
L["Click to open"] = "Haz clic para abrir"
L["Notes"] = "Notas"
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
L["The pages are still empty. Go and live an adventure!"] = "Las páginas aún están en blanco. ¡Sal a vivir una aventura!"
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
L["Bronze"] = "Bronce"
L["Silver"] = "Plata"
L["Mithril"] = "Mitril"
L["Legend"] = "Leyenda"
L["Collect %d kinds of creatures."] = "Colecciona %d especies de criaturas."
L["Bosses"] = "Jefes"
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
L["Grave"] = "Tumba"
L["Visits"] = "Visitas"
L["Deaths here"] = "Muertes aquí"
L["Most hunted here"] = "Lo más cazado aquí"
L["Places discovered"] = "Lugares descubiertos"

-- companions, honours, treasures, memories, obituary
L["%d days of life, %d creatures slain, %d quests completed"] = "%d {día|días} de vida, %d {criatura abatida|criaturas abatidas}, %d {misión completada|misiones completadas}"
L["%d days"] = "%d {día|días}"
L["%d enemies fell that day."] = "Ese día {cayó|cayeron} %d {enemigo|enemigos}."
L["%d kills together"] = "%d {baja|bajas} juntos"
L["%d times grouped"] = "%d {vez|veces} en grupo"
L["%d treasures collected"] = "%d {tesoro reunido|tesoros reunidos}"
L["%dx traded"] = "%d intercambios"
L["A painted memory"] = "Un recuerdo pintado"
L["Book of honour"] = "Libro de honor"
L["Companions"] = "Compañeros"
L["Copy for forum or Discord (Markdown)"] = "Copiar para foro o Discord (Markdown)"
L["Quickest to the level"] = "El más rápido al nivel"
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
L["Mouse wheel: zoom, drag: move, right click: reset"] = "Rueda: zoom, arrastrar: mover, clic derecho: restablecer"
L["Next rank: %s"] = "Siguiente rango: %s"
L["Night Owl"] = "Ave nocturna"
L["Not every day is a good day ..."] = "No todos los días son buenos …"
L["Not yet explored"] = "Aún sin explorar"
L["Own %d gold."] = "Reúne %d de oro."
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
L["The book waits for new stories."] = "El libro espera nuevas historias."
L["Show a note for new discoveries"] = "Avisar de nuevos descubrimientos"
L["Weekly look back at login"] = "Resumen semanal al conectarse"
L["Show when an item was first found in its tooltip"] = "Mostrar en la descripción cuándo encontré el objeto por primera vez"
L["In the diary: first found on %s"] = "En el diario: encontrado por primera vez el %s"
L["from %s"] = "de %s"

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
L["Every tier earned!"] = "¡Todos los rangos obtenidos!"
L["The game blocked the function %s. Please tell the author."] = "El juego bloqueó la función %s. Por favor, avisa al autor."
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "Este cliente no permite que los addons hagan capturas de pantalla. Las capturas en los grandes momentos quedan desactivadas."
L['"Here the journey ends, but not the story."'] = '«Aquí termina el viaje, pero no la historia.»'

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "Primeras veces"
L["First time"] = "Primera vez"
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
L["Until then the letter stays sealed. Not even you can read it."] = "Hasta entonces la carta queda sellada: ni tú puedes leerla."
L["No letters yet."] = "Todavía no hay cartas."
L["Written on day %d, at level %d"] = "Escrita el día %d, a nivel %d"
L["Opened on %s"] = "Abierta el %s"
L["Sealed, opens on day %d"] = "Sellada, se abre el día %d"
L["Sealed, opens at level %d"] = "Sellada, se abre al nivel %d"
L["in %d days"] = "en %d {día|días}"
L["A letter for later was sealed."] = "Sellé una carta para más adelante."
L["A letter from the past has opened."] = "Se ha abierto una carta del pasado."
L["Click to read the letter."] = "Haz clic para leer la carta."

L["Gatherer's map"] = "Mapa del recolector"
L["Herbalism"] = "Herboristería"
L["Mining"] = "Minería"
L["Skinning"] = "Desuello"
L["Fishing"] = "Pesca"

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
L["%d more results, type a little more"] = "%d resultados más, escribe un poco más"

L["The binding"] = "La encuadernación"
L["Corner studs"] = "Cantoneras"
L["none yet"] = "todavía ninguna"
L["Next metal at %d honour points (now %d)."] = "Siguiente metal con %d puntos de honor (ahora %d)."
L["Gems"] = "Gemas"
L["One gem for every ten honour tiers (now %d)."] = "Una gema por cada diez niveles de honor (ahora %d)."
L["Gold marks on the spine"] = "Marcas doradas en el lomo"
L["One for every ten levels."] = "Una por cada diez niveles."

-- the bookplate on the endpaper

-- sayings of the day (start page)

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
L["Screenshots at milestones: on"] = "Capturas en los hitos: activadas"
L["Screenshots at milestones: off"] = "Capturas en los hitos: desactivadas"
L["Demo mode is off."] = "Modo demo desactivado."
L["Demo mode is on. Nothing you do now is written into your diary. Type /wfd demo again to leave."] = "Modo demo activado. Lo que hagas ahora no se escribe en tu diario; escribe /wfd demo otra vez para salir."
L["You have died, but who did it slipped past the diary."] = "Ya has muerto, pero quién fue se le escapó al diario."
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
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "Tú juega, que yo voy escribiendo. Cada día que juegues se convierte en una página de este libro."
L["Discover %d flight paths."] = "Descubre %d rutas de vuelo."
L["A sketch: %d more and it is in colour."] = "Un boceto: %d más y tendrá color."
L["%d more to become a connoisseur."] = "%d más para ser un experto."
L["Connoisseur of this kind"] = "Experto en esta especie"
L["First slain on day %d"] = "Abatido por primera vez el día %d"
L["Best loot"] = "Mejor botín"
L["Got you once."] = "Te venció una vez."
L["Got you %d times."] = "Te venció %d {vez|veces}."
L["CONNOISSEUR"] = "EXPERTO"
L["Connoisseur"] = "Experto"
L["Right-click to close."] = "Clic derecho para cerrar."
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
L["Ctrl-click to set or remove a bookmark here."] = "Ctrl-clic para poner o quitar un marcapáginas aquí."
L["Click to open, right-click to remove."] = "Clic para abrir, clic derecho para quitar."
L["You are here."] = "Estás aquí."
L["Click for the hunting grounds of this area."] = "Haz clic para ver los cotos de caza de esta zona."
L["%d more, then in colour"] = "%d más y estará en color"
L["%d more, then a connoisseur"] = "%d más y serás experto"
L["%d kinds, %d slain"] = "%d {especie|especies}, %d {abatido|abatidos}"
L["Hunting grounds"] = "Cotos de caza"
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
L["Not alive, not dead, simply angry."] = "Ni vivo ni muerto: simplemente furioso."
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
L["Size: %d%%"] = "Tamaño: %d%%"
L["Next"] = "Siguiente"
L["Keys"] = "Teclas"
L["Notifications"] = "Avisos"
L["Important only"] = "Solo lo importante"
L["Quiet"] = "Silencio"
L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] = "Importante: niveles, jefes, criaturas y hallazgos raros, mazmorras, honores y cartas."
L["Home"] = "Inicio"
L["End"] = "Fin"
L["today's entry"] = "entrada de hoy"
L["Backspace"] = "Retroceso"
L["back"] = "atrás"
L["Ctrl + mouse wheel"] = "Ctrl + rueda del ratón"
L["Ctrl + F"] = "Ctrl + F"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "Puedes asignar una tecla para abrir el libro en las asignaciones de teclas del juego, en AddOns."
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
L["Click to open the diary there."] = "Haz clic para abrir el diario ahí."
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
L["km"] = "km"
L["show or hide the companion"] = "mostrar u ocultar la ventana acompañante"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "El diario que había aquí era de un personaje anterior con el mismo nombre. Se ha guardado aparte y se ha empezado un diario nuevo para ti. |cffffd100/wfd restore|r lo recupera."
L["bring back the diary put aside"] = "recuperar el diario guardado aparte"
L["No diary has been put aside."] = "No hay ningún diario guardado aparte."
L["The diary put aside is back. The interface is reloaded."] = "El diario guardado aparte ha vuelto. Se recarga la interfaz."

-- Angler's log
L["Angler's log"] = "Diario de pesca"
L["A collector's album of everything the line brought up"] = "Un álbum de coleccionista de todo lo que sacó el sedal"
L["Land %d different catches."] = "Saca %d capturas distintas."
L["Casts"] = "Lanzamientos"
L["Fish"] = "Pez"
L["Treasure"] = "Tesoro"
L["Junk"] = "Basura"
L["Odds and ends"] = "Cosas varias"
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
L["All %d bookmarks are in use. Remove one first."] = "Los %d marcapáginas están en uso. Quita uno primero."
L["Before the diary"] = "Antes del diario"
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
L["Waypoint set: %s"] = "Punto de ruta marcado: %s"
L["Map controls"] = "Controles del mapa"
L["Mouse wheel: zoom"] = "Rueda del ratón: zoom"
L["Drag: move the map"] = "Arrastrar: mover el mapa"
L["Right click: reset"] = "Clic derecho: restablecer"
L["New since you last read"] = "Nuevo desde tu última lectura"
L["Nothing new since you last read."] = "Nada nuevo desde tu última lectura."
L["Fills as soon as there is something to tell."] = "Se llena en cuanto haya algo que contar."
L["%d new moments"] = "%d momentos nuevos"
L["Names from the game (places, creatures, items) stay in the language of the game client."] = "Los nombres del juego (lugares, criaturas, objetos) se quedan en el idioma del cliente."

L["%d days, %d kills, %d quests"] = "%d {día|días}, %d {baja|bajas}, %d {misión|misiones}"

-- memories and anniversaries
L["A memory"] = "Recuerdo"
L["Read that day (day %d)"] = "Leer ese día (día %d)"
L["The diary's birthday"] = "El cumpleaños del diario"
L["%d hours in the world"] = "%d horas en este mundo"
L["Anniversary"] = "Aniversario"
L["Nothing from earlier days to remember today."] = "Hoy no hay ningún recuerdo de días pasados."
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
L["Nothing slain here yet."] = "Aquí aún no has abatido nada."
L["No places discovered here yet."] = "Aquí aún no has descubierto ningún lugar."
L["Every first, with its day and place"] = "Cada primera vez, con su día y su lugar"
L["Leather and gold is the classic book. Modern is flat and calm, strong contrast makes all writing brighter."] = "Cuero y oro es el libro clásico. Moderno es sobrio y tranquilo; el contraste alto aclara todo el texto."
L["Still to come"] = "Pendientes"
L["%d still to find"] = "faltan %d por descubrir"
L["No nemesis yet: nobody has defeated you so far."] = "Aún no hay archienemigo: nadie te ha derrotado hasta ahora."
L["Data"] = "Datos"
L["Library"] = "Biblioteca"
L["Books I read along the way"] = "Libros que leí por el camino"
L["Book"] = "Libro"
L["Note"] = "Nota"
L["Plaque"] = "Placa"
L["%d books on the shelf"] = "%d {libro|libros} en la estantería"
L["To read later"] = "Para leer más tarde"
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
L["Your title"] = "Tu título"
L["In the showcase"] = "En la vitrina"
L["Showcase"] = "Vitrina"
L["Click to make this your title."] = "Haz clic para hacerlo tu título."
L["Click to give up this title."] = "Haz clic para dejar este título."
L["Right-click to put it in the showcase."] = "Clic derecho para ponerlo en la vitrina."
L["Right-click to take it out of the showcase."] = "Clic derecho para quitarlo de la vitrina."
L["Steel sharpened, name written down."] = "El acero está afilado y el nombre, anotado."
L["The road is longer, and so is the map."] = "El camino se alarga, y el mapa también."
L["Strangers become faces in the book."] = "Los desconocidos se vuelven rostros del libro."
L["Another line in the story of this life."] = "Otra línea en la historia de esta vida."
L["Not every treasure shines at first."] = "No todo tesoro brilla al principio."
L["Some pages only open for the curious."] = "Algunas páginas solo se abren a los curiosos."
L["Hall of fame"] = "Salón de la fama"
L["Savings goal in gold:"] = "Meta de ahorro en oro:"
L["Goal reached"] = "Meta alcanzada"
L["Savings goal"] = "Meta de ahorro"
L["Set a savings goal"] = "Fijar una meta de ahorro"
L["Click to change the goal."] = "Clic para cambiar la meta."
L["Right-click to take the goal away."] = "Clic derecho para quitar la meta."
L["My own goals"] = "Mis propias metas"
L["Remove this goal"] = "Quitar esta meta"
L["Write down what you want to do next, and tick it off when it is done."] = "Anota lo que quieres hacer a continuación y márcalo cuando esté hecho."
L["Add a goal"] = "Añadir una meta"
L["What do you want to do next?"] = "¿Qué quieres hacer a continuación?"
L["%d days with entries"] = "%d {día|días} con entradas"
L["%d levels gained"] = "%d {nivel|niveles} ganados"
L["A year of travel in figures"] = "Un año de viaje en cifras"
L["Best month: %s with %d kills"] = "Mejor mes: %s con %d bajas"
L["Busiest day: %s with %d kills"] = "Día más activo: %s con %d bajas"
L["Days"] = "Días"
L["Month by month"] = "Mes a mes"
L["The first year is still being written."] = "El primer año aún se está escribiendo."
L["Time online: %s"] = "Tiempo en línea: %s"
L["Year %d"] = "Año %d"
L["Year book"] = "Anuario"
L["If you enjoy the diary, you can support its development:"] = "Si te gusta el diario, puedes apoyar su desarrollo:"
L["Support"] = "Apoyo"
L["%d mounts"] = "%d {montura|monturas}"
L["%d rides"] = "%d {paseo|paseos}"
L["%d factions"] = "%d {facción|facciones}"
L["%d years ago today, %s brought me down in %s."] = "Hace %d {año|años}, tal día como hoy, %s me derribó en %s."
L["%d years ago today I fell in %s."] = "Hace %d {año|años}, tal día como hoy, caí en %s."
L["First ridden on day %d"] = "Montada por primera vez el día %d"
L["Into the chat"] = "Al chat"
L["Most days were: %s (%d)"] = "La mayoría de los días fueron: %s (%d)"
L["Mounts"] = "Monturas"
L["My week: %d kills, %d quests, %s km, %d levels, %d new places."] = "Mi semana: %d bajas, %d misiones, %s km, %d niveles, %d lugares nuevos."
L["Narrow down the days: z:region  lv:20-30  d:30 (the last 30 days)"] = "Acotar los días: z:región  lv:20-30  d:30 (los últimos 30 días)"
L["Reputation"] = "Reputación"
L["Reputation steps up: %d"] = "Niveles de reputación subidos: %d"
L["Seen on day %d as %s"] = "Vista el día %d como %s"
L["The copy from before the update to version %s is back. The interface is reloaded."] = "Ha vuelto la copia de antes de la actualización a la versión %s. La interfaz se recarga."
L["The first ride is still to come."] = "El primer paseo a lomos aún está por llegar."
L["There is no copy from before an update."] = "No hay ninguna copia de antes de una actualización."
L["A day of battle"] = "Un día de batalla"
L["A day on the road"] = "Un día de camino"
L["A day of quests"] = "Un día de misiones"
L["A day of fortune"] = "Un día de fortuna"
L["A quiet day"] = "Un día tranquilo"
L["A day of mourning"] = "Un día de luto"
L["Every mount, and the day it was first ridden"] = "Cada montura y el día en que se montó por primera vez"
L["How the factions came to see me"] = "Cómo me fueron conociendo las facciones"
L["bring back the copy from before the last update"] = "recuperar la copia de antes de la última actualización"
L["Drag to move."] = "Arrastra para mover."
L["The notes are back at the top of the screen."] = "Las notas vuelven a estar en la parte superior de la pantalla."
L["put the notes back at the top of the screen"] = "volver a poner las notas en la parte superior de la pantalla"
L["Show a note to move it"] = "Mostrar una nota para moverla"
L["Put the notes back at the top"] = "Volver a poner las notas arriba"
L["Pop-up notes"] = "Notas emergentes"
L["Mouse wheel changes the size."] = "La rueda del ratón cambia el tamaño."
L["A memory on Start"] = "Un recuerdo en Inicio"
L["All landmarks"] = "Todos los lugares famosos"
L["All tasks and own goals"] = "Todas las tareas y metas propias"
L["Also with Ctrl + mouse wheel. Drag the corner at the bottom right for a wider or taller window."] = "También con Ctrl + rueda del ratón. Arrastra la esquina inferior derecha para una ventana más ancha o más alta."
L["Bookmarks"] = "Marcapáginas"
L["Change the language?"] = "¿Cambiar el idioma?"
L["Collections"] = "Colecciones"
L["Commands"] = "Comandos"
L["Continue reading: %s"] = "Seguir leyendo: %s"
L["Corner at the bottom right"] = "Esquina inferior derecha"
L["Ctrl + mouse wheel changes the size of everything."] = "Ctrl + rueda del ratón cambia el tamaño de todo."
L["Drag to change the size of the window."] = "Arrastra para cambiar el tamaño de la ventana."
L["Escape"] = "Escape"
L["Every honour is at its highest tier."] = "Cada honor está en su nivel más alto."
L["Every landmark seen"] = "Todos los lugares famosos vistos"
L["Forward"] = "Adelante"
L["Gold today"] = "Oro de hoy"
L["Head bar"] = "Barra superior"
L["Help"] = "Ayuda"
L["It can no longer be moved or resized by mistake."] = "Así ya no se puede mover ni cambiar de tamaño por error."
L["Keys while the mouse is over the window"] = "Teclas con el ratón sobre la ventana"
L["Keys, mouse and commands"] = "Teclas, ratón y comandos"
L["Language, export, moving, demo"] = "Idioma, exportar, mudanza, demo"
L["Lock the window"] = "Bloquear la ventana"
L["Mouse"] = "Ratón"
L["Narrow register"] = "Índice estrecho"
L["No tasks today."] = "Hoy no hay tareas."
L["Nothing to remember on this day yet. In a year, this card tells what happened today."] = "Aún no hay ningún recuerdo de este día. Dentro de un año, aquí verás lo que pasó hoy."
L["Open the settings"] = "Abrir las opciones"
L["Read today's entry"] = "Leer la entrada de hoy"
L["Reload now"] = "Recargar ahora"
L["Reset the position and size"] = "Restablecer posición y tamaño"
L["Right-click a bookmark in the register"] = "Clic derecho en un marcapáginas del índice"
L["Set a waypoint"] = "Poner un punto de ruta"
L["Show all keys and commands"] = "Mostrar todas las teclas y comandos"
L["Shows the register as signs only."] = "El índice muestra solo símbolos."
L["Size of the window"] = "Tamaño de la ventana"
L["Start"] = "Inicio"
L["Style, size of the writing, language and data are in the settings of the diary."] = "El estilo, el tamaño de la letra, el idioma y los datos están en las opciones del diario."
L["The window"] = "La ventana"
L["closes what lies on top, then the window"] = "cierra lo que está encima, luego la ventana"
L["drag to change the size of the window"] = "arrastrar para cambiar el tamaño de la ventana"
L["drag to move the window"] = "arrastrar para mover la ventana"
L["list the commands in the chat"] = "listar los comandos en el chat"
L["on foot"] = "a pie"
L["size of the window"] = "tamaño de la ventana"
L["By area"] = "Por zona"
L["By kind"] = "Por tipo"
L["By water"] = "Por aguas"
L["Closest to the next card"] = "Próxima carta primero"
L["Connoisseurs"] = "Expertos"
L["Filter by name"] = "Filtrar por nombre"
L["Kinds"] = "Especies"
L["Last slain"] = "Último abatido"
L["Most caught"] = "Más pescados"
L["Most slain"] = "Más abatidos"
L["Newest first"] = "Lo más nuevo primero"
L["Nothing here yet."] = "Aquí todavía no hay nada."
L["Nothing matches this choice."] = "Nada coincide con esta selección."
L["Previous"] = "Anterior"
L["Rare and bosses"] = "Raros y jefes"
L["Sketches"] = "Bocetos"
L["Still to find"] = "Por encontrar"
L["To discover"] = "Por descubrir"
L["Where the line was cast, and with what"] = "Dónde se lanzó la caña, y con qué"
L["A to Z"] = "De la A a la Z"
L["Done"] = "Hechas"
L["Flight masters"] = "Maestros de vuelo"
L["Given up"] = "Abandonadas"
L["Merchants"] = "Mercaderes"
L["Met last"] = "Conocidos hace poco"
L["Most spoken to"] = "Con quien más hablé"
L["Open"] = "Abiertas"
L["Quest givers"] = "Dadores de misiones"
L["Regulars"] = "Habituales"
L["Trainers"] = "Instructores"
L["Best first"] = "Lo mejor primero"
L["Best per slot"] = "Lo mejor por hueco"
L["By category"] = "Por categoría"
L["By slot"] = "Por hueco"
L["Closest to the next tier"] = "Próximo nivel primero"
L["Earned"] = "Logrados"
L["In progress"] = "En curso"
L["Secret"] = "Secretos"
L["Tiers"] = "Niveles"
L["Title"] = "Título"
L["Worn now"] = "Equipado ahora"
L["%d goals at most: tick one off or remove it first."] = "%d metas como máximo: marca una como hecha o quítala primero."
L["%d new"] = "%d nuevos"
L["%d parts"] = "%d partes"
L["Reload the interface"] = "Recargar la interfaz"
L["Type /reload to finish."] = "Escribe /reload para terminar."
L["%d bosses"] = "%d {jefe|jefes}"
L["%d fallen"] = "%d {caído|caídos}"
L["By dungeon"] = "Por mazmorra"
L["By foe"] = "Por enemigo"
L["By level"] = "Por nivel"
L["Creatures"] = "Criaturas"
L["Dungeons, cities and other places of their own"] = "Mazmorras, ciudades y otros lugares con mapa propio"
L["Fastest first"] = "Más rápidas primero"
L["Finds"] = "Hallazgos"
L["First ridden"] = "Por primera monta"
L["First ride"] = "Primera monta"
L["Graves"] = "Tumbas"
L["Highest standing"] = "Mayor reputación primero"
L["Most kills"] = "Más muertes"
L["Most rides"] = "Más montas"
L["Most together"] = "Más tiempo juntos"
L["Nobody fell"] = "Nadie cayó"
L["Other places"] = "Otros lugares"
L["Remove"] = "Quitar"
L["Resting places"] = "Lugares de descanso"
L["Rides"] = "Montas"
L["Show all %d days"] = "Mostrar los %d días"
L["Show fewer"] = "Mostrar menos"
L["Show on the world map"] = "Mostrar en el mapa del mundo"
L["With fallen"] = "Con caídos"
L["World map"] = "Mapa del mundo"
L["Chapters"] = "Capítulos"
L["Day %d of %d"] = "Día %d de %d"
L["Day after"] = "Día siguiente"
L["Day before"] = "Día anterior"
L["Go to day"] = "Ir al día"
L["Remove the bookmark"] = "Quitar el marcapáginas"
L["Set a bookmark"] = "Poner un marcapáginas"
L["Bosses and rares"] = "Jefes y raros"
L["Experienced"] = "Vivido"
L["Oldest first"] = "Más antiguos primero"
L["Places"] = "Lugares"
L["Books"] = "Libros"
L["Found"] = "Encontrados"
L["Pages are missing"] = "Faltan páginas"
L["Plaques"] = "Placas"
L["Button below a day"] = "Botón bajo un día"
L["search the diary"] = "buscar en el diario"
L["turn the days of the diary"] = "pasar los días del diario"
L["Change the letter"] = "Cambiar la carta"
L["Write a letter"] = "Escribir una carta"
L["Click to read the week."] = "Haz clic para leer la semana."
L["Click to see them all on Start."] = "Haz clic para verlo todo en Inicio."
L["Week after"] = "Semana siguiente"
L["Week before"] = "Semana anterior"
L["%d companions removed."] = "%d compañeros eliminados."
L["%d companions would be removed (strangers from battlegrounds): %s"] = "Se eliminarían %d compañeros (desconocidos de campos de batalla): %s"
L["Choose a style that suits you"] = "Elige un estilo a tu gusto"
L["Click for Start."] = "Haz clic para ir a Inicio."
L["First steps"] = "Primeros pasos"
L["Lock the companion in place"] = "Fijar el acompañante"
L["Lock the minimap button"] = "Fijar el botón del minimapa"
L["No companions to remove."] = "No hay compañeros que eliminar."
L["Put the card away"] = "Guardar la tarjeta"
L["Read a day in the diary"] = "Leer un día del diario"
L["Search the diary (Ctrl + F)"] = "Buscar en el diario (Ctrl + F)"
L["Set a bookmark below a day"] = "Poner un marcapáginas bajo un día"
L["The mouse wheel over its title changes its size."] = "La rueda del ratón sobre su título cambia su tamaño."
L["Type /wfd cleanup yes to remove them."] = "Escribe /wfd cleanup yes para eliminarlos."
L["find strangers from battlegrounds among the companions"] = "buscar desconocidos de campos de batalla entre los compañeros"
L["list what the game blocked"] = "mostrar lo que el juego bloqueó"
L["open the look back at the week"] = "abrir el resumen de la semana"
L["Change the goal"] = "Cambiar el objetivo"
L["A week of travel in figures"] = "Una semana de viaje en cifras"
L["In this place the game keeps secret what the creatures look like."] = "En este lugar el juego mantiene en secreto el aspecto de las criaturas."
L["Place discovered"] = "Lugar descubierto"
L["%s already found this place."] = "%s ya encontró este lugar."
L["Parts"] = "Secciones"
L["Nothing found under %s."] = "Nada encontrado en %s."
L["Search everywhere (%d)"] = "Buscar en todo (%d)"
L["No day fits these filters."] = "Ningún día cumple estos filtros."
L["Nothing found. Try a shorter word, or a name the way the diary writes it."] = "No se encontró nada. Prueba con una palabra más corta o con un nombre tal como lo escribe el diario."
L["Undo"] = "Deshacer"
L["Bookmark removed: %s"] = "Marcador quitado: %s"
L["Bookmark set: %s"] = "Marcador puesto: %s"
L["The diary does not know \"%s\"."] = "El diario no conoce \"%s\"."
L["Left / right arrow"] = "Flecha izquierda / derecha"
L["Up / down arrow, Page up / down"] = "Flecha arriba / abajo, Re Pág / Av Pág"
L["scroll the open page"] = "desplaza la página abierta"
L["Alt + left / right arrow"] = "Alt + flecha izquierda / derecha"
L["back and forward"] = "atrás y adelante"
L["Mouse buttons 4 and 5"] = "Botones 4 y 5 del ratón"
L["removes it (the note at the foot can undo it)"] = "lo quita (el aviso de abajo puede deshacerlo)"
L["Mouse wheel on the companion"] = "Rueda del ratón sobre el acompañante"
L["size of the companion"] = "tamaño del acompañante"
L["Mouse wheel on a note"] = "Rueda del ratón sobre un aviso"
L["size of the notes"] = "tamaño de los avisos"
L["Right-click a note"] = "Clic derecho en un aviso"
L["closes it without opening the diary"] = "lo cierra sin abrir el diario"
L["Reset filter"] = "Quitar filtro"
L["No first time yet. They come by themselves while you play."] = "Aún no hay primeras veces. Llegan solas mientras juegas."
L["When the window opens"] = "Al abrir la ventana"
L["Start after logging in"] = "Inicio tras conectarse"
L["Where I left it"] = "Donde lo dejé"
L["Back always leads to where the window was left, also after /reload."] = "Atrás siempre lleva a donde se dejó la ventana, también tras /reload."
L["The cover"] = "La portada"
L["Never"] = "Nunca"
L["Only the very first time"] = "Solo la primera vez"
L["After every login"] = "Tras cada conexión"
L["Minimap, tooltips, pictures"] = "Minimapa, descripciones, imágenes"
L["What is announced, and where"] = "Qué se anuncia y dónde"
L["Switched off, no note comes at all; the diary still writes everything down."] = "Desactivado, no aparece ningún aviso; el diario lo sigue anotando todo."
L["Place of the notes"] = "Lugar de los avisos"
L["Style and writing"] = "Estilo y letra"
L["Size, place, opening, keys"] = "Tamaño, lugar, apertura, teclas"
L["Place and size"] = "Lugar y tamaño"
L["The companion"] = "El acompañante"
L["A small window beside the game"] = "Una ventana pequeña junto al juego"
L["Backups and tidying up"] = "Copias y limpieza"
L["Bring back the diary put aside"] = "Recuperar el diario apartado"
L["Bring back the copy from before the update"] = "Recuperar la copia de antes de la actualización"
L["Remove strangers from battlegrounds"] = "Quitar a los desconocidos de campos de batalla"
L["A diary is put aside when another character's diary was found here; the copy is made before every update of the addon."] = "Un diario se aparta cuando aquí se encontró el diario de otro personaje; la copia se hace antes de cada actualización del accesorio."
L["Bring back"] = "Recuperar"
L["The diary written now is put aside in its place. The interface is reloaded."] = "El diario actual se aparta en su lugar. La interfaz se recarga."
L["%d more"] = "%d más"
L["Accepted"] = "Aceptada"
L["Click for the calling card."] = "Clic para la tarjeta de visita."
L["Click: the report. Right-click: the day."] = "Clic: el informe. Clic derecho: el día."
L["Days together"] = "Días juntos"
L["Given"] = "Dado"
L["Grouped"] = "En grupo"
L["Handed in"] = "Entregada"
L["Handed in to"] = "Entregada a"
L["It is written down by itself the first time it happens."] = "Se anota sola la primera vez que ocurre."
L["Last trade"] = "Último trato"
L["Received"] = "Recibido"
L["Reward"] = "Recompensa"
L["Steps"] = "Niveles"
L["Trades"] = "Tratos"
L["All %d quests"] = "Las %d misiones"
L["Click to read the first day of this month."] = "Clic para leer el primer día de este mes."
L["Click: the report."] = "Clic: el informe."
L["Click to edit."] = "Clic para editar."
L["Click: %s"] = "Clic: %s"
L["Edit the goal"] = "Editar el objetivo"
L["Goal removed: %s"] = "Objetivo quitado: %s"
L["The savings goal is removed."] = "Se quitó el objetivo de ahorro."
L["The tasks of the day on Start"] = "Las tareas del día en Inicio"
L["Tick off"] = "Marcar como hecho"
L["%d still to come"] = "%d por vivir"
L["A faction is noted as soon as your standing with it changes: help it, and its steps appear here."] = "Una facción se anota en cuanto cambia tu reputación con ella: ayúdala y sus niveles aparecerán aquí."
L["Accept a quest: it is written down with who gave it, where, and what it brought."] = "Acepta una misión: se anota quién te la dio, dónde y qué te reportó."
L["Click to show them one by one."] = "Clic para verlas una a una."
L["Every coin you earn or spend is drawn here, day by day."] = "Cada moneda que ganas o gastas se dibuja aquí, día a día."
L["Every creature you slay gets its card here: where it lives, how often it fell, what it left behind."] = "Cada criatura que abates recibe aquí su tarjeta: dónde vive, cuántas veces cayó, qué dejó."
L["Every find of uncommon quality or better is kept here, with its day and who dropped it."] = "Cada hallazgo de calidad poco común o mejor se guarda aquí, con su día y quién lo soltó."
L["Every visit to a dungeon gets its report: the group, the bosses, the loot, who fell."] = "Cada visita a una mazmorra recibe su informe: el grupo, los jefes, el botín, quién cayó."
L["Fish with a rod anywhere: every new catch gets its card here."] = "Pesca con caña en cualquier lugar: cada captura nueva recibe aquí su tarjeta."
L["No boss fell this time."] = "Esta vez no cayó ningún jefe."
L["Not set yet"] = "Aún sin fijar"
L["Nothing worth keeping this time."] = "Esta vez nada que valga la pena guardar."
L["Talk to a merchant, a trainer or a quest giver: everyone you speak to gets a calling card."] = "Habla con un comerciante, un instructor o quien da misiones: cada persona con la que hablas recibe una tarjeta de visita."
L["The diary writes itself while you play: every day gets its page, told as a story."] = "El diario se escribe solo mientras juegas: cada día recibe su página, contada como una historia."
L["Bookmarks stand at the foot of the register."] = "Los marcadores están al pie del índice."
L["Filter"] = "Filtro"
L["No longer read later"] = "Ya no leer más tarde"
L["Size of the notes"] = "Tamaño de las notas"
L["Turn the leaves visibly"] = "Pasar las hojas de forma visible"
