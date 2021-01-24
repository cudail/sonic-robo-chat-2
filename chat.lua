
---------------
-- variables --
---------------


local chat_config = {
	parser_interval = 1*TICRATE, -- how long to wait between attempts to parse commands
	command_interval = 1, -- how long to wait between attempts to activate a command from the queue
	spawn_distance = 300, -- how far away to spawn objects from player
	spawn_radius = 200, -- radius to spawn objects within
	chat_x_pos = 1,
	chat_y_pos = 58,
	chat_width = 100,
	chat_lines = 20,
	chat_timeout = TICRATE*10
}

local parser_timer = chat_config.parser_interval
local command_timer = chat_config.command_interval
local queue = {}
local spawned_list = {}
local spawned_spring_list = {}

local control_reverse_timer = 0
local force_jump_timer = 0
local speed_scale_timer = 0
local jump_scale_timer = 0

---------------
-- constants --
---------------

local command_file_name = "chat_commands.txt"
local config_file_name = "chat_config.cfg"

local SPAWN_MESSAGE_TIMEOUT = TICRATE*60 --length of time to display messages over spawned objects

local badnik_list = {
	greenflower =  { MT_BLUECRAWLA, MT_REDCRAWLA, MT_GFZFISH},
	technohill = { MT_GOLDBUZZ, MT_REDBUZZ, MT_DETON, MT_SPRINGSHELL },
	deepsea = { MT_SKIM, MT_JETJAW, MT_CRUSHSTACEAN  },
	castleeggman = {MT_ROBOHOOD, MT_FACESTABBER, MT_EGGGUARD},
	aridcanyon = {MT_VULTURE, MT_GSNAPPER, MT_MINUS, MT_CANARIVORE},
	redvolcano = {MT_UNIDUS, MT_PYREFLY, MT_DRAGONBOMBER},
	eggrock = {MT_JETTBOMBER, MT_JETTGUNNER, MT_POPUPTURRET, MT_SPINCUSHION, MT_SNAILER}
}

local chat_messages = {}

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

local monitor_sets = {
	all = {MT_RING_BOX,
		MT_SNEAKERS_BOX,
		MT_INVULN_BOX,
		MT_1UP_BOX,
		MT_EGGMAN_BOX,
		MT_MYSTERY_BOX,
		MT_PITY_BOX,
		MT_ATTRACT_BOX,
		MT_FORCE_BOX,
		MT_ARMAGEDDON_BOX,
		MT_WHIRLWIND_BOX,
		MT_ELEMENTAL_BOX,
		MT_FLAMEAURA_BOX,
		MT_BUBBLEWRAP_BOX,
		MT_THUNDERCOIN_BOX},
	allweighted = {MT_RING_BOX,
		MT_SNEAKERS_BOX,
		MT_INVULN_BOX,
		MT_1UP_BOX,
		MT_EGGMAN_BOX,
		MT_MYSTERY_BOX,
		{MT_PITY_BOX,
		MT_ATTRACT_BOX,
		MT_FORCE_BOX,
		MT_ARMAGEDDON_BOX,
		MT_WHIRLWIND_BOX,
		MT_ELEMENTAL_BOX,
		MT_FLAMEAURA_BOX,
		MT_BUBBLEWRAP_BOX,
		MT_THUNDERCOIN_BOX}},
	good = {MT_RING_BOX,
		MT_SNEAKERS_BOX,
		MT_INVULN_BOX,
		MT_1UP_BOX,
		MT_MYSTERY_BOX,
		MT_PITY_BOX,
		MT_ATTRACT_BOX,
		MT_FORCE_BOX,
		MT_ARMAGEDDON_BOX,
		MT_WHIRLWIND_BOX,
		MT_ELEMENTAL_BOX,
		MT_FLAMEAURA_BOX,
		MT_BUBBLEWRAP_BOX,
		MT_THUNDERCOIN_BOX},
	goodweighted = {MT_RING_BOX,
		MT_SNEAKERS_BOX,
		MT_INVULN_BOX,
		MT_1UP_BOX,
		MT_MYSTERY_BOX,
		{MT_PITY_BOX,
		MT_ATTRACT_BOX,
		MT_FORCE_BOX,
		MT_ARMAGEDDON_BOX,
		MT_WHIRLWIND_BOX,
		MT_ELEMENTAL_BOX,
		MT_FLAMEAURA_BOX,
		MT_BUBBLEWRAP_BOX,
		MT_THUNDERCOIN_BOX}},
	ring = {MT_RING_BOX},
	oneup = {MT_1UP_BOX},
	eggman = {MT_EGGMAN_BOX},
	mystery = {MT_MYSTERY_BOX},
	shield = {MT_PITY_BOX,
		MT_ATTRACT_BOX,
		MT_FORCE_BOX,
		MT_ARMAGEDDON_BOX,
		MT_WHIRLWIND_BOX,
		MT_ELEMENTAL_BOX,
		MT_FLAMEAURA_BOX,
		MT_BUBBLEWRAP_BOX,
		MT_THUNDERCOIN_BOX}
}

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

local springs = {
	yellow = {vertical=MT_YELLOWSPRING, horizontal=MT_YELLOWHORIZ, diagonal=MT_YELLOWDIAG},
	red = {vertical=MT_REDSPRING, horizontal=MT_REDHORIZ, diagonal=MT_REDDIAG},
	blue = {vertical=MT_BLUESPRING, horizontal=MT_BLUEHORIZ, diagonal=MT_BLUEDIAG}
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
	local dist = chat_config.spawn_distance*FRACUNIT
	local rrange = chat_config.spawn_radius*FRACUNIT
	local x = FixedMul(cos(player.mo.angle), dist)
	local y = FixedMul(sin(player.mo.angle), dist)

	local rrange = 200*FRACUNIT
	local xr = FixedMul(P_RandomFixed(), rrange)-rrange/2
	local yr = FixedMul(P_RandomFixed(), rrange)-rrange/2

	local spawned = P_SpawnMobjFromMobj(player.mo, x+xr, y+yr, 50*FRACUNIT, object_id)
	spawned.scale = scale
	spawned.angle = FixedAngle(P_RandomRange(0,359)*FRACUNIT)

	local linelength = 40

	spawned.chat = {}
	spawned.chat.name = username
	spawned.chat.namecolour = text_colours[namecolour] or V_YELLOWMAP
	spawned.chat.timer = 0
	spawned.chat.text = {}
	local words = split(message, " ")
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
	S_StartSound(mo, sfx_s3kcas)

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


local isnumber = function(str)
	return tonumber(str) ~= nil
end


local write_config = function()
	local file = io.openlocal(config_file_name, "w+")
	for k, v in pairs(chat_config) do
		file:write(k .. " " .. chat_config[k] .. "\n")
	end
	file:close()
end


local read_config = function()
	local file = io.openlocal(config_file_name, "r")
	for line in file:lines() do
		for k, v in pairs(chat_config) do
			local config_match = line:match(k .. " (%d+)")
			if isnumber(config_match) then
				print("Found config value '"..k.."' with value "..config_match)
				chat_config[k] = tonumber(config_match)
			end
		end
	end
	file:close()
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

	--OBJECT|{username}|{message}|{namecolour}|{objectid}
	if commandname == "OBJECT" then
		local username = command[2] or ""
		local message = command[3] or ""
		local namecolour = command[4] or "yellow"
		local objectId = tonumber(command[5])
		if not objectId then
			print("No object ID for OBJECT command")
			return false
		end
		print("Attempting to spawn object with ID ".. objectId .." with username '"..username.."'; message '"..message.."'; name colour '"..namecolour.."'")
		spawn_object_with_message(player, username, message, namecolour, objectId, FRACUNIT)

	--BADNIK|{username}|{message}|{namecolour}|[scale]
	elseif commandname == "BADNIK" then
		local username = command[2] or ""
		local message = command[3] or ""
		local namecolour = command[4] or "yellow"
		local scale = parseDecimal(command[5]) or FRACUNIT
		print("Attempting to spawn badnik with username '"..username.."'; message '"..message.."'; name colour '"..namecolour.."'; and scale "..scale)
		spawn_object_with_message(player, username, message, namecolour, pick_badnik(), scale)

	--MONITOR|{username}|{message}|{namecolour}|[set]
	elseif commandname == "MONITOR" then
		local username = command[2] or ""
		local message = command[3] or ""
		local namecolour = command[4] or "yellow"
		local monitor_set = command[5] or "allweighted"
		local monitor = rand_entry(monitor_sets[monitor_set])
		if type(monitor) == "table" then
			monitor = rand_entry(monitor)
		end
		if not monitor then monitor = MT_RING_BOX end
		print("Attempting to spawn monitor with object ID ".. monitor .." from set "..monitor_set.." with username '"..username.."'; message '"..message.."'; name colour '"..namecolour.."'")
		spawn_object_with_message(player, username, message, namecolour, monitor, FRACUNIT)

	--SPRING|{colour}|{orientation}|{direction}
	elseif commandname == "SPRING" then
		local colour = command[2] or "yellow"
		local orientation = command[3] or "vertical"
		local direction = command[4] or "forward"
		local spring_type = springs[colour][orientation]
		local spring = P_SpawnMobjFromMobj(player.mo, 0, 0, 0, spring_type)
		spring.angle = player.mo.angle + ({forward = 0, left = ANGLE_90, back = ANGLE_180, right = ANGLE_270})[direction]
		spring.life_timer = TICRATE
		table.insert(spawned_spring_list, spring)

	--CHAT|{username}|{message}|{namecolour}
	elseif commandname == "CHAT" then
		local username = command[2] or ""
		local message = command[3] or ""
		local namecolour = text_colours[command[4]] or V_YELLOWMAP
		table.insert(chat_messages, {username=username, message=message, colour=namecolour, timer=chat_config.chat_timeout})

	--SCALE|{scale}|{duration}
	elseif commandname == "SCALE" then
		local scale, dur = command[2], command[3]
		if not scale then return false end
		if not duration then return false end
		print("Attemtping to scale player by "..scale.." for "..dur.." ticks")
		player.chat.scaletimer = $1 + dur
		player.mo.destscale = parseDecimal(scale)

	--CHARACTER|[colour]|[character]|[playerId]
	elseif commandname == "CHARACTER" then
		local colour, skin, playernum
		if #command > 1 then
			if command[2] == "random" then
				colour = rand_dict_entry(skin_colours)
			elseif skin_colours[command[2]] then
				colour = skin_colours[command[2]]
			elseif not isnumber(command[2]) and skins[command[2]] then
				skin = skins[command[2]]
			end
			if #command > 2 and not isnumber(command[3]) and skins[command[3]] then
				skin = skins[command[3]].name
			end
			playernum = tonumber(command[#command])
		end
		if playernum ~= nil and players[playernum] then
			player = players[playernum]
		end
		change_character(player, colour, skin)

	--SUPER|[give_emeralds]
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

	--REVERSE|{duration}
	elseif commandname == "REVERSE" then
		local duration = tonumber(command[2])
		if duration then
			control_reverse_timer = duration
		else
			return false
		end

	--FORCE_JUMP|{duration}
	elseif commandname == "FORCE_JUMP" then
		local duration = tonumber(command[2])
		if duration then
			force_jump_timer = duration
		else
			return false
		end

	--TURN
	elseif commandname == "TURN" then
		player.mo.angle = $1 + ANGLE_180
		player.mo.momx = - $1
		player.mo.momy = - $1

	--SPEED_STATS|{scale}|{duration}
	elseif commandname == "SPEED_STATS" then
		local scale, duration = parseDecimal(command[2]), tonumber(command[3])
		if scale == nil or duration == nil or scale < 1 or duration < 1 then
			return false
		end
		speed_scale_timer = duration
		local skin = skins[player.mo.skin]
		player.normalspeed = FixedMul(skin.normalspeed, scale)
		player.runspeed = FixedMul(skin.runspeed, scale)
		player.actionspd = FixedMul(skin.actionspd, scale)
		player.mindash = FixedMul(skin.mindash, scale)
		player.maxdash = FixedMul(skin.maxdash, scale)
		player.thrustfactor = FixedMul(skin.thrustfactor, scale)

	--JUMP_STATS|{scale}|{duration}
	elseif commandname == "JUMP_STATS" then
		local scale, duration = parseDecimal(command[2]), tonumber(command[3])
		if scale == nil or duration == nil or scale < 1 or duration < 1 then
			return false
		end
		jump_scale_timer = duration
		local skin = skins[player.mo.skin]
		player.jumpfactor = FixedMul(skin.jumpfactor, scale)

	--RING
	elseif commandname == "RING" then
		S_StartSound(mo, sfx_itemup)
		player.rings = $1 + 1

	--UNRING
	elseif commandname == "UNRING" then
		S_StartSound(mo, sfx_spkdth)
		if player.rings > 0 then
			player.rings = $1 - 1
		end

	--CONFIG
	elseif commandname == "CONFIG" then
		local setting, value = command[2], tonumber(command[3])
		if not setting then return false end
		if not value then return false end
		if not chat_config[setting] then return false end
		print("Updating config setting '"..setting.."' to "..value)
		chat_config[setting] = value
		write_config()

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
		read_config()
		--write_config()
	end

	if player.chat.scaletimer > 0 then
		player.chat.scaletimer = $1 - 1
	elseif player.chat.scaletimer == 0 then
		player.mo.destscale = FRACUNIT
	end

	local i = 1
	while i <= #spawned_list do
		local b = spawned_list[i]
		if not b.valid or b.chat.timer > SPAWN_MESSAGE_TIMEOUT then
			table.remove(spawned_list, i)
		elseif b.type > 155 and b.type < 211 and b.state == S_BOX_POP2 then --is a destroyed item box
			table.remove(spawned_list, i)
		else
			b.chat.timer = $1+1
			i = $1+1
		end
	end

	i = 1
	while i <= #spawned_spring_list do
		local s = spawned_spring_list[i]
		if not s.valid then
			table.remove(spawned_spring_list, i)
		elseif s.life_timer < 1 then
			P_KillMobj(s)
			table.remove(spawned_spring_list, i)
		else
			s.life_timer = $1 - 1
			i = $1+1
		end
	end

	i = 1
	while i <= #chat_messages do
		local message = chat_messages[i]
		if message.timer < 1 then
			table.remove(chat_messages, i)
		else
			i = $1+1
		end
	end

	table.sort(spawned_list, function(a, b)
		return R_PointToDist(a.x, a.y) > R_PointToDist(b.x, b.y)
	end)


	if parser_timer < 1 then
		parser_timer = chat_config.parser_interval

		local file = io.openlocal(command_file_name, "r")

		local foundcommand = false
		for line in file:lines() do
			table.insert(queue, line)
			if not foundcommand then
				foundcommand = true
			end
		end

		if foundcommand then
			print("Read commands in from command file, wiping it.")
			io.openlocal(command_file_name, "w+")
		else
			print("No commands added to queue")
		end
	else
		parser_timer = $1 - 1
	end

	if command_timer < 1 then
		command_timer = chat_config.command_interval

		if queue and #queue > 0 then
			local comm = queue[1]
			table.remove(queue, 1)
			process_command(comm)
		end
	else
		command_timer = $1 - 1
	end

	if control_reverse_timer > 0 then
		control_reverse_timer = $1 - 1
		player.cmd.forwardmove = - $1
		player.cmd.sidemove = - $1
		player.cmd.angleturn = - $1
	end

	if force_jump_timer > 0 then
		force_jump_timer = $1 - 1
		if P_IsObjectOnGround(player.mo) then
			P_DoJump(player)
		end
	end

	if speed_scale_timer == 1 then
		speed_scale_timer = 0
		local skin = skins[player.mo.skin]
		player.normalspeed = skin.normalspeed
		player.runspeed = skin.runspeed
		player.actionspd = skin.actionspd
		player.mindash = skin.mindash
		player.maxdash = skin.maxdash
		player.thrustfactor = skin.thrustfactor
	elseif speed_scale_timer > 0 then
		speed_scale_timer = $1 - 1
	end

	if jump_scale_timer == 1 then
		jump_scale_timer = 0
		local skin = skins[player.mo.skin]
		player.jumpfactor = skin.jumpfactor
	elseif jump_scale_timer > 0 then
		jump_scale_timer = $1 - 1
	end

end)


local break_into_lines = function(view, message, max_width, flags, name_width)
	local text_lines = {}
	local words = split(message, " ")
	for i, word in pairs(words) do
		local this_line = text_lines[#text_lines]
		if #(text_lines) == 0 then
			text_lines = {word}
		elseif view.stringWidth(this_line .. " " .. word, flags, thin)/2 + (i==1 and name_width or 0) > chat_config.chat_width then
			table.insert(text_lines, word)
		else
			text_lines[#text_lines] = $1 .. " " .. word
		end
	end
	return text_lines
end


hud.add( function(v, player, camera)
	local font = "small-thin"
	local lineheight = 4


	local i, l = 1, 0
	while l < chat_config.chat_lines and i <= #chat_messages do
		local message = chat_messages[i]
		message.timer = $1 - 1

		local name = message.username
		local text = message.message
		local colour = message.colour

		local messageflags = V_SNAPTOLEFT|V_SNAPTOTOP
		local nameflags = V_SNAPTOLEFT|V_SNAPTOTOP|colour

		local nametext = name .. ": "

		local namewidth = v.stringWidth(nametext, nameflags, "thin")/2

		local x = chat_config.chat_x_pos
		local y = chat_config.chat_y_pos+i*lineheight

		local text_lines = break_into_lines(v, text, chat_config.chat_width, messageflags, namewidth)


		l = $1 - 1

		v.drawString(x, y+(l-1)*4, nametext, nameflags, font)
		for j, line in pairs(text_lines) do
			v.drawString(x+(j==1 and namewidth or 0), y+(l-1)*4, line, messageflags, font)
			l = $1 + 1
		end
		i = $1 + 1
	end
end, "game")

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


