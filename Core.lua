local AngryAssign = LibStub("AceAddon-3.0"):NewAddon("FACTSAssignments", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0", "AceTimer-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local libS = LibStub("AceSerializer-3.0")
local libC = LibStub("LibCompress")
local lwin = LibStub("LibWindow-1.1")
local libCE = libC:GetAddonEncodeTable()
local LSM = LibStub("LibSharedMedia-3.0")

local protocolVersion = 1
local comPrefix = "FACTSAss"..protocolVersion

-------------------------
-- Addon Communication --
-------------------------

function FACTSAssignments:ReceiveMessage(prefix, data, channel, sender)
	if prefix ~= comPrefix then return end

	local one = libCE:Decode(data) -- Decode the compressed data

	local two, message = libC:Decompress(one) -- Decompress the decoded data

	if not two then error("Error decompressing: " .. message); return end

	local success, final = libS:Deserialize(two) -- Deserialize the decompressed data
	if not success then error("Error deserializing " .. final); return end

	self:ProcessMessage( sender, final )
end

function AngryAssign:SendMessage(data, channel, target)
	local one = libS:Serialize(data)
	local two = libC:CompressHuffman(one)
	local final = libCE:Encode(two)

	if not channel then

		if IsInRaid() then
			channel = "RAID"

		elseif IsInGroup() then
			channel = "PARTY"

		end

	end

	if not channel then return end

  -- Debug string
	self:Print("Sending "..data[COMMAND].." over "..channel.." to "..tostring(target))

	self:SendCommMessage(comPrefix, final, channel, target, "NORMAL")
	return true
end

function AngryAssign:ProcessMessage(sender, data)
	local cmd = data[COMMAND]
	sender = EnsureUnitFullName(sender)

  -- Debug string
	self:Print("Received "..data[COMMAND].." from "..sender)

end






-------------------------------------------------------------------
---------Missing Methods that were implemented in MoP/WoD----------
-------------------------------------------------------------------

function IsInRaid()
	if(GetNumRaidMembers() > 0) then
		return true
	end
	return false;
end

function IsInGroup()
	if(GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0) then
		return true
	end
	return false;
end

function GetNumGroupMembers()
	if (IsInRaid()) then
		return GetNumRaidMembers();
	elseif (IsInGroup()) then
		return GetNumPartyMembers() + 1;
	end
end

function UnitIsGroupLeader(playerName)
	if(IsInRaid()) then
		local name, rank = GetRaidRosterInfo(UnitInRaid(playerName));
		if(rank == 2) then
			return true;
		end
	elseif (IsInGroup()) then
		if((UnitName("player") == playername) and IsPartyLeader()) then
			return true;
		end
		return true;
	end
	return false;
end

function UnitIsGroupAssistant(playerName)
	if(IsInRaid()) then
		local name, rank = GetRaidRosterInfo(UnitInRaid(playerName));
		if(rank == 1) then
			return true;
		end
	end
	return false;
end
