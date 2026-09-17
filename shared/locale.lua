Locales = Locales or {}

function _U(str, ...)
    local lang = (Config and (Config.DefaultLocale or (type(Config.Locale) == "string" and Config.Locale))) or "tr"
    if not Locales[lang] then
        lang = "en"
    end

    if Locales[lang] and Locales[lang][str] then
        if select('#', ...) > 0 then
            return string.format(Locales[lang][str], ...)
        else
            return Locales[lang][str]
        end
    end

    if Locales['en'] and Locales['en'][str] then
        if select('#', ...) > 0 then
            return string.format(Locales['en'][str], ...)
        else
            return Locales['en'][str]
        end
    end

    return str
end
