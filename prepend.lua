local tr = aegisub.gettext

script_name = tr"Prepend stuff to selected lines"
script_description = tr"Prepends stuff from textbox to all selected lines"
script_author = "biki-desu"
script_version = "2.2.4"

--Set button labels / id's
--Do it here because it's faster
local t_pl = tr"Prepend line"
local t_al = tr"Append line"
local t_pft = tr"Prepend first tag"
local t_aft = tr"Append first tag"
local t_plt = tr"Prepend last tag"
local t_alt = tr"Append last tag"
local t_ir
local t_c = tr"Clear"
local t_e = tr"Cancel"

--Configuration
local c_keepconfig = false --keep script configuration
local c_mode = 0 --0 means repetitive "abcabcabc", 1 means iterative "aaabbbccc"
local c_textbox = "" --default text

--This is called first, deals with configuration
function script_start(subs, selected_lines, active_line)
    if not c_keepconfig then --Check if we want to keep configuration, if not then reset to default
        c_mode = 0
        c_textbox = ""
    end

    agi_dialog = {
        { class = "textbox"; x = 0; y = 0; width = 80; height = 8; hint = tr"Please insert text here"; name = "textbox"; text = c_textbox; }
    }

    script_gui(subs, selected_lines)
end

--This deals with the script GUI and does a large chunk of error checking
function script_gui(subs, selected_lines)
    if c_mode == 0 then t_ir = "(abcabc) mode" else t_ir = "(aabbcc) mode" end --set current mode button/id

    local agi_button, agi_result = aegisub.dialog.display(agi_dialog, {t_pl, t_al, t_pft, t_aft, t_plt, t_alt, t_ir, t_c, t_e})
    c_textbox = agi_result.textbox

    if agi_button == t_e then --Cancel
        aegisub.cancel()
    elseif agi_button == t_c then --Clear
        c_textbox = ""
        script_gui(subs, selected_lines)
    elseif agi_button == t_ir then --Mode
        if c_mode == 1 then c_mode = 0 else c_mode = 1 end --invert the current mode
        script_gui(subs, selected_lines)
    else --don't care whenever prepending/appending at this point
        local raw_supplied_lines = c_textbox --this needs to be a separate variable for a reason, don't change it!
        local supplied_lines = splitStringToTableWithDelimeter(string.gsub(raw_supplied_lines, "\r\n", "\n"), "\n") --because windows sucks --not handling "\r" because this is long deprecated

        if isInteger(#selected_lines / #supplied_lines) and not isEmpty(raw_supplied_lines) then
            local errtxt
            if #selected_lines / #supplied_lines == 1 then
                errtxt = string.format(tr"Add %d things to %d selected lines.", #supplied_lines, #supplied_lines)
            elseif #selected_lines == 1 then
                errtxt = string.format(tr"Add %q to selected line.", raw_supplied_lines)
            elseif #supplied_lines == 1 then
                errtxt = string.format(tr"Add %q to %d selected lines.", raw_supplied_lines, #selected_lines)
            elseif isInteger(#selected_lines / #supplied_lines) then
                errtxt = string.format(tr"Add %d things repeated %d times to %d selected lines.", #supplied_lines, #selected_lines / #supplied_lines, #selected_lines)
            else
                fatal(tr"Unknown error occoured, cannot continue.")
            end
            aegisub.set_undo_point(errtxt)
            aegisub.progress.task(errtxt)

            script_process(subs, selected_lines, supplied_lines, agi_button)
        elseif isEmpty(raw_supplied_lines) then
            warn(tr"No text supplied, nothing to do.")
        elseif isEmpty(supplied_lines) then
            fatal(tr"Line parsing went wrong. THIS SCRIPT IS BROKEN.")
        elseif not isInteger(#selected_lines / #supplied_lines) then
            err(string.format(tr"Line count of the selection (%d) doesn't match pasted data (%d).", #selected_lines, #supplied_lines))
        else
            fatal(tr"Unknown error occoured, cannot continue.")
        end
    end
end

--This does the actual prepending/appending
function script_process(subs, selected_lines, supplied_lines, agi_button)
    local p_n = 1 --progress numerator
    local p_d = #selected_lines --progress denominator

    local y --counter for the supplied_lines table repetition (does the same thing as x when table has "x" thing in it)
    for x, i in ipairs(selected_lines) do
        if aegisub.progress.is_cancelled() then aegisub.cancel() end --check if we need to cancel

        if c_mode == 0 then --abcabc mode
            y = ((x - 1) % #supplied_lines) + 1 --arrays in lua start at 1 so this makes sense (-1 to make it 0,1... and +1 to make it 1,2...)
        else --aabbcc mode
            y = math.ceil((x / #selected_lines) * #supplied_lines)
        end
        if 0 >= y or y > #selected_lines then fatal(tr"Algorithm error, cannot continue.") end --do some bounds checking, DEBUG-HINT: this does the exact opposite of what it's logically supposed to do

        local l = subs[i]

        --FYI, doing checking in the loop because it's silly to assume that all lines are the same
        if agi_button == t_pl then --Prepend line
            l.text = supplied_lines[y] .. l.text
        elseif agi_button == t_al then --Append line
            l.text = l.text .. supplied_lines[y]
        else --P/A f/l tags
            local a
            if agi_button == t_pft then --Prepend first tag
                a = string.find(l.text, "{")
            elseif agi_button == t_aft then --Append first tag
                a = string.find(l.text, "}")
            elseif agi_button == t_plt then --Prepend last tag
                a = string.find(l.text, "{[^{]*$")
            elseif agi_button == t_alt then --Append last tag
                _, a = string.find(l.text, "{.*}")
            else --this should not happen, but is here just in case I add an extra button and don't write any processing code for it
                fatal(tr"Unknown action requested, cannot continue.")
            end

            if a == nil then
                if not isEmpty(supplied_lines[y]) then l.text = "{}" .. l.text end
                a = 1
            elseif agi_button == t_aft or agi_button == t_alt then
                a = a - 1 --we want to append BEFORE the "}"
            end

            l.text = string.sub(l.text, 1, a) .. supplied_lines[y] .. string.sub(l.text, a + 1, string.find(l.text, "$"))
        end

        subs[i] = l

        aegisub.progress.set((p_n / p_d) * 100)
        p_n = p_n + 1
    end
end

--------------------
--Helper Functions--
--------------------

--lazy way of doing error dialogs
function fatal(errtxt)
    aegisub.log(0, errtxt)
    aegisub.cancel()
end
function err(errtxt)
    aegisub.log(1, errtxt)
    aegisub.cancel()
end
function warn(errtxt)
    aegisub.log(2, errtxt)
    aegisub.cancel()
end
function hint(errtxt)
    aegisub.log(3, errtxt)
end

--checks if there is something in the string, now with more types
function isEmpty(x)
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
        hint(string.format(tr"isEmpty: Cannot check %s type", type(x)))
        return nil
    end
end

--Returns true if a number is an integer
function isInteger(x)
    return math.floor(x)==x
end

--This is a rewrite of stringToTable, this time with more functionality, less bloat and a variable delimeter
function splitStringToTableWithDelimeter(sLine, sDelimeter)
    local tTable = {}
--counters
    local p = 1 --start of line segment to split
    local i = 0 --end of line segment to split + delimeter
--consts
    local _, l = string.find(sDelimeter, "$") --length of the delimeter
    local q = string.find(sLine, "$") --end of line, because we want to a reference point at EOL, DEBUG-HINT: this is incremented by 1
--stuff
    while true do
        i = string.find(sLine, sDelimeter, i + l)
        if i == nil then i = q end --no more delimeters so just get the end of the string...
        table.insert(tTable, string.sub(sLine, p, i - 1)) --(i-1) because we don't want to include the first character of the delimeter
        if i == q then break end --we reached the end of the string... it would be wise to stop...
        p = i + l -- ie: string + delimeter + delimeter
    end
    return tTable
end

aegisub.register_macro(script_name, script_description, script_start)
