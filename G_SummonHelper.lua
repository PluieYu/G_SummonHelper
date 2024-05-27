---
--- Documentation https://github.com/PluieYu/G_SummonHelper?tab=readme-ov-file
--- Created by Yu.
--- DateTime: 2024/3/14 21:25
---
--

--main class--
SummonHelper = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0","AceModuleCore-2.0","AceComm-2.0","AceDB-2.0","AceDebug-2.0","AceConsole-2.0","FuBarPlugin-2.0")
local L = AceLibrary("AceLocale-2.2"):new("SummonHelper")
SpellStatus = AceLibrary("SpellStatus-1.0")
local BS = AceLibrary("Babble-Spell-2.2")

SummonHelper.hasIcon = "Interface\\Icons\\spell_shadow_twilight"
SummonHelper.Prefix =
"|cffF5F54A["..base64:dec("5bCP55qu566x").."]|r|cff9482C9"..base64:dec("5pyv5aOr5Yqp5omL").."|r"
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
	self.playerClass = UnitClass("player")
	self:SetDebugLevel(3)
	self.SummonList = {}
	self:RegisterDB("SummonHelperDB")
	self:RegisterDefaults("profile", {
		xOfs = 0,
		yOfs = 0,
		point = "center",
		relativePoint = "center",
	})
	self.opt = self.db.profile
	SHMain:OnInitialize()
	self.OnMenuRequest = SummonHelper.options
	self:SetCommPrefix(self.Prefix)
	self:RegisterChatCommand({"/smh", "/SummonHelper"}, SummonHelper.options)
	DEFAULT_CHAT_FRAME:AddMessage(buildMessage(L["已加载"]))
end

function SummonHelper:OnProfileEnable()
	self.opt = self.db.profile
end

function SummonHelper:OnEnable()
	if self.playerClass ~= L["术士"]then
		SummonHelper:OnDisable()
		return
	end

	self:RegisterComm(self.Prefix, "RAID")
	if not self:IsCommRegistered(self.Prefix,"RAID") then
		self:RegisterComm(self.Prefix, "RAID")
	end
	--Register PARTY-RAID-WHISPER chanel
	self:RegisterEvent("CHAT_MSG_PARTY", "CheckChatMessage")
	self:RegisterEvent("CHAT_MSG_PARTY_LEADER", "CheckChatMessage")

	self:RegisterEvent("CHAT_MSG_RAID", "CheckChatMessage")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER", "CheckChatMessage")
	self:RegisterEvent("CHAT_MSG_WHISPER", "CheckChatMessage")

	--self:RegisterEvent("SpellStatus_SpellCastCastingStart")
	self:RegisterEvent("SpellStatus_SpellCastFailure")
	--self:RegisterEvent("SpellStatus_SpellCastChannelingStart")
	self:RegisterEvent("SpellStatus_SpellCastChannelingFinish")
end
function SummonHelper:OnDisable()
	SummonHelper:UnregisterAllEvents()
	if SHMain.mf then
		SHMain.mf:Hide()
	end
end


function SummonHelper:CheckChatMessage(msg, name)
	local stringLen = string.len(self.Prefix)
	local SLLen = tLength(self.SummonList)
	if strsub(msg,0, stringLen) ~= self.Prefix then
		if tContain(self.SummonList, name) then
			SendChatMessage(buildMessage(L["你已在队列中" ], tostring(SLLen)), "WHISPER", nil, name)
		else
			for _, word in pairs(L["关键词"]) do
				index_stat, index_end = string.find(msg, word);
				if index_stat then
					addT(self.SummonList, name)
					SHMain:Flush()
					SendChatMessage(buildMessage(L["你已在队列中" ], tostring(SLLen)), "WHISPER", nil, name)
				end
			end
		end

	end
end
function SummonHelper:OnCommReceive(_, sender, _, method, target)
	--prefix, sender, distribution, method, target
	if target ~= nil and method ~= nil  and sender~="player"  then
		if method=="Add" then
			addT(self.SummonList, target)
		elseif method=="Remove" then
			removeT(self.SummonList, target)
		end
		SHMain:Flush()
		collectgarbage()
	end
end
function SummonHelper:AddFonc(name)
	if  tContain(self.SummonList, name) then
		return
	else
		addT(self.SummonList, name)
		SHMain:Flush()
		SummonHelper:SendCommMessage("RAID","Add", name )
	end
end
function SummonHelper:RemoveFonc(name)
	if tContain(self.SummonList, name) then
		removeT(SummonHelper.SummonList, name)
	end
	SHMain:Flush()
	SummonHelper:SendCommMessage("RAID","Remove", name )
end
function SummonHelper:SummonFonc(name)
	self:LevelDebug(2, format("SummonFoncButton has been Clicked on: %s", tostring(name)))
	local chatType = GetNumRaidMembers() > 0 and "RAID" or "PARTY"
	local unitId = getRaidIndex(name)
	local nameC = getUnitNameWithColors(name)
	local playerZone = GetZoneText()..GetSubZoneText()
	TargetUnit(unitId)
	if UnitAffectingCombat("player") then
		self:Print(L["你正在战斗中"])
	elseif UnitAffectingCombat(unitId) then
		SendChatMessage(buildMessage(L["%s 在战斗中"],nameC), chatType)
	elseif CheckInteractDistance("target", 4) then
		self:Print(buildMessage(L["%s 已在身边"], name))
		self:RemoveFonc(name)
	else
		--CastSpellByName(BS["Ritual of Summoning"])
		SpellStatus:CastSpellByName(BS["Ritual of Summoning"], false)
		SendChatMessage(buildMessage(L["正在将%s拉到 %s"],nameC, playerZone), chatType)
		SendChatMessage(buildMessage(L["正在召唤你倒 %s"], playerZone), "WHISPER", nil, name)
		self:RemoveFonc(name)
	end
end
--function SummonHelper:SpellStatus_SpellCastChannelingStart(_, name, _, _, _, _)
--	--id, name, fullName, startTime, stopTime, duration
--	if name == BS["Ritual of Summoning"] then
--		SendChatMessage(buildMessage(L["召唤仪式已经启动"]), "WHISPER", nil, SHMain.currentT)
--		--SummonHelper:RemoveFonc(SHMain.currentT)
--	end
--end
function SummonHelper:SpellStatus_SpellCastFailure(_, name, _, raison, _, _, _)
	--id, name, fullName, raison,raison2,raison3,raison4
	if name == BS["Ritual of Summoning"] then
		SendChatMessage(buildMessage(L["召唤仪式遭到破坏"]), "WHISPER", nil, SHMain.currentT)
		SummonHelper:AddFonc(SHMain.currentT)
	end
end
function SummonHelper:SpellStatus_SpellCastChannelingFinish(_, name, _, raison)
	--id, name, fullName, raison
	if name == BS["Ritual of Summoning"] then
		SendChatMessage(buildMessage(L["召唤仪式已经完成"]), "WHISPER", nil, SHMain.currentT)
	end
end
function buildMessage(TEXT, args1, args2 )
	local subMsg
	if args2 then
		subMsg = format(TEXT, args1, args2)
	elseif args1 then
		subMsg = format(TEXT, args1)
	else
		subMsg = TEXT
	end
	return format("%s %s", SummonHelper.Prefix, subMsg)
end
function getUnitNameWithColors(name)
	local raidIndex = getRaidIndex(name)
	--local UnitId = getUnitId(name)
	local _, classFilename = UnitClass(raidIndex)
	local c = RAID_CLASS_COLORS[classFilename]
	local classhexe = string.format("%2x%2x%2x", c.r*255, c.g*255, c.b*255)
	local nameWithColors = string.format("|cFF%s%s|r",  classhexe, name)
	return nameWithColors
end
function getRaidIndex(name)
	local prefix
	local NumMembers = GetNumRaidMembers()
	if NumMembers then
		prefix = "raid"
		NumMembers = 40
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
function addT(t, target)
	local tLen = tLength(t)
	table.insert(t,tLen + 1, target)
end
function removeT(t, target)
	local p = tPos(t, target)
	if p then
		table.remove(t, p)
	end
end
function tPos(t, target)
	for i, v in ipairs(t) do
		if v == target then
			return i
		end
	end
end
function tLength(table)
	local size = 0
	if  table then
		for i, v in pairs(table) do
			size = size + 1
		end
	end
	return size;
end
function tContain(t, target)
	for _, v in ipairs(t) do
		if v == target then
			return true
		end
	end
end