--Minetest
--Copyright (C) 2014 sapier
--
--This program is free software; you can redistribute it and/or modify
--it under the terms of the GNU Lesser General Public License as published by
--the Free Software Foundation; either version 2.1 of the License, or
--(at your option) any later version.
--
--This program is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU Lesser General Public License for more details.
--
--You should have received a copy of the GNU Lesser General Public License along
--with this program; if not, write to the Free Software Foundation, Inc.,
--51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

local worldname = ""

local function table_to_flags(ftable)
	-- Convert e.g. { jungles = true, caves = false } to "jungles,nocaves"
	local str = {}
	for flag, is_set in pairs(ftable) do
		str[#str + 1] = is_set and flag or ("no" .. flag)
	end
	return table.concat(str, ",")
end

-- Same as check_flag but returns a string
local function strflag(flags, flag)
	return (flags[flag] == true) and "true" or "false"
end

local cb_caverns = { "caverns", fgettext("Caverns"), "caverns",
	fgettext("Very large caverns deep in the underground") }
local tt_sea_rivers = fgettext("Sea level rivers")

local flag_checkboxes = {
	v5 = {
		cb_caverns,
	},
	v7 = {
		cb_caverns,
		{ "ridges", fgettext("Rivers"), "ridges", tt_sea_rivers },
		{ "mountains", fgettext("Mountains"), "mountains" },
		{ "floatlands", fgettext("Floatlands"), "floatlands",
		fgettext("Floating landmasses in the sky. Experimental, use with caution!") },
	},
	carpathian = {
		cb_caverns,
		{ "rivers", fgettext("Rivers"), "rivers", tt_sea_rivers },
	},
	valleys = {
		{ "altitude-chill", fgettext("Altitude chill"), "altitude_chill",
		fgettext("Reduces heat with altitude") },
		{ "altitude-dry", fgettext("Altitude dry"), "altitude_dry",
		fgettext("Reduces humidity with altitude") },
		{ "humid-rivers", fgettext("Humid rivers"), "humid_rivers",
		fgettext("Increases humidity around rivers") },
		{ "vary-river-depth", fgettext("Vary river depth"), "vary_river_depth",
		fgettext("Low humidity and high heat causes shallow or dry rivers") },
	},
	flat = {
		cb_caverns,
		{ "hills", fgettext("Hills"), "hills" },
		{ "lakes", fgettext("Lakes"), "lakes" },
	},
	fractal = {
		{ "terrain", fgettext("Additional terrain"), "terrain",
		fgettext("Generate non-fractal terrain: Oceans and underground") },
	},
}

local function create_world_formspec(dialogdata)
	-- Error out when no games found
	if #pkgmgr.games == 0 then
		error("No games found!")
		return
	end

	local mapgens = core.get_mapgen_names()

	local current_seed = core.settings:get("fixed_map_seed") or ""
	local current_mg   = core.settings:get("mg_name")
	local gameid = core.settings:get("menu_last_game")

	local flags = {
		main = core.settings:get_flags("mg_flags"),
		v5 = core.settings:get_flags("mgv5_spflags"),
		v7 = core.settings:get_flags("mgv7_spflags"),
		fractal = core.settings:get_flags("mgfractal_spflags"),
		carpathian = core.settings:get_flags("mgcarpathian_spflags"),
		valleys = core.settings:get_flags("mgvalleys_spflags"),
		flat = core.settings:get_flags("mgflat_spflags"),
	}

	local gameidx = 0
	if gameid ~= nil then
		local _
		_, gameidx = pkgmgr.find_by_gameid(gameid)

		if gameidx == nil then
			gameidx = 0
		end
	end

	local mglist = ""
	local selindex
	local i = 1
	local first_mg
	for k,v in pairs(mapgens) do
		if not first_mg then
			first_mg = v
		end
		if current_mg == v then
			selindex = i
		end
		i = i + 1
		mglist = mglist .. v .. ","
	end
	if not selindex then
		selindex = 1
		current_mg = first_mg
	end
	mglist = mglist:sub(1, -2)

	local mg_main_flags = function(mapgen, y)
		if mapgen == "singlenode" then
			return "", y
		end

		local form = "checkbox[0.1," .. y .. ";flag_mg_caves;" ..
			fgettext("Caves") .. ";"..strflag(flags.main, "caves").."]"
		y = y + 0.5

		form = form .. "checkbox[0.1,"..y..";flag_mg_dungeons;" ..
			fgettext("Dungeons") .. ";"..strflag(flags.main, "dungeons").."]"
		y = y + 0.5

		local d_name = fgettext("Decorations")
		local d_tt
		d_tt = fgettext("Structures appearing on the terrain, typically trees and plants")
		form = form .. "checkbox[0.1,"..y..";flag_mg_decorations;" ..
			d_name .. ";" ..
			strflag(flags.main, "decorations").."]" ..
			"tooltip[flag_mg_decorations;" ..
			d_tt ..
			"]"
		y = y + 0.5

		form = form .. "tooltip[flag_mg_caves;" ..
		fgettext("Network of tunnels and caves")
		.. "]"
		return form, y
	end

	local mg_specific_flags = function(mapgen, y)
		if not flag_checkboxes[mapgen] then
			return "", y
		end

		local form = ""
		for _,tab in pairs(flag_checkboxes[mapgen]) do
			local id = "flag_mg"..mapgen.."_"..tab[1]
			form = form .. ("checkbox[0.1,%f;%s;%s;%s]"):
				format(y, id, tab[2], strflag(flags[mapgen], tab[3]))

			if tab[4] then
				form = form .. "tooltip["..id..";"..tab[4].."]"
			end
			y = y + 0.5
		end

		return form, y
	end

	current_seed = core.formspec_escape(current_seed)

	local y_start = 0.0
	local y = y_start
	local str_flags, str_spflags
	local label_flags, label_spflags = "", ""
	y = y + 0.5
	str_flags, y = mg_main_flags(current_mg, y)
	if str_flags ~= "" then
		label_flags = "label[0,"..y_start..";" .. fgettext("Mapgen flags") .. "]"
		y_start = y + 0.4
	else
		y_start = 0.0
	end
	y = y_start + 0.5
	str_spflags = mg_specific_flags(current_mg, y)
	if str_spflags ~= "" then
		label_spflags = "label[0,"..y_start..";" .. fgettext("Mapgen-specific flags") .. "]"
	end

	-- Add a little funny thing if you select singlenode, which has no mapgen params.
	if str_flags == '' then
		str_flags = "label[1.3,2;... dust ...]"
	end

	return formspec_wrapper([[
		formspec_version[4]
		size[12.25,7,true]

		${common_styling}

		container[0,0]
		label[0.3,0.6;World name]
		field[0.3,0.9;5.5,0.7;te_world_name;;${worldname}]
		label[0.3,2;Seed]
		field[0.3,2.3;5.5,0.7;te_seed;;${current_seed}]
		label[0.3,3.5;Mapgen]
		dropdown[0.3,3.9;5.5,0.8;dd_mapgen;${mglist};${selindex}]
		textlist[-10,3.85;4,2;games;${gamelist};${gameidx};false]
		container_end[]

		box[6.15,0.3;5.5,5.2;#1f1f1f]
		container[6.6,0.6]
		style_type[label;textcolor=#ffffff]
		${flags}
		container_end[]

		button[2.9,6;3,0.8;world_create_confirm;Create]
		button[6.4,6;3,0.8;world_create_cancel;Cancel]
	]], {
		common_styling = kl_formspec_styling(),
		worldname = core.formspec_escape(worldname),
		current_seed = current_seed,
		mglist = mglist,
		selindex = selindex,
		gamelist = pkgmgr.gamelist(),
		gameidx = gameidx,
		flags = label_flags..str_flags..label_spflags..str_spflags
	})
end

local function create_world_buttonhandler(this, fields)

	if fields["world_create_confirm"] or
		fields["key_enter"] then

		local worldname = fields["te_world_name"]
		local gameindex = core.get_textlist_index("games")

		if gameindex ~= nil then
			-- For unnamed worlds use the generated name 'world<number>',
			-- where the number increments: it is set to 1 larger than the largest
			-- generated name number found.
			if worldname == "" then
				local worldnum_max = 0
				for _, world in ipairs(menudata.worldlist:get_list()) do
					if world.name:match("^world%d+$") then
						local worldnum = tonumber(world.name:sub(6))
						worldnum_max = math.max(worldnum_max, worldnum)
					end
				end
				worldname = "world" .. worldnum_max + 1
			end

			core.settings:set("fixed_map_seed", fields["te_seed"])

			local message
			if not menudata.worldlist:uid_exists_raw(worldname) then
				core.settings:set("mg_name",fields["dd_mapgen"])
				message = core.create_world(worldname,gameindex)
			else
				message = fgettext("A world named \"$1\" already exists", worldname)
			end

			if message ~= nil then
				gamedata.errormessage = message
			else
				core.settings:set("menu_last_game",pkgmgr.games[gameindex].id)
				if this.data.update_worldlist_filter then
					menudata.worldlist:set_filtercriteria(pkgmgr.games[gameindex].id)
					mm_game_theme.update("singleplayer", pkgmgr.games[gameindex].id)
				end
				menudata.worldlist:refresh()
				core.settings:set("mainmenu_last_selected_world",
									menudata.worldlist:raw_index_by_uid(worldname))
			end
		else
			gamedata.errormessage = fgettext("No game selected")
		end
		this:delete()
		return true
	end

	worldname = fields.te_world_name

	if fields["games"] then
		local gameindex = core.get_textlist_index("games")
		core.settings:set("menu_last_game", pkgmgr.games[gameindex].id)
		return true
	end

	for k,v in pairs(fields) do
		local split = string.split(k, "_", nil, 3)
		if split and split[1] == "flag" then
			local setting
			if split[2] == "mg" then
				setting = "mg_flags"
			else
				setting = split[2].."_spflags"
			end
			-- We replaced the underscore of flag names with a dash.
			local flag = string.gsub(split[3], "-", "_")
			local ftable = core.settings:get_flags(setting)
			if v == "true" then
				ftable[flag] = true
			else
				ftable[flag] = false
			end
			local flags = table_to_flags(ftable)
			core.settings:set(setting, flags)
			return true
		end
	end

	if fields["world_create_cancel"] then
		this:delete()
		return true
	end

	if fields["dd_mapgen"] then
		core.settings:set("mg_name", fields["dd_mapgen"])
		return true
	end

	return false
end


function create_create_world_dlg(update_worldlistfilter)
	worldname = ""
	local retval = dialog_create("sp_create_world",
					create_world_formspec,
					create_world_buttonhandler,
					nil)
	retval.update_worldlist_filter = update_worldlistfilter

	return retval
end
