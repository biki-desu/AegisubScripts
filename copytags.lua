local tr = aegisub.gettext

script_name_ui = tr"Copy tags"
script_description_ui = tr"Copies tags from selected lines to textbox"
script_name_cl = tr"Copy tags to clipboard"
script_description_cl = tr"Copies tags from selected lines to clipboard"
script_author = "biki-desu"
script_version = "1.3.3"

clipboard = require 'aegisub.clipboard'

local t_c = tr"Copy to Clipboard"
local t_e = tr"Exit"

function copytags_cl(subs, selected_lines)
    tagggs = getTagsFromSelectedLines(subs, selected_lines)
    if not clipboard.set(tagggs) then fatal(tr"The clipboard could not be set, an error occurred.") end
end

function copytags_ui(subs, selected_lines)
    tagggs = getTagsFromSelectedLines(subs, selected_lines)

    copytags_gui = {}
    copytags_gui.cfg = {{ class = "textbox"; name = "textbox"; x = 0; y = 0; height = 8; width = 80; value = tagggs }}
    local cfg_k, cfg_v
    cfg_k, cfg_v = aegisub.dialog.display(copytags_gui.cfg, {t_c, t_e})

    if cfg_k == t_c then
        if not clipboard.set(tagggs) then fatal(tr"The clipboard could not be set, an error occurred.") end
        aegisub.progress.task(tr"Done")
    else
        aegisub.cancel()
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

--Code deduplication
function getTagsFromSelectedLines(subs, selected_lines)
    local sTags = ""
    local slTags = ""
    for x, i in ipairs(selected_lines) do
        local l = subs[i].text
        slTags = getTagsFromLine(l)
        sTags = sTags .. slTags .. "\n"
    end
    sTags = string.gsub(sTags, "(\n)$", "")
    return sTags
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
    return sTags
end

aegisub.register_macro(script_name_ui, script_description_ui, copytags_ui)
aegisub.register_macro(script_name_cl, script_description_cl, copytags_cl)
