local tr = aegisub.gettext

script_name = tr"Add stuff to selected lines"
script_description = tr"Adds stuff from textbox to all selected lines"
script_author = "Suomynona"
script_version = "1.0.0.0"

if not add_stuff_script then add_stuff_script = {} end

add_stuff_script.conf = {
	[1] = { class = "textbox"; name = "add_these_tags"; x = 0; y = 0; height = 4; width = 100 }
}

function add_stuff_script.process(subtitles, selected_lines, active_line)

    local cfg_res, config
	
    cfg_res, config = aegisub.dialog.display(add_stuff_script.conf, {"Add","Cancel"})

    if cfg_res == "Add" then
		for z, i in ipairs(selected_lines) do
			local l = subtitles[i]
			
		    --local a = l.text:match("{[^}]+}")
			
			--if a then
				l.text = config.add_these_tags .. l.text
			--else
				--l.text = "{" .. config.add_these_tags .. "}" .. l.text
			--end
			
			subtitles[i] = l
		end
		
		aegisub.set_undo_point(script_name)
		
        aegisub.progress.task("Done")
		
    else
        aegisub.progress.task("Cancelled"); 
    end

end

aegisub.register_macro(script_name, tr"Adds tags to all selected lines", add_stuff_script.process)
