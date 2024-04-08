---
--- Documentation https://github.com/PluieYu/G_SummonHelper?tab=readme-ov-file
--- Created by Yu.
--- DateTime: 2024/3/14 21:25
---
--
local L = AceLibrary("AceLocale-2.2"):new("SummonHelper")
L:RegisterTranslations("enUS", function() return {
	["已加载"] = "loaded",
	["重置"] = "ResetPos",
	["重置拉人界面"] = "Reset frame position",
	["显示"]= "ShowFrame",
	["显示拉人界面"]= "Show SummonHelperFrame",
	["关键词"] = { 'Summon', 'summon' },
	["团队打字打关键词被拉到 %s"] = "write the key words |cffF5F54A['Summon']|r in raid to get summon to |cffF5F54A[%s]|r",
	["术士"] = "术士",
	["你正在战斗中"] = "You are in combat",
	["%s 在战斗中"] = " %s is in combat",
	["%s 已在身边"] = " %s is already here",

	["正在将%s拉到 %s"] = "Summoning |cffF5F54A[|r%s|cffF5F54A]|r to  |cffF5F54A[%s]|r please assistant",
	["正在召唤你倒 %s"] = "|cffF5F54A[%s]|r Ritual of Summoning start in 5sec",
	["召唤仪式遭到破坏"] = "Summoning failed",
	["召唤仪式已经启动"] = "Summoning on the way, waiting 2 players assistant ",
	["召唤仪式已经完成"] = "Summoning finish, Accept and come",
	font = "Fonts\\FRIZQT__.TTF"
} end)