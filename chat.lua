

local wait_timer = 10--35*5

local badnik_list = {
	greenflower =  { MT_BLUECRAWLA, MT_REDCRAWLA, MT_GFZFISH},
	technohill = { MT_GOLDBUZZ, MT_REDBUZZ, MT_DETON, MT_SPRINGSHELL },
	deepsea = { MT_SKIM, MT_JETJAW, MT_CRUSHSTACEAN  },
	castleeggman = {MT_ROBOHOOD, MT_FACESTABBER, MT_EGGGUARD},
	aridcanyon = {MT_VULTURE, MT_GSNAPPER, MT_MINUS, MT_CANARIVORE},
	redvolcano = {MT_UNIDUS, MT_PTERABYTE, MT_PYREFLY, MT_DRAGONBOMBER},
	eggrock = {MT_JETTBOMBER, MT_JETTGUNNER, MT_POPUPTURRET, MT_SPINCUSHION, MT_SNAILER}
}


local queue = {}

local command_file_name = "chat_commands.txt"

local level_list = {
	"greenflower", "greenflower", "greenflower",
	"technohill", "technohill", "technohill",
	"deepsea", "deepsea", "deepsea",
	"castleeggman", "castleeggman", "castleeggman",
	"aridcanyon", "aridcanyon", "aridcanyon",
	"redvolcano"
}

local colours = {
	pink = V_MAGENTAMAP,
	yellow = V_YELLOWMAP,
	green = V_GREENMAP,
	blue = V_BLUEMAP,
	red = V_REDMAP,
	orange = V_ORANGEMAP,
	cyan = V_SKYMAP,
	purple = V_PURPLEMAP,
	turqoise = V_AQUAMAP
}

level_list[22] = "eggrock"
level_list[23] = "eggrock"
level_list[23] = "eggrock"

local spawned_list = {}

local name_examples = {"oakenreef", "BlazeHedgehog", "bestfriendmothman"}
local text_examples = {"test", "hello", "hi"}


local rand = function(list)
	return list[ P_RandomRange(1, #list) ]
end

local spawn_badnik = function(player, username, message, namecolour, badnik)
	local dist = 300*FRACUNIT
	local x = FixedMul(cos(player.mo.angle), dist)
	local y = FixedMul(sin(player.mo.angle), dist)

	local rrange = 200*FRACUNIT
	local xr = FixedMul(P_RandomFixed(), rrange)-rrange/2
	local yr = FixedMul(P_RandomFixed(), rrange)-rrange/2

	local spawned = P_SpawnMobjFromMobj(player.mo, x+xr, y+yr, 50*FRACUNIT, badnik)

	spawned.chat = {}
	spawned.chat.name = username
	spawned.chat.text = message
	spawned.chat.namecolour = colours[namecolour] or V_YELLOWMAP
	table.insert(spawned_list, spawned)
end


local pick_badnik = function()
	local levelname = level_list[gamemap]
	if levelname then
		local level = badnik_list[levelname]
		if level then
			return rand(level)
		end
	end
	return MT_PENGUINATOR
end

local split = function(string)
	local list = {}
	for token in string.gmatch(string, "[^\t]+") do
		table.insert(list, token)
	end
	return list
end

local process_command = function (command_string)
	print("Trying to process command: " .. command_string )

	local command = split(command_string)
	if command[1] == "BADNIK" then
		local player = players[0]
		print("Attempting to spawn badnik with username '"..command[2].."'; message '"..command[3].."'; and name colour '"..command[4].."'")
		spawn_badnik(player, command[2], command[3], command[4], pick_badnik())
	else
		print("Unknown command "..command[1])
	end
end




addHook("PreThinkFrame", function()
	for i, b in pairs(spawned_list) do
		if not b.valid then
			table.remove(spawned_list, i)
		end
	end

	if paused or menuactive or gamemap == titlemap then
		return
	end

	if wait_timer < 1 then
		wait_timer = 35*5

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

	for p in players.iterate do
		if p.cmd.buttons & BT_CUSTOM1 and p.mo then
			local username = rand(name_examples)
			local message = rand(text_examples)
			local namecolour = rand( {"pink","yellow","cyan"} )
			local badnik = MT_PENGUINATOR
			local levelname = level_list[gamemap]
			if levelname then
				local level = badnik_list[levelname]
				badnik = rand(level)
			end

			spawn_badnik(p, username, message, namecolour, badnik)
		end
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
			local vangdiff = R_PointToAngle2(0, 0, b.z-cam.z, h) - ANGLE_90
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

			local nameflags = V_SNAPTOLEFT|V_SNAPTOTOP
			nameflags = $1 | b.chat.namecolour
			local namefont = "thin-fixed-center"
			v.drawString(hpos, vpos-8*FRACUNIT, b.chat.name, nameflags, namefont)

			local textflags = V_SNAPTOLEFT|V_SNAPTOTOP
			local textfont = "thin-fixed-center"
			v.drawString(hpos, vpos, b.chat.text, textflags, textfont)
		end
	end
end, "game")


