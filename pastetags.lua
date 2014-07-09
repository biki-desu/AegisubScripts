local tr = aegisub.gettext

script_name = tr"Paste tags from clipboard"
script_description = tr"Prepends tags from clipboard to selected lines"
script_author = "biki-desu"
script_version = "1.1.1"

clipboard = require 'aegisub.clipboard'

function pastetags_cl(subs, selected_lines)
    local clipboard_content = clipboard.get()
    if clipboard_content = nil then err(tr"The clipboard does not currently contain text or an error occured.") end
    local tablefiedClipboard = stringToTable(clipboard_content)
    local supplied_lines = getTagsFromTable(tablefiedClipboard)

    if isInteger(#selected_lines / #supplied_lines) then
        if #selected_lines / #supplied_lines == 1 then errtxt = string.format(tr"Add %s things to %s selected lines.", #supplied_lines, #supplied_lines) elseif #selected_lines == 1 then errtxt = string.format(tr"Add %q to selected line.", cfg_v.textbox) elseif #selected_lines / #supplied_lines == #selected_lines then errtxt = string.format(tr"Add %q to %s selected lines.", cfg_v.textbox, #selected_lines) else errtxt = string.format(tr"Add %s things repeated %s times to %s selected lines.", #supplied_lines, #selected_lines / #supplied_lines, #selected_lines) end
        aegisub.set_undo_point(errtxt) --plural undo text ^^
        
        local y --counter for the supplied_lines table repetition (does the same thing as x when table has "x" thing in it, otherwise it repeats itself )
        for x, i in ipairs(selected_lines) do
            y = ((x - 1) % #supplied_lines) + 1 --arrays in lua start at 1 so this makes sense (-1 to make it 0,1... and +1 to make it 1,2...)
            local l = subs[i]
            l.text = supplied_lines[y] .. l.text
            subs[i] = l
        end
    else
        err(string.format(tr"Line count of the selection (%s) doesn't match pasted data (%s).", #supplied_lines, #selected_lines))
    end
end

--------------------
--Helper Functions--
--------------------

--lazy way of doing error dialogs
function err(errtxt)
    aegisub.log(0, errtxt)
    aegisub.cancel()
end

--Returns true if a number is an integer
function isInteger(x)
    return math.floor(x) == x
end

--Splits a multi-line string into a table of one-line strings
function stringToTable(sLine)
    local data = string.gsub(sLine, "\r\n", "\n") --because windows sucks --not handling "\r" because this is long deprecated
    local p = {} --char table for start of line index
    local q = {} --char table for end of line index
    table.insert(p, 1) --first entry
    local i = 0 --counter
    local j = 0 --counter
    while true do
        j = i
        i = string.find(data, "\n", i + 1) --as "\n" is one character
        if i == j + 1 then --if line empty, ie: "^...\n(\n)...\n...$" (found the thing in brackets)
            table.insert(q, i - 1)
            table.insert(p, i + 1)
        elseif i == nil then --if found last new line, ie: "^...(\n)...$" (found the thing in brackets)
            i = string.find(data, "$") --find the index of last character in the string, ie "^...nil"
            table.insert(q, i - 1)
            break
        else --if found a new line and there's at least one more, ie: "^...(\n)...\n...$" (found the thing in brackets)
            table.insert(q, i - 1)
            table.insert(p, i + 1)
        end
    end
    local aTable = {}
    for u = 1, #p, 1 do
        t = string.sub(data, p[u], q[u])
        table.insert(aTable, t)
    end
    return aTable
end

--Strips text and comments from given table of lines
function getTagsFromTable(tLines)
    local sTag = ""
    local tTags = {}
    for x, i in ipairs(tLines) do
        sTag = string.gsub(getTagsFromLine(i), "\r\n", "\n")
        sTag = string.gsub(sTag, "\n", "\\N")
        table.insert(tTags,sTag)
    end
    return tTags
end

--Wrapper for string.find as re.find doesn't work
function getTagsFromLine(l)
    local sTags = ""
    local i = 1
    while true do
        local p, q
        p, q = string.find(l, "({\\[^}]*})", i)
        if p == nil then break end
        sTags = sTags .. string.sub(l, p, q)
        i = q + 1
    end
    --sTags = string.gsub(sTags, "(\n)$", "")
    return sTags
end

aegisub.register_macro(script_name, script_description, pastetags_cl)
