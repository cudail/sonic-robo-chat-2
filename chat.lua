

local spawned_list = {}

local name_examples = {"oakenreef", "BlazeHedgehog", "bestfriendmothman"}
local text_examples = {"test", "hello", "hi"}

local spawn_badnik = function(player)
	local dist = 300*FRACUNIT
	local x = FixedMul(cos(player.mo.angle), dist)
	local y = FixedMul(sin(player.mo.angle), dist)

	local rrange = 200*FRACUNIT
	local xr = FixedMul(P_RandomFixed(), rrange)-rrange/2
	local yr = FixedMul(P_RandomFixed(), rrange)-rrange/2

	local spawned = P_SpawnMobjFromMobj(player.mo, x+xr, y+yr, 50*FRACUNIT, MT_BLUECRAWLA)

	spawned.chat = {}
	spawned.chat.name = name_examples[ P_RandomRange( 1, #name_examples ) ]
	spawned.chat.text = text_examples[ P_RandomRange( 1, #text_examples ) ]
	table.insert(spawned_list, spawned)
end



addHook("PreThinkFrame", function()
	for i, b in pairs(spawned_list) do
		if not b.valid then
			table.remove(spawned_list, i)
		end
	end

	for p in players.iterate do
		if p.cmd.buttons & BT_CUSTOM1 and p.mo then
			spawn_badnik(p)
		end
	end



	--print(#spawned_list)
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


			local h = FixedHypot(cam.x-b.x, cam.y-b.y)
			--local vang1 = R_PointToAngle2(cam.z, b.z, 0, h) - ANGLE_90

			local vangle = first_person and player.aiming or cam.aiming or 0 --+ vang1
			vangle = AngleFixed($1)

			vangle = $1
			if vangle > 180*FRACUNIT then
				vangle = $1-360*FRACUNIT
			end

			local hpos = hudwidth/2 - FixedMul(distance, tan(hangle))
			local vpos = 100*FRACUNIT + FixedDiv(FixedMul(vangle,200*FRACUNIT), 56*FRACUNIT)

			local nameflags = V_YELLOWMAP|V_SNAPTOLEFT|V_SNAPTOTOP
			local namefont = "thin-fixed-center"
			v.drawString(hpos, vpos-8*FRACUNIT, b.chat.name, nameflags, namefont)

			local textflags = V_SNAPTOLEFT|V_SNAPTOTOP
			local textfont = "thin-fixed-center"
			v.drawString(hpos, vpos, b.chat.text, textflags, textfont)
		end
	end
end, "game")


