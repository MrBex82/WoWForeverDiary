-- American English: the English keys use British spelling, this file adjusts it
local ADDON, WFD = ...
local L, loc = WFD:NewLocale("enUS")

L["Favourite prey"] = "Favorite prey"
L["Distance travelled"] = "Distance traveled"
L["The tabs on the right lead to the parts of the book, one colour for each group. Point at them to read their names. A red dot shows how much is new since you last read."] = "The tabs on the right lead to the parts of the book, one color for each group. Point at them to read their names. A red dot shows how much is new since you last read."
L["%d more, then in colour"] = "%d more, then in color"

-- the remaining diary templates fall back to the English defaults in Narrator.lua
loc.listAnd = " and "
loc.narrator = {
    walk = {
        "Walked about %s kilometers%s.",
        "My feet say roughly %s kilometers%s.",
        "Around %s kilometers on foot%s, and my legs know it.",
    },
}
L["Book of honour"] = "Book of honor"
L["%d of %d honour tiers reached"] = "%d of %d honor tiers reached"
L["Walk 50 kilometres."] = "Walk 50 kilometers."
L["Walk 250 kilometres."] = "Walk 250 kilometers."
L["Walk %d kilometres."] = "Walk %d kilometers."
L["Honour points"] = "Honor points"
L["A secret honour. Keep exploring!"] = "A secret honor. Keep exploring!"
L["Honour earned: %s"] = "Honor earned: %s"
L["Honour earned: %s (%s)"] = "Honor earned: %s (%s)"
L["Honour"] = "Honor"
L["%d honour points"] = "%d honor points"
L["Some honours stay hidden until you find them."] = "Some honors stay hidden until you find them."
L["Walk %d kilometres today."] = "Walk %d kilometers today."
L["Kilometres"] = "Kilometers"
L["Honours"] = "Honors"
L["Honour earned"] = "Honor earned"
L["Walk %d kilometres this week."] = "Walk %d kilometers this week."
L["Earn %d honour tiers this week."] = "Earn %d honor tiers this week."
L["Next metal at %d honour points (now %d)."] = "Next metal at %d honor points (now %d)."
L["One gem for every ten honour tiers (now %d)."] = "One gem for every ten honor tiers (now %d)."
L["First honour"] = "First honor"
L["Walk one kilometre today."] = "Walk one kilometer today."
L["A sketch - %d more and it is in colour."] = "A sketch - %d more and it is in color."
L["Scales like armour. Mind the tail."] = "Scales like armor. Mind the tail."
