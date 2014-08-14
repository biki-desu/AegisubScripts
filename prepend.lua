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
local t_abcabc = tr"(abcabc) mode"
local t_aabbcc = tr"(aabbcc) mode"
local t_c = tr"Clear"
local t_e = tr"Cancel"

--Configuration
local c = {
    act = nil, --action, true = prepend, false == append
    btn = nil,
    keepconfig = false, --keep script configuration
    mode = true, --true means repetitive "abcabcabc", false means iterative "aaabbbccc"
    nth = nil, --1st tag
    textbox = "", --default text
}

--This is called first, deals with configuration
script_start = function (subs, selected_lines, active_line)
    if not c.keepconfig then --Check if we want to keep configuration, if not then reset to default
        c.mode = true
        c.nth = nil
        c.textbox = ""
    end

    c.act = nil

    script_gui(subs, selected_lines)
end

--This deals with the script GUI and does a large chunk of error checking
script_gui = function (subs, selected_lines)
    --Set current mode button/id
    t_ir = c.mode and t_abcabc or t_aabbcc

    --Gui config, this must be here as we want to set its initial text
    local agi_dialog = {
        { class = "textbox"; x = 0; y = 0; width = 70; height = 8; hint = tr"Please insert text here"; name = "textbox"; text = c.textbox; }
    }
    local agi_button, agi_result = aegisub.dialog.display(agi_dialog, {t_pl, t_al, t_pft, t_aft, t_plt, t_alt, t_ir, t_c, t_e})

    --Set configuration from gui result
    c.btn = agi_button --do it this way to avoid passing agi_result to every function >_>
    c.act, c.nth = getConfigFromButton(agi_button) --pass it as an arg to make it clearer as to what this thing is doing
    c.textbox = agi_result.textbox

    --Determine what to do
    if agi_button == nil then --This is here just in case the gui fails
        fatal(tr"Unknown error occoured, cannot continue.")
    elseif agi_button == t_e then --Cancel
        aegisub.cancel()
    elseif agi_button == t_c then --Clear
        c.textbox = ""
        script_gui(subs, selected_lines)
    elseif agi_button == t_ir then --Mode
        c.mode = not c.mode --invert the current mode
        script_gui(subs, selected_lines)
    else --do what this script is supposed to do
        local supplied_lines = splitStringToTableWithDelimeter(string.gsub(string.gsub(c.textbox, "\r\n", "\n"), "\r", "\n"), "\n") --because windows sucks --not handling "\r" because this is long deprecated
        if isInteger(#selected_lines / #supplied_lines) and not isEmpty(c.textbox) then
            local sStatus = formatStatusMsg(selected_lines, supplied_lines)
            aegisub.progress.task(sStatus)
            script_process(subs, selected_lines, supplied_lines)
            aegisub.set_undo_point(firstCharToLowercase(sStatus))
        elseif isEmpty(c.textbox) then
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
script_process = function (subs, selected_lines, supplied_lines)
    local p_n = 1 --progress numerator
    local p_d = #selected_lines --progress denominator

    local y --counter for the supplied_lines table repetition (does the same thing as x when table has "x" thing in it)
    for x, i in ipairs(selected_lines) do
        if aegisub.progress.is_cancelled() then aegisub.cancel() end --check if we need to cancel

        if c.mode then --abcabc mode
            y = ((x - 1) % #supplied_lines) + 1 --arrays in lua start at 1 so this makes sense (-1 to make it 0,1... and +1 to make it 1,2...)
        else --aabbcc mode
            y = math.ceil((x / #selected_lines) * #supplied_lines)
        end
        if 0 >= y or y > #selected_lines then fatal(tr"Algorithm error, cannot continue.") end --do some bounds checking, DEBUG-HINT: this does the exact opposite of what it's logically supposed to do

        local l = subs[i]

        --FYI, doing checking in the loop because it's silly to assume that all lines are the same
        if c.nth == 0 then
            l.text = c.act and supplied_lines[y] .. l.text or l.text .. supplied_lines[y]
        else --P/A f/l tags
            local a
            if c.nth == 1 then
                a = c.act and string.find(l.text, "{") or string.find(l.text, "}")
            elseif c.nth == -1 then
                a = c.act and string.find(l.text, "{[^{]*$") or string.find(l.text, "}[^}]*$")
            else
                a = c.act and stringRegexIterator(l.text, "{", c.nth) or stringRegexIterator(l.text, "}", c.nth)
            end
            if a == nil then
                if not isEmpty(supplied_lines[y]) then l.text = "{}" .. l.text end
                a = 1
            elseif not c.act then
                a = a - 1 --we want to append BEFORE the "}"
            end

            l.text = string.sub(l.text, 1, a) .. supplied_lines[y] .. string.sub(l.text, a + 1, #l.text + 1)
        end

        subs[i] = l

        aegisub.progress.set((p_n / p_d) * 100)
        p_n = p_n + 1 --Increment the numerator
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

--A dirty function to turn the first character of a string to lower case
firstCharToLowercase = function (sString)
    return string.lower(string.sub(sString, 1, 1)) .. string.sub(sString, 2, #sString + 1)
end

--Do this through another function because it clutters some other function >_>
getConfigFromButton = function (c_btn)
    local c_act, c_nth = c.act, c.nth --don't modify globals but return them
    if c_btn == t_pl then --Prepend line
        c_act = true
        c_nth = 0
    elseif c_btn == t_al then --Append line
        c_act = false
        c_nth = 0
    elseif c_btn == t_pft then --Prepend first tag
        c_act = true
        c_nth = 1
    elseif c_btn == t_aft then --Append first tag
        c_act = false
        c_nth = 1
    elseif c_btn == t_pnt then --Prepend nth tag
        c_act = true
    elseif c_btn == t_ant then --Append nth tag
        c_act = false
    elseif c_btn == t_plt then --Prepend last tag
        c_act = true
        c_nth = -1
    elseif c_btn == t_alt then --Append last tag
        c_act = false
        c_nth = -1
    elseif c_btn == t_ir then --Mode
        c_act = t_ir
        c_nth = nil
    elseif c_btn == t_c then --Clear
        c_act = t_c
        c_nth = nil
    elseif c_btn == t_e then --Cancel
        c_act = t_e
        c_nth = nil
    else
        fatal(tr"getConfigFromButton: Unknown action requested.")
    end
    return c_act, c_nth
end

--Dialog and undo text formatting
formatStatusMsg = function (selected_lines, supplied_lines)
    local sActName, sActType

    if c.act == true then
        sActName = tr"Prepending"
    elseif c.act == false then
        sActName = tr"Appending"
    else
        fatal(tr"formatStatusMsg: Requested message cannot be formatted, unknown action requested.")
    end

    if c.nth == nil then
        fatal(tr"formatStatusMsg: Requested message cannot be formatted, unknown position requested.")
    elseif c.nth == 0 then
        sActType = tr"the line"
    elseif c.nth == 1 then
        sActType = tr"the first tag"
    elseif c.nth == 2 then
        sActType = tr"the 2nd tag"
    elseif c.nth == 3 then
        sActType = tr"the 3rd tag"
    elseif c.nth == -1 then
        sActType = tr"the last tag"
    elseif isInteger(c.nth) then
        sActType = string.format(tr"the %dth tag", c.nth)
    else
        fatal(tr"formatStatusMsg: Requested message cannot be formatted, unknown position requested.")
    end

    local nSel = #selected_lines
    local nSup = #supplied_lines
    local sMsg
    if nSel == 1 and nSup == 1 then
        local sText = string.gsub(c.textbox, "\\\\", "\\")
        sMsg = string.format(tr"%s %q to %s.", sActName, sText, sActType)
    elseif nSup == 1 then
        local sText = string.gsub(c.textbox, "\\\\", "\\")
        sMsg = string.format(tr"%s %q to %s %d times.", sActName, sText, sActType, nSel)
    elseif nSel == nSup then
        sMsg = string.format(tr"%s %d things to %d %s.", sActName, nSup, nSel, sActType .. "s")
    elseif isInteger(nSel / nSup) then
        local sMode = c.mode and t_abcabc or t_aabbcc
        sMsg = string.format(tr"%s %d things repeated %d times to %d %s using %s.", sActName, nSup, (nSel / nSup), nSel, sActType .. "s", sMode)
        if nSel / nSup == 2 then sMsg:gsub("2 times", "twice") end
    else
        fatal(tr"formatStatusMsg: Requested message cannot be formatted, unknown scenario requested.")
    end
    return sMsg
end

--Checks if there is something in the variable as asserting is bad
isEmpty = function (x)
    if type(x) == "nil" then
        return true --yup, an uninitialised variable
    elseif type(x) == "string" then
        x = "" and return true or return false
    elseif type(x) == "number" then
        return false --a "number" is a result of a calculation, so cannot be empty
    elseif type(x) == "table" then
        return isEmpty(table.concat(x)) --can't really check if a table is empty, so concat it and check is the string is empty
    elseif type(x) == "boolean" then
        return false --you're either true or false, so you cannot be empty
    else
        hint(string.format(tr"isEmpty: Cannot check %s type.", type(x)))
        return nil --any other type is probably not empty, but we're not certain
    end
end

--Returns true if a number is an integer
isInteger function (x)
    return math.floor(x)==x
end

--A shitty iterator to find the nth result of a regex query
stringRegexIterator = function (sLine, sRegex, nPos)
--checks
    if isEmpty(sLine) then fatal(tr"stringRegexIterator: the input string cannot be empty.") end
    if isEmpty(sRegex) then fatal(tr"stringRegexIterator: the regular expression cannot be empty.") end
    if isEmpty(nPos) then fatal(tr"stringRegexIterator: the 'stop after' point cannot be empty.") end
--return
    local p, q = 0, 0
--counters
    local i = 1
    local x = 0
--logic
    for x = 1,nPos,1 do
        p, q = string.find(sLine, sRegex, i)
        if p == nil then break else i = q + 1 end
    end
    return p, q
end

--Does what it says in the name, returns a table
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

aegisub.register_macro(script_name, script_description, script_start)
