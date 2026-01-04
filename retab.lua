--[[
retab.lua
Author: Kamil BuriXon Burek
Version: 1.0.0
Year: 2026
Micro version: >= 2.0.0

Description:
  Simple Micro plugin to toggle indentation between tabs and spaces.
  Automatically uses the buffer's tabsize setting.
  Supports two-way conversion (spaces -> tabs, tabs -> spaces).
  Displays info about changes in Micro's InfoBar.

Usage:
  retab
	- Converts indentation in the current buffer.
	- Lines starting with spaces will be converted to tabs (based on tabsize).
	- Lines starting with tabs will be converted to spaces.

License:
  MIT
--]]

local config = import("micro/config")
local buffer = import("micro/buffer")
local micro = import("micro")

function init()
	config.MakeCommand("retab", retab, config.NoComplete)
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

	local convertedToTabs = 0
	local convertedToSpaces = 0

	for i = 0, lineCount - 1 do
		local line = tostring(buf:Line(i))

		-- tabs -> spaces
		local tabs = line:match("^(\t+)")
		if tabs then
			buf:Replace(
				buffer.Loc(0, i),
				buffer.Loc(#tabs, i),
				string.rep(" ", #tabs * tabsize)
			)
			convertedToSpaces = convertedToSpaces + 1
		else
			-- spaces -> tabs
			local spaces = line:match("^( +)")
			if spaces then
				local count = #spaces
				local tabsCount = math.floor(count / tabsize)
				local rest = count % tabsize

				if tabsCount > 0 then
					buf:Replace(
						buffer.Loc(0, i),
						buffer.Loc(count, i),
						string.rep("\t", tabsCount) .. string.rep(" ", rest)
					)
					convertedToTabs = convertedToTabs + 1
				end
			end
		end
	end

	-- Show info on InfoBar
	if convertedToTabs > 0 and convertedToSpaces == 0 then
		micro.InfoBar():Message("Converted indentation: spaces -> TAB")
	elseif convertedToSpaces > 0 and convertedToTabs == 0 then
		micro.InfoBar():Message("Converted indentation: TAB -> spaces")
	elseif convertedToTabs > 0 and convertedToSpaces > 0 then
		micro.InfoBar():Message("Converted mixed indentation: spaces ↔ TAB")
	else
		micro.InfoBar():Message("No indentation changes needed")
	end
end
