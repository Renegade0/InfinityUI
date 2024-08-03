
my_radar_sprites = {}

my_radar_sprite =
{
	main_text = "",
	items = {},
	timed_effects = {},
	portrait = ""
}

--rgRadarKey = ";"

function my_Radar_KeyPressedListener(key)
	if key ~= EEex_Key_GetFromName(RgRadarKey) then return end -- PECCA

	Infinity_PopMenu('RADAR')
	--Infinity_PopMenu('RG_RADAR_PC')
	local object = EEex_GameObject_GetUnderCursor()
	if object and object:isSprite() then
		for s=1,#my_radar_sprites do
			local candidate = my_radar_sprites[s]
			if candidate.m_id == object.m_id then
				SPRITE_ROW = s
				rgRadarSelectedCreId = object.m_id
				my_screen_radar_Inspect_sprite(SPRITE_ROW)
			end
		end
	end
	if RgRadarKey ~= '' then
		Infinity_PushMenu('RADAR')
	end
	--if RgRadarShowPcEffects == 1 then
	--	Infinity_PushMenu('RG_RADAR_PC')
	--end
end

if EEex_Active then
	EEex_Key_AddPressedListener(my_Radar_KeyPressedListener)
end

function center_on_sprite(sprite)
	local pos_x = sprite.m_pos.x
	local pos_y = sprite.m_pos.y
	
	local cmd = 'MoveViewPoint([' .. pos_x .. '.' .. pos_y .. '],INSTANT)'
	C:Eval(cmd)
end

function my_screen_radar_Inspect_sprite(sprite_row)

	my_radar_sprite =
	{
		main_text = "",
		items = {},
		timed_effects = {},
		portrait = ""
	}
	if sprite_row < 0 or sprite_row > #my_radar_sprites then return end

		
	local result = ""
	local sprite = my_radar_sprites[sprite_row]
	rgRadarSelectedCreId = sprite.m_id
	
	-- Portrait
	local base = EEex_UDToPtr(sprite.m_baseStats)
	local portrait = EEex_ReadLString(base + 0x2C, 8) -- sprite.m_baseStats.m_portraitSmall
	my_radar_sprite.portrait = My_Ternary(portrait and portrait:upper() ~= "NONE", portrait, nil)

	-- Now, read sprite stats
	local base = EEex_UDToPtr(sprite.m_resref)
	local resref = EEex_ReadLString(base + 0x00, 8)

	result = sprite:getName():upper() .. " // " .. resref .. "\n"
	
	
	-- alignment
	local alignment = ALIGNMENTS[sprite.m_liveTypeAI.m_Alignment]
	-- race // TODO : SHOULD BE A BETTER WAY WITH EEEX DOC, too lazy at the mpoment
	local raceIDS = EEex_Resource_LoadIDS("RACE")
	local race_id = sprite.m_liveTypeAI.m_Race
	local race = My_Ternary(raceIDS:hasID(race_id), raceIDS:getLine(race_id), race_id)
	raceIDS:free()

	-- class // TODO: SHOULD BE A BETTER WAY WITH EEEX DOC, too lazy at the moment
	local classIDS = EEex_Resource_LoadIDS("CLASS")
	local class_id = sprite.m_liveTypeAI.m_Class
	local class = My_Ternary(classIDS:hasID(class_id), classIDS:getLine(class_id), class_id)
	classIDS:free()
	-- allegiance
	local allegiance = my_colored_allegiance(sprite.m_liveTypeAI.m_EnemyAlly)
	result = result .. alignment .. " " .. race .. " " .. class .. " // " .. allegiance .. "\n"

	-- //
	local function stat_colored(stat)
		if stat >= 18 then return "^G" .. stat .. "^-" end
		if stat <=  7 then return "^R" .. stat .. "^-" end
		return stat
	end
	local str = sprite:getStat(STATS_STR)
	local str_extra = sprite:getStat(STATS_STREXTRA)
	local stats = "^DSTR:^-" .. stat_colored(str) .. My_Ternary(str == 18, "/" .. str_extra, "^-")
					.. "^D DEX: ^-" .. stat_colored(sprite:getStat(STATS_DEX))
					.. "^D CON: ^-" .. stat_colored(sprite:getStat(STATS_CON)) .. "\n"
					.. "^DINT: ^-" .. stat_colored(sprite:getStat(STATS_INT))
					.. "^D WIS: ^-" .. stat_colored(sprite:getStat(STATS_WIS))
					.. "^D CHA: ^-" .. stat_colored(sprite:getStat(STATS_CHA))
	result = result
		.. "^DHP: ^-" .. sprite.m_baseStats.m_hitPoints .. " / " .. sprite:getStat(STATS_MAXHITPOINTS) .. "\n"
		.. stats .. "\n"
		.. "^DTHAC0: ^-" .. sprite:getStat(STATS_THAC0) .. "\n"

	
	
	
	-- AC
	local ac = sprite:getStat(STATS_ARMORCLASS)
	local ac_c = ac + sprite:getStat(STATS_ACCRUSHINGMOD)
	local ac_m = ac + sprite:getStat(STATS_ACMISSILEMOD)
	local ac_p = ac + sprite:getStat(STATS_ACPIERCINGMOD)
	local ac_s = ac + sprite:getStat(STATS_ACSLASHINGMOD)
	if ac_c == ac_m	and ac_c == ac_p and ac_c == ac_s then
		ac = "^DAC: ^-" .. ac_c
	else
		ac = "^DAC: ^-" .. ac_c .. ", " .. ac_m .. ", " .. ac_p .. ", " .. ac_s .. "^-"
	end
	result = result .. ac .. "\n"

	-- Saves
	result = result
		.. "^DSave vs Paralysis/Poison/Death: ^-" .. sprite:getStat(STATS_SAVEVSDEATH) .. "\n"
		.. "^DSave vs Rod/Staff/Wand: ^-" .. sprite:getStat(STATS_SAVEVSWANDS) .. "\n"
		.. "^DSave vs Petrification/Polymorph: ^-" .. sprite:getStat(STATS_SAVEVSPOLY) .. "\n"
		.. "^DSave vs Breath: ^-" .. sprite:getStat(STATS_SAVEVSBREATH) .. "\n"
		.. "^DSave vs Spell: ^-" .. sprite:getStat(STATS_SAVEVSSPELL) .. "\n"

	
	-- Resistances
	local function g_or_r(value)
		if value < 0 then return "^R" .. value .. "^-\n" end
		if value > 0 then return "^G" .. value .. "^-\n" end
		return ""
	end
	local function resistance(sprite, text, stat_id)
		local value = sprite:getStat(stat_id)
		if value ~= 0 then
			return text .. g_or_r(value)
		end
		return ""
	end
	result = result .. resistance(sprite, "^DResistance Crushing: ^-", STATS_RESISTCRUSHING)
	result = result .. resistance(sprite, "^DResistance Missile: ^-", STATS_RESISTMISSILE)
	result = result .. resistance(sprite, "^DResistance Piercing: ^-", STATS_RESISTPIERCING)
	result = result .. resistance(sprite, "^DResistance Slashing: ^-", STATS_RESISTSLASHING)
	result = result .. resistance(sprite, "^vRESISTANCE MAGIC: ^-", STATS_RESISTMAGIC)
	result = result .. resistance(sprite, "^DResistance Fire: ^-", STATS_RESISTFIRE)
	result = result .. resistance(sprite, "^DResistance Cold: ^-", STATS_RESISTCOLD)
	result = result .. resistance(sprite, "^DResistance Acid: ^-", STATS_RESISTACID)
	result = result .. resistance(sprite, "^DResistance Electricity: ^-", STATS_RESISTELECTRICITY)
	result = result .. resistance(sprite, "^DResistance Poison: ^-", STATS_RESISTPOISON)

	my_radar_sprite.main_text = result -- ASSIGN UI SPRITE STATS HERE
	
	local function rg_g_or_r(value)
		if value < 0 then return "^R" .. value .. "^-" end
		if value > 0 then return "^G" .. value .. "^-" end
		return ""
	end
	--local function rg_resistance(sprite, desc, stat_id)
	--	local value = sprite:getStat(stat_id)
	--	if value ~= 0 then
	--		list = { text = desc .. rg_g_or_r(value) }
	--		return list
	--	end
	--end
	local function rg_is_resistance(stat_id)
		local value = sprite:getStat(stat_id)
		if value ~= 0 then
			return true
		else
			return false
		end
	end
	local rgAll = {}
	local rgAdvInfo1 = ""
	local rgAdvInfo2 = ""
	--if rgRadarShowAdvInfo == 1 then
	--	rgAdvInfo1 = "^X (" .. resref .. ")^-"
	--end
	rgAll[#rgAll +1] = { desc = sprite:getName():upper() .. rgAdvInfo1} -- 
	rgAll[#rgAll +1] = { desc = alignment .. " - " .. race .. " - " .. class} -- .. " // " .. allegiance 
	rgAll[#rgAll +1] = { desc = "^DHP: ^-" .. sprite.m_baseStats.m_hitPoints .. " / " .. sprite:getStat(STATS_MAXHITPOINTS) }
	rgAll[#rgAll +1] = { desc = "^DSTR: ^-" .. stat_colored(str) .. My_Ternary(str == 18, "/" .. str_extra, "^-") .. "^D DEX: ^-" .. stat_colored(sprite:getStat(STATS_DEX)) .. "^D CON: ^-" .. stat_colored(sprite:getStat(STATS_CON)) }
	rgAll[#rgAll +1] = { desc = "^DINT: ^-" .. stat_colored(sprite:getStat(STATS_INT)) .. "^D WIS: ^-" .. stat_colored(sprite:getStat(STATS_WIS)) .. "^D CHA: ^-" .. stat_colored(sprite:getStat(STATS_CHA)) }
	rgAll[#rgAll +1] = { desc = "^DTHAC0: ^-" .. sprite:getStat(STATS_THAC0) }
	rgAll[#rgAll +1] = { desc = ac }
	rgAll[#rgAll +1] = { desc = "^DSave vs Paralysis/Poison/Death: ^-" .. sprite:getStat(STATS_SAVEVSDEATH) }
	rgAll[#rgAll +1] = { desc = "^DSave vs Rod/Staff/Wand: ^-" .. sprite:getStat(STATS_SAVEVSWANDS) }
	rgAll[#rgAll +1] = { desc = "^DSave vs Petrification/Polymorph: ^-" .. sprite:getStat(STATS_SAVEVSPOLY) }
	rgAll[#rgAll +1] = { desc = "^DSave vs Breath: ^-" .. sprite:getStat(STATS_SAVEVSBREATH) }
	rgAll[#rgAll +1] = { desc = "^DSave vs Spell: ^-" .. sprite:getStat(STATS_SAVEVSSPELL) }
	if rg_is_resistance(STATS_RESISTCRUSHING) then rgAll[#rgAll +1] = { desc = "^DResistance Crushing: ^-" .. rg_g_or_r(STATS_RESISTCRUSHING) } end
	if rg_is_resistance(STATS_RESISTMISSILE) then rgAll[#rgAll +1] = { desc = "^DResistance Missile: ^-" .. rg_g_or_r(STATS_RESISTMISSILE) } end
	if rg_is_resistance(STATS_RESISTPIERCING) then rgAll[#rgAll +1] = { desc = "^DResistance Piercing: ^-" .. rg_g_or_r(STATS_RESISTPIERCING) } end
	if rg_is_resistance(STATS_RESISTSLASHING) then rgAll[#rgAll +1] = { desc = "^DResistance Slashing: ^-" .. rg_g_or_r(STATS_RESISTSLASHING) } end
	if rg_is_resistance(STATS_RESISTMAGIC) then rgAll[#rgAll +1] = { desc = "^vRESISTANCE MAGIC: ^-" .. rg_g_or_r(STATS_RESISTMAGIC) } end
	if rg_is_resistance(STATS_RESISTFIRE) then rgAll[#rgAll +1] = { desc = "^DResistance Fire: ^-" .. rg_g_or_r(STATS_RESISTFIRE) } end
	if rg_is_resistance(STATS_RESISTCOLD) then rgAll[#rgAll +1] = { desc = "^DResistance Cold: ^-" .. rg_g_or_r(STATS_RESISTCOLD) } end
	if rg_is_resistance(STATS_RESISTACID) then rgAll[#rgAll +1] = { desc = "^DResistance Acid: ^-" .. rg_g_or_r(STATS_RESISTACID) } end
	if rg_is_resistance(STATS_RESISTELECTRICITY) then rgAll[#rgAll +1] = { desc = "^DResistance Electricity: ^-" .. rg_g_or_r(STATS_RESISTELECTRICITY) } end
	if rg_is_resistance(STATS_RESISTPOISON) then rgAll[#rgAll +1] = { desc = "^DResistance Poison: ^-" .. rg_g_or_r(STATS_RESISTPOISON) } end
	
	local effects = {}
	local timed_effects = Sprite_Timed_Effects(sprite)
	for t=1,#timed_effects do
		local time_effect = timed_effects[t]

		local now = My_Current_Time()
		local expired_time = My_Current_Time(time_effect.duration)
		local delta = expired_time.ticks - now.ticks
		local remaining_time = My_Current_Time(delta)
		local color = My_Ternary(remaining_time.days <= 0 and remaining_time.hours <= 0 and remaining_time.minutes <= 0 and remaining_time.seconds <= 30, "^t", "")
		local remain_time_hms = remaining_time.hms
		if remaining_time.days <= 0 and remaining_time.hours <= 0 then remain_time_hms = remaining_time.ms end
		if remaining_time.days <= 0 and remaining_time.hours <= 0 and remaining_time.minutes <= 0 then remain_time_hms = remaining_time.s end
		--if rgRadarShowAdvInfo == 1 then
		--	rgAdvInfo2 = my_radar_secondary_type_parser(time_effect,nil)
		--end
		--local detail = my_radar_secondary_type_parser(time_effect,time_effect.spellName) .. " - "
		--	.. rgAdvInfo2
		--	--.. " " .. my_radar_effect_detail(time_effect)
		--	.. color .. remain_time_hms
		--	--.. " // ^W" .. map_label(OPCODES, time_effect.opcode) .. "^-"
		local detail = my_radar_secondary_type_parser(time_effect,time_effect.spellName)  ..
					   time_effect.spellName .. "^- - " ..
					   remain_time_hms
					   

		local effect_block = {
			-- detail interface
			icon = time_effect.icon,
			count = 0,
			text = detail,
			-- show detail interface
			is_effect = true,
			identified = 1,
			descPicture = "",
			description = time_effect.description,
			usages = 0,
			count = 0,
			isBag = 0,
			icon = time_effect.icon,
			res = time_effect.res, --.. " // " .. time_effect.opcode,
			tint = "",
			name = time_effect.spellName,
			duration = time_effect.duration,
			opcode = time_effect.opcode,
		}
		effects[#effects +1] = effect_block
		
		--if #effects == 1 then rgAll[#rgAll +1] = { text = "" } end
		
		if #effects == 1 then 
			rgAll[#rgAll +1] = { desc = "" } 
			rgAll[#rgAll +1] = { desc = "Effects: (^vSpell^- / ^tCombat^- / ^bNon-combat^-)" } 
		end
		rgAll[#rgAll +1] = effect_block
	end

	my_radar_sprite.timed_effects = effects -- ASSIGN SPRITE EFFECTS HERE

	-- Items
	local sprite_items = Sprite_Items(sprite)
	table.sort(sprite_items,function(a, b)	return a.slot.sprite_item_sort_order < b.slot.sprite_item_sort_order end)

	local selected_weapon =  nil
	local left_weapon =  nil
	local items = {}
	for i=1,#sprite_items do
		local item = sprite_items[i]
		if item.slot.id ~= SLOT_FIST or (item.slot.id ~= SLOT_FIST and item.is_weapon_selected) then
			local block = {
				-- detail interface
				icon = item.icon,
				count = My_Ternary(item.qty > 1 or item.resref == "MISC07", item.qty, nil),
				text = item.name .. " // " .. My_Ternary(item.is_weapon_selected or item.slot.id == SLOT_SHIELD, "^G", "^D") .. item.slot.name,
				-- show detail interface
				identified = 1,
				descPicture = item.descPicture,
				description = item.description,
				usages = 0,
				isBag = 0,
				icon = item.icon,
				res = item.resref,
				tint = "",
				name = item.item_name,
			}
			items[#items +1] = block
			if #items == 1 then rgAll[#rgAll +1] = { text = "" } end
			
			if rgRadarShowAdvInfo == 1 then
				rgAll[#rgAll +1] = block
			else
				if item.is_weapon_selected then
					rgAll[#rgAll +1] = block
				end
			end
		end
	end
	my_radar_sprite.items = items -- ASSIGN ITEMS SPRITE ITEMS HERE

	my_radar_sprite.all_info = rgAll

end







local selected_sprite_id = -1
function my_screen_radar_Search_sprites()
	local result = {}
	local done = {}
	--local rgNoParty = {}
	--local rgParty = {}
	--local rgNoPartyNeutral = {}
	rgRadarPcNumber = 0
	
	local radius = 448
	if rgRadarShowExtendRadius == 1 then
		radius = 9999
	end

	-- OLD VERSION OF EEEx WAS BETTER BUT B3 CHANGED THAT...
	for base_1_toon=EEex_Sprite_GetNumCharacters(), 1, -1 do
		local base_0_toon = base_1_toon -1
		local toon = EEex_Sprite_GetInPortrait(base_0_toon)
		
		--local rgTarget = "[ANYONE]"
		--if rgRadarShowAllCreatures ~= 0 then
		--	rgTarget = "[ENEMY]"
		--end
		local sprites = EEex_Sprite_GetAllOfTypeStringInRange(
						toon,
						"[ANYONE]", --"[ANYONE]", EVILBUTBLUE
						radius, -- 448 --999999
						false)
		for s=1,#sprites do
			local sprite = sprites[s]
			if not done[tostring(sprite.m_id)] then
				done[tostring(sprite.m_id)] = true
				
				--local anim = sprite.m_liveTypeAI.m_Animation

				local only_initial = true
				local ea = sprite.m_liveTypeAI.m_EnemyAlly
				local allegiance = my_colored_allegiance(ea, only_initial)
				local rgal = 0
				if ea == 2 then
					rgal = 1
				elseif ea == 3 then
					rgal = 2
				elseif ea == 4 then
					rgal = 3
				elseif ea == 255 then
					rgal = 4
				else
					rgal = 5
				end
				
				--local raceIDS = EEex_Resource_LoadIDS("RACE")
				--local race_id = sprite.m_liveTypeAI.m_Race
				--local race = My_Ternary(raceIDS:hasID(race_id), raceIDS:getLine(race_id), race_id)
				--if race:len() > 8 then
				--	race = string.sub(race, 1, 8)
				--end
				--raceIDS:free()
	
				-- Portrait
				local base = EEex_UDToPtr(sprite.m_baseStats)
				local portrait = EEex_ReadLString(base + 0x2C, 8) -- sprite.m_baseStats.m_portraitSmall
				sprite.portrait = My_Ternary(portrait and portrait:upper() ~= "NONE", portrait, nil)
				
				sprite.displayed_name = rgal .. " - " .. sprite:getName() .. " " .. sprite.m_baseStats.m_hitPoints
				sprite.displayed_name_short = sprite:getName()
				sprite.hp = sprite.m_baseStats.m_hitPoints .. '/' .. sprite:getStat(STATS_MAXHITPOINTS)
				sprite.tooltip = sprite.displayed_name_short .. '\n' .. sprite.hp
				sprite.image = 'rgx' .. sprite.m_animation.m_animation.m_animationID
				sprite.effects = {}
				
				--sprite.pos_x = sprite.m_pos.x
				
				local sprite_items = Sprite_Items(sprite)
				--local item = sprite_items[1]
				sprite.selected = ''
				for k=1,#sprite_items do
					if sprite_items[k].is_weapon_selected == true then
						sprite.selected = sprite_items[k].icon
						break
					end
				end
				
				local now = My_Current_Time()
				local effects = {}
				local timed_effects = Sprite_Timed_Effects(sprite)
				for t=1,#timed_effects do
					local time_effect = timed_effects[t]
			
					local effect_block = {
						icon = time_effect.icon,
						res = time_effect.res, --.. " // " .. time_effect.opcode,
						name = time_effect.spellName,
						duration = time_effect.start - time_effect.duration,
						remaining = time_effect.duration - now.ticks,
						
						count = 0,
						text = detail,
						is_effect = true,
						identified = 1,
						descPicture = "",
						description = time_effect.description,
						usages = 0,
						count = 0,
						isBag = 0,
						tint = "",
						opcode = time_effect.opcode,
					}
					effects[#effects +1] = effect_block
					
				end
				sprite.effects = effects
				
				
				sprite.pc = false
				if ea == 2 then
					sprite.pc = true
					rgRadarPcNumber= rgRadarPcNumber+1
					result[#result +1] = sprite
				end
				if rgRadarShowCreaturesR == 1 then
					if ea == 255 then
						result[#result +1] = sprite
					end
				end
				if rgRadarShowCreaturesG == 1 then
					if ea == 3 or ea == 4 then
						result[#result +1] = sprite
					end
				end
				if rgRadarShowCreaturesB == 1 then
					if ea ~= 255 and ea ~= 2 and ea ~= 3 and ea ~= 4  then
						result[#result +1] = sprite
					end
				end
				
				--if sprite.m_liveTypeAI.m_EnemyAlly == 2 then
				--	rgParty[#rgParty +1] = sprite
				--end
				--if sprite.m_liveTypeAI.m_EnemyAlly ~= 2 then
				--	rgNoParty[#rgNoParty +1] = sprite
				--end
				--if sprite.m_liveTypeAI.m_EnemyAlly == 3 or sprite.m_liveTypeAI.m_EnemyAlly == 4 or sprite.m_liveTypeAI.m_EnemyAlly == 255 then
				--	rgNoPartyNeutral[#rgNoPartyNeutral +1] = sprite
				--end
			end
		end
		
	end

	table.sort(result,function(a, b) return a.displayed_name < b.displayed_name end)
	--table.sort(rgParty,function(a, b) return a.displayed_name < b.displayed_name end)
	--table.sort(rgNoParty,function(a, b) return a.displayed_name < b.displayed_name end)
	--table.sort(rgNoPartyNeutral,function(a, b) return a.displayed_name < b.displayed_name end)

	my_radar_sprites = result
	--my_radar_sprites_p = rgParty
	--my_radar_sprites_np = rgNoParty
	--my_radar_sprites_npn = rgNoPartyNeutral
end

function my_colored_allegiance(allegiance_id, only_initial)
	local allegiance = tostring(allegiance_id)
	if allegiance_id == 2 or allegiance_id == 3 or allegiance_id == 4 then
		allegiance = " ^G" .. My_Ternary(only_initial, 'P', EAS[tostring(allegiance_id)]) .. "^-"
	end

	if allegiance_id == 255 then
		allegiance = "^R" .. My_Ternary(only_initial, 'E', EAS[tostring(allegiance_id)]) .. "^-"
	end

	return allegiance
end


my_radar_effect_parsers = {}
function my_radar_effect_parser_default(effect)

	-- // Helper
	local function append_text_if_not_opcode(opcodes, opcode, text, value)
		for i=1,#opcodes do
			if opcodes[i] == opcode then
				return text
			end
		end

		text = text .. value
		return text
	end

	local detail = "p1:"..effect.p1 .. " p2:"..effect.p2
	return detail
end

function my_radar_effect_parser_218(effect)
	return " skins count=".. effect.p1
end

function my_colored_secondary_type(secondary_type,text)
	local label = map_label(SECONDARY_TYPES,tostring(secondary_type))
	
		
	local color = ""
	if secondary_type ==  1 then color = "^v" end
	if secondary_type ==  7 then color = "^t" end
	if secondary_type == 13 then color = "^b" end

	--if text == nil then
	--	if #color > 0 then return color .. label .. "^-" .. " - " end
	--	return label .. " - "
	--else
	--	if #color > 0 then return color .. text .. "^-" end
	--	return text
	--end
	--if rgRadarShowAdvInfo == 1 then
	--	return color .. label .. " - "
	--else
		return color
	--end
	
end
function my_radar_secondary_type_parser(effect,text)
	if effect.opcode == OPCODE_RESTORE_LOST_SPELLS_261
	then
		return ""
	end

	if effect.secondary_type == SECONDARY_TYPE_SPELL_PROTECTION
	or effect.secondary_type == SECONDARY_TYPE_COMBAT_PROTECTION
	or effect.secondary_type == SECONDARY_TYPE_NON_COMBAT then
		return my_colored_secondary_type(effect.secondary_type,text)
	end

	return ""
end

function my_radar_effect_parser_261(effect)
	return ""
end

function my_radar_effect_parsers_initialize()
	local MAX_OPCODE = 500
	for d=1,MAX_OPCODE do
		my_radar_effect_parsers[#my_radar_effect_parsers +1] = my_radar_effect_parser_default
	end

	my_radar_effect_parsers[OPCODE_STONESKIN_218] 			= my_radar_effect_parser_218
	my_radar_effect_parsers[OPCODE_RESTORE_LOST_SPELLS_261] = my_radar_effect_parser_261
end
my_radar_effect_parsers_initialize()

function my_radar_effect_detail(effect)
	return my_radar_effect_parsers[effect.opcode](effect)
end
