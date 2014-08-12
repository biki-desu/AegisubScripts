local tr = aegisub.gettext

script_name = tr"Prepend stuff to selected lines"
script_description = tr"Prepends stuff from textbox to all selected lines"
script_author = "biki-desu"
script_version = "2.2.7"

--Set button labels / id's
--Do it here because it's faster
local t_pl = tr"Prepend line"
local t_al = tr"Append line"
local t_pft = tr"Prepend first tag"
local t_aft = tr"Append first tag"
local t_plt = tr"Prepend last tag"
local t_alt = tr"Append last tag"
local t_pnt = tr"Prepend nth tag"
local t_ant = tr"Append nth tag"
local t_ir
local t_abcabc = "(abcabc) mode"
local t_aabbcc = "(aabbcc) mode"
local t_c = tr"Clear"
local t_e = tr"Cancel"

--Configuration
local c_act = nil --action, true = prepend, false == append
local c_keepconfig = false --keep script configuration
local c_mode = true --true means repetitive "abcabcabc", false means iterative "aaabbbccc"
local c_nth = nil --1st tag
local c_textbox = "" --default text

--This is called first, deals with configuration
function script_start(subs, selected_lines, active_line)
    if not c_keepconfig then --Check if we want to keep configuration, if not then reset to default
        c_mode = true
        c_nth = nil
        c_textbox = ""
    end

    c_act = nil

    script_gui(subs, selected_lines)
end

--This deals with the script GUI and does a large chunk of error checking
function script_gui(subs, selected_lines)
    t_ir = c_mode and t_abcabc or t_aabbcc --set current mode button/id

    local agi_dialog = {
        { class = "textbox"; x = 0; y = 0; width = 70; height = 8; hint = tr"Please insert text here"; name = "textbox"; text = c_textbox; }
    }

    local agi_button, agi_result = aegisub.dialog.display(agi_dialog, {t_pl, t_al, t_pft, t_aft, t_plt, t_alt, t_ir, t_c, t_e})
    c_act, c_nth = getConfigFromButton(agi_button)
    c_textbox = agi_result.textbox

    if c_act == t_e then --Cancel
        aegisub.cancel()
    elseif c_act == t_c then --Clear
        c_textbox = ""
        script_gui(subs, selected_lines)
    elseif c_act == t_ir then --Mode
        c_mode = not c_mode --invert the current mode
        script_gui(subs, selected_lines)
    else --don't care whenever prepending/appending at this point
        local supplied_lines = splitStringToTableWithDelimeter(string.gsub(string.gsub(c_textbox, "\r\n", "\n"), "\r", "\n"), "\n") --because windows sucks --not handling "\r" because this is long deprecated
        if isInteger(#selected_lines / #supplied_lines) and not isEmpty(c_textbox) then
            local sStatus = formatStatusMsg(selected_lines, supplied_lines)
            aegisub.progress.task(sStatus)
            script_process(subs, selected_lines, supplied_lines)
            aegisub.set_undo_point(firstCharToLowercase(sStatus))
        elseif isEmpty(c_textbox) then
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
function script_process(subs, selected_lines, supplied_lines)
    local p_n = 1 --progress numerator
    local p_d = #selected_lines --progress denominator

    local y --counter for the supplied_lines table repetition (does the same thing as x when table has "x" thing in it)
    for x, i in ipairs(selected_lines) do
        if aegisub.progress.is_cancelled() then aegisub.cancel() end --check if we need to cancel

        if c_mode then --abcabc mode
            y = ((x - 1) % #supplied_lines) + 1 --arrays in lua start at 1 so this makes sense (-1 to make it 0,1... and +1 to make it 1,2...)
        else --aabbcc mode
            y = math.ceil((x / #selected_lines) * #supplied_lines)
        end
        if 0 >= y or y > #selected_lines then fatal(tr"Algorithm error, cannot continue.") end --do some bounds checking, DEBUG-HINT: this does the exact opposite of what it's logically supposed to do

        local l = subs[i]

        --FYI, doing checking in the loop because it's silly to assume that all lines are the same
        if c_nth == 0 then
            l.text = c_act and supplied_lines[y] .. l.text or l.text .. supplied_lines[y]
        else --P/A f/l tags
            local a
            if c_nth == 1 then
                a = c_act and string.find(l.text, "{") or string.find(l.text, "}")
            elseif c_nth == -1 then
                a = c_act and string.find(l.text, "{[^{]*$") or string.find(l.text, "}[^}]*$")
            else
                a = c_act and stringRegexIterator(l.text, "{", c_nth) or stringRegexIterator(l.text, "}", c_nth)
            end
            if a == nil then
                if not isEmpty(supplied_lines[y]) then l.text = "{}" .. l.text end
                a = 1
            elseif not c_act then
                a = a - 1 --we want to append BEFORE the "}"
            end

            l.text = string.sub(l.text, 1, a) .. supplied_lines[y] .. string.sub(l.text, a + 1, #l.text + 1)
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

--A dirty function to turn the first character of a string to lower case
function firstCharToLowercase(sString)
    return string.lower(string.sub(sString, 1, 1)) .. string.sub(sString, 2, #sString + 1)
end

--Do this through another function because it clutters some other function >_>
function getConfigFromButton(agi_button)
    local c_act, c_nth = c_act, c_nth --don't modify globals
    if agi_button == t_pl then --Prepend line
        c_act = true
        c_nth = 0
    elseif agi_button == t_al then --Append line
        c_act = false
        c_nth = 0
    elseif agi_button == t_pft then --Prepend first tag
        c_act = true
        c_nth = 1
    elseif agi_button == t_aft then --Append first tag
        c_act = false
        c_nth = 1
    elseif agi_button == t_pnt then --Prepend nth tag
        c_act = true
    elseif agi_button == t_ant then --Append nth tag
        c_act = false
    elseif agi_button == t_plt then --Prepend last tag
        c_act = true
        c_nth = -1
    elseif agi_button == t_alt then --Append last tag
        c_act = false
        c_nth = -1
    elseif agi_button == t_ir then --Mode
        c_act = t_ir
        c_nth = nil
    elseif agi_button == t_c then --Clear
        c_act = t_c
        c_nth = nil
    elseif agi_button == t_e then --Cancel
        c_act = t_e
        c_nth = nil
    else
        fatal(tr"getConfigFromButton: Unknown action requested.")
    end
    return c_act, c_nth
end

--Dialog and undo text formatting
function formatStatusMsg(selected_lines, supplied_lines)
    local c_act, c_nth, c_textbox = c_act, c_nth, c_textbox --don't modify globals
    local sActName, sActType

    if c_act == true then
        sActName = tr"Prepending"
    elseif c_act == false then
        sActName = tr"Appending"
    else
        fatal(tr"formatStatusMsg: Requested message cannot be formatted, unknown action requested.")
    end

    if c_nth == nil then
        fatal(tr"formatStatusMsg: Requested message cannot be formatted, unknown position requested.")
    elseif c_nth == 0 then
        sActType = tr"the line"
    elseif c_nth == 1 then
        sActType = tr"the first tag"
    elseif c_nth == 2 then
        sActType = tr"the 2nd tag"
    elseif c_nth == 3 then
        sActType = tr"the 3rd tag"
    elseif c_nth == -1 then
        sActType = tr"the last tag"
    elseif isInteger(c_nth) then
        sActType = string.format(tr"the %dth tag", c_nth)
    else
        fatal(tr"formatStatusMsg: Requested message cannot be formatted, unknown position requested.")
    end

    local nSel = #selected_lines
    local nSup = #supplied_lines
    local sMsg
    if nSel == 1 and nSup == 1 then
        local sText = string.gsub(c_textbox, "\\\\", "\\")
        sMsg = string.format(tr"%s %q to %s.", sActName, sText, sActType)
    elseif nSup == 1 then
        local sText = string.gsub(c_textbox, "\\\\", "\\")
        sMsg = string.format(tr"%s %q to %s %d times.", sActName, sText, sActType, nSel)
    elseif nSel == nSup then
        sMsg = string.format(tr"%s %d things to %d %s.", sActName, nSup, nSel, sActType .. "s")
    elseif isInteger(nSel / nSup) then
        local sMode = c_mode and t_abcabc or t_aabbcc
        sMsg = string.format(tr"%s %d things repeated %d times to %d %s using %s.", sActName, nSup, (nSel / nSup), nSel, sActType .. "s", sMode)
        if nSel / nSup == 2 then sMsg:gsub("2 times", "twice") end
    else
        fatal(tr"formatStatusMsg: Requested message cannot be formatted, unknown scenario requested.")
    end
    return sMsg
end

--Checks if there is something in the string, now with more types
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
        hint(string.format(tr"isEmpty: Cannot check %s type.", type(x)))
        return nil
    end
end

--Returns true if a number is an integer
function isInteger(x)
    return math.floor(x)==x
end

--A shitty iterator because >effort
function stringRegexIterator(sLine, sRegex, nPos)
    if isEmpty(sLine) then fatal(tr"stringRegexIterator: the input string cannot be empty.") end
    if isEmpty(sRegex) then fatal(tr"stringRegexIterator: the regular expression cannot be empty.") end
    if isEmpty(nPos) then fatal(tr"stringRegexIterator: the 'stop after' point cannot be empty.") end
    local i = 1
    local x = 0

    local p, q
    for x = 1,nPos,1 do
        p, q = string.find(sLine, sRegex, i)
        if p == nil then break else i = q + 1 end
    end
    return p, q
end

--This is a rewrite of stringToTable, this time with more functionality, less bloat and a variable delimeter
function splitStringToTableWithDelimeter(sLine, sDelimeter)
--checks
    if isEmpty(sLine) then fatal(tr"splitStringToTableWithDelimeter: the input string cannot be empty.") end
    if isEmpty(sDelimeter) then fatal(tr"splitStringToTableWithDelimeter: the delimeter cannot be empty.") end
--return
    local tTable = {}
--counters
    local p = 1 --start of line segment to split
    local i = 0 --end of line segment to split + delimeter
--consts
    local l = #sDelimeter --length of the delimeter
    local q = #sLine + 1 --end of line, because we want to a reference point at EOL, DEBUG-HINT: this is incremented by 1
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
