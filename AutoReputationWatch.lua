local frame = CreateFrame("FRAME", "AutoReputationWatchFrame");
frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE");

local messages = { }
local patterns = { };

messages = {
	FACTION_STANDING_DECREASED,
	FACTION_STANDING_INCREASED
}

for i, msg in ipairs(messages) do
	msg = string.gsub(msg, "%%s", "(.+)");
	msg = string.gsub(msg, "%%d", "(%%d+)");
	
	patterns[i] = msg;
end

local function eventHandler (self, event, message)
	if (event ~= "CHAT_MSG_COMBAT_FACTION_CHANGE") then
		return;
	end
	
	local current = GetWatchedFactionInfo();
	
	for i, pattern in ipairs(patterns) do
		local name, amount = string.match(message, pattern);

		if (name and name ~= current) then
			local count = GetNumFactions();
			
			for i = 0, count do
				local compare = GetFactionInfo(i);
				
				if (compare == name) then
					SetWatchedFactionIndex(i);
					return;
				end
			end
		end
	end
end
		
frame:SetScript("OnEvent", eventHandler);