
function map_label(map,key)
	local value = map[tostring(key)]
	if value then return value end
	return tostring(key)
end



-- AABBGGRR
fontcolors['b'] = 'FFFFB700'
fontcolors['t'] = '80FFFF00'
fontcolors['v'] = "FFB75EB7" -- lured
fontcolors['y'] = "FF0AEAEC"
fontcolors['w'] = 'FFFFB4B4' -- lured and stored
fontcolors['Y'] = 'FFFF88FF'
fontcolors['W'] = fontcolors['w'] --'FFFFB4B4'
fontcolors['K'] = 'FF1F3BFC' -- FFFC3B1F
function Display_Font_Colors()
	local notes = { }
	notes['G'] = "00 - Green : NUEE"
	notes['E'] = "01 - MY Blue : SWS"
	notes['Y'] = "02 - MY Light Ping : TRION"
	notes['W'] = "03 - MY Light Violet : SWS"
	notes['K'] = "04 - MY Red : KHARLA"
	notes['v'] = "05 - MY Violet : picked, AI OFF, PICK OFF"
	notes['y'] = "06 - MY Yellow : ITM resource"
	notes['b'] = "07 - MY Sky Blue : Toon name, Toon title, Luring"
	notes['t'] = "08 - MY Teal : Stored, Ground, coord, xp"	
	--
	notes['$'] = "10 - Gold"
	notes['1'] = "11 - Marble : title"
	notes['2'] = "12 - Marble : title highlight"
	notes['3'] = "13 - Marble : subtitle"
	notes['4'] = "14 - Light Marble : subtitle highlight"
	notes['5'] = "15 - Black : parchment"
	notes['6'] = "16 - Light Marble : parchment highlight"
	notes['7'] = "17 - Black : alternate parchment"
	notes['8'] = "18 - Dark Yellow : alternate parchment highlight"
	notes['9'] = "19 - White : semitrans dark background"
	notes['A'] = "20 - White : semitrans dark background highlight"
	notes['B'] = "21 - White : ?"
	notes['C'] = "22 - Light Mint : Minty update color"
	notes['D'] = "23 - Light Orange : orangy subtitle color"
	--
	notes['H'] = "24 - Orange : font color, cre name"
	--
	notes['M'] = "25 - Dark Red : parchment"
	--
	notes['R'] = "26 - Red"
	notes['S'] = "27 - Orange Red: Charge"
	--
	notes['w'] = "28 - Light Violet"

	local My_font_colors = { }
	for k,v in pairs(fontcolors) do
		local note = table_value(notes, k)
		if note ~= nil then note = " // " .. note else note = "" end
		My_font_colors[#My_font_colors +1] = { key = k, color = v, note = note }
	end
	table.sort(My_font_colors, function(a, b) return a.note < b.note end)

	for c=1,#My_font_colors do
		local fc = My_font_colors[c]
		Infinity_DisplayString(fc.key .. " : " .. "^" ..fc.key.. fc.color .. fc.note)
	end
end



-- STATS.IDS
STATS_MAXHITPOINTS = 1
STATS_ARMORCLASS = 2
STATS_ACCRUSHINGMOD = 3
STATS_ACMISSILEMOD = 4
STATS_ACPIERCINGMOD = 5
STATS_ACSLASHINGMOD = 6
STATS_THAC0 = 7
STATS_NUMBEROFATTACKS = 8
STATS_SAVEVSDEATH = 9
STATS_SAVEVSWANDS = 10
STATS_SAVEVSPOLY = 11
STATS_SAVEVSBREATH = 12
STATS_SAVEVSSPELL = 13
STATS_RESISTFIRE = 14
STATS_RESISTCOLD = 15
STATS_RESISTELECTRICITY = 16
STATS_RESISTACID = 17
STATS_RESISTMAGIC = 18
STATS_RESISTMAGICFIRE = 19
STATS_RESISTMAGICCOLD = 20
STATS_RESISTSLASHING = 21
STATS_RESISTCRUSHING = 22
STATS_RESISTPIERCING = 23
STATS_RESISTMISSILE = 24
STATS_FATIGUE = 30
STATS_LEVEL = 34
STATS_STR = 36
STATS_STREXTRA = 37
STATS_INT = 38
STATS_WIS = 39
STATS_DEX = 40
STATS_CON = 41
STATS_CHA = 42
STATS_IDS_XP = 44
STATS_LEVEL_2 = 68
STATS_ENCUMBERANCE = 71
STATS_RESISTPOISON = 74
STATS_STONESKINS = 88

-- OPCODE
OPCODE_DAMAGE_MOD_000 = 0
OPCODE_APR_MOD_001 = 1
OPCODE_CURRENT_HP_MOD_17 = 17
OPCODE_REGENERATION_098 = 98
OPCODE_REMOVE_ITEM_112 = 112
OPCODE_CREATE_INVENTORY_ITEM_122 = 122
OPCODE_REMOVE_INVENTORY_ITEM_123 = 123
OPCODE_CREATE_ITEM_IN_SLOT_143 = 143
OPCODE_CAST_SPELL_146 = 146
OPCODE_STONESKIN_218 = 218
OPCODE_RESTORE_LOST_SPELLS_261 = 261
OPCODE_MAGICAL_REST_316 = 316
OPCODES = {}
OPCODES[tostring(OPCODE_DAMAGE_MOD_000)] = "000-Damage Modifier"
OPCODES[tostring(OPCODE_APR_MOD_001)] = "001-APR Modifier"
OPCODES[tostring(OPCODE_REGENERATION_098)] = "098-Regeneration"
OPCODES[tostring(OPCODE_RESTORE_LOST_SPELLS_261)] = "261-Restore Lost Spells"
OPCODES[tostring(OPCODE_STONESKIN_218)] = "218-Stoneskin"



-- SLOTS.IDS
SLOT_AMULET = 0
SLOT_ARMOR = 1
SLOT_BELT = 2
SLOT_BOOTS = 3
SLOT_CLOAK = 4
SLOT_GAUNTLETS = 5
SLOT_HELMET = 6
SLOT_RINGL = 7
SLOT_RINGR = 8
SLOT_SHIELD = 9
SLOT_FIST = 10
SLOT_QUIVER_1 = 11
SLOT_QUIVER_2 = 12
SLOT_QUIVER_3 = 13
SLOT_QUIVER_4 = 14 -- Unused in BG2EE
SLOT_QUICKITEM_1 = 15
SLOT_QUICKITEM_2 = 16
SLOT_QUICKITEM_3 = 17
SLOT_INVENTORY_1 = 18
SLOT_INVENTORY_2 = 19
SLOT_INVENTORY_3 = 20
SLOT_INVENTORY_4 = 21
SLOT_INVENTORY_5 = 22
SLOT_INVENTORY_6 = 23
SLOT_INVENTORY_7 = 24
SLOT_INVENTORY_8 = 25
SLOT_INVENTORY_9 = 26
SLOT_INVENTORY_10 = 27
SLOT_INVENTORY_11 = 28
SLOT_INVENTORY_12 = 29
SLOT_INVENTORY_13 = 30
SLOT_INVENTORY_14 = 31
SLOT_INVENTORY_15 = 32
SLOT_INVENTORY_16 = 33
SLOT_INVENTORY_17 = 34 --
SLOT_WEAPON_1 = 35
SLOT_WEAPON_2 = 36
SLOT_WEAPON_3 = 37
SLOT_WEAPON_4 = 38

SLOTS = {}
SLOTS[tostring(SLOT_AMULET)] 		= { name = "Amulet" 		, sprite_item_sort_order =  8, }
SLOTS[tostring(SLOT_ARMOR)] 		= { name = "Armor"  		, sprite_item_sort_order =  9, }
SLOTS[tostring(SLOT_BELT)] 			= { name = "Belt"   		, sprite_item_sort_order = 15, }
SLOTS[tostring(SLOT_BOOTS)] 		= { name = "Boots"  		, sprite_item_sort_order = 11, }
SLOTS[tostring(SLOT_CLOAK)] 		= { name = "Cloak"  		, sprite_item_sort_order = 10, }
SLOTS[tostring(SLOT_GAUNTLETS)] 	= { name = "Gauntlets"		, sprite_item_sort_order = 12, }
SLOTS[tostring(SLOT_HELMET)] 		= { name = "Helmet"   		, sprite_item_sort_order =  7, }
SLOTS[tostring(SLOT_RINGL)] 		= { name = "Ring L"   		, sprite_item_sort_order = 13, }
SLOTS[tostring(SLOT_RINGR)] 		= { name = "Ring R"   		, sprite_item_sort_order = 14, }
SLOTS[tostring(SLOT_SHIELD)] 		= { name = "Shield"   		, sprite_item_sort_order =  6, }
SLOTS[tostring(SLOT_FIST)] 			= { name = "Fist"     		, sprite_item_sort_order =  5, }
SLOTS[tostring(SLOT_QUIVER_1)] 		= { name = "Quiver 1" 		, sprite_item_sort_order = 23, } 
SLOTS[tostring(SLOT_QUIVER_2)] 		= { name = "Quiver 2" 		, sprite_item_sort_order = 24, } 
SLOTS[tostring(SLOT_QUIVER_3)] 		= { name = "Quiver 3" 		, sprite_item_sort_order = 25, } 
SLOTS[tostring(SLOT_QUIVER_4)] 		= { name = "Quiver 4" 		, sprite_item_sort_order = 26, } -- Unused in BG2EE
SLOTS[tostring(SLOT_QUICKITEM_1)] 	= { name = "Quick Item 1"   , sprite_item_sort_order = 20, }
SLOTS[tostring(SLOT_QUICKITEM_2)] 	= { name = "Quick Item 2"   , sprite_item_sort_order = 21, }
SLOTS[tostring(SLOT_QUICKITEM_3)] 	= { name = "Quick Item 3"   , sprite_item_sort_order = 22, }
SLOTS[tostring(SLOT_INVENTORY_1)] 	= { name = "Inv 1"			, sprite_item_sort_order = 30, }
SLOTS[tostring(SLOT_INVENTORY_2)] 	= { name = "Inv 2"			, sprite_item_sort_order = 31, }
SLOTS[tostring(SLOT_INVENTORY_3)] 	= { name = "Inv 3"			, sprite_item_sort_order = 32, }
SLOTS[tostring(SLOT_INVENTORY_4)] 	= { name = "Inv 4"			, sprite_item_sort_order = 33, }
SLOTS[tostring(SLOT_INVENTORY_5)] 	= { name = "Inv 5"			, sprite_item_sort_order = 34, }
SLOTS[tostring(SLOT_INVENTORY_6)] 	= { name = "Inv 6"			, sprite_item_sort_order = 35, }
SLOTS[tostring(SLOT_INVENTORY_7)] 	= { name = "Inv 7"			, sprite_item_sort_order = 36, }
SLOTS[tostring(SLOT_INVENTORY_8)] 	= { name = "Inv 8"			, sprite_item_sort_order = 37, }
SLOTS[tostring(SLOT_INVENTORY_9)] 	= { name = "Inv 9"			, sprite_item_sort_order = 38, }
SLOTS[tostring(SLOT_INVENTORY_10)] 	= { name = "Inv 10"			, sprite_item_sort_order = 39, }
SLOTS[tostring(SLOT_INVENTORY_11)] 	= { name = "Inv 11"			, sprite_item_sort_order = 40, }
SLOTS[tostring(SLOT_INVENTORY_12)] 	= { name = "Inv 12"			, sprite_item_sort_order = 41, }
SLOTS[tostring(SLOT_INVENTORY_13)] 	= { name = "Inv 13"			, sprite_item_sort_order = 42, }
SLOTS[tostring(SLOT_INVENTORY_14)] 	= { name = "Inv 14"			, sprite_item_sort_order = 43, }
SLOTS[tostring(SLOT_INVENTORY_15)] 	= { name = "Inv 15"			, sprite_item_sort_order = 44, }
SLOTS[tostring(SLOT_INVENTORY_16)] 	= { name = "Inv 16"			, sprite_item_sort_order = 45, }
SLOTS[tostring(SLOT_INVENTORY_17)] 	= { name = "Inv 17"			, sprite_item_sort_order = 46, }
SLOTS[tostring(SLOT_WEAPON_1)] 		= { name = "Weapon 1"		, sprite_item_sort_order =  1, }
SLOTS[tostring(SLOT_WEAPON_2)] 		= { name = "Weapon 2"		, sprite_item_sort_order =  2, }
SLOTS[tostring(SLOT_WEAPON_3)] 		= { name = "Weapon 3"		, sprite_item_sort_order =  3, }
SLOTS[tostring(SLOT_WEAPON_4)] 		= { name = "Weapon 4"		, sprite_item_sort_order =  4, }
function initialize_SLOTS()
	for k,v in pairs(SLOTS) do
		v.id = tonumber(k)		
	end
end
initialize_SLOTS()

SECONDARY_TYPE_SPELL_PROTECTION = 1
SECONDARY_TYPE_COMBAT_PROTECTION = 7
SECONDARY_TYPE_NON_COMBAT = 13
SECONDARY_TYPES = {}
SECONDARY_TYPES[tostring(SECONDARY_TYPE_SPELL_PROTECTION)] = "Spell"
SECONDARY_TYPES[tostring(SECONDARY_TYPE_COMBAT_PROTECTION)] = "Combat"
SECONDARY_TYPES[tostring(SECONDARY_TYPE_NON_COMBAT)] = "Non-combat"


ALIGNMENTS = {}
ALIGNMENTS[0x00] = "NONE"
ALIGNMENTS[0x11] = "^GLG^-"
ALIGNMENTS[0x12] = "^bLN^-"
ALIGNMENTS[0x13] = "^RLE^-"
ALIGNMENTS[0x21] = "^GNG^-"
ALIGNMENTS[0x22] = "^bN^-"
ALIGNMENTS[0x23] = "^RNE^-"
ALIGNMENTS[0x31] = "^GCG^-"
ALIGNMENTS[0x32] = "^bCN^-"
ALIGNMENTS[0x33] = "^RCE^-"
ALIGNMENTS[0x01] = "MASK_GOOD"
ALIGNMENTS[0x02] = "MASK_GENEUTRAL"
ALIGNMENTS[0x03] = "MASK_EVIL"
ALIGNMENTS[0x10] = "MASK_LAWFUL"
ALIGNMENTS[0x20] = "MASK_LCNEUTRAL"
ALIGNMENTS[0x30] = "MASK_CHAOTIC"


EAS = {}
EAS[tostring(0)]   = "ANYONE"
EAS[tostring(1)]   = "INANIMATE"
EAS[tostring(2)]   = "PC"
EAS[tostring(3)]   = "FAMILIAR"
EAS[tostring(4)]   = "ALLY"
EAS[tostring(5)]   = "CONTROLLED"
EAS[tostring(6)]   = "CHARMED"
EAS[tostring(28)]  = "GOODBUTRED"
EAS[tostring(29)]  = "GOODBUTBLUE"
EAS[tostring(30)]  = "GOODCUTOFF"
EAS[tostring(31)]  = "NOTGOOD"
EAS[tostring(126)] = "ANYTHING"
EAS[tostring(128)] = "NEUTRAL"
EAS[tostring(199)] = "NOTEVIL"
EAS[tostring(200)] = "EVILCUTOFF"
EAS[tostring(201)] = "EVILBUTGREEN"
EAS[tostring(202)] = "EVILBUTBLUE"
EAS[tostring(255)] = "ENEMY"
EAS[tostring(254)] = "CHARMED_PC"