local tr = aegisub.gettext

script_name = tr"Copy/paste tags to/from clipboard"
script_description = tr"Copies/pastes tags from/to selected lines to/from clipboard"

script_name_c = tr"Copy tags to clipboard"
script_description_c = tr"Copies tags from selected lines to clipboard"

script_name_p = tr"Paste tags from clipboard"
script_description_p = tr"Prepends tags from clipboard to selected lines"

script_author = "biki-desu"
script_version = "2.0.1"

clipboard = require 'aegisub.clipboard'

copytags = function (subs, selected_lines, active_line)
    local ourTags = getTagsFromSelectedLines(subs, selected_lines)
    if not clipboard.set(ourTags) then fatal(tr"The clipboard could not be set, an error occurred.") end
end

pastetags = function (subs, selected_lines, active_line)
    local clipboard_contents = clipboard.get()
    if clipboard_contents == nil then err(tr"The clipboard does not currently contain text or an error occured.") end
    local supplied_lines = getTagsFromTable(splitStringToTableWithDelimeter(clipboard_contents, "\n"))

    if isEmpty(getTagsFromLine(clipboard_contents)) then
        warn(tr"The clipboard doesn't seem to contain any valid tags, nothing to do.")
    elseif not #selected_lines == #supplied_lines then
        err(string.format(tr"Line count of the selection (%d) doesn't match pasted data (%d). Use prepend.lua for more advanced tag pasting.", #selected_lines, #supplied_lines))
    else
        aegisub.set_undo_point(tr)
        
        for x, i in ipairs(selected_lines) do
            if aegisub.progress.is_cancelled() then aegisub.cancel() end --check if we need to cancel
            local l = subs[i]
            l.text = supplied_lines[x] .. l.text
            subs[i] = l
        end
    end
end

--------------------
--Helper Functions--
--------------------

--lazy way of doing error dialogs
fatal = function (errtxt)
    aegisub.log(0, errtxt)
    aegisub.cancel()
end
err = function (errtxt)
    aegisub.log(1, errtxt)
    aegisub.cancel()
end
warn = function (errtxt)
    aegisub.log(2, errtxt)
    aegisub.cancel()
end
hint = function (errtxt)
    aegisub.log(3, errtxt)
end

--checks if there is something in the string, now with more types
isEmpty = function (x)
    if type(x) == "nil" then
        return true
    elseif type(x) == "string" then
        if x == "" then return true else return false end
    elseif type(x) == "number" then
        return false --a "number" is a result of a calculation, so cannot be empty
    elseif type(x) == "table" then
        if table.concat(x) == "" or table.concat(x) == nil then return true else return false end
    elseif type(x) == "boolean" then
        return false --you're either true or false, so you cannot be empty
    else
        hint(string.format(tr"isEmpty: Cannot check %s type.", type(x)))
        return nil
    end
end

--This is a rewrite of stringToTable, this time with more functionality, less bloat and a variable delimeter
splitStringToTableWithDelimeter = function (sLine, sDelimeter)
--checks
    if isEmpty(sLine) then fatal(tr"splitStringToTableWithDelimeter: the input string cannot be empty.") end
    sDelimeter = nil and sDelimeter or "\n" --assume a default value if nil, it doesn't make any sense if a delim is nil, they could set it to the string nil tho
--return
    local tTable = {}
--consts
    local l = #sDelimeter --length of the delimeter
    local q = #sLine + 1 --end of line, because we want to a reference point at EOL, DEBUG-HINT: this is incremented by 1
--counters
    local p = 1 --start of line segment to split (x + 1)
    local i = p - l --end of line segment to split minus the delimeter (which is later added thus making this equal to 1)
--logic
    while true do
        i = string.find(sLine, sDelimeter, i + l)
        if i == nil then i = q end --no more delimeters so just get the end of the string...
        table.insert(tTable, string.sub(sLine, p, i - 1)) --(i-1) because we don't want to include the first character of the delimeter
        if i == q then break end --we reached the end of the string... it would be wise to stop...
        p = i + l -- ie: string + delimeter + delimeter
    end
    return tTable
end

--Strips text and comments from given table of lines
getTagsFromTable = function (tLines)
    if isEmpty(tLines) then fatal(tr"getTagsFromTable: the input table cannot be empty.") end
    local tTags = {}
    for _, i in ipairs(tLines) do
        local sTags = ""
        sTags = string.gsub(string.gsub(getTagsFromLine(i), "\r\n", "\n"), "\r", "\n")
        sTags = string.gsub(sTags, "\n", "\\N") --if for some reason a line has a \n in it, replace it with \\N
        table.insert(tTags,sTags)
    end
    return tTags
end

--Code deduplication
getTagsFromSelectedLines = function (subs, selected_lines)
    local sTags = ""
    for _, i in ipairs(selected_lines) do
        local l = subs[i].text
        sTags = sTags .. getTagsFromLine(l) .. "\n"
    end
    sTags = string.gsub(sTags, "(\n)$", "")
    return sTags
end

--Iterator for string.find as we cannot use re.find due to compatibility
getTagsFromLine = function (sLine)
    if isEmpty(sLine) then fatal(tr"getTagsFromLine: the input string cannot be empty.") end
    local sTags = ""
    local i = 1
    while true do
        local p, q
        p, q = string.find(sLine, "({\\[^}]*})", i) --what we really want to do is "({\\[^}]*})+"
        if p == nil then break end
        sTags = sTags .. string.sub(sLine, p, q)
        i = q + 1
    end
    return sTags
end

aegisub.register_macro(script_name_c, script_description_c, copytags)
aegisub.register_macro(script_name_p, script_description_p, pastetags)
