
---------------
-- variables --
---------------

local wait_timer = 10
local queue = {}
local spawned_list = {}


---------------
-- constants --
---------------

local command_file_name = "chat_commands.txt"

local SPAWN_MESSAGE_TIMEOUT = TICRATE*60 --length of time to display messages over spawned objects


local badnik_list = {
	greenflower =  { MT_BLUECRAWLA, MT_REDCRAWLA, MT_GFZFISH},
	technohill = { MT_GOLDBUZZ, MT_REDBUZZ, MT_DETON, MT_SPRINGSHELL },
	deepsea = { MT_SKIM, MT_JETJAW, MT_CRUSHSTACEAN  },
	castleeggman = {MT_ROBOHOOD, MT_FACESTABBER, MT_EGGGUARD},
	aridcanyon = {MT_VULTURE, MT_GSNAPPER, MT_MINUS, MT_CANARIVORE},
	redvolcano = {MT_UNIDUS, MT_PTERABYTE, MT_PYREFLY, MT_DRAGONBOMBER},
	eggrock = {MT_JETTBOMBER, MT_JETTGUNNER, MT_POPUPTURRET, MT_SPINCUSHION, MT_SNAILER}
}

local level_list = {
	"greenflower", "greenflower", "greenflower",
	"technohill", "technohill", "technohill",
	"deepsea", "deepsea", "deepsea",
	"castleeggman", "castleeggman", "castleeggman",
	"aridcanyon", "aridcanyon", "aridcanyon",
	"redvolcano"
}
level_list[22] = "eggrock"
level_list[23] = "eggrock"
level_list[23] = "eggrock"

local text_colours = {
	pink = V_MAGENTAMAP,
	yellow = V_YELLOWMAP,
	green = V_GREENMAP,
	blue = V_BLUEMAP,
	red = V_REDMAP,
	grey = V_GRAYMAP,
	orange = V_ORANGEMAP,
	sky = V_SKYMAP,
	purple = V_PURPLEMAP,
	aqua = V_AQUAMAP,
	peridot = V_PERIDOTMAP,
	azure = V_AZUREMAP,
	brown = V_BROWNMAP,
	rosy = V_ROSYMAP
}

local skin_colours = {
	white = SKINCOLOR_WHITE,
	bone = SKINCOLOR_BONE,
	cloudy = SKINCOLOR_CLOUDY,
	grey = SKINCOLOR_GREY,
	silver = SKINCOLOR_SILVER,
	carbon = SKINCOLOR_CARBON,
	jet = SKINCOLOR_JET,
	black = SKINCOLOR_BLACK,
	aether = SKINCOLOR_AETHER,
	slate = SKINCOLOR_SLATE,
	bluebell = SKINCOLOR_BLUEBELL,
	pink = SKINCOLOR_PINK,
	yogurt = SKINCOLOR_YOGURT,
	brown = SKINCOLOR_BROWN,
	bronze = SKINCOLOR_BRONZE,
	tan = SKINCOLOR_TAN,
	beige = SKINCOLOR_BEIGE,
	moss = SKINCOLOR_MOSS,
	azure = SKINCOLOR_AZURE,
	lavender = SKINCOLOR_LAVENDER,
	ruby = SKINCOLOR_RUBY,
	salmon = SKINCOLOR_SALMON,
	red = SKINCOLOR_RED,
	crimson = SKINCOLOR_CRIMSON,
	flame = SKINCOLOR_FLAME,
	ketchup = SKINCOLOR_KETCHUP,
	peachy = SKINCOLOR_PEACHY,
	quail = SKINCOLOR_QUAIL,
	sunset = SKINCOLOR_SUNSET,
	copper = SKINCOLOR_COPPER,
	apricot = SKINCOLOR_APRICOT,
	orange = SKINCOLOR_ORANGE,
	rust = SKINCOLOR_RUST,
	gold = SKINCOLOR_GOLD,
	sandy = SKINCOLOR_SANDY,
	yellow = SKINCOLOR_YELLOW,
	olive = SKINCOLOR_OLIVE,
	lime = SKINCOLOR_LIME,
	peridot = SKINCOLOR_PERIDOT,
	apple = SKINCOLOR_APPLE,
	green = SKINCOLOR_GREEN,
	forest = SKINCOLOR_FOREST,
	emerald = SKINCOLOR_EMERALD,
	mint = SKINCOLOR_MINT,
	seafoam = SKINCOLOR_SEAFOAM,
	aqua = SKINCOLOR_AQUA,
	teal = SKINCOLOR_TEAL,
	wave = SKINCOLOR_WAVE,
	cyan = SKINCOLOR_CYAN,
	sky = SKINCOLOR_SKY,
	cerulean = SKINCOLOR_CERULEAN,
	icy = SKINCOLOR_ICY,
	sapphire = SKINCOLOR_SAPPHIRE,
	cornflower = SKINCOLOR_CORNFLOWER,
	blue = SKINCOLOR_BLUE,
	cobalt = SKINCOLOR_COBALT,
	vapor = SKINCOLOR_VAPOR,
	dusk = SKINCOLOR_DUSK,
	pastel = SKINCOLOR_PASTEL,
	purple = SKINCOLOR_PURPLE,
	bubblegum = SKINCOLOR_BUBBLEGUM,
	magenta = SKINCOLOR_MAGENTA,
	neon = SKINCOLOR_NEON,
	violet = SKINCOLOR_VIOLET,
	lilac = SKINCOLOR_LILAC,
	plum = SKINCOLOR_PLUM,
	raspberry = SKINCOLOR_RASPBERRY,
	rosy = SKINCOLOR_ROSY
}

local chaosEmeralds = {
	MT_EMERALD1,
	MT_EMERALD2,
	MT_EMERALD3,
	MT_EMERALD4,
	MT_EMERALD5,
	MT_EMERALD6,
	MT_EMERALD7
}


---------------
-- functions --
---------------


local split = function(string, delimiter)
	local list = {}
	for token in string.gmatch(string, "[^"..delimiter.."]+") do
		table.insert(list, token)
	end
	return list
end

local trim = function(str)
	return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

local parseDecimal = function(text)
	if text == nil then
		return nil
	end
	local num = tonumber(text)
	if num then
		return num*FRACUNIT
	end

	local parts = split(text, ".")
	if parts == nil or #parts ~= 2 then
		return nil
	end

	local integer, decimal = parts[1], parts[2]
	num = tonumber(integer)
	if num == nil then
		return nil
	end

	num = $1*FRACUNIT
	for i=1, #decimal do
		local digit = tonumber(string.sub(decimal, i, i))
		if digit == nil then
			return nil
		end
		num = $1 + digit*FRACUNIT/(i*10)
	end

	return num
end


local rand_entry = function(list)
	if list[0] then
		return list[ P_RandomRange(0, #list - 1) ]
	else
		return list[ P_RandomRange(1, #list) ]
	end
end

local rand_dict_entry = function(tbl)
	local keyset = {}
	for k, v in pairs(tbl) do
		table.insert(keyset, k)
	end
	return tbl[rand_entry(keyset)]
end


local last = function(list)
	return list[#list]
end


local spawn_object_with_message = function(player, username, message, namecolour, object_id, scale)
	local dist = 300*FRACUNIT
	local x = FixedMul(cos(player.mo.angle), dist)
	local y = FixedMul(sin(player.mo.angle), dist)

	local rrange = 200*FRACUNIT
	local xr = FixedMul(P_RandomFixed(), rrange)-rrange/2
	local yr = FixedMul(P_RandomFixed(), rrange)-rrange/2

	local spawned = P_SpawnMobjFromMobj(player.mo, x+xr, y+yr, 50*FRACUNIT, object_id)
	spawned.scale = scale

	local linelength = 40

	spawned.chat = {}
	spawned.chat.name = username
	spawned.chat.namecolour = text_colours[namecolour] or V_YELLOWMAP
	spawned.chat.timer = 0
	spawned.chat.text = {}
	local words = split(message, " ")
	local current_length = 0
	for i = 1, #words do
		if #(spawned.chat.text) == 0 then
			spawned.chat.text = {words[i]}
		elseif #(last(spawned.chat.text)) > linelength then
			table.insert(spawned.chat.text, words[i])
		elseif #(last(spawned.chat.text)) + #words[i] + 1 > linelength then
			table.insert(spawned.chat.text, words[i])
		else
			spawned.chat.text[#spawned.chat.text] = last(spawned.chat.text) .. " " .. words[i]
		end
	end

	table.insert(spawned_list, spawned)
end



local pick_badnik = function()
	local levelname = level_list[gamemap]
	if levelname then
		local level = badnik_list[levelname]
		if level then
			return rand_entry(level)
		end
	end
	return MT_PENGUINATOR
end


local change_character = function(player, colour, skin)
	if not skin then
		local skintable = rand_entry(skins)
		while not skintable or skintable.name == player.mo.skin do
			skintable = rand_entry(skins)
		end
		skin = skintable.name
	end

	if colour == "random" then
		colour = rand_entry(skin_colours)
	elseif not colour then
		colour = skins[skin].prefcolor
	end

	R_SetPlayerSkin(player, skin)
	player.mo.color = colour
end


local process_command = function (command_string)
	print("Trying to process command: " .. command_string )
	local command = split(command_string, "|")
	if not command or #command == 0 then
		return
	end
	for i=1, #command do
		command[i] = trim($1)
	end
	local player = players[0]
	local commandname = command[1]
	--BADNIK|{username}|{message}|{namecolour}|[scale]
	if commandname == "BADNIK" then
		local username, message, namecolour, scale = command[2], command[3], command[4], parseDecimal(command[5])
		if scale == nil then
			scale = FRACUNIT
		end
		print("Attempting to spawn badnik with username '"..username.."'; message '"..message.."'; name colour '"..namecolour.."'; and scale "..scale)
		spawn_object_with_message(player, command[2], command[3], command[4], pick_badnik(), scale)

	--SCALE|{scale}|{duration}
	elseif commandname == "SCALE" then
		local scale, dur = command[2], command[3]
		print("Attemtping to scale player by "..scale.." for "..dur.." ticks")
		player.chat.scaletimer = $1 + dur
		player.mo.destscale = parseDecimal(scale)

	--CHARACTER|[colour]|[name]
	elseif commandname == "CHARACTER" then
		local colour, skin
		if #command > 1 then
			if command[2] == "random" then
				colour = rand_dict_entry(skin_colours)
			elseif skin_colours[command[2]] then
				colour = skin_colours[command[2]]
			elseif skins[command[2]] then
				skin = skins[command[2]]
			end
			if #command > 2 and skins[command[3]] then
				skin = skins[command[3]].name
			end
		end
		change_character(player, colour, skin)

	--SUPER	[give_emeralds]
	elseif commandname == "SUPER" then
		if skins[player.mo.skin].flags & SF_SUPER == 0 then
			print(player.mo.skin .. " cannot go super.")
			return false
		end

		if not All7Emeralds(emeralds) then
			if command[2] == "true" then
				print("granting emeralds")
				for i = 1, #chaosEmeralds do
					P_SpawnMobj(player.mo.x, player.mo.y, player.mo.z, chaosEmeralds[i])
				end
			else
				print("player does not have emeralds, cannot go super")
				return false
			end
		end
		print("Forcing super")
		P_DoSuperTransformation(player)
	else
		print("Unknown command "..command[1])
	end
end



-----------
-- hooks --
-----------



addHook("PreThinkFrame", function()
	if paused or menuactive or gamemap == titlemap then
		return
	end

	local player = players[0]

	if player.playerstate ~= PST_LIVE or player.pflags & PF_FINISHED > 0 or player.exiting > 0 then
		return
	end

	if player.chat == nil then
		player.chat = {scaletimer = 0}
	end

	if player.chat.scaletimer > 0 then
		player.chat.scaletimer = $1 - 1
	elseif player.chat.scaletimer == 0 then
		player.mo.destscale = FRACUNIT
	end

	for i, b in pairs(spawned_list) do
		if not b.valid or b.chat.timer > SPAWN_MESSAGE_TIMEOUT then
			table.remove(spawned_list, i)
		else
			b.chat.timer = $1+1
		end
	end

	table.sort(spawned_list, function(a, b)
		return R_PointToDist(a.x, a.y) > R_PointToDist(b.x, b.y)
	end)

	if wait_timer < 1 then
		wait_timer = TICRATE*5

		local file = io.openlocal(command_file_name, "r")

		for line in file:lines() do
			table.insert(queue, line)
		end
		io.openlocal(command_file_name, "w+")


		if queue and #queue > 0 then
			process_command(queue[1])
			table.remove(queue, 1)
		end

	else
		wait_timer = $1 - 1
	end
end)



hud.add( function(v, player, camera)
	local first_person = not camera.chase
	local cam = first_person and player.mo or camera
	local hudwidth = 320*FRACUNIT
	local hudheight = (320*v.height()/v.width())*FRACUNIT

	local fov = ANGLE_90 -- Can this be fetched live instead of assumed?

	local distance = FixedDiv(hudwidth / 2, tan(fov/2)) -- the "distance" the HUD plane is projected from the player

	for i, b in pairs(spawned_list) do
		if b.valid then

			if not P_CheckSight(player.mo, b) then continue end

			local hangdiff = R_PointToAngle2(cam.x, cam.y, b.x, b.y) --Angle between camera vector and object
			local hangle = hangdiff - cam.angle

			--check if object is outside of our field of view
			--converting to fixed just to normalise things
			--e.g. this will convert 365° to 5° for us
			local fhanlge = AngleFixed(hangle)
			local fhfov = AngleFixed(fov/2)
			local f360 = AngleFixed(ANGLE_MAX)
			if fhanlge < f360 - fhfov and fhanlge > fhfov then
				continue
			end

			--figure out vertical angle
			local h = FixedHypot(cam.x-b.x, cam.y-b.y)
			local vangdiff = R_PointToAngle2(0, 0, b.z-cam.z+b.height+20*FRACUNIT, h) - ANGLE_90
			local vcangle = first_person and player.aiming or cam.aiming or 0
			local vangle = vcangle + vangdiff

			--again just check if we're outside the FOV
			local fvangle = AngleFixed(vangle)
			local fvfov = FixedMul(AngleFixed(fov), FRACUNIT*v.height()/v.width())
			if fvangle < f360 - fvfov and fvangle > fvfov then
				continue
			end

			local hpos = hudwidth/2 - FixedMul(distance, tan(hangle))
			local vpos = hudheight/2 + FixedMul(distance, tan(vangle))

			local namefont = "thin-fixed-center"
			local textfont = "thin-fixed-center"
			local lineheight = 8
			if R_PointToDist(b.x, b.y) > 1000*FRACUNIT then
				namefont = "small-thin-fixed-center"
				textfont = "small-thin-fixed-center"
				lineheight = 4
			end

			local nameflags = V_SNAPTOLEFT|V_SNAPTOTOP
			nameflags = $1 | b.chat.namecolour

			v.drawString(hpos, vpos-lineheight*FRACUNIT*#b.chat.text, b.chat.name, nameflags, namefont)

			local textflags = V_SNAPTOLEFT|V_SNAPTOTOP
			for i=1, #b.chat.text do
				v.drawString(hpos, vpos-lineheight*FRACUNIT*(#b.chat.text-i), b.chat.text[i], textflags, textfont)
			end
		end
	end
end, "game")


