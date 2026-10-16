-- British English: the keys are already British, only the date order differs
local ADDON, WFD = ...
local _, loc = WFD:NewLocale("enGB")

loc.date = "%d/%m/%Y"
loc.dayMonth = "%d/%m"
loc.listAnd = " and "
function loc.longDate(d)
    return string.format("%s, %d %s %d", loc.weekdays[d.wday], d.day, loc.months[d.month], d.year)
end
