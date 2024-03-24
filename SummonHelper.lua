---
--- Documentation https://github.com/PluieYu/SummonHelper?tab=readme-ov-file
--- Created by Yu.
--- DateTime: 2024/3/14 21:25
---
--

--main class--
SummonHelper = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0","AceModuleCore-2.0","AceComm-2.0","AceDB-2.0","AceDebug-2.0","AceConsole-2.0","FuBarPlugin-2.0")
local L = AceLibrary("AceLocale-2.2"):new("SummonHelper")

local Prefix = "SummonHelper"
local BS = AceLibrary("Babble-Spell-2.2")
--local BZ = AceLibrary("Babble-Zone-2.2")
local SpellStatus = AceLibrary("SpellStatus-1.0")

SummonHelper.hasIcon = "Interface\\Icons\\spell_shadow_twilight"
SummonHelper.defaultMinimapPosition = 160
SummonHelper.hideWithoutStandby = true
SummonHelper.options = {
	type = "group",
	args = {
		ResetPos = {
			type = "execute",
			name = L["重置"],
			desc = L["重置拉人界面"],
			order = 1,
			func = function() SummonHelper.SummonHelperFrame:ResetFramePosition() end,
		},
		ShowFrame = {
			type = "execute",
			name = L["显示"],
			desc = L["显示拉人界面"],
			order = 1,
			func = function() SummonHelper.SummonHelperFrame.frame:Show() end,
		},
	}
}

function SummonHelper:OnInitialize()
	playerClass = UnitClass("player")
	self:SetDebugLevel(3)
	self.SummonList = {}
	self.SummonListHide = {}
	self:RegisterDB("SummonHelperDB")
	self:RegisterDefaults("profile", {
		xOfs = nil,
		yOfs = nil,
		point = nil,
		relativePoint = nil,
	})
	self.opt = self.db.profile
	self.SummonHelperFrame = SummonHelperFrame
	self.SummonHelperFrame:SetupFrame()
	self.OnMenuRequest = SummonHelper.options
	self:SetCommPrefix(Prefix)
	self:RegisterChatCommand({"/smh", "/SummonHelper"}, SummonHelper.options)
	DEFAULT_CHAT_FRAME:AddMessage(string.format("%s: %s", L["小皮箱术士拉人助手"], L["已加载"]))
end

function SummonHelper:OnProfileEnable()
	self.opt = self.db.profile
end

function SummonHelper:OnEnable()
	if playerClass ~= "术士" then
		SummonHelper:OnDisable()
		return
	end
	self:RegisterComm(Prefix, "RAID")
	if not self:IsCommRegistered(Prefix,"RAID") then
		self:RegisterComm(Prefix, "RAID")
	end
	--Register PARTY-RAID-WHISPER chanel
	self:RegisterEvent("CHAT_MSG_PARTY", "CheckChatMessage")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "CheckChatMessage")

	self:RegisterEvent("CHAT_MSG_RAID", "CheckChatMessage")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "CheckChatMessage")
	self:RegisterEvent("CHAT_MSG_WHISPER", "CheckChatMessage")

	self:RegisterEvent("SpellStatus_SpellCastCastingStart")
	self:RegisterEvent("SpellStatus_SpellCastFailure")
	self:RegisterEvent("SpellStatus_SpellCastChannelingStart")
	self:RegisterEvent("SpellStatus_SpellCastChannelingFinish")

end

function SummonHelper:OnDisable()
	if self:IsCommRegistered(Prefix,"RAID") then
		SummonHelper:UnregisterComm(Prefix, "RAID")
	end
	SummonHelper:UnregisterAllEvents()
	self.SummonHelperFrame.frame:Hide()
end


function SummonHelper:CheckChatMessage(msg, name)
	if not string.find(msg,  L["小皮箱术士拉人助手"]) then
		for _, word in pairs(L["关键词"]) do
			index_stat, index_end = string.find(msg, word);
			if index_stat then
				self:OnCommReceive("", "", "RAID", "Add", name)
				self:SendCommMessage("RAID","Add",name)
				self.SummonHelperFrame.frame:Show()
			end
		end
	end
	--self:IsCommRegistered(Prefix,"RAID")

end

function SummonHelper:SpellStatus_SpellCastCastingStart(id, name, fullName, startTime, stopTime, duration)
	if name == BS["Ritual of Summoning"] then
		self:LevelDebug(2, format("SpellStatus_SpellCastCastingStart: <%s>", tostring(name)))
		self.SummoningTarget = UnitName("target")
		self:SendCommMessage("RAID","Summoning", self.SummoningTarget )
	end
end
function SummonHelper:SpellStatus_SpellCastChannelingStart(id, name, fullName, startTime, stopTime, duration)
	if name == BS["Ritual of Summoning"] then
		self:LevelDebug(2, format("SpellStatus_SpellCastChannelingStart: <%s>", tostring(name)))
		SendChatMessage(string.format("%s: %s", L["小皮箱术士拉人助手"], L["召唤仪式已经启动"]), "WHISPER", nil, self.SummoningTarget)

	end
end

function SummonHelper:SpellStatus_SpellCastFailure(id, name, fullName, raison,raison2,raison3,raison4 )
	if name == BS["Ritual of Summoning"] then
		self:LevelDebug(2, format("SpellStatus_SpellCastFailure on : <%s> for the reason <%s>", tostring(name), tostring(raison)))
		self:SendCommMessage("RAID","SummoningFailure", self.SummoningTarget )
		SendChatMessage(string.format("%s: %s", L["小皮箱术士拉人助手"], L["召唤仪式遭到破坏"]), "WHISPER", nil, self.SummoningTarget)
	end
end


function SummonHelper:SpellStatus_SpellCastChannelingFinish(id, name, fullName, raison)
	if name == BS["Ritual of Summoning"] then
		self:LevelDebug(2, format("SpellStatus_SpellCastChannelingFinish on : <%s> for the reason <%s>", tostring(name), tostring(raison)))
		SendChatMessage(string.format("%s: %s", L["小皮箱术士拉人助手"], L["召唤仪式已经完成"]), "WHISPER", nil, self.SummoningTarget)
		SummonHelper:RemoveFonc(self.SummoningTarget)

	end
end


function SummonHelper:OnCommReceive(prefix, sender, distribution, method, target)
	if target ~= nil and method ~= nil then
		targetPos = tablefind(self.SummonList, target)
		self:LevelDebug(2, format("Got Comm Msg: <%s> on <%s>", tostring(method), tostring(target)))
		if method=="Add"  and targetPos == nil then
			table.insert(self.SummonList, target)
			self:Reflash()
		elseif method=="Remove" and targetPos ~= nil then
			table.remove(self.SummonList, targetPos)
			self:Reflash()
		elseif method=="Summoning" and targetPos ~= nil then
			self:HideSummoningTarget(target)
		elseif method=="SummoningFailure" and targetPos ~= nil then
			self:ShowSummoningTarget(target)
		end
	end
end

function tablefind(tab,el)
	for index, value in pairs(tab) do
			if value == el then
				return index
			end
		end
	end

function SummonHelper:RemoveFonc(name)
	self:LevelDebug(2, format("RemoveFonc has been active on: %s", tostring(name)))
	self:OnCommReceive("", "", "RAID", "Remove", name)
	SummonHelper:SendCommMessage("RAID","Remove", name )
end
function SummonHelper:SummonFonc(name)
	self:LevelDebug(2, format("SummonFoncButton has been Clicked on: %s", tostring(name)))
	SummonHelper:SendCommMessage("RAID","Summoning", name )
	local unitId = self:GetUnitId(name)
	local playerZone = self:GetZone("player")
	TargetUnit(unitId)
	if UnitAffectingCombat("player") then
		self:Print(L["你正在战斗中"])
	elseif UnitAffectingCombat(unitId) then
		self:Print(string.format(L["%s 在战斗中"], name))
	elseif CheckInteractDistance("target", 4) then
		self:Print(string.format(L["%s 已在身边"], name))
		self:RemoveFonc(name)
	else
		--CastSpellByName(BS["Ritual of Summoning"])
		SpellStatus:CastSpellByName(BS["Ritual of Summoning"],false)

		local chatType = "PARTY"
		if GetNumRaidMembers() > 0 then
			chatType = "RAID"
		end
		SendChatMessage(
				string.format(
						string.format("%s: %s", L["小皮箱术士拉人助手"], L["正在将%s拉到 %s"]),
						self:GetUnitNameWithColors(name), playerZone),
				chatType)
		SendChatMessage(
				string.format(
						string.format("%s: %s", L["小皮箱术士拉人助手"], L["正在召唤你倒 %s"]),
						playerZone),
				"WHISPER", nil, name)
	end
end









function SummonHelper:GetUnitId(name)
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers(), 1 do
			local aName = GetRaidRosterInfo(i)
			if aName == name then
				return "Raid" .. i
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers(), 1 do
			local unitId = "Party" .. i
			local aName = UnitName(unitId)
			if aName == name then
				return unitId
			end
		end
	end
	return nil
end
function SummonHelper:GetZone(unitId)
	if GetNumRaidMembers() > 0 then
		if unitId then
			if unitId == "player" then
				unitId = self:GetUnitId(GetUnitName(unitId))
				local _, _, _, _, _, _, zone = GetRaidRosterInfo(string.sub(unitId, 5))
				return zone
			elseif string.find(unitId, "Raid") then
				local _, _, _, _, _, _, zone = GetRaidRosterInfo(string.sub(unitId, 5))
				return zone
			end
		end
	elseif GetNumPartyMembers() > 0 then
		if unitId then
			-- how do I get the zone of party members?
			return GetRealZoneText()
		end
	end

	return nil
end
function SummonHelper:Reflash()
	for i = 1, 5 do
		if self.SummonList[i] then
			if tablefind(self.SummonListHide, self.SummonList[i]) then
				self:LevelDebug(2, format("Target in the hiden list: %s", tostring(tablefind(self.SummonListHide, self.SummonList[i]) )))
			end
			if not tablefind(self.SummonListHide, self.SummonList[i]) then
				self.SummonHelperFrame.frame.Candidate["player"..i].text:SetText(self.SummonList[i])
				self.SummonHelperFrame.frame.Candidate["player"..i]:Show()
			end
		else
			self.SummonHelperFrame.frame.Candidate["player"..i].text:SetText("N/A")
			self.SummonHelperFrame.frame.Candidate["player"..i]:Hide()			end
		end
end
function SummonHelper:HideSummoningTarget(target)
	for i = 1, 5 do
		if self.SummonHelperFrame.frame.Candidate["player"..i].text:GetText()  == target then
			self:LevelDebug(2, format("HideSummoningTarget: %s", tostring(target)))
			self.SummonHelperFrame.frame.Candidate["player"..i]:Hide()
			table.insert(self.SummonListHide , target)
			break
		end
	end
end
function SummonHelper:ShowSummoningTarget(target)
	for i = 1, 5 do
		if self.SummonHelperFrame.frame.Candidate["player"..i].text:GetText()  == target then
			self:LevelDebug(2, format("ShowSummoningTarget: %s", tostring(target)))
			self.SummonHelperFrame.frame.Candidate["player"..i]:Show()
			targetPos = tablefind(self.SummonListHide, target)
			if targetPos then
				table.remove(self.SummonListHide, targetPos)
			end
			break
		end
	end
end

--function SummonHelper:autoSummon()
--	local timeStart = os.time()
--	while true do
--		if not endSpellStatus:IsCastingOrChanneling()  then
--			local target = SummonList[1]
--			if target then
--				self:SummonFonc(target)
--			elseif os.time() - timeStart > 60 * 5 then
--				break
--			end
--		end
--	end
--end

function SummonHelper:GetRaidIndex(name)
	local prefix = nil
	local NumMembers = GetNumRaidMembers()
	if NumMembers then
		prefix = "raid"
	else
		NumMembers = GetNumPartyMembers()
		prefix = "party"
	end
	for i = 1, NumMembers do
		if UnitName(prefix..i) == name then
			return prefix..i
		end
	end
end

function SummonHelper:GetUnitNameWithColors(name)
	local raidIndex = self:GetRaidIndex(name)
	local className, classFilename = UnitClass(raidIndex)
	local c = RAID_CLASS_COLORS[classFilename]
	local classhexe = string.format("%2x%2x%2x", c.r*255, c.g*255, c.b*255)
	local nameWithColors = string.format("|cFF%s%s|r",  classhexe, name)
	return nameWithColors
end