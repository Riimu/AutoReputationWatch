local commandList = { };

local function showMessage (message)
	print(message);
end

local function checkToggle (toggle)
	if (toggle == nil) then
		return nil;
	end
	
	toggle = string.lower(toggle);
	
	if (toggle == "true" or toggle == "on" or toggle == "enable") then
		return true;
	elseif (toggle == "false" or toggle == "off" or toggle == "disable") then
		return false;
	else
		return nil;
	end
end

local function listIgnoredFactions ()
	if (next(ARW_IgnoredFactions) == nil) then
		showMessage("There are currently no ignored factions");
	else
		showMessage("Auto Reputation Watch is currently ignoring these factions:");
		
		for name, value in pairs(ARW_IgnoredFactions) do
			showMessage(name);
		end
	end			
end

local function ignore (faction, ...)
	if (faction == nil) then
		listIgnoredFactions();
	else
		faction = table.concat({faction, ...}, " ");
		name = ARW_findFaction(faction, true);
		
		if (not name) then
			showMessage("Unknown faction '" .. faction .. "'");
		elseif (ARW_IgnoredFactions[name]) then
			showMessage("The faction '" .. name .. "' is already ignored");
		else
			ARW_IgnoredFactions[name] = true;
			showMessage("The faction '" .. name .. "' is no longer automatically watched");
		end
	end
end

local function unignore (faction, ...)
	if (faction == nil) then
		listIgnoredFactions();
	else
		faction = table.concat({faction, ...}, " ");
		
		-- In case of deprecated reputations allow removing by direct name
		if (ARW_IgnoredFactions[faction]) then
			name = faction
		else
			name = ARW_findFaction(faction, true);
		end
		
		if (not name) then
			showMessage("Unknown faction '" .. faction .. "'");
		elseif (ARW_IgnoredFactions[name]) then
			ARW_IgnoredFactions[name] = nil;
			showMessage("The faction '" .. name .. "' is now automatically watched again");
		else
			showMessage("The faction '" .. name .. "' is not currently ignored");
		end
	end
end

local function verbose (toggle)
	toggle = checkToggle(toggle);
	
	if (toggle == nil) then
		toggle = not ARW_VerboseSwitch;
	end
	
	ARW_VerboseSwitch = toggle;
	
	if (ARW_VerboseSwitch) then
		showMessage("Auto Reputation Watch will now inform about changes");
	else
		showMessage("Auto Reputation Watch wont inform about changes");
	end
end

local function hidden (toggle)
	toggle = checkToggle(toggle);
	
	if (toggle == nil) then
		toggle = not ARW_FindHiddenFactions;
	end
	
	ARW_FindHiddenFactions = toggle;
	
	if (ARW_FindHiddenFactions) then
		showMessage("Auto Reputation Watch will now look into collapsed groups");
	else
		showMessage("Auto Reputation Watch wont look into collapsed groups");
	end
end

local function commandHandler (msg)
	local args = { };
	
	for word in string.gmatch(msg, "[^%s]+") do
		table.insert(args, word);
	end
	
	if (#args < 1) then
		showMessage("Auto Reputation Watch " .. ARW_version .. ". Available slash commands:");
		
		for cmd, info in pairs(commandList) do
			showMessage("/arw " .. cmd .. " " .. info["info"]);
		end
	else
		cmd = string.lower(table.remove(args, 1));
		
		if (not commandList[cmd]) then
			showMessage("Unknown command '" .. cmd .. "'. Use '/arw' to see all available commands");
		else
			commandList[cmd]["callback"](unpack(args));
		end
	end
end

commandList = {
	["ignore"] = {
		["callback"] = ignore,
		["info"] = "<faction> - Stops faction from being automatically watched"
	},
	["unignore"] = {
		["callback"] = unignore,
		["info"] = "<faction> - Removes faction from being ignored",
	},
	["verbose"] = {
		["callback"] = verbose,
		["info"] = "<on/off> - Makes Auto Reputation Watch inform about changes",
	},
	["hidden"] = {
		["callback"] = hidden,
		["info"] = "<on/off> - Prevents looking for factions in collapsed groups",
	}
}

SLASH_AUTOREPUTATIONWATCH1 = "/arw";
SLASH_AUTOREPUTATIONWATCH2 = "/autoreputationwatch";
SlashCmdList["AUTOREPUTATIONWATCH"] = commandHandler;