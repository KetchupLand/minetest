--Minetest
--Copyright (C) 2013 sapier
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

--------------------------------------------------------------------------------

local kl_devs = {
	"Danil_2461",
	"ROllerozxa"
}

local core_developers = {
	"Perttu Ahola (celeron55) <celeron55@gmail.com>",
	"sfan5 <sfan5@live.de>",
	"Nathanaël Courant (Nore/Ekdohibs) <nore@mesecons.net>",
	"Loic Blot (nerzhul/nrz) <loic.blot@unix-experience.fr>",
	"paramat",
	"Andrew Ward (rubenwardy) <rw@rubenwardy.com>",
	"Krock/SmallJoker <mk939@ymail.com>",
	"Lars Hofhansl <larsh@apache.org>",
	"Pierre-Yves Rollo <dev@pyrollo.com>",
	"v-rob <robinsonvincent89@gmail.com>",
}

-- For updating active/previous contributors, see the script in ./util/gather_git_credits.py

local active_contributors = {
	"Wuzzy [devtest game, visual corrections]",
	"Zughy [Visual improvements, various fixes]",
	"Maksim (MoNTE48) [Android]",
	"numzero [Graphics and rendering]",
	"appgurueu [Various internal fixes]",
	"Desour [Formspec and vector API changes]",
	"HybridDog [Rendering fixes and documentation]",
	"Hugues Ross [Graphics-related improvements]",
	"ANAND (ClobberXD) [Mouse buttons rebinding]",
	"luk3yx [Fixes]",
	"hecks [Audiovisuals, Lua API]",
	"LoneWolfHT [Object crosshair, documentation fixes]",
	"Lejo [Server-related improvements]",
	"EvidenceB [Compass HUD element]",
	"Paul Ouellette (pauloue) [Lua API, documentation]",
	"TheTermos [Collision detection, physics]",
	"David CARLIER [Unix & Haiku build fixes]",
	"dcbrwn [Object shading]",
	"Elias Fleckenstein [API features/fixes]",
	"Jean-Patrick Guerrero (kilbith) [model element, visual fixes]",
	"k.h.lai [Memory leak fixes, documentation]",
}

local previous_core_developers = {
	"BlockMen",
	"Maciej Kasatkin (RealBadAngel) [RIP]",
	"Lisa Milne (darkrose) <lisa@ltmnet.com>",
	"proller",
	"Ilya Zhuravlev (xyz) <xyz@minetest.net>",
	"PilzAdam <pilzadam@minetest.net>",
	"est31 <MTest31@outlook.com>",
	"kahrl <kahrl@gmx.net>",
	"Ryan Kwolek (kwolekr) <kwolekr@minetest.net>",
	"sapier",
	"Zeno",
	"ShadowNinja <shadowninja@minetest.net>",
	"Auke Kok (sofar) <sofar@foo-projects.org>",
}

local previous_contributors = {
	"Nils Dagsson Moskopp (erlehmann) <nils@dieweltistgarnichtso.net> [Minetest Logo]",
	"red-001 <red-001@outlook.ie>",
	"Giuseppe Bilotta",
	"Dániel Juhász (juhdanad) <juhdanad@gmail.com>",
	"MirceaKitsune <mirceakitsune@gmail.com>",
	"Constantin Wenger (SpeedProg)",
	"Ciaran Gultnieks (CiaranG)",
	"stujones11 [Android UX improvements]",
	"Rogier <rogier777@gmail.com> [Fixes]",
	"Gregory Currie (gregorycu) [optimisation]",
	"srifqi [Fixes]",
	"JacobF",
	"Jeija <jeija@mesecons.net> [HTTP, particles]",
}

local toptext = [[
KetchupLand and the KetchupLand Launcher makes use of
the free and open source Minetest voxel game engine.
]]

local function buildCreditList(source)
	local ret = {}
	for i = 1, #source do
		ret[i] = core.formspec_escape("- "..source[i])
	end
	return table.concat(ret, ",,")
end

return {
	name = "about",
	caption = fgettext("About"),
	cbf_formspec = function(tabview, name, tabdata)
		local logofile = core.formspec_escape(defaulttexturedir.."logo.png")
		local version = core.get_version()
		local openuserdatafolder

		if PLATFORM ~= "Android" then
			openuserdatafolder = [[
				tooltip[userdata;Opens the directory that contains user-provided worlds, games, mods,\n
					and texture packs in a file manager / explorer.]
				button[0,4;3.5,1;userdata;Open User Data Folder]
			]]
		end

		return formspec_wrapper([[
			image[0.75,0.5;2.2,2.2;${logofile}]
			style[label_button;border=false;textcolor=#000000]
			button[0,2;3.5,2;label_button;${version_string}]
			${common_styling}
			tablecolumns[color;text]
			tableoptions[background=#000000FF;highlight=#000000FF;border=false]
			table[3.5,-0.25;8.45,5.95;list_credits;#FF0000,Credits:,
			,,#FFFF00,KetchupLand Developers,
			,${kl_devs},,,
			,,#00FF00,${toptext},
			,,#FFFF00,Minetest Core Developers,
			,${core_developers},
			,,#FFFF00,Minetest Active Contributors,
			,${active_contributors},
			,,#FFFF00,Minetest Previous Core Developers,
			,${previous_core_developers},
			,,#FFFF00,Minetest Previous Contributors,
			,${previous_contributors},;1]
			${openuserdatafolder}
		]], {
			logofile = logofile,
			version_string = version.project.." "..version.string,
			common_styling = kl_formspec_styling(),
			kl_devs = buildCreditList(kl_devs),
			toptext = toptext,
			core_developers = buildCreditList(core_developers),
			active_contributors = buildCreditList(active_contributors),
			previous_core_developers = buildCreditList(previous_core_developers),
			previous_contributors = buildCreditList(previous_contributors),
			openuserdatafolder = openuserdatafolder
		})
	end,
	cbf_button_handler = function(this, fields, name, tabdata)
		if fields.label_button then
			core.open_url("https://ketchupland.github.io")
		end

		if fields.userdata then
			core.open_dir(core.get_user_path())
		end
	end,
}
