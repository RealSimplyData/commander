local DEBUG_MODE = true
local LOG_CONTEXTS = {
    ["Wait"] = "Commander; âŗ %s",
    ["Warn"] = "Commander; â ī¸ %s",
    ["Success"] = "Commander; â %s",
    ["Error"] = "Commander; đĢ %s",
    ["Confusion"] = "Commander; đ¤ˇđģââī¸ %s",
    ["Info"] = "Commander; âšī¸ %s"
}

return function(context, ...)
    if DEBUG_MODE then
        if LOG_CONTEXTS[context] then
            if context == "Error" then
                error(string.format(LOG_CONTEXTS[context], ...), 2)
            elseif context == "Warn" then
                warn(string.format(LOG_CONTEXTS[context], ...))
            else
                print(string.format(LOG_CONTEXTS[context], ...))
            end
        end
    end
end