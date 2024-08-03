
function my_Show_Description(resref, restype) -- itm or spl

	local item_res = EEex_Resource_Demand(resref, restype)

	if item_res == nil then return end

	local item_file = EEex_UDToPtr(item_res)
	if item_file == 0 then return end

	local desc_picture = EEex_ReadLString(item_file + 0x58,8)
	local desc = Infinity_FetchString(EEex_Read32(item_file + 0x54))
	if desc == "" then desc = Infinity_FetchString(EEex_Read32(item_file + 0x50)) end

	local item =
	{
		usages = 0,
		identified = 1,
		description = desc,
		descPicture = desc_picture,
		tint = "",
		res = resref,
		--zresref = object.zresref,
		count = 0,
		icon = "", --object.icon,
		isBag = 0,
		name = "object.name",
		restoreable = true,
		index = index
	}
	showItemDescription(item, nil)

end


function My_ScreenSize()

	local w, h = Infinity_GetScreenSize()
	if w > 2560 or h > 1440 then w = 2560 h = 1440 end

	return w, h
end

my_RESTORE_PAUSE_STATE_TO_ON = nil
function my_Store_Pause_State(on_off)
	my_RESTORE_PAUSE_STATE_TO_ON = on_off
end

function my_Restore_Pause_State()
	if my_RESTORE_PAUSE_STATE_TO_ON then
		my_Force_Pause()
	else	
		my_Force_UnPause()
	end
end

function my_Force_Pause()
	if worldScreen:CheckIfPaused() then return end
	
	B3TimeStep_TogglePause()
	--worldScreen:TogglePauseGame(true)
end

function my_Force_UnPause()
	if not worldScreen:CheckIfPaused() then return end
	
	B3TimeStep_TogglePause()
	--worldScreen:TogglePauseGame(true)
end




-- =============================================================================
-- OPERATORS
-- =============================================================================
function My_Ternary(cond , T , F )
    if cond then return T else return F end
end

function My_Binary(T , F )
    if T then return T else return F end
end



-- =============================================================================
-- MY TIME
-- =============================================================================
function My_CurrentTimeString()
	-- OLD
	-- local now = worldScreen:GetCurrentTimeString()
	-- local day = now:match("(.*)\n")
	-- local hour = now:match("\n(.*)")
	-- return day .. " " .. hour
	local now = My_Current_Time()
	--return now.litteral .. " " ..  now.seconds .. "''"
	return now.ticks

end


My_ONE_HOUR = 4500 -- ticks
-- 1rd = 100 ticks
function My_Current_Time(ticks)
	-- https://forums.beamdog.com/discussion/13885/durations-descriptions-list-of-issues
	-- 1 day in game = 24 hours in-game = 1200 rounds = 7200 seconds
	-- 1 hour = 5 Turns = 50 rounds = 300 seconds
	-- 1 turn = 10 rounds = 60 seconds
	-- 1 round = 6 seconds
	-- Casting time is in tenths of a round. Casting time 1 = 0.6 second Casting time 9 = 5.4 seconds

	-- 2.6.5: timer:GetCurrentTime() => 100 = 1 round == 6 s
	-- 1000 = 60 s = 1 min
	-- 60000 = 1 heure

	local result = {}
	result.ticks = My_Binary(ticks, timer:GetCurrentTime())

	local seconds = math.floor(result.ticks / 15)
	local r_ticks = result.ticks % 15
	--DS(result.ticks)DS(seconds)DS(r_ticks)
	result.remaining_ticks = r_ticks

	result.days = (seconds - seconds % 7200) / 7200

    local seconds_without_days = seconds - 7200 * result.days
	result.hours = math.floor( (seconds_without_days - result.days % 300) / 300 )

	local seconds_without_hours = seconds_without_days - 300 * result.hours
	result.minutes = math.floor((seconds_without_hours - seconds_without_hours % 5) / 5 )

	local seconds_without_minutes = math.floor(seconds_without_hours - 5 * result.minutes)
	result.seconds = seconds_without_minutes

	local reverted_ticks = (result.days*7200 + result.hours * 300 + result.minutes *5 + result.seconds) * 15 + result.remaining_ticks
	--result.debug = "Day " .. result.days .. " Hour " .. result.hours .. ":" .. result.minutes .. ":" .. result.seconds
	result.pretty_print = "Day " .. result.days
		.. " Hour " .. string.format('%02d', result.hours)
		.. ":" .. string.format('%02d', result.minutes)
		.. ":" .. string.format('%02d', result.seconds)
		-- .. "," .. result.remaining_ticks
		-- .. " = " .. result.ticks
		-- .. " = " .. reverted_ticks

	result.hms = string.format('%02d', result.hours)
		.. ":"
		.. string.format('%02d', result.minutes)
		.. ":"
		.. string.format('%02d', result.seconds)
	result.ms = string.format('%02d', result.minutes) .. ":" .. string.format('%02d', result.seconds) .. "," .. string.format('%02d', result.remaining_ticks)
	result.s = string.format('%02d', result.seconds) .. "." .. string.format('%02d', result.remaining_ticks)
	return result
end



My_display_buffer = nil
function WITH(txt) My_display_buffer = txt return My_display_buffer end
function AND(txt) My_display_buffer = My_display_buffer .. ", " .. txt return My_display_buffer end
function DS(txt)
	local msg = My_Ternary(My_display_buffer == nil, "", My_display_buffer)
	if msg ~= "" then
		msg = msg .. " " .. My_Ternary(txt == nil, "", txt)
	else
		msg = My_Ternary(txt == nil, "", txt)
	end

	if msg == 'SEPARATOR' then msg = " " end
	Infinity_DisplayString(msg)
	My_display_buffer = ""
end



function table_value(mytable, key)
	for k,v in pairs(mytable) do
		if (k == key) then return v end
	end
	return nil
end

function K4(t,deep)
	return K4_printTable(t, deep)
end
function K4_printTable(t,deep)
	local txt = ''
	local print_t_cache = {}
	
	local level = 1 
	if deep then level = deep end
	
	local function sub_print_t(t, indent)
		level = level -1
		if print_t_cache[tostring(t)] then
			txt = txt .. indent .. '*' .. tostring(t) .. '\n'
		else
			print_t_cache[tostring(t)] = true
			if type(t) == 'table' then
				for pos, val in pairs(t) do
					if pos and val then
						--if type(val) == 'table' then
						if type(val) == 'table' and level > 0 then
							txt = txt .. indent .. '[' .. pos .. '] => ' .. tostring(t) .. ' {' .. '\n'
							sub_print_t(val, indent .. " ")
							txt = txt .. indent .. string.rep(' ', string.len(tostring(pos)) + 6) .. '}' .. '\n'
						elseif type(val) == 'string' then
							txt = txt .. indent .. '[' .. pos .. '] => "' .. val .. '"' .. '\n'														
						else							
							txt = txt .. indent .. '[' .. pos .. '] => ' .. tostring(val) ..'\n'
						end
					end
				end
			else
				txt = txt .. indent .. tostring(t) .. '\n'
			end
		end
	end

	if type(t) == 'table' then
		txt = txt .. tostring(t) .. ' {' .. '\n'
		sub_print_t(t, '  ')
		txt = txt .. '}' .. '\n'
	else
		sub_print_t(t, '  ')
	end
	Infinity_DisplayString(txt)
end




function MY_trim(s)
   return s:match'^%s*(.*%S)' or ''
   -- or : local resistance_value = string.gsub(buffer[index], "%s+", "")
end
  -- mystring:gmatch("[^\r\n:]+")


function K4_printTable_CANON(t)
	local txt = ''
	local print_t_cache = {}
	local function sub_print_t(t, indent)
		if print_t_cache[tostring(t)] then
			txt = txt .. indent .. '*' .. tostring(t) .. '\n'
		else
			print_t_cache[tostring(t)] = true
			if type(t) == 'table' then
				for pos, val in pairs(t) do
					if type(val) == 'table' then
						txt = txt .. indent .. '[' .. pos .. '] => ' .. tostring(t) .. ' {' .. '\n'
						sub_print_t(val, indent .. string.rep(' ', string.len(tostring(pos)) + 8))
						txt = txt .. indent .. string.rep(' ', string.len(tostring(pos)) + 6) .. '}' .. '\n'
					elseif type(val) == 'string' then
						txt = txt .. indent .. '[' .. pos .. '] => "' .. val .. '"' .. '\n'
					else
						txt = txt .. indent .. '[' .. pos .. '] => ' .. tostring(val) ..'\n'
					end
				end
			else
				txt = txt .. indent .. tostring(t) .. '\n'
			end
		end
	end

	if type(t) == 'table' then
		txt = txt .. tostring(t) .. ' {' .. '\n'
		sub_print_t(t, '  ')
		txt = txt .. '}' .. '\n'
	else
		sub_print_t(t, '  ')
	end
	Infinity_DisplayString(txt)
end




function tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  DS(toprint)
  return toprint
end

----local res = EEex_Resource_Demand("SW1H01","itm")
		----local res = EEex_Resource_Demand("AR0700","are") -- K4_printTable(res)
		----local res = EEex_Resource_Demand("BAG04","STO") -- K4_printTable(res)
		--Infinity_DisplayString("11")
		--if res ~= nil then
		--	local res_file = EEex_UDToPtr(res)
		--
		--	Infinity_DisplayString("OK")
		--else
		--	Infinity_DisplayString("BAD")
--end


-- // Time
	-- // TODO if key == Hot_key_SPACE then
	-- // TODO 	if not worldScreen:CheckIfPaused() then
	-- // TODO 		chatboxScrollToBottom = 1
	-- // TODO 		--C:Eval('RevealAreaOnMap("WQ0001")')
	-- // TODO 		--CopperCoronet_People_Should_Return_Neutral_When_Hendak_Quest1_Done()
	-- // TODO 	end
	-- // TODO 	--worldScreen:TogglePauseGame(false) --> UNPAUSE
	-- // TODO 	--worldScreen:TogglePauseGame(true) --> PAUSE
	-- // TODO 	end

	-- //worldScreen:CheckIfPaused()


-- // FYI
-- status = status .. " ==> " .. sprite:getLocalInt("SWS_MIGHTY_ATT_DEX")
-- status = status .. " ==> " .. EEex_GameState_GetGlobalInt("SWS_MIGHTY_ATT_DEX")

-- // FYI
-- EEex_Read8(address)
-- EEex_Read16(address)
-- EEex_Read32(address)
-- EEex_Read64(address)
-- EEex_ReadU8(address)
-- EEex_ReadU16(address)
-- EEex_ReadU32(address)
-- EEex_ReadU64(address)
-- EEex_ReadPointer(address) / EEex_ReadPtr(address)
-- EEex_ReadString(address)
-- EEex_ReadLString(address, length)
-- EEex_Write8(address, value)
-- EEex_Write16(address, value)
-- EEex_Write32(address, value)
-- EEex_Write64(address, value)
-- EEex_WritePointer(address, value) / EEex_WritePtr(address, value)
-- EEex_WriteString(address, value)
-- EEex_WriteLString(address, value, length)


-- FYI
--button
--{
--	enabled        "FW_IsFrameActivated_ITEMS()"
--	icon lua       "GEMS_TEMPLATE_Icon_Bam()"
--	frame lua      "GEMS_TEMPLATE_Icon_Frame()"
--	tooltip lua    "GEMS_TEMPLATE_Icon_Tooltip()"
--	--usages lua     "9" -- NOTE: BOTTOM LEFT NUMBER
--	count lua      "GEMS_TEMPLATE_Icon_Count()" -- NOTE: BOTTOM RIGHT NUMBER
--	action         "GEMS_TEMPLATE_Icon_Action()" -- HINT
--	actionalt      "GEMS_TEMPLATE_Icon_ActionAlt()" -- RESTORE TO INVENTORY
--	--useOverlayTint "GEMS_Visible()"
--	greyscale lua  "GEMS_Icon_GreyScale()" -- NOTE: SHADOWED
--	overlayTint 180 180 180
--	align center center
--	-- scaleToClip
--}

-- incrChapter(-1)
-- tooltip force lua "sidebarForceTooltips == 1"
-- tooltip force top
-- clickable lua "sidebarsGreyed ~= 1"

-- action "Infinity_OnPortraitLClick(0); rgActiveArea = 1"
-- actionAlt "Infinity_OnPortraitRClick(0)"
-- actionDbl "Infinity_OnPortraitDblClick(0)"
-- actiondrag "Infinity_SwapWithPortrait(0)"
-- actionEnter "mouseOverPortrait = 0"
-- actionExit "mouseOverPortrait = -1; rgUpdateSlotsOnExit()"


-- INFINITY UI
-- rgdbcrep.bam -- MOS34003.pvrz // Record/Portrait/Edge
-- red large scale, rgdmbcg.bam -- MOS34046 rgdmbcg[1..5] : Edge
-- red large scale, no -- MOS34080 
-- scroll shape, RGDWLBC -- MOS34083, 34107, ! 34123 !,  35500 34023 34201 34203 34205
-- edge MOS34085, MOS34089, 35340 + 35341 + 35342 + 35355 + 35357 + 35420 + 35421 + 35430 + 35431
-- full rect edge 34150, 34155
-- H edge MOS34086
-- scroll MOS34092
-- bckgd MOS34103, 34110, 34111, 34121

--worldScreen:TogglePauseGame(true)
-- Infinity_SetOffset('JOURNAL',w, h)


--menu
--{
--	name 'JOURNAL'
--	align left top
--	align center top
--	offset -10 -10
--	ignoreEsc
--	modal

-- Infinity_FocusTextEdit('luaEditArea')

--bitmap lua "%bitmap%"

-- text lua '%text%'
-- text point 12
-- text color 255 255 255 255
-- text shadow 1
-- pad 5 5 0 0
-- align left top
-- respectClipping
-- TEXT_inventoryError

--
-- e:SelectEngine(worldScreen) // 'MAGE'