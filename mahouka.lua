--[[
HOW TO USE THIS SHITTY SCRIPT:

Style for positioning: pls2delete it afterwards
Style: Mah Ouka,Avenir LT Std,25,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,-1,0,0,0,100,100,0,0,1,0,0,4,0,0,0,1

HOW TO USE:
{\fad(a,b)\pos(x,y)}Text
a = frame offset
b = time at which to start the fade
x,y = initial position of sign

override tags are not kept

insert "{}" where a chunk appears in the next frame

Example:
Comment: 0,0:00:00.64,0:00:02.98,Mah Ouka,,0,0,0,,{\fad(27,2154)\pos(122,139)}20{}95-10-{}29 / 0{}0:15 /{} Yokohama
]]

local tr = aegisub.gettext

script_name = tr"Do Mahouka Things"
script_description = tr""
script_author = "biki-desu"
script_version = "1.0"

local t_m = tr"DO MOVING THINGIES"
local t_e = tr"CANCER"

mahouka = function (subs, selected_lines, active_line)
	local agi_button, agi_result = aegisub.dialog.display({{ class = "label"; x = 0; y = g; width = 2; height = 1; label = tr"DO MAHOUKA THINGS"; }}, {t_m, t_e})

	if agi_button == t_e then
		aegisub.cancel()
	elseif agi_button == t_m then
		local tCount = 0
		local tTable = {}
		for i, j in ipairs(selected_lines) do

			local m = j + tCount
			local l = subs[m]
			local st = l.start_time
			local et = l.end_time

			local _, _, moff = string.find(l.text, "\\fad[e]?%((%d+),(%d+)%)")
			if moff == nil then err("AEGISUB FUCKED UP, pls2try running this again") end
			local moffset = (aegisub.ms_from_frame(aegisub.frame_from_ms(st) + 1) - aegisub.ms_from_frame(aegisub.frame_from_ms(st))) - moff

			local ltable = splitStringToTableWithDelimeter(l.text, "{}")
			local str = ""

			for x, y in ipairs(ltable) do
				if x == 1 then
					str =  "{"
					_, _, _, fadestart = string.find(y, "\\fad[e]?%((%d+),(%d+)%)")
					fadeend   = aegisub.ms_from_frame(aegisub.frame_from_ms(et)) - aegisub.ms_from_frame(aegisub.frame_from_ms(st)) - moffset
					str = str .. "\\fade(0,0,220,0,0," .. fadestart .. "," .. fadeend .. ")"

					_, _, posx, posy = string.find(y, "\\pos%((.-),(.-)%)")
					newposx = posx + (0.1 * (aegisub.frame_from_ms(et) - aegisub.frame_from_ms(st)))
					motionstart = aegisub.ms_from_frame(aegisub.frame_from_ms(st) + #ltable + 1) - aegisub.ms_from_frame(aegisub.frame_from_ms(st)) - moffset
					motionend   = aegisub.ms_from_frame(aegisub.frame_from_ms(et)) - aegisub.ms_from_frame(aegisub.frame_from_ms(st)) - moffset
					str = str .. "\\move(" .. posx .. "," .. posy .. "," .. newposx .. "," .. posy .. "," .. motionstart .. "," .. motionend .. ")"

					str = str .. "\\an4\\fnAvenir LT Std\\fs25\\c&HFFFFFF&\\b1\\blur0.8}"
					str = str .. string.sub(y, string.find(y, "}") + 1, #y)
				else
					num = aegisub.ms_from_frame(aegisub.frame_from_ms(st) + x - 1) - aegisub.ms_from_frame(aegisub.frame_from_ms(st)) - moffset
					str = str .. "{\\alpha&HFF&\\t(" .. num .. "," .. num .. ",\\alpha&H00&)}" .. y
				end
			end

			local sstr = string.gsub(string.gsub(str, "\\c&HFFFFFF&", "\\c&H000000&"), "\\alpha&H00&", "\\alpha&H20&")
			pos = string.find(sstr, "}")
			sstr = string.sub(sstr, 1, pos - 1) .. "\\alpha&H20&" .. string.sub(sstr, pos, #sstr)
			mve1, mve2, mve = string.find(sstr, "(\\move%(.-%))")
			_, _, px, py, nx, ny, ms, me = string.find(mve, "\\move%((.-),(.-),(.-),(.-),(%d+),(%d+)%)")
			sstr = string.sub(sstr, 1, mve1 - 1) .. "\\move(" .. px + 2 .. "," .. py + 2 .. "," .. nx + 2 .. "," .. ny + 2 .. "," .. ms .. "," .. me .. ")" .. string.sub(sstr, mve2 + 1, #sstr)

			tCount = tCount + 1
			subs.insert(m + 1, l)
			local b = subs[m + 1]
			b.text = sstr
			subs[m + 1] = b
			table.insert(tTable, m + 1)

			tCount = tCount + 1
			subs.insert(m + 2, l)
			local a = subs[m + 2]
			a.text = str
			subs[m + 2] = a
			table.insert(tTable, m + 2)

			l.comment = true
			subs[m] = l
		end

		return tTable
	else
		fatal(tr"Unknown error occoured, cannot continue.")
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

--Does what it says in the name, returns a table
splitStringToTableWithDelimeter = function (sLine, sDelimeter)
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

aegisub.register_macro(script_name, script_description, mahouka)
