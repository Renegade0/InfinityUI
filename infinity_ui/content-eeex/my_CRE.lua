
function Sprite_Portraits(sprite)
	local base = EEex_UDToPtr(sprite.m_baseStats)
	local portrait_M = EEex_ReadLString(base + 0x2C, 8) -- sprite.m_baseStats.m_portraitSmall
	local portrait_L = EEex_ReadLString(base + 0x34, 8)
	local portrait_H = string.sub(portrait_M,1,(#portrait_M -1)) .. "H"
	return portrait_M, portrait_L, portrait_H
end

function Sprite_Scripts(sprite)
	local base = EEex_UDToPtr(sprite.m_baseStats)
	local override = EEex_ReadLString(base + 0x240, 8)
	local class    = EEex_ReadLString(base + 0x248, 8)
	local race     = EEex_ReadLString(base + 0x280, 8)
	local general  = EEex_ReadLString(base + 0x258, 8)
	local default  = EEex_ReadLString(base + 0x260, 8)
	return override, class, race, general, default
end

function Sprite_HasItem(sprite, itm_resref)
	local slots = {}
	itm_resref = itm_resref:upper()
	local base = EEex_UDToPtr(sprite.m_equipment.m_items)
	for i=SLOT_AMULET,SLOT_WEAPON_4 do
		local address = base + i*8 -- *8 because x64
		local item = EEex_Read32(address)
		if (item ~= 0) then
			local resref = EEex_ReadLString(item + 0x08 + 0x08, 8)
			if resref:upper() == itm_resref then
				slots[#slots +1] = i
			end
		end
	end
	return slots
end

function Sprite_HasItem_InSlot(sprite, itm_resref, slots)

	itm_resref = itm_resref:upper()
	local base = EEex_UDToPtr(sprite.m_equipment.m_items)
	for s=1,#slots do
		local i =slots[s]
		local address = base + i*8 -- *8 because x64
		local item = EEex_Read32(address)
		if (item ~= 0) then
			local resref = EEex_ReadLString(item + 0x08 + 0x08, 8)
			if resref:upper() == itm_resref then return true end
		end
	end

	return nil
end


function Sprite_Items(sprite)
local base = EEex_UDToPtr(sprite.m_equipment.m_items)
local selected_weapon_slot = sprite.m_equipment.m_selectedWeapon
local items = {}
for k,v in pairs(SLOTS) do
	local i=v.id
	local address = base + i*8 -- *8 because x64
	local item = EEex_Read32(address)
	if (item ~= 0) then
		local resref = EEex_ReadLString(item + 0x08 + 0x08, 8)
		if resref then resref = resref:upper() end

		local equip_flags = EEex_Read32(item + 0x24)
		local qty_or_charge_1 = EEex_Read16(item + 0x1C)
		local qty_or_charge_2 = EEex_Read16(item + 0x1C + 0x2)
		local qty_or_charge_3 = EEex_Read16(item + 0x1C + 0x4)
		local charge_2 = EEex_Read16(item + 0x1C + 2)
		local charge_3 = EEex_Read16(item + 0x1C + 4)

		local res = EEex_Resource_Demand(resref,"itm") -- K4_printTable(res)
		if res ~= nil then
			local item_file = EEex_UDToPtr(res)
			local item_name = Infinity_FetchString(EEex_Read32(item_file + 0x0C))

			local item_category = EEex_Read16(item_file + 0x1C)
			local qty = My_Ternary(item_category ==  5 -- Arrows
								or item_category ==  9 -- Potion
								or item_category == 11 -- Scroll
								or item_category == 14 -- Bullets
								or item_category == 31 -- Bolts
								or item_category == 33 -- Gold
								or item_category == 34 -- Gems
								,qty_or_charge_1
								,qty_or_charge_1)

			--Infinity_DisplayString(sprite_name .. " / " .. SLOTS[i +1] .. " : " .. resref .. " // ^y" .. item_name .. "^- (" .. qty .. ") <" .. equip_flags .. "> " .. unstealable .. undroppable .. item_undroppable .. slot_unstealable .. " " .. charge_2 .. " " .. charge_3)

			local name = item_name
			local desc_strref = EEex_Read32(item_file + 0x54)
			local desc = Infinity_FetchString(desc_strref)
			if desc == "" then desc = Infinity_FetchString(EEex_Read32(item_file + 0x50)) end

			local max_in_stack = EEex_Read16(item_file + 0x38)			
			if max_in_stack == 1 then qty = 1 end
			local obj = {
				resref = resref,
				item_name = item_name,
				name = name,
				qty = qty,
				qty_2 = qty_or_charge_2,
				qty_3 = qty_or_charge_3,
				slot = v,
				is_weapon_selected = selected_weapon_slot == v.id,
				icon = EEex_ReadLString(item_file + 0x3A, 8),
				text = "^D"..v.name .. ": ^-" .. My_Ternary(qty > 1, "^t" .. tostring(qty) .. "^- ", "") .. name,
				descPicture = EEex_ReadLString(item_file + 0x58, 8),
				description = desc,
				weight = EEex_Read16(item_file + 0x4C)
				}
			items[#items +1] = obj
		end -- // if res not nil
	end
end

return items
end



function Sprite_Timed_Effects(sprite)

	local result = {}
	local seenSpells = {}

	EEex_Utility_IterateCPtrList(sprite.m_timedEffectList, function(effect)

		-- Only process spell effects
		local sourceType = effect.m_sourceType
		if sourceType == 2 then return end -- Continue EEex_Utility_IterateCPtrList

		--
		if effect.m_effectId == 142 -- Display Icon
		then return end

		local sourceResref = effect.m_sourceRes:get()
		
		-- Sanity check
		if sourceResref == "" then return end -- Continue EEex_Utility_IterateCPtrList

		-- Already added this spell
		if seenSpells[sourceResref] then return end -- Continue EEex_Utility_IterateCPtrList

		-- Skip completely permanent spells (to hide behind-the-scenes spells)
		local m_durationType = effect.m_durationType
		if m_durationType == 9 then return end -- Continue EEex_Utility_IterateCPtrList

		if effect.m_effectId == 261 then return end -- RESTORE SPELL OPCODE
		
		seenSpells[sourceResref] = true

		local spellHeader = EEex_Resource_Demand(sourceResref, "SPL")
		-- Sanity check
		if not spellHeader then return end -- Continue EEex_Utility_IterateCPtrList

		local casterLevel = effect.m_casterLevel
		if casterLevel <= 0 then casterLevel = 1 end

		local abilityData = spellHeader:getAbilityForLevel(casterLevel)

		-- The caster shouldn't have been able to cast this spell, just use the first ability
		if not abilityData then
			abilityData = spellHeader:getAbility(0)
			-- The spell didn't even have an ability...
			if not abilityData then return end -- Continue EEex_Utility_IterateCPtrList
		end

		local spell_file = EEex_UDToPtr(spellHeader)
		local spellName = Infinity_FetchString(spellHeader.genericName)
		if spellName == "" then
			local strref = EEex_Read32(spell_file + 0x0C)
			if strref ~= 9999999 then spellName = Infinity_FetchString(strref) end
		end
		if spellName == "" then spellName = "(No Name)" end

		-- Skip no-icon spells (to hide behind-the-scenes spells)
		local spellIcon = abilityData.quickSlotIcon:get()
		if spellIcon == "" then return end -- Continue EEex_Utility_IterateCPtrList

		local desc_strref = EEex_Read32(spell_file + 0x50)
		local desc = Infinity_FetchString(desc_strref)
		if desc == "" then desc = Infinity_FetchString(EEex_Read32(spell_file + 0x54)) end
		
		local listData = {} -- time_effect
		listData.res = sourceResref
		listData.icon = spellIcon
		listData.description = desc
		listData.spellName = spellName
		listData.duration = effect.m_duration
		listData.opcode = effect.m_effectId
		listData.power = effect.m_spellLevelq
		listData.p1 = effect.m_effectAmount
		listData.p2 = effect.m_dWFlags
		listData.secondary_type = effect.m_secondaryType
		listData.start = effect.m_effectAmount5

		result[#result +1] = listData
	end)

	return result
end


function try_find_crefile(resref)
	
	for c=65,90 do
		local candidate = string.char(c)..string.sub(resref,2)
		DS(candidate)
		local cre_file = EEex_Resource_Demand(candidate,"CRE") 
		if cre_file then return cre_file, candidate end
	end
	return nil, resref
end


-- // DOMAIN -------------------------------------------------------------------

function Sprite_Create_Item_In_Slot(sprite, itm_resref, slot)

	EEex_GameObject_ApplyEffect(sprite, {
		["effectID"] = OPCODE_CREATE_ITEM_IN_SLOT_143,
		["sourceID"] = sprite.m_id,
		["sourceTarget"] = sprite.m_id,
		["spellLevel"] = 1,
		["durationType"] = 1,
		["res"] = itm_resref,
		["effectAmount"] = slot,
		["m_effectAmount2"] = 0,
		["m_effectAmount3"] = 0,
	})
end


