local tr = aegisub.gettext

script_name = tr"Prepend stuff to selected lines"
script_description = tr"Prepends stuff from textbox to all selected lines"
script_author = "biki-desu"
script_version = "2.1.1"

if not prepend_stuff_ui then prepend_stuff_ui = {} end
prepend_stuff_ui.cfg = {{ class = "textbox"; name = "textbox"; x = 0; y = 0; height = 8; width = 80 }}
local t_p = tr"Prepend"
local t_a = tr"Append"
local t_e = tr"Exit"

function prepend_stuff(subs, selected_lines, active_line)
    local cfg_k, cfg_v, errtxt
    cfg_k, cfg_v = aegisub.dialog.display(prepend_stuff_ui.cfg, {t_p, t_a, t_e})
    if cfg_k == t_p or cfg_k == t_e then --don't care whenever prepending/appending at this point
        local supplied_lines = stringToTable(cfg_v.textbox)
        if isInteger(#selected_lines / #supplied_lines) then
            if #selected_lines / #supplied_lines == 1 then errtxt = string.format("Add %s things to %s selected lines.", #supplied_lines, #supplied_lines) elseif #selected_lines == 1 then errtxt = string.format("Add %q to selected line.", cfg_v.textbox) elseif #selected_lines / #supplied_lines == #selected_lines then errtxt = string.format("Add %q to %s selected lines.", cfg_v.textbox, #selected_lines) else errtxt = string.format("Add %s things repeated %s times to %s selected lines.", #supplied_lines, #selected_lines / #supplied_lines, #selected_lines) end
            aegisub.set_undo_point(errtxt) --plural undo text ^^
            
            local y --counter for the supplied_lines table repetition (does the same thing as x when table has "x" thing in it, otherwise it repeats itself )
            for x, i in ipairs(selected_lines) do
                y = ((x - 1) % #supplied_lines) + 1 --arrays in lua start at 1 so this makes sense (-1 to make it 0,1... and +1 to make it 1,2...)
                local l = subs[i]
                if cfg_k == t_p then l.text = supplied_lines[y] .. l.text else l.text = l.text .. supplied_lines[y] end --differentiate between prepending/appending
                subs[i] = l
            end
        else
            errtxt = string.format("Line count of the selection (%s) doesn't match pasted data (%s).", #supplied_lines, #selected_lines)
            aegisub.dialog.display({{class="label", label=errtxt, x=0, y=0, width=4, height=2}}, {"OK"}, {close='OK'})
        end
        aegisub.progress.task(tr"Done")
    else
        aegisub.progress.task(tr"Cancelled")
    end
end

--------------------
--Helper Functions--
--------------------

--Returns true if a number is an integer
function isInteger(x)
    return math.floor(x)==x
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

aegisub.register_macro(script_name, script_description, prepend_stuff)
