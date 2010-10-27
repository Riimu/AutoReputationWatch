ARW_version = "v1.1";

local frame = CreateFrame("FRAME", "AutoReputationWatchFrame");

frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");
frame:RegisterEvent("ADDON_LOADED");

-- Saved Variables
ARW_FindHiddenFactions = true;
ARW_VerboseSwitch = false;
ARW_IgnoredFactions = { }

local messages = { };
local patterns = { };

local function initializeAddon ()
	messages = {
		FACTION_STANDING_DECREASED,
		FACTION_STANDING_INCREASED
	}

	for i, msg in ipairs(messages) do
		msg = string.gsub(msg, "%%s", "(.+)");
		msg = string.gsub(msg, "%%d", "(%%d+)");
		
		patterns[i] = msg;
	end
end

local function parseFactionChange (message)	
	local currentName = GetWatchedFactionInfo();
	local openHeaders = { };
	local found = false;
	
	for i, pattern in ipairs(patterns) do
		local findName, amount = string.match(message, pattern);

		if (findName) then
			if (findName == currentName or ARW_IgnoredFactions[findName]) then
				break;
			end
			
			local found = ARW_findFaction(findName, ARW_FindHiddenFactions,
				true, SetWatchedFactionIndex);
			
			if (found) then
				if (ARW_VerboseSwitch) then
					print("Changed watched faction to " .. found);
				end
				
				break;
			end
		end
	end
end

function ARW_findFaction (findName, findHidden, keepOpen, callback)
	local openHeaders = { };
	local found = false;
	local returnValue = false;
		
	local count = GetNumFactions();
	local i = 1;
	
	findName = string.lower(findName);
	
	--  While loop, since count can change mid loop
	while (i <= count) do
		local name, description, standingId, bottomValue, topValue,
			earnedValue, atWarWith, canToggleAtWar, isHeader,
			isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(i);
		
		if (findName == string.lower(name)) then
			if (callback) then
				callback(i);
			end
			
			returnValue = name;
			found = true;
			break;
		elseif (isHeader and isCollapsed and findHidden) then
			ExpandFactionHeader(i);
			table.insert(openHeaders, i);
			count = GetNumFactions();
		end
		
		i = i + 1;
	end
	
	-- Collapse opened headers back
	if (#openHeaders > 0) then
		local collapseLevel = 2;
		
		-- Go through the list in reverse to maintain indexes
		for i = #openHeaders, 1, -1 do
			local index = openHeaders[i];
			
			-- When faction was switched, do not hide the watched faction
			if (found and keepOpen and collapseLevel > 0) then
				local name, description, standingId, bottomValue, topValue,
					earnedValue, atWarWith, canToggleAtWar, isHeader,
					isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(index);
					
				if (isChild and collapseLevel > 1) then
					collapseLevel = 1;
				elseif (not isChild and collapseLevel > 0) then
					collapseLevel = 0;
				else
					CollapseFactionHeader(index);
				end
			else
				CollapseFactionHeader(index);
			end
		end
	end
	
	return returnValue;
end

local function eventHandler (self, event, arg1)
	if (event == "ADDON_LOADED" and arg1 == "AutoReputationWatch") then
		initializeAddon();
	elseif (event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then
		parseFactionChange(arg1);
	end
end
		
frame:SetScript("OnEvent", eventHandler);
