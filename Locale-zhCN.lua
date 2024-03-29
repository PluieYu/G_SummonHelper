---
--- Documentation https://github.com/PluieYu/G_SummonHelper?tab=readme-ov-file
--- Created by Yu.
--- DateTime: 2024/3/14 21:25
---
--
local L = AceLibrary("AceLocale-2.2"):new("SummonHelper")
L:RegisterTranslations("zhCN", function() return {
	["已加载"] = "已加载",
	["重置"] = "重置",
	["重置拉人界面"] = "重置拉人界面",
	["显示"]= "显示",
	["显示拉人界面"]= "显示拉人界面",
	["关键词"] = { "求拉", "求啦" },
	["团队打字打关键词被拉到 %s"] = "团队打字|cffF5F54A['求拉']|r即可被召唤到 |cffF5F54A[%s]|r",
	["你正在战斗中"] = "你正在战斗中",
	["%s 在战斗中"] = " %s 正在战斗中",
	["%s 已在身边"] = " %s 已经在身边",
	["正在将%s拉到 %s"] = "正在将 |cffF5F54A[|r%s|cffF5F54A]|r 拖拽到 |cffF5F54A[%s]|r 需要两个好心人帮忙点门",
	["正在召唤你倒 %s"] = "|cffF5F54A[%s]|r 的召唤仪式5秒后启动 请耐心等待",
	["召唤仪式遭到破坏"] = "召唤仪式遭到破坏 请耐心等待后继续召唤",
	["召唤仪式已经启动"] = "召唤仪式已经启动 等待周围队友点门 请开麦催促",
	["召唤仪式已经完成"] = "召唤仪式已经完成 麻溜的点确认过来 若1分钟后没有确认 回复'求拉'继续",
	font = "Fonts\\FRIZQT__.TTF"
} end)

