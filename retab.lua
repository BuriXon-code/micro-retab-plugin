--[[
retab.lua
Author: Kamil BuriXon Burek
Version: 1.1.0
Year: 2026

Description:
  Simple Micro plugin to toggle indentation between tabs and spaces.
  Automatically uses the buffer's tabsize setting.
  Supports two-way conversion (spaces -> tabs, tabs -> spaces).
  Displays info about changes in Micro's InfoBar.

Usage:
	retab
	- Mixed leading whitespace -> convert all leading whitespace to ONLY TABs (ceil), so file becomes tab-only.
	- All-space-leading lines -> convert spaces -> tabs where possible (floor, keep remainder < tabsize).
	- All-tab-leading lines -> convert leading tabs -> spaces.
	- InfoBar shows counts.
--]]

local config = import("micro/config")
local buffer = import("micro/buffer")
local micro = import("micro")

function init()
	config.MakeCommand("retab", retab, config.NoComplete)
end

local function leading_ws(s)
	return s:match("^[ \t]+")
end

local function compute_columns(ws, tabsize)
	local total = 0
	for i = 1, #ws do
		local ch = ws:sub(i, i)
		if ch == "\t" then
			total = total + tabsize
		else
			total = total + 1
		end
	end
	return total
end

local function count_leading_char(s, ch)
	local cnt = 0
	for i = 1, #s do
		if s:sub(i, i) == ch then
			cnt = cnt + 1
		else
			break
		end
	end
	return cnt
end

function retab(bp, args)
	local buf = bp.Buf
	local tabsize = tonumber(buf.Settings["tabsize"]) or 4

	local lineCount
	if type(buf.LinesNum) == "function" then
		lineCount = buf:LinesNum()
	else
		lineCount = buf.LinesNum
	end

	local hasLineStartingWithSpace = false
	local hasLineStartingWithTab = false

	-- detect: does any line start with ' ' ? does any line start with '\t' ?
	for i = 0, lineCount - 1 do
		local line = tostring(buf:Line(i))
		if line:sub(1,1) == " " then
			hasLineStartingWithSpace = true
		elseif line:sub(1,1) == "\t" then
			hasLineStartingWithTab = true
		end
		if hasLineStartingWithSpace and hasLineStartingWithTab then
			break
		end
	end

	local convertedToTabs = 0
	local convertedToSpaces = 0
	local normalizedMixed = 0

	for i = 0, lineCount - 1 do
		local line = tostring(buf:Line(i))
		local ws = leading_ws(line)
		if not ws then
			-- nothing to do
		else
			if hasLineStartingWithSpace and hasLineStartingWithTab then
				-- MIXED: convert ALL leading whitespace to ONLY tabs (use ceil so no remainder spaces remain)
				local totalCols = compute_columns(ws, tabsize)
				local tabsCount = math.ceil(totalCols / tabsize)
				local replacement = string.rep("\t", tabsCount)
				if replacement ~= ws then
					buf:Replace(buffer.Loc(0, i), buffer.Loc(#ws, i), replacement)
					normalizedMixed = normalizedMixed + 1
					-- update counters for informative message:
					if ws:find(" ") and tabsCount > 0 then convertedToTabs = convertedToTabs + 1 end
					if ws:find("\t") and tabsCount == 0 then convertedToSpaces = convertedToSpaces + 1 end
				end

			elseif hasLineStartingWithSpace and not hasLineStartingWithTab then
				-- only space-leading lines -> convert spaces -> tabs where possible (floor), keep remainder
				if ws:match("^ +$") then
					local count = #ws
					local tabsCount = math.floor(count / tabsize)
					local rest = count % tabsize
					if tabsCount > 0 then
						local replacement = string.rep("\t", tabsCount) .. string.rep(" ", rest)
						buf:Replace(buffer.Loc(0, i), buffer.Loc(count, i), replacement)
						convertedToTabs = convertedToTabs + 1
					end
				end

			elseif hasLineStartingWithTab and not hasLineStartingWithSpace then
				-- only tab-leading lines -> convert leading tabs -> spaces, leave any following spaces intact
				local tabsCount = count_leading_char(ws, "\t")
				if tabsCount > 0 then
					local replacementForTabs = string.rep(" ", tabsCount * tabsize)
					buf:Replace(buffer.Loc(0, i), buffer.Loc(tabsCount, i), replacementForTabs)
					convertedToSpaces = convertedToSpaces + 1
				end
			end
		end
	end

	-- Compose message
	local msg = nil
	if hasLineStartingWithSpace and hasLineStartingWithTab then
		if normalizedMixed > 0 then
			msg = string.format("Normalized mixed indentation to TABs: %d lines adjusted.", normalizedMixed)
		else
			msg = "Mixed indentation detected but no changes were necessary."
		end
	else
		if convertedToTabs > 0 and convertedToSpaces == 0 then
			msg = string.format("Converted indentation: spaces -> tabs (%d lines).", convertedToTabs)
		elseif convertedToSpaces > 0 and convertedToTabs == 0 then
			msg = string.format("Converted indentation: tabs -> spaces (%d lines).", convertedToSpaces)
		elseif convertedToTabs > 0 and convertedToSpaces > 0 then
			msg = string.format("Converted indentation: %d lines to tabs, %d lines to spaces.", convertedToTabs, convertedToSpaces)
		else
			msg = "No indentation changes needed."
		end
	end

	micro.InfoBar():Message(msg)
end
