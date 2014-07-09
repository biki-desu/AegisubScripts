local tr = aegisub.gettext

script_name = tr"Deduplicate all selected lines"
script_description = tr"Deduplicate all selected lines"
script_author = "Suomynona"
script_version = "1.0.0.0"

if not deduplicate_script then deduplicate_script = {} end

function deduplicate_script.process(subtitles, selected_lines, active_line)
    local c, n
    c = 0
    n = subtitles.n
    for _, i in ipairs(selected_lines) do
        local l = subtitles[i]
        local g = (i + 1)
--        if not i == n then
            local a = false
            repeat
                local m = subtitles[g]
                if l.text == m.text then
                    local x = m.start_time
                    local y = l.end_time
                    if x and y then
                        if (x - y) < 1211 and (x - y) > -2591 then --difference between start and end (biggest diff i ever saw when writing this script)
                            l.end_time = m.end_time
                            subtitles.delete(g)
                            g = (g + 1)
                            
                            -- counting stuff
                            c = (c + 1)
                            n = (n - 1)
                        else
                            aegisub.log(4, "%d difference between 2 identical lines (lines %d and %d), not bothering", m.start_time - l.end_time, i, g)
                            aegisub.log(4, '\n')
                        end
                    else
                    aegisub.log(4, "Lines %d and %d have nill start/end time, this should not happen", i, g)
                    aegisub.log(4, '\n')
                    end
                else
                    a = true
                end
            until a == true
--        end
        subtitles[i] = l
    end
    local undo = string.format("Deduplicated %d lines", c)
    aegisub.log(4, "Deduplicated %d lines, started with %d, left with %d", c, subtitles.n, n)
    aegisub.log(4, '\n')
    aegisub.set_undo_point(undo)
    aegisub.progress.task("Done")
end

aegisub.register_macro(script_name, tr"Deduplicates all selected lines", deduplicate_script.process)
