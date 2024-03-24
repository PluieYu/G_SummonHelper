
local L = AceLibrary("AceLocale-2.2"):new("SummonHelper")
L:RegisterTranslations("enUS", function() return {
	["SummonHelperFrame"] = '小皮箱术士拉人助手',
	["ResetPos"] = "重置位置",
	["Reset frame position."] = "重置拉人界面",
	["ShowFrame"]= "显示",
	["Show SummonHelper Frame"]= "显示拉人界面",

	["key words"] = { '求拉', '求啦' },
	["Say key words to get Summon  to %s"] = "<小皮箱术士拉人助手> 团队打字'求拉'即可被召唤到 >-%s-<",

	["You are in combat"] = '你正在战斗中',
	["%s is in combat"] = ' %s 正在战斗中',
	["%s is already here"] = ' %s 已经在身边',
	["Summoning %s to %s Please assist summoning"] = "<小皮箱术士拉人助手> 正在将 |cffF5F54A[|r%s|cffF5F54A]|r 拖拽到 |cffF5F54A[%s]|r 周围的队友麻溜的点门",
	["Summoning you to %s"] =  "<小皮箱术士拉人助手> <-%s-> 的召唤仪式5秒后启动 请耐心等待",
	["Summoning failed"] =     "<小皮箱术士拉人助手> 召唤仪式遭到破坏 请耐心等待后继续召唤",
	["Summoning on the way"] = "<小皮箱术士拉人助手> 召唤仪式已经启动 等待周围队友点门 请开麦催促点门",
	["Summoning finish"] =     "<小皮箱术士拉人助手> 召唤仪式已经完成 麻溜的点确认过来 若1分钟后没有确认 回复'求拉'继续",
	font = "Fonts\\FRIZQT__.TTF"
} end)