

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
	for i, b in pairs(spawned_list) do
		local first_person = not camera.chase
		local cam = first_person and player.mo or camera
		if b.valid then
			local ang1 = R_PointToAngle2(cam.x, cam.y, b.x, b.y)
			local angle = ang1 - cam.angle
			angle = AngleFixed($1)/FRACUNIT
			--print(angle)
			if angle > 180 then
				angle = $1-360
			end



			local h = FixedHypot(cam.x-b.x, cam.y-b.y)
			--local vang1 = R_PointToAngle2(cam.z, b.z, 0, h) - ANGLE_90

			local vangle = player.aiming --+ vang1
			vangle = AngleFixed($1)

			vangle = $1/FRACUNIT
			if vangle > 180 then
				vangle = $1-360
			end

			--print(AngleFixed(vang1)/FRACUNIT)

			local hpos = 160 - angle*320/90
			local vpos = 100 + vangle*200/56 --this works for first person, not third

			local nameflags = V_YELLOWMAP|V_SNAPTOLEFT|V_SNAPTOTOP
			local namefont = "thin-center"
			v.drawString(hpos, vpos-8, b.chat.name, nameflags, namefont)

			local textflags = V_SNAPTOLEFT|V_SNAPTOTOP
			local textfont = "thin-center"
			v.drawString(hpos, vpos, b.chat.text, textflags, textfont)
		end
	end
end, "game")


