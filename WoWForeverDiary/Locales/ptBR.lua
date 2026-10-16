-- Brazilian Portuguese translation (English phrases are the keys)
local ADDON, WFD = ...
local L, loc = WFD:NewLocale("ptBR")

local T = {
    -- chat / log
    ["Diary"] = "Diário",
    ["Travel diary active - today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."] =
        "Diário de viagem ativo - hoje é o |cffffd100dia %d|r. |cffffd100/wfd|r abre o diário.",
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
    ["LIFELINE"] = "LINHA DA VIDA",
    ["now"] = "agora",
    ["Screenshot:"] = "Captura de tela:",
    ["Click to read this day."] = "Clique para ler este dia.",
    ["Click to open the diary."] = "Clique para abrir o diário.",
    ["%d kills today"] = "%d abates hoje",
    ["%d quests today"] = "%d missões hoje",
    ["DEMO MODE - invented data"] = "MODO DEMO - dados inventados",

    -- tabs
    ["Journal"] = "Diário",
    ["World Map"] = "Mapa-múndi",
    ["Bestiary"] = "Bestiário",
    ["People"] = "Pessoas",
    ["Quest Book"] = "Livro de missões",
    ["Statistics"] = "Estatísticas",
    ["Export"] = "Exportar",

    -- journal
    ["Today"] = "Hoje",
    ["Chronicle"] = "Crônica",
    ["Overview"] = "Resumo",
    ["Nothing recorded yet."] = "Nada registrado ainda.",
    ["Balance of the day"] = "Balanço do dia",
    ["Enemies slain"] = "Inimigos abatidos",
    ["Quests completed"] = "Missões concluídas",
    ["(done / accepted)"] = "(concluídas / aceitas)",
    ["People spoken to"] = "Pessoas com quem falou",
    ["Experience gained"] = "Experiência obtida",
    ["Distance travelled"] = "Distância percorrida",
    ["flown"] = "voando",
    ["Time online"] = "Tempo on-line",
    ["Deaths"] = "Mortes",
    ["Jumps"] = "Pulos",
    ["Purse"] = "Bolsa",
    ["Income"] = "Receitas",
    ["Expenses"] = "Despesas",
    ["Net"] = "Saldo",
    ["Fallen foes"] = "Inimigos derrotados",
    ["... and %d more kinds"] = "... e mais %d espécies",
    ["Completed quests"] = "Missões concluídas",
    ["Spoken to"] = "Conversas",
    ["Loot (%d items)"] = "Saque (%d itens)",
    ["Loot"] = "Saque",
    ["Places"] = "Lugares",
    ["Special moments"] = "Momentos especiais",
    ["photo"] = "foto",

    -- map
    ["Footsteps"] = "Pegadas",
    ["Kills"] = "Abates",
    ["Quests"] = "Missões",
    ["No map art available for this area."] = "Não há mapa disponível para esta área.",
    ["VISITED AREAS"] = "ÁREAS VISITADAS",
    ["Play"] = "Reproduzir",
    ["Stop"] = "Parar",
    ["Only this day"] = "Somente este dia",
    ["Drag the slider through time: your footsteps grow day by day."] = "Arraste o controle pelo tempo: suas pegadas crescem dia após dia.",
    ["Spoken to %d times"] = "%d conversas",
    ["Quest accepted here"] = "Missão aceita aqui",
    ["Quest handed in here"] = "Missão entregue aqui",
    ["You died here"] = "Você morreu aqui",
    ["Killed by %s"] = "Morto por %s",
    ["Footprints: %d spots   Kills: %d   Deaths: %d"] = "Pegadas: %d lugares   Abates: %d   Mortes: %d",
    ["No travels recorded yet."] = "Nenhuma viagem registrada ainda.",

    -- bestiary
    ["Name"] = "Nome",
    ["Level"] = "Nível",
    ["Recent"] = "Recente",
    ["Foes"] = "Inimigos",
    ["Nemeses"] = "Nêmesis",
    ["Bosses and rares"] = "Chefes e raros",
    ["Boss"] = "Chefe",
    ["Rare"] = "Raro",
    ["Elite"] = "Elite",
    ["Normal"] = "Normal",
    ["No portrait"] = "Sem retrato",
    ["KILLS PER DAY"] = "ABATES POR DIA",
    ["Kills: %d"] = "Abates: %d",
    ["Rank: #%d of %d kinds"] = "Posição: nº %d de %d espécies",
    ["First kill:"] = "Primeiro abate:",
    ["Last kill:"] = "Último abate:",
    ["Seen in:"] = "Visto em:",
    ["This creature killed you %d times."] = "Esta criatura matou você %d vezes.",
    ["Your nemesis"] = "Seu nêmesis",
    ["Last seen in:"] = "Visto pela última vez em:",
    ["Last time:"] = "Última vez:",
    ["You have killed it %d times."] = "Você a abateu %d vezes.",
    ["Nobody has killed you yet."] = "Ninguém matou você ainda.",

    -- people
    ["Talks"] = "Conversas",
    ["First met"] = "Primeiro encontro",
    ["Show on map"] = "Mostrar no mapa",
    ["QUESTS WITH THIS PERSON"] = "MISSÕES COM ESTA PESSOA",
    ["Conversations: %d"] = "Conversas: %d",
    ["Found in:"] = "Encontra-se em:",
    ["First met:"] = "Primeiro encontro:",
    ["Last met:"] = "Último encontro:",
    ["given and received"] = "dada e recebida",
    ["given"] = "dada",
    ["handed in"] = "recebida",
    ["No quests recorded."] = "Nenhuma missão registrada.",
    ["Role:"] = "Função:",
    ["All"] = "Todos",
    ["%d of %d people"] = "%d de %d pessoas",
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
    ["Completed"] = "Concluídas",
    ["Open"] = "Abertas",
    ["Abandoned"] = "Abandonadas",
    ["In progress"] = "Em andamento",
    ["Received from:"] = "Recebida de:",
    ["Handed in to:"] = "Entregue a:",
    ["Accepted:"] = "Aceita:",
    ["Completed:"] = "Concluída:",
    ["Took:"] = "Duração:",
    ["Experience:"] = "Experiência:",
    ["Gold reward:"] = "Recompensa em ouro:",
    ["Reward:"] = "Recompensa:",
    ["Where I accepted it"] = "Onde a aceitei",
    ["Where I handed it in"] = "Onde a entreguei",
    ["%d of %d quests completed"] = "%d de %d missões concluídas",
    ["No quests recorded yet."] = "Nenhuma missão registrada ainda.",

    -- statistics
    ["Gold"] = "Ouro",
    ["XP"] = "XP",
    ["Time"] = "Tempo",
    ["Distance"] = "Distância",
    ["Nothing to chart yet."] = "Nada para mostrar ainda.",
    ["WHERE THE MONEY CAME FROM"] = "DE ONDE VEIO O DINHEIRO",
    ["WHERE THE MONEY WENT"] = "PARA ONDE FOI O DINHEIRO",
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
    ["As text"] = "Como texto",
    ["Select all"] = "Selecionar tudo",
    ["Ctrl+C copies the selection."] = "Ctrl+C copia a seleção.",
    ["SETTINGS"] = "CONFIGURAÇÕES",
    ["Take a screenshot at milestones"] = "Capturar a tela em marcos importantes",
    ["Announce milestones in chat"] = "Anunciar marcos no bate-papo",
    ["Show minimap button"] = "Mostrar botão no minimapa",
    ["First day"] = "Primeiro dia",

    -- redesigned interface
    ["Travel Diary"] = "Diário de viagem",
    ["Day of life"] = "Dia de vida",
    ["Days of life"] = "Dias de vida",
    ["Memories of the day"] = "Lembranças do dia",
    ["A day without great events."] = "Um dia sem grandes acontecimentos.",
    ["Ledger"] = "Balanço",
    ["Experience"] = "Experiência",
    ["Conversations"] = "Conversas",
    ["On foot"] = "A pé",
    ["Map of my travels"] = "Mapa das minhas viagens",
    ["Layers"] = "Camadas",
    ["%d kinds - %d kills"] = "%d espécies - %d abates",
    ["%d nemeses"] = "%d nêmesis",
    ["No creature has fallen yet."] = "Nenhuma criatura caiu ainda.",
    ["Slain"] = "Abatidos",
    ["Rank"] = "Posição",
    ["First kill"] = "Primeiro abate",
    ["Last kill"] = "Último abate",
    ["Seen in"] = "Visto em",
    ["Killed you"] = "Matou você",
    ["You slew it"] = "Abatida por você",
    ["Last seen in"] = "Visto pela última vez em",
    ["Last time"] = "Última vez",
    ["\"First encountered on day %d in %s.\""] = "\"Primeiro encontro no dia %d, em %s.\"",
    ["\"Revenge is a dish best served cold.\""] = "\"A vingança é um prato que se come frio.\"",
    ["Acquaintances"] = "Conhecidos",
    ["Found in"] = "Encontra-se em",
    ["Place"] = "Local",
    ["Last met"] = "Último encontro",
    ["Region"] = "Região",
    ["Received from"] = "Recebida de",
    ["Handed in to"] = "Entregue a",
    ["Accepted"] = "Aceita",
    ["Took"] = "Duração",
    ["Reward"] = "Recompensa",
    ["Balance of a life"] = "Balanço de uma vida",
    ["Since %s"] = "Desde %s",
    ["Remarkable"] = "Destaques",
    ["Bloodiest day"] = "Dia mais sangrento",
    ["Richest day"] = "Dia mais lucrativo",
    ["Favourite prey"] = "Presa favorita",
    ["Arch-enemy"] = "Arqui-inimigo",
    ["Home of the heart"] = "Lar do coração",
    ["Closest confidant"] = "Confidente mais próximo",
    ["Day by day"] = "Dia a dia",
    ["Came from"] = "Origem",
    ["Went to"] = "Destino",
    ["Transcript"] = "Transcrição",
    ["Settings"] = "Configurações",
    ["Size of the book"] = "Tamanho do livro",
    ["Demo"] = "Demo",
    ["Start demo mode"] = "Iniciar modo demo",
    ["Leave demo mode"] = "Sair do modo demo",
    ["Commands"] = "Comandos",
    ["open or close the diary"] = "abrir ou fechar o diário",
    ["explore with invented data"] = "explorar com dados inventados",
    ["screenshots on or off"] = "ativar ou desativar capturas de tela",
    ["minimap button on or off"] = "mostrar ou ocultar o botão do minimapa",
    ["\"Screenshots are saved in the Screenshots folder of your game.\""] = "\"As capturas de tela ficam na pasta Screenshots do jogo.\"",
}
for k, v in pairs(T) do L[k] = v end

-- dates and diary entries
loc.date = "%d/%m/%Y"
loc.decimal = ","
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
        "{Um inimigo caiu|%d inimigos caíram} pelas minhas mãos.",
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
        "Continua ...",
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
L["Appendix"] = "Apêndice"
L["Begun on %s"] = "Iniciado em %s"
L["Bookmark"] = "Marcador"
L["Click to open today's entry."] = "Clique para abrir o registro de hoje."
L["Click to open"] = "Clique para abrir"
L["Contents"] = "Sumário"
L["Notes"] = "Notas"
L["Page %d"] = "Página %d"
L["Realm: %s"] = "Reino: %s"
L["This book belongs to"] = "Este livro pertence a"
L["in %s, at level %d"] = "%s, no nível %d"
L["in %s, on the first day of my life"] = "%s, no primeiro dia da minha vida"
L["of"] = "de"

-- book pages (diary, appendix)
L["\"Whoever wanders, gathers stories.\""] = "\"Quem viaja, coleciona histórias.\""
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
L["%d kills"] = "%d abates"
L["%d quests"] = "%d missões"
L["died %dx"] = "%d mortes"
L["Kept as a memory"] = "Guardado como lembrança"
L["Click to read this day aloud in chat."] = "Clique para ler este dia em voz alta no bate-papo."
L["The pages are still empty. Go and live an adventure!"] = "As páginas ainda estão em branco. Vá viver uma aventura!"
L["p. %d"] = "p. %d"
L["Milestones"] = "Marcos"
L["The great moments of a life"] = "Os grandes momentos de uma vida"
L["No milestones yet."] = "Nenhum marco ainda."
L["Maps"] = "Mapas"
L["%s spent here"] = "%s passados aqui"
L["Route"] = "Rota"
L["Kill sites"] = "Locais de combate"
L["Graves"] = "Túmulos"
L["First visit"] = "Primeira visita"
L["Time spent"] = "Tempo passado"
L["Creatures slain here"] = "Criaturas abatidas aqui"
L["Acquaintances here"] = "Conhecidos aqui"
L["A naturalist's notes"] = "Notas de um naturalista"
L["Slain %d times"] = "Abatida %d vezes"
L["Killed you %d times"] = "Matou você %d vezes"
L["Every creature, by number slain"] = "Cada criatura, por número de abates"
L["Everyone I met on my way"] = "Todos que encontrei pelo caminho"
L["Every coin, in and out"] = "Cada moeda, entrada e saída"
L["Balance"] = "Saldo"
L["Day"] = "Dia"
L["Tasks taken and done"] = "Tarefas aceitas e cumpridas"
L["Scribe's notes"] = "Notas do escriba"
L["How this book is kept"] = "Como este livro é mantido"
L["Copy the diary as text"] = "Copiar o diário como texto"
L["Copy the diary as JSON"] = "Copiar o diário como JSON"
L["Ledger"] = "Livro-caixa"

-- own notes
L["Click here to write your own notes ..."] = "Clique aqui para escrever suas próprias notas ..."
L["My own thoughts:"] = "Meus próprios pensamentos:"
L["+ note"] = "+ nota"
L["edit note"] = "editar nota"
L["Save"] = "Salvar"
L["Cancel"] = "Cancelar"

-- cards
L["Wanted poster"] = "Cartaz de procurado"
L["Acquaintance"] = "Conhecido"
L["Click for the wanted poster."] = "Clique para ver o cartaz de procurado."
L["Click for the portrait."] = "Clique para ver o retrato."

-- collector's album
L["A collector's album of every creature slain"] = "Um álbum de coleção de todas as criaturas abatidas"
L["kinds collected  -  %d creatures slain"] = "espécies coletadas  -  %d criaturas abatidas"
L["Bronze"] = "Bronze"
L["Silver"] = "Prata"
L["Mithril"] = "Mithril"
L["Legend"] = "Lenda"
L["Collect %d kinds of creatures."] = "Colete %d espécies de criaturas."
L["Reached!"] = "Alcançado!"
L["%d still missing."] = "Faltam %d."
L["Bosses"] = "Chefes"
L["Rare creatures"] = "Criaturas raras"
L["Album pages"] = "Páginas do álbum"
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
L["Nobody was met here yet."] = "Você ainda não conheceu ninguém aqui."
L["Grave"] = "Túmulo"
L["Chronicle of the region"] = "Crônica da região"
L["Visits"] = "Visitas"
L["Quests completed here"] = "Missões concluídas aqui"
L["Deaths here"] = "Mortes aqui"
L["Most hunted here"] = "Mais caçados aqui"
L["Places discovered"] = "Lugares descobertos"

-- companions, honours, treasures, memories, obituary
L["%d days of life  -  %d creatures slain  -  %d quests completed"] = "%d dias de vida  -  %d criaturas abatidas  -  %d missões concluídas"
L["%d days"] = "%d dias"
L["%d enemies fell that day."] = "Naquele dia caíram %d inimigos."
L["%d kills together"] = "%d abates juntos"
L["%d of %d honours earned"] = "%d de %d honras conquistadas"
L["%d times grouped"] = "%d vezes em grupo"
L["%d treasures collected"] = "%d tesouros coletados"
L["%dx traded"] = "%d trocas"
L["A painted memory"] = "Uma lembrança pintada"
L["Book of honour"] = "Livro de honra"
L["Companions"] = "Companheiros"
L["Copy for forum or Discord (Markdown)"] = "Copiar para fórum ou Discord (Markdown)"
L["Fell in %s"] = "Caiu em %s"
L["Fell to %s"] = "Caiu diante de %s"
L["Slain by %s"] = "Morte pelas mãos de %s"
L["Fellow adventurers"] = "Companheiros de aventura"
L["Fellowship"] = "Irmandade"
L["Grouped with %s"] = "Em grupo com %s"
L["In memoriam"] = "In memoriam"
L["Loot of %s"] = "Saque de %s"
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
L["You were in %s."] = "Você esteve em %s."
L["early in the morning"] = "de manhã cedo"
L["in the morning"] = "pela manhã"
L["around noon"] = "por volta do meio-dia"
L["in the afternoon"] = "à tarde"
L["in the evening"] = "ao anoitecer"
L["late at night"] = "tarde da noite"
L["earned"] = "conquistado"
L["first met %s"] = "primeiro encontro em %s"

-- honours
L["First Blood"] = "Primeiro sangue"
L["Slay your first creature."] = "Abata sua primeira criatura."
L["Slayer"] = "Matador"
L["Slay 100 creatures."] = "Abata 100 criaturas."
L["Scourge of the Wilds"] = "Flagelo das terras selvagens"
L["Slay 1000 creatures."] = "Abata 1000 criaturas."
L["Champion"] = "Campeão"
L["Slay 5000 creatures."] = "Abata 5000 criaturas."
L["Specialist"] = "Especialista"
L["Slay 100 of a single kind."] = "Abata 100 criaturas de uma mesma espécie."
L["Naturalist"] = "Naturalista"
L["Collect 50 kinds of creatures."] = "Colete 50 espécies de criaturas."
L["Rare Hunter"] = "Caçador de raridades"
L["Slay 5 rare creatures."] = "Abata 5 criaturas raras."
L["Bane of Bosses"] = "Flagelo dos chefes"
L["Defeat a boss."] = "Derrote um chefe."
L["Giant Slayer"] = "Matador de gigantes"
L["Defeat 10 bosses."] = "Derrote 10 chefes."
L["Into the Depths"] = "Rumo às profundezas"
L["Enter a dungeon."] = "Entre em uma masmorra."
L["Hunter"] = "Caçador"
L["Helping Hand"] = "Mão amiga"
L["Complete 10 quests."] = "Conclua 10 missões."
L["Hero of the People"] = "Herói do povo"
L["Complete 100 quests."] = "Conclua 100 missões."
L["Explorer"] = "Explorador"
L["Discover 25 places."] = "Descubra 25 lugares."
L["Cartographer"] = "Cartógrafo"
L["Discover 100 places."] = "Descubra 100 lugares."
L["Globetrotter"] = "Andarilho do mundo"
L["Visit 5 regions."] = "Visite 5 regiões."
L["Wanderer"] = "Andarilho"
L["Walk 50 kilometres."] = "Percorra 50 quilômetros a pé."
L["Pathfinder"] = "Desbravador"
L["Walk 250 kilometres."] = "Percorra 250 quilômetros a pé."
L["Frequent Flyer"] = "Viajante frequente"
L["Take 10 flights."] = "Faça 10 voos."
L["Thrifty"] = "Econômico"
L["Own 10 gold."] = "Tenha 10 de ouro."
L["Wealthy"] = "Abastado"
L["Own 100 gold."] = "Tenha 100 de ouro."
L["Seasoned"] = "Experiente"
L["Reach level 20."] = "Alcance o nível 20."
L["Veteran"] = "Veterano"
L["Reach level 40."] = "Alcance o nível 40."
L["Reach level 60."] = "Alcance o nível 60."
L["Untouchable"] = "Intocável"
L["Play 5 days in a row without dying."] = "Jogue 5 dias seguidos sem morrer."
L["Faithful Chronicler"] = "Cronista fiel"
L["Keep this diary for 30 days."] = "Mantenha este diário por 30 dias."
L["Sociable"] = "Sociável"
L["Meet 25 people."] = "Conheça 25 pessoas."
L["Bouncy"] = "Saltitante"
L["Jump 1000 times."] = "Pule 1000 vezes."
L["Treasure Hunter"] = "Caçador de tesouros"
L["Find 5 rare items."] = "Encontre 5 itens raros."
L["Group with 5 other adventurers."] = "Agrupe-se com 5 outros aventureiros."

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
L["%d of %d landmarks found"] = "%d de %d pontos turísticos encontrados"
L["%d of %d regions explored"] = "%d de %d regiões exploradas"
L["%d tiers earned"] = "%d níveis conquistados"
L["A familiar face ..."] = "Um rosto conhecido ..."
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
L["Every journey needs a pause ..."] = "Toda jornada precisa de uma pausa ..."
L["Every region of this continent is explored."] = "Todas as regiões deste continente foram exploradas."
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
L["Just one more quest ..."] = "Só mais uma missão ..."
L["Keep this diary for %d days."] = "Mantenha este diário por %d dias."
L["Landmark discovered: %s"] = "Ponto turístico descoberto: %s"
L["Landmark"] = "Ponto turístico"
L["Landmarks"] = "Pontos turísticos"
L["Loot %d items."] = "Saqueie %d itens."
L["Marathon"] = "Maratona"
L["Master of a Craft"] = "Mestre de um ofício"
L["Meet %d flight masters."] = "Conheça %d mestres de voo."
L["Meet %d people."] = "Conheça %d pessoas."
L["Mouse wheel: zoom  -  drag: move  -  right click: reset"] = "Roda do mouse: zoom  -  arrastar: mover  -  clique direito: redefinir"
L["Next goals"] = "Próximas metas"
L["Next rank: %s"] = "Próximo nível: %s"
L["Night Owl"] = "Coruja noturna"
L["Not every day is a good day ..."] = "Nem todo dia é um bom dia ..."
L["Not yet explored"] = "Ainda não explorada"
L["Own %d gold."] = "Tenha %d de ouro."
L["People met"] = "Pessoas conhecidas"
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
L["So many roads, so little time ..."] = "Tantos caminhos, tão pouco tempo ..."
L["Some honours stay hidden until you find them."] = "Algumas honras ficam ocultas até que você as encontre."
L["Spend %d hours in the world on a single day."] = "Passe %d horas no mundo em um único dia."
L["Spend %d hours in the world."] = "Passe %d horas no mundo."
L["Take %d flights."] = "Faça %d voos."
L["Talk to the same person %d times."] = "Fale %d vezes com a mesma pessoa."
L["The early bird catches the worm ..."] = "Deus ajuda quem cedo madruga ..."
L["The purse over the days"] = "A bolsa ao longo dos dias"
L["There is no place like home ..."] = "Não há lugar como o lar ..."
L["This game client knows none of the landmarks."] = "Este cliente do jogo não conhece nenhum dos pontos turísticos."
L["Towns of Kalimdor"] = "Locais de Kalimdor"
L["Towns of the Eastern Kingdoms"] = "Locais dos Reinos do Leste"
L["Trade with %d players."] = "Negocie com %d jogadores."
L["Unexplored regions"] = "Regiões inexploradas"
L["Up, up and away ..."] = "Para o alto e avante ..."
L["Use your hearthstone %d times."] = "Use sua Pedra de Regresso %d vezes."
L["Visit %d capital cities."] = "Visite %d capitais."
L["Visit %d regions in a single day."] = "Visite %d regiões em um único dia."
L["Visit %d regions."] = "Visite %d regiões."
L["Visit %d trainers."] = "Visite %d instrutores."
L["Walk %d kilometres."] = "Percorra %d quilômetros a pé."
L["Well Rested"] = "Bem descansado"
L["What is left to discover"] = "O que ainda falta descobrir"
L["When the moon stands highest ..."] = "Quando a lua está mais alta ..."
L["Where will the road lead tomorrow?"] = "Para onde o caminho levará amanhã?"
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
L["of %d kinds"] = "de %d tipos"
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
L["A quiet week"] = "Uma semana tranquila"
L["The book waits for new stories."] = "O livro aguarda novas histórias."
L["Show a note for new discoveries"] = "Avisar sobre novas descobertas"
L["Weekly look back at login"] = "Resumo semanal ao entrar"

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
L["They sent me to the spirit healer"] = "Eles me mandaram ao Curandeiro Espiritual"
L["Nemesis number one"] = "Nêmesis número um"
L["Nobody has defeated you yet. Long may it last!"] = "Ninguém derrotou você ainda. Que continue assim!"
L["Killed you %d times"] = "Matou você %d vezes"
L["Revenge taken"] = "Vingança cumprida"
L["Score unsettled"] = "Contas a acertar"
L["You slew them %d times."] = "Você os abateu %d vezes."
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
L["Every tier earned - complete!"] = "Todos os níveis conquistados - concluído!"
L["The game blocked the function %s. Please tell the author."] = "O jogo bloqueou a função %s. Por favor, avise o autor."
L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."] = "Este cliente não permite que addons tirem capturas de tela. As capturas nos grandes momentos foram desativadas."
L['"Here the journey ends, but not the story."'] = '“Aqui termina a jornada, mas não a história.”'
L['"Whoever wanders, gathers stories."'] = '“Quem viaja coleciona histórias.”'

-- first times, family book, time capsule, gatherer's map, task of the week, search, the binding
L["First times"] = "Primeiras vezes"
L["First time"] = "Primeira vez"
L["%d of %d experienced"] = "%d de %d vividas"
L["Not yet experienced."] = "Ainda não vivido."
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
L["First skill at 75"] = "Primeira habilidade em 75"
L["First mount"] = "Primeira montaria"
L["First epic item"] = "Primeiro item épico"

L["Family book"] = "Livro da família"
L["%d characters on this account"] = "%d personagens nesta conta"
L["you"] = "você"
L["Last seen %s"] = "Visto pela última vez em %s"
L["Who got there first?"] = "Quem chegou primeiro?"
L["Log in with your other characters once, and they will appear here."] = "Entre uma vez com seus outros personagens e eles vão aparecer aqui."

L["Time capsule"] = "Cápsula do tempo"
L["Letters to my future self"] = "Cartas para o meu eu do futuro"
L["Dear me, when you read this ..."] = "Querido eu, quando você ler isto ..."
L["Seal the letter and open it ..."] = "Selar a carta e abrir ..."
L["in a week"] = "em uma semana"
L["in a month"] = "em um mês"
L["at level %d"] = "no nível %d"
L["Until then the letter stays sealed - not even you can read it."] = "Até lá a carta fica selada - nem você pode ler."
L["No letters yet."] = "Nenhuma carta ainda."
L["Written on day %d, at level %d"] = "Escrita no dia %d, no nível %d"
L["Opened on %s"] = "Aberta em %s"
L["Sealed - opens on day %d"] = "Selada - abre no dia %d"
L["Sealed - opens at level %d"] = "Selada - abre no nível %d"
L["in %d days"] = "em %d dias"
L["A letter for later was sealed."] = "Selei uma carta para depois."
L["A letter from the past has opened."] = "Uma carta do passado foi aberta."
L["Click to read the letter."] = "Clique para ler a carta."

L["Gatherer's map"] = "Mapa do coletor"
L["Where the good things grow"] = "Onde crescem as coisas boas"
L["Herbalism"] = "Herborismo"
L["Mining"] = "Mineração"
L["Skinning"] = "Esfolamento"
L["Fishing"] = "Pesca"
L["Most found here"] = "Mais encontrado aqui"
L["Nothing gathered yet. Herbs, ore and hides show up here as soon as you gather them."] = "Nada coletado ainda. Ervas, minério e couro aparecem aqui assim que você coletar."

L["Task of the week"] = "Tarefa da semana"
L["Task of the week done: %s"] = "Tarefa da semana cumprida: %s"
L["Click for the next goals."] = "Clique para ver as próximas metas."
L["Slay %d creatures this week."] = "Abata %d criaturas nesta semana."
L["Complete %d quests this week."] = "Conclua %d missões nesta semana."
L["Walk %d kilometres this week."] = "Caminhe %d quilômetros nesta semana."
L["Meet %d new people this week."] = "Conheça %d pessoas novas nesta semana."
L["Visit %d different regions this week."] = "Visite %d regiões diferentes nesta semana."
L["Earn %d honour tiers this week."] = "Conquiste %d níveis de honra nesta semana."
L["Finish a dungeon run this week."] = "Conclua uma incursão em masmorra nesta semana."
L["Find %d new landmarks this week."] = "Encontre %d pontos turísticos novos nesta semana."
L["Week by Week"] = "Semana a semana"
L["Complete %d tasks of the week."] = "Cumpra %d tarefas da semana."

L["Search the diary"] = "Buscar no diário"
L["Days, people, creatures, quests and places."] = "Dias, pessoas, criaturas, missões e lugares."
L["Search: a name, a quest, a place ..."] = "Buscar: um nome, uma missão, um lugar ..."
L["Nothing found."] = "Nada encontrado."
L["%d more results - type a little more"] = "Mais %d resultados - digite um pouco mais"

L["The binding"] = "A encadernação"
L["Corner studs"] = "Cantoneiras"
L["none yet"] = "nenhuma ainda"
L["Next metal at %d honour points (now %d)."] = "Próximo metal com %d pontos de honra (agora %d)."
L["Gems"] = "Gemas"
L["One gem for every ten honour tiers (now %d)."] = "Uma gema a cada dez níveis de honra (agora %d)."
L["Gold marks on the spine"] = "Marcas douradas na lombada"
L["One for every ten levels."] = "Uma a cada dez níveis."

-- the bookplate on the endpaper
L["FROM THE LIBRARY OF"] = "DA BIBLIOTECA DE"

-- sayings of the day (start page)
L["SAYING OF THE DAY"] = "DITADO DO DIA"
L["Whoever wanders, gathers stories."] = "Quem viaja coleciona histórias."
L["Every road starts at your own door."] = "Todo caminho começa na porta de casa."
L["A full pack is light when the heart is lighter."] = "Uma mochila cheia é leve quando o coração é ainda mais leve."
L["Maps show the way - only feet know it."] = "Os mapas mostram o caminho; só os pés o conhecem."
L["The longest journey is the one you never write down."] = "A viagem mais longa é aquela que nunca se escreve."
L["Ink fades slower than memory."] = "A tinta desbota mais devagar que a memória."
L["A good campfire turns strangers into companions."] = "Uma boa fogueira transforma estranhos em companheiros."
L["The mountain does not care how tired you are - just keep going."] = "A montanha não liga para o seu cansaço; o que importa é seguir."
L["Today's detour is tomorrow's best story."] = "O desvio de hoje é a melhor história de amanhã."
L["Gold comes and goes, the story stays."] = "O ouro vem e vai; a história fica."
L["Count the days by friends, not by miles."] = "Conte os dias em amigos, não em léguas."
L["Even the smallest kobold guards a candle for someone."] = "Até o menor kobold guarda uma vela para alguém."
L["Resting is part of the road."] = "Descansar também faz parte do caminho."
L["Fear is a map with too many blank spots."] = "O medo é um mapa com espaços em branco demais."
L["Every scar has a page in this book."] = "Cada cicatriz tem sua página neste diário."
L["Look back now and then - the view is part of the journey."] = "Olhe para trás de vez em quando: a vista faz parte da viagem."
L["The wise traveller asks the innkeeper first."] = "O viajante sábio pergunta primeiro ao taverneiro."
L["Rain on the road, sunshine in the story."] = "Chuva na estrada, sol na história."
L["Whoever never falls never learns to get up."] = "Quem nunca cai nunca aprende a se levantar."
L["A quest half done is still a step forward."] = "Uma missão pela metade ainda é um passo à frente."
L["The horizon travels with you - that is why it never gets dull."] = "O horizonte viaja com você; por isso nunca fica chato."
L["Write it down, or it never happened."] = "Escreva, senão nunca aconteceu."
L["Old boots know more than new maps."] = "Botas velhas sabem mais que mapas novos."
L["Courage is being afraid and saddling up anyway."] = "Coragem é ter medo e selar o cavalo mesmo assim."
L["Tomorrow the road will still be there. Tonight the fire is warm."] = "Amanhã a estrada ainda estará lá. Hoje à noite, a fogueira está quente."
L["A traveller's purse is light, a traveller's diary is heavy."] = "Bolsa leve, diário pesado: assim é o viajante."
L["The best places are on no map."] = "Os melhores lugares não estão em mapa nenhum."
L["Every hero once did not know the way."] = "Todo herói um dia não sabia o caminho."
L["Share your bread, and the road shares its secrets."] = "Divida seu pão, e a estrada dividirá seus segredos."
L["The story is not over while a page is still blank."] = "A história não acaba enquanto houver uma página em branco."

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
L["To the contents"] = "Ir para o sumário"
L["Screenshots at milestones: on"] = "Capturas em marcos importantes: ligadas"
L["Screenshots at milestones: off"] = "Capturas em marcos importantes: desligadas"
L["Demo mode is off."] = "Modo demo desligado."
L["Demo mode is on. Nothing you do now is written into your diary - type /wfd demo again to leave."] = "Modo demo ligado. O que você fizer agora não entra no seu diário - digite /wfd demo de novo para sair."
L["You have died, but who did it slipped past the diary."] = "Você já morreu, mas quem foi escapou ao diário."
L["Already in the quest log"] = "Aceitas antes do diário"
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
L["Walk one kilometre today."] = "Caminhe um quilômetro hoje."
L["WELCOME"] = "BEM-VINDO"
L["Just play, I'll write along. Every day you play becomes a page in this book."] = "É só jogar, eu escrevo junto. Cada dia de jogo vira uma página deste livro."
L["See a sample book"] = "Ver um livro de exemplo"
L["To today's entry"] = "Ir para hoje"
L["Discover %d flight paths."] = "Descubra %d rotas de voo."
L["A sketch - %d more and it is in colour."] = "Um esboço - mais %d e ganha cor."
L["%d more to become a connoisseur."] = "Mais %d para se tornar um conhecedor."
L["Connoisseur of this kind"] = "Conhecedor desta espécie"
L["First slain on day %d"] = "Abatido pela primeira vez no dia %d"
L["Best loot"] = "Melhor saque"
L["Got you once."] = "Pegou você uma vez."
L["Got you %d times."] = "Pegou você %d vezes."
L["CONNOISSEUR"] = "CONHECEDOR"
L["Connoisseur"] = "Conhecedor"
L["Every kind known here is collected."] = "Todas as espécies conhecidas aqui foram coletadas."
L["Kinds of creatures"] = "Tipos de criaturas"
L["Who fell to your blade, by kind"] = "Quem caiu diante da sua lâmina, por tipo"
L["Unknown kind"] = "Tipo desconhecido"
L["%d kinds  -  %d slain"] = "%d espécies  -  %d abatidos"
L["Hunting grounds"] = "Terrenos de caça"
L["Sighted"] = "Avistado"
L["Kinds slain here"] = "Espécies abatidas aqui"
L["Each pin marks where the first of its kind fell."] = "Cada marcador mostra onde caiu o primeiro de sua espécie."
L["Versatile Hunter"] = "Caçador versátil"
L["Slay creatures of %d different types."] = "Abata criaturas de %d tipos diferentes."
L["Slay 50 of each of %d kinds."] = "Abata 50 de cada uma de %d espécies."
L["Slay 50 of one kind."] = "Abata 50 de uma mesma espécie."
L["Quick on its feet, but it never looks back."] = "Ágil nas patas, mas nunca olha para trás."
L["Its pelt would fetch a fair price in town."] = "Sua pele valeria um bom preço na cidade."
L["Talks big, fights small."] = "Muita conversa, pouca luta."
L["Carried more coins than sense."] = "Carregava mais moedas que juízo."
L["Smells worse than it fights."] = "Cheira pior do que luta."
L["Dead once already. Twice is a habit."] = "Já morreu uma vez. Duas é costume."
L["Burning eyes, burning temper."] = "Olhos em chamas, gênio em chamas."
L["Whoever summoned this one owes me an apology."] = "Quem invocou este me deve desculpas."
L["Not alive, not dead - simply angry."] = "Nem vivo nem morto - apenas furioso."
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
L["Go to page (1 - %d):"] = "Ir para a página (1 - %d):"
L["Size: %d%%"] = "Tamanho: %d%%"
L["The bookmarks"] = "Os marcadores"
L["The bookmarks on the right lead to the parts of the book. A red dot shows how much is new since you last read."] = "Os marcadores à direita levam às partes do livro. Um ponto vermelho mostra quanto há de novo desde a última leitura."
L["Search"] = "Busca"
L["The spyglass on the spine searches the whole book: days, people, creatures, quests and places."] = "A luneta na lombada busca no livro inteiro: dias, pessoas, criaturas, missões e lugares."
L["Turning pages"] = "Virar páginas"
L["Turn the pages with the arrows, the mouse wheel or the arrow keys. The red ribbon below always leads to today; Backspace takes you back. Ctrl + mouse wheel changes the size of the book."] = "Vire as páginas com as setas, a roda do mouse ou as teclas de seta. A fita vermelha embaixo sempre leva a hoje; Backspace volta. Ctrl + roda muda o tamanho do livro."
L["Almost everything can be clicked"] = "Quase tudo é clicável"
L["Cards, names, days and maps open more. Right-click the page number to go to any page. The settings are in the scribe's notes at the very end."] = "Cartas, nomes, dias e mapas abrem mais. Clique com o botão direito no número da página para ir a qualquer página. As configurações estão nas notas do escriba, bem no final."
L["Next"] = "Próximo"
L["Skip"] = "Pular"
L["Got it"] = "Entendi"
L["Handling"] = "Uso"
L["Keys and comfort"] = "Teclas e conforto"
L["Notifications"] = "Notificações"
L["Important only"] = "Só o importante"
L["Quiet"] = "Silêncio"
L["Important: levels, bosses, rare creatures and finds, deaths, dungeons, honours and letters."] = "Importante: níveis, chefes, criaturas e achados raros, mortes, masmorras, honras e cartas."
L["Keys while the mouse is over the book"] = "Teclas com o mouse sobre o livro"
L["Arrow keys, Page up / down"] = "Setas, Page Up / Down"
L["turn the page"] = "virar a página"
L["Home"] = "Home"
L["contents"] = "sumário"
L["End"] = "End"
L["today's entry"] = "registro de hoje"
L["Backspace"] = "Backspace"
L["back"] = "voltar"
L["Ctrl + mouse wheel"] = "Ctrl + roda do mouse"
L["size of the book"] = "tamanho do livro"
L["Right-click the page number"] = "Botão direito no número da página"
L["go to a page"] = "ir para uma página"
L["open or close the book"] = "abrir ou fechar o livro"
L["A key to open the book can be set in the game's key bindings, under AddOns."] = "Você pode definir uma tecla para abrir o livro nos atalhos do jogo, em AddOns."
L["The book"] = "O livro"
L["Reset the position"] = "Redefinir a posição"
L["Show the introduction again"] = "Mostrar a introdução de novo"
L["Open the scribe's notes"] = "Abrir as notas do escriba"
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
L["Waiting for a code ..."] = "Aguardando um código ..."
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
L["Both reload the interface. With bigger writing a few long lines may run close together."] = "Ambas recarregam a interface. Com letra maior, algumas linhas longas podem ficar apertadas."
L["Click to open the diary there."] = "Clique para abrir o diário ali."
L["Companion"] = "Companheiro"
L["Fold in or out"] = "Recolher ou expandir"
L["How the book looks"] = "Como o livro aparece"
L["Leather and gold"] = "Couro e ouro"
L["Leather and gold is the old book. Modern is flat and calm, strong contrast makes all writing brighter."] = "Couro e ouro é o livro de sempre. Moderno é simples e calmo; alto contraste deixa todo o texto mais claro."
L["Modern"] = "Moderno"
L["Next honours"] = "Próximas honras"
L["Online"] = "On-line"
L["Show the companion beside the game"] = "Mostrar a janela companheira ao lado do jogo"
L["Size of the writing"] = "Tamanho da letra"
L["Strong contrast"] = "Alto contraste"
L["Style of the book"] = "Estilo do livro"
L["The companion can be shown again in the settings or with /wfd companion."] = "A janela companheira pode ser mostrada de novo nas configurações ou com /wfd companion."
L["Turn the leaves visibly"] = "Virar as folhas de forma visível"
L["Turning the pages"] = "Virar páginas"
L["km"] = "km"
L["reloads the interface"] = "recarrega a interface"
L["show or hide the companion"] = "mostrar ou ocultar a janela companheira"
L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."] = "O diário encontrado aqui era de um personagem anterior com o mesmo nome. Ele foi guardado à parte e um diário novo foi iniciado para você. |cffffd100/wfd restore|r o traz de volta."
L["bring back the diary put aside"] = "trazer de volta o diário guardado à parte"
L["No diary has been put aside."] = "Nenhum diário foi guardado à parte."
L["The diary put aside is back. The interface is reloaded."] = "O diário guardado à parte voltou. A interface é recarregada."
