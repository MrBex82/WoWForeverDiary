-- Brazilian Portuguese translation (English phrases are the keys)
local ADDON, WFD = ...
local L, loc = WFD:NewLocale("ptBR")

local T = {
    -- chat / log
    ["Diary"] = "Diário",
    ["Travel diary active. Today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
        "Diário de viagem ativo. Hoje é o |cffffd100dia %d|r. |cffffd100/wfd|r abre o diário.",
    ["%d creatures slain in total"] = "%d criaturas abatidas no total",
    ["First victory over the boss %s!"] = "Primeira vitória sobre o chefe %s!",
    ["Rare creature slain: %s"] = "Criatura rara abatida: %s",
    ["Boss %s defeated again (%dx)"] = "Chefe %s derrotado novamente (%dx)",
    ["Died to %s in %s"] = "Morte para %s (%s)",
    ["Died in %s"] = "Morte em %s",
    ["Met %s (%s)"] = "Conheceu %s (%s)",
    ["Hearthstone bound to %s"] = "Pedra de Regresso vinculada a %s",
    ["Quest accepted: %s"] = "Missão aceita: %s",
    ["Quest abandoned: %s"] = "Missão abandonada: %s",
    ["Quest completed: %s"] = "Missão concluída: %s",
    ["First quest completed: %s"] = "Primeira missão concluída: %s",
    ["%d quests completed"] = "%d missões concluídas",
    ["Took a flight to %s"] = "Voo para %s",
    ["Wealth reached: %s"] = "Fortuna alcançada: %s",
    ["Found %s"] = "Encontrado: %s",
    ["Epic find: %s"] = "Achado épico: %s",
    ["Rare find: %s"] = "Achado raro: %s",
    ["Discovered a new land: %s"] = "Nova terra descoberta: %s",
    ["Entered %s"] = "Chegada: %s",
    ["Discovered: %s (%s)"] = "Descoberto: %s (%s)",
    ["First visit to the dungeon %s"] = "Primeira visita à masmorra %s",
    ["Entered the dungeon %s"] = "Entrada na masmorra %s",
    ["Level %d reached!"] = "Nível %d alcançado!",
    ["%s increased to %d"] = "%s subiu para %d",
    ["%s mastered up to %d"] = "%s dominado até %d",
    ["Used the hearthstone"] = "Pedra de Regresso usada",
    ["%dh %02dm"] = "%dh %02dmin",
    ["%dm"] = "%dmin",

    -- window
    ["Travel Diary of %s"] = "Diário de viagem de %s",
    ["Day %d"] = "Dia %d",
    ["Level %d"] = "Nível %d",
    ["Level %s"] = "Nível %s",
    ["online"] = "on-line",
    ["Screenshot:"] = "Captura de tela:",
    ["Click to read this day."] = "Clique para ler este dia.",
    ["Click to open the diary."] = "Clique para abrir o diário.",
    ["%d kills today"] = "%d {abate|abates} hoje",
    ["%d quests today"] = "%d {missão|missões} hoje",
    ["DEMO MODE: invented data"] = "MODO DEMO: dados inventados",

    -- tabs
    ["Bestiary"] = "Bestiário",
    ["People"] = "Pessoas",
    ["Quest Book"] = "Livro de missões",

    -- journal
    ["Today"] = "Hoje",
    ["Chronicle"] = "Crônica",
    ["Enemies slain"] = "Inimigos abatidos",
    ["Quests completed"] = "Missões concluídas",
    ["People spoken to"] = "Pessoas com quem falou",
    ["Distance travelled"] = "Distância percorrida",
    ["flown"] = "voando",
    ["Time online"] = "Tempo on-line",
    ["Deaths"] = "Mortes",
    ["Income"] = "Receitas",
    ["Expenses"] = "Despesas",
    ["Net"] = "Saldo",
    ["Fallen foes"] = "Inimigos derrotados",
    ["Loot"] = "Saque",

    -- map
    ["Kills"] = "Abates",
    ["Quests"] = "Missões",
    ["No map art available for this area."] = "Não há mapa disponível para esta área.",
    ["Play"] = "Reproduzir",
    ["Spoken to %d times"] = "%d {conversa|conversas}",
    ["You died here"] = "Você morreu aqui",
    ["Killed by %s"] = "Morto por %s",
    ["No travels recorded yet."] = "Nenhuma viagem registrada ainda.",

    -- bestiary
    ["Boss"] = "Chefe",
    ["Rare"] = "Raro",
    ["Elite"] = "Elite",
    ["Normal"] = "Normal",
    ["No portrait"] = "Sem retrato",

    -- people
    ["First met"] = "Primeiro encontro",
    ["No quests recorded."] = "Nenhuma missão registrada.",
    ["All"] = "Todos",
    ["You have not talked to anyone yet."] = "Você ainda não falou com ninguém.",
    ["Conversation"] = "Conversa",
    ["Vendor"] = "Mercador",
    ["Trainer"] = "Instrutor",
    ["Flight master"] = "Mestre de Voo",
    ["Banker"] = "Bancário",
    ["Stable master"] = "Mestre do Estábulo",
    ["Petitions"] = "Petições",
    ["Auctioneer"] = "Leiloeiro",

    -- quests
    ["No quests recorded yet."] = "Nenhuma missão registrada ainda.",

    -- statistics
    ["Gold"] = "Ouro",
    ["In total: %d kills  |  %d quests  |  %s online  |  %.1f km on foot  |  %d deaths  |  %d jumps"] =
        "No total: %d abates  |  %d missões  |  %s on-line  |  %.1f km a pé  |  %d mortes  |  %d pulos",

    -- money categories
    ["Quest rewards"] = "Recompensas de missão",
    ["Vendor sales"] = "Vendas a mercadores",
    ["Mail"] = "Correio",
    ["Trading"] = "Comércio",
    ["Auction house"] = "Casa de Leilões",
    ["Repairs"] = "Reparos",
    ["Purchases"] = "Compras",
    ["Training"] = "Treinamento",
    ["Flights"] = "Voos",
    ["Bank"] = "Banco",
    ["Other"] = "Outros",

    -- export / settings
    ["Born:"] = "Nascimento:",
    ["Select all"] = "Selecionar tudo",
    ["Ctrl+C copies the selection."] = "Ctrl+C copia a seleção.",
    ["Take a screenshot at milestones"] = "Capturar a tela em marcos importantes",
    ["Show minimap button"] = "Mostrar botão no minimapa",

    -- redesigned interface
    ["Travel Diary"] = "Diário de viagem",
    ["Experience"] = "Experiência",
    ["Conversations"] = "Conversas",
    ["On foot"] = "A pé",
    ["Map of my travels"] = "Mapa das minhas viagens",
    ["Slain"] = "Abatidos",
    ["First kill"] = "Primeiro abate",
    ["Last kill"] = "Último abate",
    ["Seen in"] = "Visto em",
    ["Killed you"] = "Matou você",
    ["Last met"] = "Último encontro",
    ["Received from"] = "Recebida de",
    ["Took"] = "Duração",
    ["Came from"] = "Origem",
    ["Went to"] = "Destino",
    ["Transcript"] = "Transcrição",
    ["Settings"] = "Configurações",
    ["Size of the book"] = "Tamanho do livro",
    ["Demo"] = "Demo",
    ["Start demo mode"] = "Iniciar modo demo",
    ["Leave demo mode"] = "Sair do modo demo",
    ["open or close the diary"] = "abrir ou fechar o diário",
    ["explore with invented data"] = "explorar com dados inventados",
    ["screenshots on or off"] = "ativar ou desativar capturas de tela",
    ["minimap button on or off"] = "mostrar ou ocultar o botão do minimapa",
}
for k, v in pairs(T) do L[k] = v end

-- dates and diary entries
loc.date = "%d/%m/%Y"
loc.decimal = ","
loc.thousands = "."
loc.listAnd = " e "
loc.dayMonth = "%d/%m"
loc.weekdays = { "domingo", "segunda-feira", "terça-feira", "quarta-feira", "quinta-feira", "sexta-feira", "sábado" }
loc.months = { "janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro" }
function loc.longDate(d)
    local wd = loc.weekdays[d.wday]
    return string.format("%s%s, %d de %s de %d", wd:sub(1, 1):upper(), wd:sub(2), d.day, loc.months[d.month], d.year)
end

loc.narrator = {
    birth = {
        "Dia 1. %s, %s. Ponto de partida: %s. O que vem agora? Não faço ideia.",
        "Dia 1. Sou %s e %s, e tudo começa aqui: %s. Vamos ver no que dá.",
    },
    begin = {
        "Dia 1. A partir de hoje, anoto tudo o que me acontece pelo caminho.",
    },
    open = {
        "Dia %d, %s.",
        "Dia %d. Hoje foi a vez de %s.",
        "Dia %d. De volta à estrada, mais pelos lados de %s.",
    },
    far = "terras desconhecidas",
    walk = {
        "Uns %s quilômetros a pé%s.",
        "Meus pés dizem: mais ou menos %s quilômetros%s.",
        "Quase %s quilômetros andando%s, e minhas pernas sentiram.",
    },
    via = " (%s)",
    fly = " O resto do caminho fiz voando.",
    kills = {
        "Derrotei {um inimigo|%d inimigos}.",
        "Derrubei %d {criatura|criaturas}.",
        "{Um inimigo|%d inimigos} a menos no mundo.",
    },
    top = {
        "A maioria: %s (%dx).",
        "%s foi quem mais cruzou meu caminho (%dx).",
    },
    special = "Pra lembrar: %s.",
    deaths = {
        "Morri {uma vez|%d vezes}.%s",
        "Beijei o chão {uma vez|%d vezes} hoje.%s",
    },
    deathBy = " A última foi culpa de %s.",
    noDeath = {
        "Hoje não morri nenhuma vez.",
        "Zero mortes hoje. Nada mal.",
    },
    questDone = {
        "{Uma missão concluída|%d missões concluídas}: %s.",
        "Riscado da lista: %s.",
    },
    questAcc = {
        "E {chegou uma nova|chegaram %d novas}.",
        "E já {tem outra tarefa esperando|tem %d tarefas novas esperando}.",
    },
    questAccOnly = {
        "{Aceitei uma tarefa nova, mas ainda não terminei.|Aceitei %d tarefas novas e ainda não terminei nenhuma.}",
    },
    more = "e mais algumas",
    quote = {
        "%s me disse: %s",
        "Nas palavras de %s: %s",
    },
    quoteAnon = "Uma frase ficou na cabeça: %s",
    npcs = {
        "{Só conversei com %s.|Conversei com %d pessoas, entre elas %s.}",
        "{Uma conversa, com %s.|%d conversas, por exemplo com %s.}",
    },
    gain = {
        "Minha bolsa ficou %s mais pesada.",
        "No fim das contas, %s a mais no bolso.",
    },
    loss = {
        "Minha bolsa ficou %s mais leve.",
        "No fim das contas, o dia me custou %s.",
    },
    src = " A maior parte da renda: %s (%s).",
    spent = " O maior gasto: %s (%s).",
    item = {
        "Melhor achado: %s.",
        "Achado do dia: %s.",
    },
    levels = {
        "Nível %s!",
        "Subi para o nível %s.",
        "E aí: nível %s!",
    },
    quiet = {
        "Dia tranquilo. Pouca coisa pra contar.",
        "Hoje não aconteceu muita coisa.",
    },
    begun = {
        "O dia mal começou.",
        "O dia ainda é jovem.",
        "O novo dia está só começando.",
    },
    ongoing = {
        "O dia ainda não acabou.",
        "Continua …",
        "Vamos ver o que mais o dia traz.",
    },
    close = {
        "Por hoje é só.",
        "Chega por hoje. Amanhã tem mais.",
        "Hora de descansar um pouco.",
        "Vamos ver o que amanhã traz.",
    },
    closeLong = {
        "%s na estrada. Tá bom por hoje.",
        "Depois de %s, não aguento mais.",
        "No total, %s de pé. Amanhã tem mais.",
    },
    none = "Não há registro para este dia.",
}

-- book interface
L["Begun on %s"] = "Iniciado em %s"
L["Bookmark"] = "Marcador"
L["Click to open today's entry."] = "Clique para abrir o registro de hoje."
L["Click to open"] = "Clique para abrir"
L["Notes"] = "Notas"
L["of"] = "de"

-- book pages (diary, appendix)
L["Arrival in %s"] = "Chegada: %s"
L["Days in %s"] = "Dias de viagem: %s"
L["Shadows over %s"] = "Sombras sobre %s"
L["The roads of %s"] = "Os caminhos de %s"
L["Under the skies of %s"] = "Sob os céus de %s"
L["Awakening in %s"] = "Despertar: %s"
L["Return to %s"] = "Retorno: %s"
L["Chapter"] = "Capítulo"
L["Level %d-%d"] = "Nível %d-%d"
L["Days %d-%d"] = "Dias %d-%d"
L["Level %d!"] = "Nível %d!"
L["%d kills"] = "%d {abate|abates}"
L["%d quests"] = "%d {missão|missões}"
L["died %dx"] = "%d {morte|mortes}"
L["Kept as a memory"] = "Guardado como lembrança"
L["The pages are still empty. Go and live an adventure!"] = "As páginas ainda estão em branco. Vá viver uma aventura!"
L["Milestones"] = "Marcos"
L["The great moments of a life"] = "Os grandes momentos de uma vida"
L["No milestones yet."] = "Nenhum marco ainda."
L["Maps"] = "Mapas"
L["%s spent here"] = "%s passados aqui"
L["Route"] = "Rota"
L["Kill sites"] = "Locais de combate"
L["First visit"] = "Primeira visita"
L["Time spent"] = "Tempo passado"
L["Acquaintances here"] = "Conhecidos aqui"
L["Slain %d times"] = "Abatida %d {vez|vezes}"
L["Everyone I met on my way"] = "Todos que encontrei pelo caminho"
L["Every coin, in and out"] = "Cada moeda, entrada e saída"
L["Balance"] = "Saldo"
L["Day"] = "Dia"
L["Tasks taken and done"] = "Tarefas aceitas e cumpridas"
L["Copy the diary as text"] = "Copiar o diário como texto"
L["Copy the diary as JSON"] = "Copiar o diário como JSON"
L["Ledger"] = "Livro-caixa"

-- own notes
L["Click here to write your own notes ..."] = "Clique aqui para escrever suas próprias notas …"
L["My own thoughts:"] = "Meus próprios pensamentos:"
L["+ note"] = "+ nota"
L["edit note"] = "editar nota"
L["Save"] = "Salvar"
L["Cancel"] = "Cancelar"

-- cards
L["Acquaintance"] = "Conhecido"
L["Click for the wanted poster."] = "Clique para ver o cartaz de procurado."
L["Click for the portrait."] = "Clique para ver o retrato."

-- collector's album
L["A collector's album of every creature slain"] = "Um álbum de coleção de todas as criaturas abatidas"
L["Bronze"] = "Bronze"
L["Silver"] = "Prata"
L["Mithril"] = "Mithril"
L["Legend"] = "Lenda"
L["Collect %d kinds of creatures."] = "Colete %d espécies de criaturas."
L["Bosses"] = "Chefes"
L["%d kinds"] = "%d espécies"
L["Lv %s"] = "Nv. %s"
L["NEW"] = "NOVO"
L["not yet found"] = "ainda não encontrada"

-- language switch
L["German"] = "Alemão"
L["English"] = "Inglês"
L["French"] = "Francês"
L["Spanish"] = "Espanhol"
L["Portuguese"] = "Português"
L["Russian"] = "Russo"
L["Korean"] = "Coreano"
L["Chinese (traditional)"] = "Chinês (tradicional)"
L["Language"] = "Idioma"
L["Game language (%s)"] = "Idioma do jogo (%s)"
L["The diary will reload the interface to switch the language."] = "O diário recarregará a interface para trocar o idioma."
L["Korean and Chinese text needs a game client with those fonts."] = "Textos em coreano e chinês exigem um cliente do jogo com essas fontes."

-- map spreads
L["Places of note"] = "Lugares notáveis"
L["Grave"] = "Túmulo"
L["Visits"] = "Visitas"
L["Deaths here"] = "Mortes aqui"
L["Most hunted here"] = "Mais caçados aqui"
L["Places discovered"] = "Lugares descobertos"

-- companions, honours, treasures, memories, obituary
L["%d days of life, %d creatures slain, %d quests completed"] = "%d {dia|dias} de vida, %d {criatura abatida|criaturas abatidas}, %d {missão concluída|missões concluídas}"
L["%d days"] = "%d {dia|dias}"
L["%d enemies fell that day."] = "Naquele dia {caiu|caíram} %d {inimigo|inimigos}."
L["%d kills together"] = "%d {abate|abates} juntos"
L["%d times grouped"] = "%d {vez|vezes} em grupo"
L["%d treasures collected"] = "%d {tesouro coletado|tesouros coletados}"
L["%dx traded"] = "%d trocas"
L["A painted memory"] = "Uma lembrança pintada"
L["Book of honour"] = "Livro de honra"
L["Companions"] = "Companheiros"
L["Copy for forum or Discord (Markdown)"] = "Copiar para fórum ou Discord (Markdown)"
L["Quickest to the level"] = "O mais rápido ao nível"
L["Fell in %s"] = "Caiu em %s"
L["Slain by %s"] = "Morte pelas mãos de %s"
L["Fellow adventurers"] = "Companheiros de aventura"
L["Fellowship"] = "Irmandade"
L["Grouped with %s"] = "Em grupo com %s"
L["In memoriam"] = "In memoriam"
L["No trades yet."] = "Nenhuma troca ainda."
L["No treasures found yet."] = "Nenhum tesouro encontrado ainda."
L["Rested here"] = "Descanso aqui"
L["Times rested here"] = "Descansos aqui"
L["The last moment"] = "O último instante"
L["Today, %d days ago"] = "Hoje, há %d dias"
L["Trading partners"] = "Parceiros de troca"
L["Treasures"] = "Tesouros"
L["Who walked beside me"] = "Quem caminhou ao meu lado"
L["You have not grouped with anyone yet."] = "Você ainda não se agrupou com ninguém."
L["I was in %s."] = "Eu estive em %s."
L["early in the morning"] = "de manhã cedo"
L["in the morning"] = "pela manhã"
L["around noon"] = "por volta do meio-dia"
L["in the afternoon"] = "à tarde"
L["in the evening"] = "ao anoitecer"
L["late at night"] = "tarde da noite"
L["earned"] = "conquistado"
L["first met %s"] = "primeiro encontro em %s"

-- honours
L["Slayer"] = "Matador"
L["Specialist"] = "Especialista"
L["Naturalist"] = "Naturalista"
L["Rare Hunter"] = "Caçador de raridades"
L["Giant Slayer"] = "Matador de gigantes"
L["Into the Depths"] = "Rumo às profundezas"
L["Hunter"] = "Caçador"
L["Helping Hand"] = "Mão amiga"
L["Explorer"] = "Explorador"
L["Wanderer"] = "Andarilho"
L["Pathfinder"] = "Desbravador"
L["Frequent Flyer"] = "Viajante frequente"
L["Thrifty"] = "Econômico"
L["Seasoned"] = "Experiente"
L["Untouchable"] = "Intocável"
L["Faithful Chronicler"] = "Cronista fiel"
L["Sociable"] = "Sociável"
L["Bouncy"] = "Saltitante"
L["Treasure Hunter"] = "Caçador de tesouros"

-- keepsake captions
L["Level up"] = "Nível"
L["Epic find"] = "Achado épico"
L["Rare find"] = "Achado raro"
L["Death"] = "Morte"
L["New land"] = "Nova terra"
L["Dungeon"] = "Masmorra"
L["Quest"] = "Missão"
L["Wealth"] = "Riqueza"
L["Skill"] = "Profissão"
L["Hunt"] = "Caçada"
L["Moment"] = "Momento"

-- honour tiers, atlas, landmarks, secrets
L["%d honour points"] = "%d pontos de honra"
L["%d of %d regions explored"] = "%d de %d regiões exploradas"
L["%d tiers earned"] = "%d {nível conquistado|níveis conquistados}"
L["A familiar face ..."] = "Um rosto conhecido …"
L["A secret honour. Keep exploring!"] = "Uma honra secreta. Continue explorando!"
L["Adventure"] = "Aventura"
L["Almost there"] = "Quase lá"
L["Atlas"] = "Atlas"
L["Bad Day"] = "Dia de cão"
L["Barterer"] = "Negociante"
L["Be on the road before seven in the morning."] = "Esteja na estrada antes das sete da manhã."
L["Be on the road between midnight and four o'clock."] = "Esteja na estrada entre meia-noite e quatro horas."
L["Bloodbath"] = "Banho de sangue"
L["Busy Bee"] = "Abelha operária"
L["Capital Tourist"] = "Turista das capitais"
L["Capitals"] = "Capitais"
L["Click for all landmarks."] = "Clique para ver todos os pontos turísticos."
L["Click for the map of this region."] = "Clique para ver o mapa desta região."
L["Click to open this part of the book."] = "Clique para abrir esta parte do livro."
L["Collection"] = "Coleção"
L["Combat"] = "Combate"
L["Complete %d quests in a single day."] = "Conclua %d missões em um único dia."
L["Complete %d quests."] = "Conclua %d missões."
L["Complete!"] = "Concluído!"
L["Curiosities"] = "Curiosidades"
L["Dark places, rich rewards"] = "Lugares sombrios, recompensas ricas"
L["Defeat %d bosses."] = "Derrote %d chefes."
L["Destination of the day"] = "Destino do dia"
L["Devoted"] = "Dedicado"
L["Die %d times and rise again."] = "Morra %d vezes e levante-se novamente."
L["Die %d times in a single day."] = "Morra %d vezes em um único dia."
L["Discover %d places."] = "Descubra %d lugares."
L["Do business with %d merchants."] = "Faça negócios com %d mercadores."
L["Dungeons"] = "Masmorras"
L["Eager Student"] = "Aluno dedicado"
L["Early Bird"] = "Madrugador"
L["Elite Slayer"] = "Caçador de elites"
L["Encounters"] = "Encontros"
L["Enter %d dungeons."] = "Entre em %d masmorras."
L["Epic Fortune"] = "Sorte épica"
L["Every journey needs a pause ..."] = "Toda jornada precisa de uma pausa …"
L["Exploration"] = "Exploração"
L["Explored"] = "Explorada"
L["Explorer's checklist"] = "Lista do explorador"
L["Famous places of Azeroth"] = "Lugares famosos de Azeroth"
L["Find %d epic items."] = "Encontre %d itens épicos."
L["Find %d landmarks."] = "Encontre %d pontos turísticos."
L["Find %d rare items."] = "Encontre %d itens raros."
L["Fortune and craft"] = "Fortuna e ofício"
L["Globetrotter's Day"] = "Dia de andarilho"
L["Group with %d other adventurers."] = "Agrupe-se com %d outros aventureiros."
L["Haggler"] = "Pechincheiro"
L["Hoarder"] = "Acumulador"
L["Homesick"] = "Saudade de casa"
L["Honour earned: %s (%s)"] = "Honra conquistada: %s (%s)"
L["Honour earned: %s"] = "Honra conquistada: %s"
L["Honour points"] = "Pontos de honra"
L["Honour"] = "Honra"
L["Jump %d times."] = "Pule %d vezes."
L["Just one more quest ..."] = "Só mais uma missão …"
L["Keep this diary for %d days."] = "Mantenha este diário por %d dias."
L["Landmark discovered: %s"] = "Ponto turístico descoberto: %s"
L["Landmark"] = "Ponto turístico"
L["Landmarks"] = "Pontos turísticos"
L["Loot %d items."] = "Colete %d itens."
L["Marathon"] = "Maratona"
L["Master of a Craft"] = "Mestre de um ofício"
L["Meet %d people."] = "Conheça %d pessoas."
L["Mouse wheel: zoom, drag: move, right click: reset"] = "Roda do mouse: zoom, arrastar: mover, clique direito: redefinir"
L["Next rank: %s"] = "Próximo nível: %s"
L["Night Owl"] = "Coruja noturna"
L["Not every day is a good day ..."] = "Nem todo dia é um bom dia …"
L["Not yet explored"] = "Ainda não explorada"
L["Own %d gold."] = "Junte %d de ouro."
L["Phoenix"] = "Fênix"
L["Play %d days in a row without dying."] = "Jogue %d dias seguidos sem morrer."
L["Raids"] = "Raides"
L["Raise a skill to %d."] = "Eleve uma profissão a %d."
L["Reach level %d."] = "Alcance o nível %d."
L["Regions explored"] = "Regiões exploradas"
L["Regular"] = "Freguês"
L["Rest at %d places."] = "Descanse em %d lugares."
L["Secrets"] = "Segredos"
L["Sightseer"] = "Turista"
L["Slay %d creatures in a single day."] = "Abata %d criaturas em um único dia."
L["Slay %d creatures."] = "Abata %d criaturas."
L["Slay %d elite creatures."] = "Abata %d criaturas de elite."
L["Slay %d of a single kind."] = "Abata %d criaturas de uma mesma espécie."
L["Slay %d rare creatures."] = "Abata %d criaturas raras."
L["So many roads, so little time ..."] = "Tantos caminhos, tão pouco tempo …"
L["Some honours stay hidden until you find them."] = "Algumas honras ficam ocultas até que você as encontre."
L["Spend %d hours in the world on a single day."] = "Passe %d horas no mundo em um único dia."
L["Spend %d hours in the world."] = "Passe %d horas no mundo."
L["Take %d flights."] = "Faça %d voos."
L["Talk to the same person %d times."] = "Fale %d vezes com a mesma pessoa."
L["The early bird catches the worm ..."] = "Deus ajuda quem cedo madruga …"
L["The purse over the days"] = "A bolsa ao longo dos dias"
L["There is no place like home ..."] = "Não há lugar como o lar …"
L["This game client knows none of the landmarks."] = "Este cliente do jogo não conhece nenhum dos pontos turísticos."
L["Towns of Kalimdor"] = "Locais de Kalimdor"
L["Towns of the Eastern Kingdoms"] = "Locais dos Reinos do Leste"
L["Trade with %d players."] = "Negocie com %d jogadores."
L["Up, up and away ..."] = "Para o alto e avante …"
L["Use your hearthstone %d times."] = "Use sua Pedra de Regresso %d vezes."
L["Visit %d capital cities."] = "Visite %d capitais."
L["Visit %d regions in a single day."] = "Visite %d regiões em um único dia."
L["Visit %d regions."] = "Visite %d regiões."
L["Visit %d trainers."] = "Visite %d instrutores."
L["Walk %d kilometres."] = "Percorra %d quilômetros a pé."
L["Well Rested"] = "Bem descansado"
L["What is left to discover"] = "O que ainda falta descobrir"
L["When the moon stands highest ..."] = "Quando a lua está mais alta …"
L["Wings of the World"] = "Asas do mundo"
L["You have not seen this place yet."] = "Você ainda não viu este lugar."
L["You have seen every landmark. Remarkable!"] = "Você viu todos os pontos turísticos. Notável!"
L["days"] = "dias"
L["done"] = "concluídas"
L["given up"] = "abandonadas"
L["kills"] = "abates"
L["open"] = "abertas"

-- treasure album, wanted posters
L["WANTED"] = "PROCURA-SE"
L["of %d kinds"] = "de %d espécies"
L["Next mark: %d slain"] = "Próxima marca: %d abatidos"
L["Every mark reached"] = "Todas as marcas alcançadas"
L["Uncommon"] = "Incomum"
L["Epic"] = "Épico"
L["Legendary"] = "Lendário"

-- tasks of the day, pop-ups, week in review
L["Slay %d creatures today."] = "Abata %d criaturas hoje."
L["Complete %d quests today."] = "Conclua %d missões hoje."
L["Meet %d new people."] = "Conheça %d pessoas novas."
L["Discover %d new places."] = "Descubra %d lugares novos."
L["Walk %d kilometres today."] = "Percorra %d quilômetros a pé hoje."
L["Find an uncommon or better item."] = "Encontre um item incomum ou melhor."
L["Visit the landmark %s."] = "Visite o ponto turístico %s."
L["Set foot in %s."] = "Ponha os pés em %s."
L["Task of the day done: %s"] = "Tarefa do dia cumprida: %s"
L["All tasks of the day done! %d days in a row."] = "Todas as tarefas do dia cumpridas! %d dias seguidos."
L["All tasks of the day done!"] = "Todas as tarefas do dia cumpridas!"
L["Tasks of the day"] = "Tarefas do dia"
L["Task of the day"] = "Tarefa do dia"
L["Dungeon Crawler"] = "Explorador de masmorras"
L["Finish %d dungeon runs."] = "Conclua %d incursões em masmorras."
L["Diligent"] = "Diligente"
L["Do all tasks of the day on %d days."] = "Cumpra todas as tarefas do dia em %d dias."
L["Dutiful"] = "Cumpridor"
L["Do all tasks of the day %d days in a row."] = "Cumpra todas as tarefas do dia por %d dias seguidos."
L["Open the diary"] = "Abrir o diário"
L["Close"] = "Fechar"
L["The week in review"] = "Resumo da semana"
L["Creatures slain"] = "Criaturas abatidas"
L["Levels"] = "Níveis"
L["Kilometres"] = "Quilômetros"
L["New places"] = "Lugares novos"
L["New regions"] = "Regiões novas"
L["Honours"] = "Honras"
L["Best day"] = "Melhor dia"
L["The book waits for new stories."] = "O livro aguarda novas histórias."
L["Show a note for new discoveries"] = "Avisar sobre novas descobertas"
L["Weekly look back at login"] = "Resumo semanal ao entrar"
L["Show when an item was first found in its tooltip"] = "Mostrar na dica quando o item foi encontrado pela primeira vez"
L["In the diary: first found on %s"] = "No diário: encontrado pela primeira vez em %s"
L["from %s"] = "de %s"

-- records, level timeline, gallery, nemeses, dungeon reports
L["Records"] = "Recordes"
L["The best and the worst of days"] = "Os melhores e os piores dias"
L["Most creatures slain in a day"] = "Mais abates em um dia"
L["Most quests in a day"] = "Mais missões em um dia"
L["Richest day"] = "Dia mais lucrativo"
L["Most experience in a day"] = "Mais experiência em um dia"
L["Longest day in the world"] = "Dia mais longo no mundo"
L["Longest walk in a day"] = "Maior caminhada em um dia"
L["Most places discovered in a day"] = "Mais lugares descobertos em um dia"
L["Most new faces in a day"] = "Mais rostos novos em um dia"
L["Fastest level"] = "Nível mais rápido"
L["Slowest level"] = "Nível mais lento"
L["Longest run without dying"] = "Maior período sem morrer"
L["Darkest day"] = "Dia mais sombrio"
L["Level timeline"] = "Linha do tempo de níveis"
L["How long each level took"] = "Quanto tempo cada nível levou"
L["Played for these levels"] = "Tempo jogado nestes níveis"
L["Per level"] = "Por nível"
L["No level-ups recorded yet."] = "Nenhuma subida de nível registrada ainda."
L["Still on the way."] = "Ainda a caminho."
L["Reached the next level on day %d."] = "Próximo nível alcançado no dia %d."
L["Gallery"] = "Galeria"
L["Moments, painted in the gear of their day"] = "Momentos, pintados com o equipamento do dia"
L["The first painting waits for your first great moment."] = "A primeira pintura aguarda seu primeiro grande momento."
L["Nemeses"] = "Nêmesis"
L["Nemesis number one"] = "Nêmesis número um"
L["Nobody has defeated you yet. Long may it last!"] = "Ninguém derrotou você ainda. Que continue assim!"
L["Killed you %d times"] = "Matou você %d {vez|vezes}"
L["Revenge taken"] = "Vingança cumprida"
L["Score unsettled"] = "Contas a acertar"
L["You slew them %d times."] = "Você os abateu %d {vez|vezes}."
L["Dungeon reports"] = "Relatórios de masmorra"
L["No dungeon visited yet. The depths are waiting."] = "Nenhuma masmorra visitada ainda. As profundezas aguardam."
L["Duration"] = "Duração"
L["Fallen"] = "Caídos"
L["The group"] = "O grupo"
L["Me"] = "Eu"
L["Nobody fell."] = "Ninguém caiu."

-- ledger figures, achievement pop-up, blocked functions, quotes
L["Best day: day %d"] = "Melhor dia: dia %d"
L["Worst day: day %d"] = "Pior dia: dia %d"
L["Per day"] = "Por dia"
L["Honour earned"] = "Honra conquistada"
L["Landmark discovered"] = "Ponto turístico descoberto"
L["Next tier:"] = "Próximo nível:"
L["Every tier earned!"] = "Todos os níveis conquistados!"
L["The game blocked the function %s. Please tell the author."] = "O jogo bloqueou a função %s. Por favor, avise o autor."
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "Este cliente não permite que addons tirem capturas de tela. As capturas nos grandes momentos foram desativadas."
L['"Here the journey ends, but not the story."'] = '“Aqui termina a jornada, mas não a história.”'

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "Primeiras vezes"
L["First time"] = "Primeira vez"
L["Click for all first times."] = "Clique para ver todas as primeiras vezes."
L["First creature slain"] = "Primeira criatura abatida"
L["First quest completed"] = "Primeira missão concluída"
L["First level up"] = "Primeiro nível ganho"
L["First uncommon item"] = "Primeiro item incomum"
L["First death"] = "Primeira morte"
L["First group"] = "Primeiro grupo"
L["First elite slain"] = "Primeiro elite abatido"
L["First trade"] = "Primeira troca"
L["First hearthstone"] = "Primeira pedra de regresso"
L["First landmark"] = "Primeiro ponto turístico"
L["First honour"] = "Primeira honra"
L["First rare item"] = "Primeiro item raro"
L["First rare creature"] = "Primeira criatura rara"
L["First flight"] = "Primeiro voo"
L["First gold coin"] = "Primeira moeda de ouro"
L["First dungeon"] = "Primeira masmorra"
L["First boss"] = "Primeiro chefe"
L["First skill at 75"] = "Primeira profissão em 75"
L["First mount"] = "Primeira montaria"
L["First epic item"] = "Primeiro item épico"

L["Family book"] = "Livro da família"
L["%d characters on this account"] = "%d {personagem|personagens} nesta conta"
L["you"] = "você"
L["Last seen %s"] = "Visto pela última vez em %s"
L["Who got there first?"] = "Quem chegou primeiro?"
L["Log in with your other characters once, and they will appear here."] = "Entre uma vez com seus outros personagens e eles vão aparecer aqui."

L["Time capsule"] = "Cápsula do tempo"
L["Letters to my future self"] = "Cartas para o meu eu do futuro"
L["Dear me, when you read this ..."] = "Querido eu, quando você ler isto …"
L["Seal the letter and open it ..."] = "Selar a carta e abrir …"
L["in a week"] = "em uma semana"
L["in a month"] = "em um mês"
L["at level %d"] = "no nível %d"
L["Until then the letter stays sealed. Not even you can read it."] = "Até lá a carta fica selada. Nem você pode ler."
L["No letters yet."] = "Nenhuma carta ainda."
L["Written on day %d, at level %d"] = "Escrita no dia %d, no nível %d"
L["Opened on %s"] = "Aberta em %s"
L["Sealed, opens on day %d"] = "Selada, abre no dia %d"
L["Sealed, opens at level %d"] = "Selada, abre no nível %d"
L["in %d days"] = "em %d {dia|dias}"
L["A letter for later was sealed."] = "Selei uma carta para depois."
L["A letter from the past has opened."] = "Uma carta do passado foi aberta."
L["Click to read the letter."] = "Clique para ler a carta."

L["Gatherer's map"] = "Mapa do coletor"
L["Herbalism"] = "Herborismo"
L["Mining"] = "Mineração"
L["Skinning"] = "Esfolamento"
L["Fishing"] = "Pesca"

L["Task of the week"] = "Tarefa da semana"
L["Task of the week done: %s"] = "Tarefa da semana cumprida: %s"
L["Click for the next goals."] = "Clique para ver as próximas metas."
L["Slay %d creatures this week."] = "Abata %d criaturas nesta semana."
L["Complete %d quests this week."] = "Conclua %d missões nesta semana."
L["Walk %d kilometres this week."] = "Percorra %d quilômetros a pé nesta semana."
L["Meet %d new people this week."] = "Conheça %d pessoas novas nesta semana."
L["Visit %d different regions this week."] = "Visite %d regiões diferentes nesta semana."
L["Earn %d honour tiers this week."] = "Conquiste %d níveis de honra nesta semana."
L["Finish a dungeon run this week."] = "Conclua uma incursão em masmorra nesta semana."
L["Find %d new landmarks this week."] = "Encontre %d pontos turísticos novos nesta semana."
L["Week by Week"] = "Semana a semana"
L["Complete %d tasks of the week."] = "Cumpra %d tarefas da semana."

L["Search the diary"] = "Buscar no diário"
L["%d more results, type a little more"] = "Mais %d resultados, digite um pouco mais"

L["The binding"] = "A encadernação"
L["Corner studs"] = "Cantoneiras"
L["none yet"] = "nenhuma ainda"
L["Next metal at %d honour points (now %d)."] = "Próximo metal com %d pontos de honra (agora %d)."
L["Gems"] = "Gemas"
L["One gem for every ten honour tiers (now %d)."] = "Uma gema a cada dez níveis de honra (agora %d)."
L["Gold marks on the spine"] = "Marcas douradas na lombada"
L["One for every ten levels."] = "Uma a cada dez níveis."

-- the bookplate on the endpaper

-- sayings of the day (start page)

-- covered cards in the bestiary: kinds your other characters know
L["Not yet discovered"] = "Ainda não descoberto"
L["Known to %s"] = "%s já conhece esta criatura"
L["%d to discover"] = "%d por descobrir"
L["in the east"] = "no leste"
L["in the south-east"] = "no sudeste"
L["in the south"] = "no sul"
L["in the south-west"] = "no sudoeste"
L["in the west"] = "no oeste"
L["in the north-west"] = "no noroeste"
L["in the north"] = "no norte"
L["in the north-east"] = "no nordeste"
L["in the middle"] = "no centro"
L["Screenshots at milestones: on"] = "Capturas em marcos importantes: ligadas"
L["Screenshots at milestones: off"] = "Capturas em marcos importantes: desligadas"
L["Demo mode is off."] = "Modo demo desligado."
L["Demo mode is on. Nothing you do now is written into your diary. Type /wfd demo again to leave."] = "Modo demo ligado. O que você fizer agora não entra no seu diário. Digite /wfd demo de novo para sair."
L["You have died, but who did it slipped past the diary."] = "Você morreu, mas o diário não viu quem foi."
L["Angler"] = "Pescador"
L["Raise Fishing to %d."] = "Eleve Pesca a %d."
L["Big Catch"] = "Boa pescaria"
L["Catch %d fish."] = "Pesque %d peixes."
L["Field Medic"] = "Médico de campanha"
L["Raise First Aid to %d."] = "Eleve Primeiros Socorros a %d."
L["Camp Cook"] = "Cozinheiro de acampamento"
L["Raise Cooking to %d."] = "Eleve Culinária a %d."
L["Sighted, not yet slain"] = "Avistado, ainda não abatido"
L["perhaps %s"] = "talvez %s"
L["You have been %s of this area least of all. Something may still be waiting there."] = "Onde você menos andou foi %s desta região. Talvez ainda haja algo esperando lá."
L["Defeat a boss."] = "Derrote um chefe."
L["Slay a rare creature."] = "Abata uma criatura rara."
L["Slay an elite creature."] = "Abata uma criatura de elite."
L["Visit a capital city."] = "Visite uma capital."
L["Enter a dungeon."] = "Entre em uma masmorra."
L["Take a flight."] = "Faça um voo."
L["Group with another adventurer."] = "Agrupe-se com outro aventureiro."
L["Visit a trainer."] = "Visite um instrutor."
L["Trade with another player."] = "Negocie com outro jogador."
L["Complete a quest."] = "Conclua uma missão."
L["Die once and rise again."] = "Morra uma vez e levante-se de novo."
L["Finish a dungeon run."] = "Conclua uma incursão em masmorra."
L["Do all tasks of the day on one day."] = "Cumpra todas as tarefas do dia em um dia."
L["Complete a task of the week."] = "Cumpra uma tarefa da semana."
L["Find a rare item."] = "Encontre um item raro."
L["Find an epic item."] = "Encontre um item épico."
L["Dear me, if you are reading this, you made it through the first week. Did you ever find out who was stealing the candles in the mine?"] = "Querido eu, se você está lendo isto, sobreviveu à primeira semana. Chegou a descobrir quem roubava as velas da mina?"
L["Marker set on the map: %s (%d, %d)"] = "Marcador colocado no mapa: %s (%d, %d)"
L["No marker can be set on this map."] = "Não é possível colocar um marcador neste mapa."
L["Click to set a marker on the map."] = "Clique para colocar um marcador no mapa."
L["Right-click for the map of this region."] = "Clique com o botão direito para ver o mapa desta região."
L["1 kind"] = "1 espécie"
L["Discover a new place."] = "Descubra um lugar novo."
L["Walk one kilometre today."] = "Percorra um quilômetro a pé hoje."
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "É só jogar, eu escrevo junto. Cada dia de jogo vira uma página deste livro."
L["Discover %d flight paths."] = "Descubra %d rotas de voo."
L["A sketch: %d more and it is in colour."] = "Um esboço: mais %d e ganha cor."
L["%d more to become a connoisseur."] = "Mais %d para se tornar um conhecedor."
L["Connoisseur of this kind"] = "Conhecedor desta espécie"
L["First slain on day %d"] = "Abatido pela primeira vez no dia %d"
L["Best loot"] = "Melhor saque"
L["Got you once."] = "Pegou você uma vez."
L["Got you %d times."] = "Pegou você %d {vez|vezes}."
L["CONNOISSEUR"] = "CONHECEDOR"
L["Connoisseur"] = "Conhecedor"
L["Right-click to close."] = "Clique direito para fechar."
L["bookmark"] = "marcador"
L["Goals and honour"] = "Metas e honra"
L["The world"] = "O mundo"
L["Hunt and loot"] = "Caça e espólio"
L["People and money"] = "Pessoas e dinheiro"
L["Keepsakes"] = "Lembranças"
L["Best find for every slot"] = "Melhor achado para cada espaço"
L["worn right now"] = "equipado agora"
L["Click to show only these."] = "Clique para mostrar só estes."
L["Click to show all again."] = "Clique para mostrar tudo de novo."
L["Ctrl-click to set or remove a bookmark here."] = "Ctrl-clique para pôr ou tirar um marcador aqui."
L["Click to open, right-click to remove."] = "Clique para abrir, clique direito para remover."
L["You are here."] = "Você está aqui."
L["Click for the hunting grounds of this area."] = "Clique para ver os territórios de caça desta área."
L["%d more, then in colour"] = "mais %d e fica colorido"
L["%d more, then a connoisseur"] = "mais %d e você vira conhecedor"
L["%d kinds, %d slain"] = "%d {espécie|espécies}, %d {abatido|abatidos}"
L["Hunting grounds"] = "Terrenos de caça"
L["Versatile Hunter"] = "Caçador versátil"
L["Slay creatures of %d different types."] = "Abata criaturas de %d tipos diferentes."
L["Slay 50 of each of %d kinds."] = "Abata 50 de cada uma de %d espécies."
L["Slay 50 of one kind."] = "Abata 50 criaturas de uma mesma espécie."
L["Quick on its feet, but it never looks back."] = "Ágil nas patas, mas nunca olha para trás."
L["Its pelt would fetch a fair price in town."] = "Sua pele valeria um bom preço na cidade."
L["Talks big, fights small."] = "Muita conversa, pouca luta."
L["Carried more coins than sense."] = "Carregava mais moedas que juízo."
L["Smells worse than it fights."] = "Cheira pior do que luta."
L["Dead once already. Twice is a habit."] = "Já morreu uma vez. Duas é costume."
L["Burning eyes, burning temper."] = "Olhos em chamas, gênio em chamas."
L["Whoever summoned this one owes me an apology."] = "Quem invocou este me deve desculpas."
L["Not alive, not dead, simply angry."] = "Nem vivo nem morto, apenas furioso."
L["Left nothing behind but a puddle of fury."] = "Não deixou nada além de uma poça de fúria."
L["Scales like armour. Mind the tail."] = "Escamas como armadura. Cuidado com a cauda."
L["One day I will face its big brothers."] = "Um dia enfrentarei seus irmãos mais velhos."
L["The ground shook long after it fell."] = "O chão tremeu muito depois de sua queda."
L["Big enough to have its own weather."] = "Grande o bastante para ter seu próprio clima."
L["Gnomish work, no doubt. Loud and leaky."] = "Obra gnômica, sem dúvida. Barulhenta e vazando."
L["It sparked, it whirred, it stopped."] = "Faiscou, zumbiu e parou."
L["It never stood a chance."] = "Nunca teve chance."
L["Small, harmless and now a footnote."] = "Pequeno, inofensivo e agora uma nota de rodapé."
L["A strange creature. I made a note, just in case."] = "Uma criatura estranha. Anotei, só por precaução."
L["Worth remembering, or at least worth writing down."] = "Vale lembrar, ou ao menos anotar."
L["Back"] = "Voltar"
L["To the page you came from (Backspace)."] = "Para a página de onde você veio (Backspace)."
L["Size: %d%%"] = "Tamanho: %d%%"
L["Next"] = "Próximo"
L["Keys"] = "Teclas"
L["Notifications"] = "Notificações"
L["Important only"] = "Só o importante"
L["Quiet"] = "Silêncio"
L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] = "Importante: níveis, chefes, criaturas e achados raros, masmorras, honras e cartas."
L["Home"] = "Home"
L["End"] = "End"
L["today's entry"] = "registro de hoje"
L["Backspace"] = "Backspace"
L["back"] = "voltar"
L["Ctrl + mouse wheel"] = "Ctrl + roda do mouse"
L["Ctrl + F"] = "Ctrl + F"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "Você pode definir uma tecla para abrir o livro nos atalhos do jogo, em AddOns."
L["Right-click to go to a page."] = "Clique com o botão direito para ir a uma página."
L["%d new since you last read"] = "%d novos desde a última leitura"
L["Right-click for the settings."] = "Clique com o botão direito para as configurações."
L["Drag to move this button."] = "Arraste para mover este botão."
L["Click to open."] = "Clique para abrir."
L["Moving code"] = "Código de mudança"
L["This code holds the whole diary of this character. Copy it with Ctrl+C and keep it somewhere safe, for example in a text file. On the other computer, open the same window with \"Read a moving code\" and paste it there."] = "Este código contém todo o diário deste personagem. Copie-o com Ctrl+C e guarde-o em um lugar seguro, por exemplo em um arquivo de texto. No outro computador, abra a janela com \"Ler um código de mudança\" e cole-o lá."
L["The code could not be made."] = "Não foi possível criar o código."
L["%d days, %d characters. Now press Ctrl+C."] = "%d dias, %d caracteres. Agora pressione Ctrl+C."
L["Read a moving code"] = "Ler um código de mudança"
L["Paste the moving code of this character with Ctrl+V. The diary written on this computer is then replaced by the one from the code, and the interface is reloaded."] = "Cole o código de mudança deste personagem com Ctrl+V. O diário deste computador será substituído pelo do código e a interface será recarregada."
L["Waiting for a code ..."] = "Aguardando um código …"
L["Replace the diary and reload"] = "Substituir o diário e recarregar"
L["This is not a moving code of the diary."] = "Isto não é um código de mudança do diário."
L["The code is damaged or incomplete. Copy it again, all of it."] = "O código está danificado ou incompleto. Copie-o de novo, inteiro."
L["Diary of %s (%s), %d days, %d kinds of creatures, %d people."] = "Diário de %s (%s), %d dias, %d espécies de criaturas, %d pessoas."
L["Careful: this code belongs to %s, but you are playing %s."] = "Cuidado: este código pertence a %s, mas você está jogando com %s."
L["The diary of this character on this computer will be replaced."] = "O diário deste personagem neste computador será substituído."
L["Leave demo mode first."] = "Saia primeiro do modo de demonstração."
L["moving code of this character"] = "código de mudança deste personagem"
L["read a moving code"] = "ler um código de mudança"
L["Moving to another computer"] = "Mudança para outro computador"
L["Make a moving code"] = "Criar um código de mudança"
L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."] = "Ou simplesmente leve a pasta WTF do jogo: ela contém os diários de todos os personagens."
L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."] = "Uma janela pequena com os números de hoje, as tarefas e as honras mais perto do próximo nível. Arraste pelo título e recolha com o sinal de menos."
L["Appearance"] = "Aparência"
L["Click to open the diary there."] = "Clique para abrir o diário ali."
L["Fold in or out"] = "Recolher ou expandir"
L["Leather and gold"] = "Couro e ouro"
L["Modern"] = "Moderno"
L["Next honours"] = "Próximas honras"
L["Online"] = "On-line"
L["Show the companion beside the game"] = "Mostrar a janela companheira ao lado do jogo"
L["Size of the writing"] = "Tamanho da letra"
L["Strong contrast"] = "Alto contraste"
L["Style of the book"] = "Estilo do livro"
L["The companion can be shown again in the settings or with /wfd companion."] = "A janela companheira pode ser mostrada de novo nas configurações ou com /wfd companion."
L["km"] = "km"
L["show or hide the companion"] = "mostrar ou ocultar a janela companheira"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "O diário encontrado aqui era de um personagem anterior com o mesmo nome. Ele foi guardado à parte e um diário novo foi iniciado para você. |cffffd100/wfd restore|r o traz de volta."
L["bring back the diary put aside"] = "trazer de volta o diário guardado à parte"
L["No diary has been put aside."] = "Nenhum diário foi guardado à parte."
L["The diary put aside is back. The interface is reloaded."] = "O diário guardado à parte voltou. A interface é recarregada."

-- Angler's log
L["Angler's log"] = "Diário de pesca"
L["A collector's album of everything the line brought up"] = "Um álbum de colecionador de tudo que a linha trouxe"
L["Land %d different catches."] = "Puxe %d capturas diferentes."
L["Casts"] = "Lançamentos"
L["Fish"] = "Peixe"
L["Treasure"] = "Tesouro"
L["Junk"] = "Lixo"
L["Odds and ends"] = "Miudezas"
L["Nothing has bitten yet."] = "Nada mordeu ainda."
L["Waters and tackle"] = "Águas e equipamento"
L["Where it bites, and what you fished with"] = "Onde morde e com o que você pescou"
L["Waters"] = "Águas"
L["%d caught in %d casts"] = "%d {captura|capturas} em %d {lançamento|lançamentos}"
L["Tackle"] = "Equipamento"
L["%d casts"] = "%d {lançamento|lançamentos}"
L["No fishing pole seen yet."] = "Nenhuma vara de pescar vista ainda."
L["Casts with a lure"] = "Lançamentos com isca"
L["Casts in all"] = "Lançamentos no total"
L["CAUGHT"] = "PESCADO"
L["Caught"] = "Pescado"
L["Of all catches"] = "De todas as capturas"
L["First catch"] = "Primeira captura"
L["Last catch"] = "Última captura"
L["On a lure"] = "Com isca"
L["WHERE IT BIT"] = "ONDE MORDEU"
L["Next mark: %d caught"] = "Próxima marca: %d pescados"
L["New catch: %s"] = "Nova captura: %s"
L["Catch"] = "Captura"
L["Fish Lore"] = "Saber dos peixes"
L["Fishing pole"] = "Vara de pescar"
L["Lure"] = "Isca"
L["Fishing gear"] = "Roupa de pesca"

-- 0.1.11: the today page, group pages, dog-ears, search filters, the companion's offer
L["Click to go to a page."] = "Clique para ir a uma página."
L["Right-click for the contents."] = "Clique direito para o sumário."
L["Click to set a bookmark here."] = "Clique para pôr um marcador aqui."
L["Click to remove the bookmark."] = "Clique para tirar o marcador."
L["All %d bookmarks are in use. Remove one first."] = "Os %d marcadores estão em uso. Remova um primeiro."
L["Before the diary"] = "Antes do diário"
L["open a part: today, bestiary, honour, ledger, atlas, settings ... or a day number"] = "abrir uma parte: today, bestiary, honour, ledger, atlas, settings … ou um número de dia"
L["Parchment"] = "Pergaminho"
L["Parchment is bright, like old quest paper."] = "Pergaminho é claro, como o papel das missões."
L["General"] = "Geral"
L["Tasks"] = "Tarefas"
L["Day, week and month"] = "Dia, semana e mês"
L["Perfect days"] = "Dias perfeitos"
L["Longest run"] = "Maior sequência"
L["Tasks done"] = "Tarefas cumpridas"
L["Weeks done"] = "Semanas cumpridas"
L["Months done"] = "Meses cumpridos"
L["Task of the month"] = "Tarefa do mês"
L["Task of the month done: %s"] = "Tarefa do mês cumprida: %s"
L["Slay %d creatures this month."] = "Abata %d criaturas neste mês."
L["Complete %d quests this month."] = "Conclua %d missões neste mês."
L["Walk %d kilometres this month."] = "Percorra %d quilômetros a pé neste mês."
L["Meet %d new people this month."] = "Conheça %d pessoas novas neste mês."
L["Visit %d different regions this month."] = "Visite %d regiões diferentes neste mês."
L["Earn %d honour tiers this month."] = "Conquiste %d níveis de honra neste mês."
L["Finish %d dungeon runs this month."] = "Conclua %d incursões em masmorra neste mês."
L["Find %d new landmarks this month."] = "Encontre %d pontos turísticos novos neste mês."
L["Waypoint set: %s"] = "Ponto de passagem marcado: %s"
L["Map controls"] = "Controles do mapa"
L["Mouse wheel: zoom"] = "Roda do mouse: zoom"
L["Drag: move the map"] = "Arrastar: mover o mapa"
L["Right click: reset"] = "Clique direito: redefinir"
L["New since you last read"] = "Novo desde a sua última leitura"
L["Nothing new since you last read."] = "Nada de novo desde a sua última leitura."
L["Fills as soon as there is something to tell."] = "Será preenchido assim que houver algo para contar."
L["%d new moments"] = "%d novos momentos"
L["Names from the game (places, creatures, items) stay in the language of the game client."] = "Os nomes do jogo (lugares, criaturas, itens) ficam no idioma do cliente."

L["%d days, %d kills, %d quests"] = "%d {dia|dias}, %d {abate|abates}, %d {missão|missões}"

-- memories and anniversaries
L["A memory"] = "Lembrança"
L["Read that day (day %d)"] = "Ler aquele dia (dia %d)"
L["The diary's birthday"] = "O aniversário do diário"
L["%d hours in the world"] = "%d horas neste mundo"
L["Anniversary"] = "Aniversário"
L["Nothing from earlier days to remember today."] = "Hoje não há nenhuma lembrança de dias passados."
L["A memory as a note at login"] = "Uma lembrança como aviso ao entrar"
L["show today's memory again"] = "mostrar de novo a lembrança de hoje"
loc.narrator.memory = {
    years = "{Hoje faz um ano|Hoje faz %d anos}",
    days = "Há %d dias",
    intro = {
        "%s, eu andava por %s.",
        "%s, meu caminho passava por %s.",
    },
    first = "E uma primeira vez: %s.",
}
loc.narrator.jubilee = {
    born = "Já faz {um ano|%d anos} que escrevi a primeira página deste diário.",
    hours = "Já são %d horas neste mundo. É muito chão.",
    level = "Já faz {um ano|%d anos} que cheguei ao nível %d.",
}

-- fate: every death
L["Fate"] = "Destino"
L["Every fall on the way"] = "Cada queda no caminho"
L["Places of death"] = "Lugares de morte"
L["Last death"] = "Última morte"
L["Every death"] = "Todas as mortes"
L["Cause unknown"] = "Causa desconhecida"
L["Group: %d"] = "Grupo: %d"
L["Stubborn"] = "Teimoso"
L["Defeat a foe that has defeated you three times."] = "Derrote um inimigo que te derrotou três vezes."

-- the journey replayed on the atlas
L["Watch the journey grow"] = "Ver a jornada crescer"
L["Day by day, from the first step to today."] = "Dia a dia, do primeiro passo até hoje."
L["Pause"] = "Pausar"
L["Keep the picture"] = "Guardar a imagem"
L["Drag to go to a day."] = "Arraste para ir a um dia."
L["Esc ends the replay."] = "Esc encerra a reprodução."
L["This game client does not allow addons to take screenshots."] = "Este cliente não permite que addons tirem capturas de tela."
L["kill"] = "abate"
L["day"] = "dia"
L["Nothing slain here yet."] = "Nada abatido aqui ainda."
L["No places discovered here yet."] = "Nenhum lugar descoberto aqui ainda."
L["Every first, with its day and place"] = "Cada primeira vez, com seu dia e lugar"
L["Leather and gold is the classic book. Modern is flat and calm, strong contrast makes all writing brighter."] = "Couro e ouro é o livro clássico. Moderno é simples e calmo; alto contraste deixa todo o texto mais claro."
L["Still to come"] = "Em aberto"
L["%d still to find"] = "faltam %d para descobrir"
L["No nemesis yet: nobody has defeated you so far."] = "Ainda sem arqui-inimigo: ninguém derrotou você até agora."
L["Data"] = "Dados"
L["Library"] = "Biblioteca"
L["Books I read along the way"] = "Livros que li pelo caminho"
L["Book"] = "Livro"
L["Note"] = "Bilhete"
L["Plaque"] = "Placa"
L["%d books on the shelf"] = "%d {livro|livros} na estante"
L["To read later"] = "Para ler depois"
L["The shelf is empty. Every book, note and plaque you read will stand here."] = "A estante está vazia. Cada livro, bilhete e placa que você ler ficará aqui."
L["Pages are missing: read the rest to complete this book."] = "Faltam páginas: leia o resto para completar este livro."
L["Read by %s on %s"] = "Lido por %s em %s"
L["Read later"] = "Ler depois"
L["Bookworm"] = "Rato de biblioteca"
L["Read %d books, notes and plaques."] = "Leia %d livros, bilhetes e placas."
L["Read a book, a note or a plaque."] = "Leia um livro, um bilhete ou uma placa."
L["Scholar"] = "Erudito"
L["Read %d books to the last page."] = "Leia %d livros até a última página."
L["Read a book to the last page."] = "Leia um livro até a última página."
L["Your title"] = "Seu título"
L["In the showcase"] = "Na vitrine"
L["Showcase"] = "Vitrine"
L["Click to make this your title."] = "Clique para torná-la seu título."
L["Click to give up this title."] = "Clique para deixar este título."
L["Right-click to put it in the showcase."] = "Clique com o botão direito para pôr na vitrine."
L["Right-click to take it out of the showcase."] = "Clique com o botão direito para tirar da vitrine."
L["Steel sharpened, name written down."] = "O aço está afiado, o nome está anotado."
L["The road is longer, and so is the map."] = "A estrada fica mais longa, e o mapa também."
L["Strangers become faces in the book."] = "Estranhos viram rostos no livro."
L["Another line in the story of this life."] = "Mais uma linha na história desta vida."
L["Not every treasure shines at first."] = "Nem todo tesouro brilha de início."
L["Some pages only open for the curious."] = "Algumas páginas só se abrem aos curiosos."
L["Hall of fame"] = "Galeria da fama"
L["Savings goal in gold:"] = "Meta de poupança em ouro:"
L["Goal reached"] = "Meta alcançada"
L["Savings goal"] = "Meta de poupança"
L["Set a savings goal"] = "Definir uma meta de poupança"
L["Click to change the goal."] = "Clique para mudar a meta."
L["Right-click to take the goal away."] = "Clique com o botão direito para remover a meta."
L["My own goals"] = "Minhas próprias metas"
L["Remove this goal"] = "Remover esta meta"
L["Write down what you want to do next, and tick it off when it is done."] = "Anote o que você quer fazer em seguida e marque quando estiver feito."
L["Add a goal"] = "Adicionar uma meta"
L["What do you want to do next?"] = "O que você quer fazer em seguida?"
L["%d days with entries"] = "%d {dia|dias} com registros"
L["%d levels gained"] = "%d {nível|níveis} ganhos"
L["A year of travel in figures"] = "Um ano de viagem em números"
L["Best month: %s with %d kills"] = "Melhor mês: %s com %d abates"
L["Busiest day: %s with %d kills"] = "Dia mais movimentado: %s com %d abates"
L["Days"] = "Dias"
L["Month by month"] = "Mês a mês"
L["The first year is still being written."] = "O primeiro ano ainda está sendo escrito."
L["Time online: %s"] = "Tempo online: %s"
L["Year %d"] = "Ano %d"
L["Year book"] = "Anuário"
L["If you enjoy the diary, you can support its development:"] = "Se você gosta do diário, pode apoiar o desenvolvimento:"
L["Support"] = "Apoio"
L["%d mounts"] = "%d {montaria|montarias}"
L["%d rides"] = "%d {passeio|passeios}"
L["%d factions"] = "%d {facção|facções}"
L["%d years ago today, %s brought me down in %s."] = "Há %d {ano|anos}, neste mesmo dia, %s me derrubou em %s."
L["%d years ago today I fell in %s."] = "Há %d {ano|anos}, neste mesmo dia, eu caí em %s."
L["First ridden on day %d"] = "Cavalgada pela primeira vez no dia %d"
L["Into the chat"] = "Para o chat"
L["Most days were: %s (%d)"] = "A maioria dos dias foi: %s (%d)"
L["Mounts"] = "Montarias"
L["My week: %d kills, %d quests, %s km, %d levels, %d new places."] = "Minha semana: %d abates, %d missões, %s km, %d níveis, %d lugares novos."
L["Narrow down the days: z:region  lv:20-30  d:30 (the last 30 days)"] = "Filtrar os dias: z:região  lv:20-30  d:30 (os últimos 30 dias)"
L["Reputation"] = "Reputação"
L["Reputation steps up: %d"] = "Níveis de reputação subidos: %d"
L["Seen on day %d as %s"] = "Vista no dia %d como %s"
L["The copy from before the update to version %s is back. The interface is reloaded."] = "A cópia de antes da atualização para a versão %s voltou. A interface será recarregada."
L["The first ride is still to come."] = "O primeiro passeio ainda está por vir."
L["There is no copy from before an update."] = "Não há nenhuma cópia de antes de uma atualização."
L["A day of battle"] = "Um dia de batalha"
L["A day on the road"] = "Um dia na estrada"
L["A day of quests"] = "Um dia de missões"
L["A day of fortune"] = "Um dia de fortuna"
L["A quiet day"] = "Um dia tranquilo"
L["A day of mourning"] = "Um dia de luto"
L["Every mount, and the day it was first ridden"] = "Cada montaria e o dia em que foi montada pela primeira vez"
L["How the factions came to see me"] = "Como as facções passaram a me conhecer"
L["bring back the copy from before the last update"] = "trazer de volta a cópia de antes da última atualização"
L["Drag to move."] = "Arraste para mover."
L["The notes are back at the top of the screen."] = "As notas voltaram para o alto da tela."
L["put the notes back at the top of the screen"] = "colocar as notas de volta no alto da tela"
L["Show a note to move it"] = "Mostrar uma nota para movê-la"
L["Put the notes back at the top"] = "Colocar as notas de volta no alto"
L["Pop-up notes"] = "Notas pop-up"
L["Mouse wheel changes the size."] = "A roda do mouse muda o tamanho."
L["A memory on Start"] = "Uma lembrança no Início"
L["All landmarks"] = "Todos os pontos turísticos"
L["All tasks and own goals"] = "Todas as tarefas e metas próprias"
L["Also with Ctrl + mouse wheel. Drag the corner at the bottom right for a wider or taller window."] = "Também com Ctrl + roda do mouse. Arraste o canto inferior direito para uma janela mais larga ou mais alta."
L["Bookmarks"] = "Marcadores"
L["Change the language?"] = "Mudar o idioma?"
L["Collections"] = "Coleções"
L["Commands"] = "Comandos"
L["Continue reading: %s"] = "Continuar lendo: %s"
L["Corner at the bottom right"] = "Canto inferior direito"
L["Ctrl + mouse wheel changes the size of everything."] = "Ctrl + roda do mouse muda o tamanho de tudo."
L["Drag to change the size of the window."] = "Arraste para mudar o tamanho da janela."
L["Escape"] = "Esc"
L["Every honour is at its highest tier."] = "Toda honraria está no nível mais alto."
L["Every landmark seen"] = "Todos os pontos turísticos vistos"
L["Forward"] = "Avançar"
L["Gold today"] = "Ouro de hoje"
L["Head bar"] = "Barra superior"
L["Help"] = "Ajuda"
L["It can no longer be moved or resized by mistake."] = "Assim ela não pode mais ser movida nem redimensionada sem querer."
L["Keys while the mouse is over the window"] = "Teclas com o mouse sobre a janela"
L["Keys, mouse and commands"] = "Teclas, mouse e comandos"
L["Language, export, moving, demo"] = "Idioma, exportar, mudança, demo"
L["Lock the window"] = "Travar a janela"
L["Mouse"] = "Mouse"
L["Narrow register"] = "Índice estreito"
L["No tasks today."] = "Hoje não há tarefas."
L["Nothing to remember on this day yet. In a year, this card tells what happened today."] = "Ainda não há lembrança deste dia. Daqui a um ano, este cartão conta o que aconteceu hoje."
L["Open the settings"] = "Abrir as configurações"
L["Read today's entry"] = "Ler a entrada de hoje"
L["Reload now"] = "Recarregar agora"
L["Reset the position and size"] = "Redefinir posição e tamanho"
L["Right-click a bookmark in the register"] = "Clique direito num marcador do índice"
L["Set a waypoint"] = "Marcar um ponto de rota"
L["Show all keys and commands"] = "Mostrar todas as teclas e comandos"
L["Shows the register as signs only."] = "O índice mostra só símbolos."
L["Size of the window"] = "Tamanho da janela"
L["Start"] = "Início"
L["Style, size of the writing, language and data are in the settings of the diary."] = "Estilo, tamanho da letra, idioma e dados estão nas configurações do diário."
L["The window"] = "A janela"
L["closes what lies on top, then the window"] = "fecha o que está por cima, depois a janela"
L["drag to change the size of the window"] = "arrastar para mudar o tamanho da janela"
L["drag to move the window"] = "arrastar para mover a janela"
L["list the commands in the chat"] = "listar os comandos no chat"
L["on foot"] = "a pé"
L["size of the window"] = "tamanho da janela"
L["By area"] = "Por região"
L["By kind"] = "Por tipo"
L["By water"] = "Por águas"
L["Closest to the next card"] = "Próxima carta primeiro"
L["Connoisseurs"] = "Conhecedores"
L["Filter by name"] = "Filtrar por nome"
L["Kinds"] = "Espécies"
L["Last slain"] = "Último abatido"
L["Most caught"] = "Mais pescados"
L["Most slain"] = "Mais abatidos"
L["Newest first"] = "Mais novos primeiro"
L["Nothing here yet."] = "Ainda não há nada aqui."
L["Nothing matches this choice."] = "Nada corresponde a esta escolha."
L["Previous"] = "Anterior"
L["Rare and bosses"] = "Raros e chefes"
L["Sketches"] = "Esboços"
L["Still to find"] = "Ainda por achar"
L["To discover"] = "Por descobrir"
L["Where the line was cast, and with what"] = "Onde a linha foi lançada, e com o quê"
L["A to Z"] = "De A a Z"
L["Done"] = "Concluídas"
L["Flight masters"] = "Mestres de voo"
L["Given up"] = "Abandonadas"
L["Merchants"] = "Mercadores"
L["Met last"] = "Conhecidos por último"
L["Most spoken to"] = "Com quem mais falei"
L["Open"] = "Abertas"
L["Quest givers"] = "Doadores de missões"
L["Regulars"] = "Frequentes"
L["Trainers"] = "Instrutores"
L["Best first"] = "Melhores primeiro"
L["Best per slot"] = "Melhor por espaço"
L["By category"] = "Por categoria"
L["By slot"] = "Por espaço"
L["Closest to the next tier"] = "Próximo nível primeiro"
L["Earned"] = "Conquistadas"
L["In progress"] = "Em andamento"
L["Secret"] = "Secretas"
L["Tiers"] = "Níveis"
L["Title"] = "Título"
L["Worn now"] = "Usando agora"
L["%d goals at most: tick one off or remove it first."] = "No máximo %d metas: marque uma como feita ou remova-a primeiro."
L["%d new"] = "%d novos"
L["%d parts"] = "%d partes"
L["Reload the interface"] = "Recarregar a interface"
L["Type /reload to finish."] = "Digite /reload para terminar."
L["%d bosses"] = "%d {chefe|chefes}"
L["%d fallen"] = "%d {caído|caídos}"
L["By dungeon"] = "Por masmorra"
L["By foe"] = "Por inimigo"
L["By level"] = "Por nível"
L["Creatures"] = "Criaturas"
L["Dungeons, cities and other places of their own"] = "Masmorras, cidades e outros lugares com mapa próprio"
L["Fastest first"] = "Mais rápidas primeiro"
L["Finds"] = "Achados"
L["First ridden"] = "Por primeira montaria"
L["First ride"] = "Primeira montaria"
L["Graves"] = "Túmulos"
L["Highest standing"] = "Maior reputação primeiro"
L["Most kills"] = "Mais abates"
L["Most rides"] = "Mais montarias"
L["Most together"] = "Mais tempo juntos"
L["Nobody fell"] = "Ninguém caiu"
L["Other places"] = "Outros lugares"
L["Remove"] = "Remover"
L["Resting places"] = "Locais de descanso"
L["Rides"] = "Montarias"
L["Show all %d days"] = "Mostrar todos os %d dias"
L["Show fewer"] = "Mostrar menos"
L["Show on the world map"] = "Mostrar no mapa-múndi"
L["With fallen"] = "Com caídos"
L["World map"] = "Mapa-múndi"
L["Chapters"] = "Capítulos"
L["Day %d of %d"] = "Dia %d de %d"
L["Day after"] = "Dia seguinte"
L["Day before"] = "Dia anterior"
L["Go to day"] = "Ir para o dia"
L["Remove the bookmark"] = "Remover o marcador"
L["Set a bookmark"] = "Colocar um marcador"
L["Bosses and rares"] = "Chefes e raros"
L["Experienced"] = "Vivido"
L["Oldest first"] = "Mais antigos primeiro"
L["Places"] = "Lugares"
L["Books"] = "Livros"
L["Found"] = "Encontrados"
L["Pages are missing"] = "Faltam páginas"
L["Plaques"] = "Placas"
L["Button below a day"] = "Botão abaixo de um dia"
L["search the diary"] = "pesquisar no diário"
L["turn the days of the diary"] = "passar os dias do diário"
L["Change the letter"] = "Alterar a carta"
L["Write a letter"] = "Escrever uma carta"
L["Click to read the week."] = "Clique para ler a semana."
L["Click to see them all on Start."] = "Clique para ver tudo no Início."
L["Week after"] = "Semana seguinte"
L["Week before"] = "Semana anterior"
L["%d companions removed."] = "%d companheiros removidos."
L["%d companions would be removed (strangers from battlegrounds): %s"] = "%d companheiros seriam removidos (desconhecidos de campos de batalha): %s"
L["Choose a style that suits you"] = "Escolha um estilo do seu gosto"
L["Click for Start."] = "Clique para ir ao Início."
L["First steps"] = "Primeiros passos"
L["Lock the companion in place"] = "Fixar o companheiro"
L["Lock the minimap button"] = "Fixar o botão do minimapa"
L["No companions to remove."] = "Nenhum companheiro para remover."
L["Put the card away"] = "Guardar o cartão"
L["Read a day in the diary"] = "Ler um dia do diário"
L["Search the diary (Ctrl + F)"] = "Pesquisar no diário (Ctrl + F)"
L["Set a bookmark below a day"] = "Colocar um marcador abaixo de um dia"
L["The mouse wheel over its title changes its size."] = "A roda do mouse sobre o título muda o tamanho."
L["Type /wfd cleanup yes to remove them."] = "Digite /wfd cleanup yes para removê-los."
L["find strangers from battlegrounds among the companions"] = "encontrar desconhecidos de campos de batalha entre os companheiros"
L["list what the game blocked"] = "mostrar o que o jogo bloqueou"
L["open the look back at the week"] = "abrir o resumo da semana"
L["Change the goal"] = "Mudar o objetivo"
L["A week of travel in figures"] = "Uma semana de viagem em números"
L["In this place the game keeps secret what the creatures look like."] = "Neste lugar o jogo mantém em segredo a aparência das criaturas."
L["Place discovered"] = "Lugar descoberto"
L["%s already found this place."] = "%s já encontrou este lugar."
L["Parts"] = "Seções"
L["Nothing found under %s."] = "Nada encontrado em %s."
L["Search everywhere (%d)"] = "Buscar em tudo (%d)"
L["No day fits these filters."] = "Nenhum dia corresponde a estes filtros."
L["Nothing found. Try a shorter word, or a name the way the diary writes it."] = "Nada encontrado. Tente uma palavra mais curta ou um nome do jeito que o diário escreve."
L["Undo"] = "Desfazer"
L["Bookmark removed: %s"] = "Marcador removido: %s"
L["Bookmark set: %s"] = "Marcador adicionado: %s"
L["The diary does not know \"%s\"."] = "O diário não conhece \"%s\"."
L["Left / right arrow"] = "Seta esquerda / direita"
L["Up / down arrow, Page up / down"] = "Seta cima / baixo, Page Up / Down"
L["scroll the open page"] = "rola a página aberta"
L["Alt + left / right arrow"] = "Alt + seta esquerda / direita"
L["back and forward"] = "voltar e avançar"
L["Mouse buttons 4 and 5"] = "Botões 4 e 5 do mouse"
L["removes it (the note at the foot can undo it)"] = "remove (o aviso embaixo pode desfazer)"
L["Mouse wheel on the companion"] = "Roda do mouse no companheiro"
L["size of the companion"] = "tamanho do companheiro"
L["Mouse wheel on a note"] = "Roda do mouse num aviso"
L["size of the notes"] = "tamanho dos avisos"
L["Right-click a note"] = "Clique direito num aviso"
L["closes it without opening the diary"] = "fecha sem abrir o diário"
L["Reset filter"] = "Limpar filtro"
L["No first time yet. They come by themselves while you play."] = "Nenhuma primeira vez ainda. Elas chegam sozinhas enquanto você joga."
L["When the window opens"] = "Ao abrir a janela"
L["Start after logging in"] = "Início após entrar"
L["Where I left it"] = "Onde parei"
L["Back always leads to where the window was left, also after /reload."] = "Voltar sempre leva aonde a janela foi deixada, também após /reload."
L["The cover"] = "A capa"
L["Never"] = "Nunca"
L["Only the very first time"] = "Só na primeira vez"
L["After every login"] = "Após cada login"
L["Minimap, tooltips, pictures"] = "Minimapa, dicas, imagens"
L["What is announced, and where"] = "O que é avisado, e onde"
L["Switched off, no note comes at all; the diary still writes everything down."] = "Desligado, nenhum aviso aparece; o diário ainda anota tudo."
L["Place of the notes"] = "Lugar dos avisos"
L["Style and writing"] = "Estilo e letra"
L["Size, place, opening, keys"] = "Tamanho, lugar, abertura, teclas"
L["Place and size"] = "Lugar e tamanho"
L["The companion"] = "O companheiro"
L["A small window beside the game"] = "Uma janela pequena ao lado do jogo"
L["Backups and tidying up"] = "Cópias e arrumação"
L["Bring back the diary put aside"] = "Trazer de volta o diário guardado"
L["Bring back the copy from before the update"] = "Trazer de volta a cópia de antes da atualização"
L["Remove strangers from battlegrounds"] = "Remover estranhos de campos de batalha"
L["A diary is put aside when another character's diary was found here; the copy is made before every update of the addon."] = "Um diário é guardado quando o diário de outro personagem foi encontrado aqui; a cópia é feita antes de cada atualização do addon."
L["Bring back"] = "Trazer de volta"
L["The diary written now is put aside in its place. The interface is reloaded."] = "O diário atual é guardado no lugar dele. A interface é recarregada."
L["%d more"] = "mais %d"
L["Accepted"] = "Aceita"
L["Click for the calling card."] = "Clique para o cartão de visita."
L["Click: the report. Right-click: the day."] = "Clique: o relatório. Clique direito: o dia."
L["Days together"] = "Dias juntos"
L["Given"] = "Dado"
L["Grouped"] = "Em grupo"
L["Handed in"] = "Entregue"
L["Handed in to"] = "Entregue a"
L["It is written down by itself the first time it happens."] = "É anotado sozinho na primeira vez que acontece."
L["Last trade"] = "Última troca"
L["Received"] = "Recebido"
L["Reward"] = "Recompensa"
L["Steps"] = "Níveis"
L["Trades"] = "Trocas"
L["All %d quests"] = "Todas as %d missões"
L["Click to read the first day of this month."] = "Clique para ler o primeiro dia deste mês."
L["Click: the report."] = "Clique: o relatório."
L["Click to edit."] = "Clique para editar."
L["Click: %s"] = "Clique: %s"
L["Edit the goal"] = "Editar o objetivo"
L["Goal removed: %s"] = "Objetivo removido: %s"
L["The savings goal is removed."] = "A meta de economia foi removida."
L["The tasks of the day on Start"] = "As tarefas do dia no Início"
L["Tick off"] = "Marcar como feito"
L["%d still to come"] = "%d por viver"
L["A faction is noted as soon as your standing with it changes: help it, and its steps appear here."] = "Uma facção é anotada assim que sua reputação com ela muda: ajude-a, e os níveis aparecem aqui."
L["Accept a quest: it is written down with who gave it, where, and what it brought."] = "Aceite uma missão: ela é anotada com quem a deu, onde e o que rendeu."
L["Click to show them one by one."] = "Clique para mostrá-las uma a uma."
L["Every coin you earn or spend is drawn here, day by day."] = "Cada moeda que você ganha ou gasta é desenhada aqui, dia a dia."
L["Every creature you slay gets its card here: where it lives, how often it fell, what it left behind."] = "Cada criatura abatida ganha aqui seu cartão: onde vive, quantas vezes caiu, o que deixou."
L["Every find of uncommon quality or better is kept here, with its day and who dropped it."] = "Cada achado de qualidade incomum ou melhor fica guardado aqui, com o dia e quem o deixou cair."
L["Every visit to a dungeon gets its report: the group, the bosses, the loot, who fell."] = "Cada visita a uma masmorra ganha seu relatório: o grupo, os chefes, o saque, quem caiu."
L["Fish with a rod anywhere: every new catch gets its card here."] = "Pesque com uma vara em qualquer lugar: cada nova captura ganha aqui seu cartão."
L["No boss fell this time."] = "Desta vez nenhum chefe caiu."
L["Not set yet"] = "Ainda não definido"
L["Nothing worth keeping this time."] = "Desta vez nada que valha guardar."
L["Talk to a merchant, a trainer or a quest giver: everyone you speak to gets a calling card."] = "Fale com um mercador, um instrutor ou quem dá missões: cada pessoa com quem você fala ganha um cartão de visita."
L["The diary writes itself while you play: every day gets its page, told as a story."] = "O diário se escreve sozinho enquanto você joga: cada dia ganha sua página, contada como uma história."
L["Bookmarks stand at the foot of the register."] = "Os marcadores ficam no pé do índice."
L["Filter"] = "Filtro"
L["No longer read later"] = "Não ler mais tarde"
L["Size of the notes"] = "Tamanho das notas"
L["Turn the leaves visibly"] = "Virar as folhas de forma visível"
