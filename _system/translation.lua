local function init()
	local assetTranslation = Sirin.CTranslationAsset.instance()
	-- t.default = "" -- Mandatory
	-- t.strKR = "" -- Korean
	-- t.strBR = "" -- Portuguese (Brazil)
	-- t.strCN = "" -- Chinese (Simplified)
	-- t.strGB = "" -- British English
	-- t.strID = "" -- Indonesian
	-- t.strJP = "" -- Japanese
	-- t.strPH = "" -- Filipino
	-- t.strRU = "" -- Russian
	-- t.strTW = "" -- Chinese (Traditional)
	-- t.strUS = "" -- US English
	-- t.strTH = "" -- Thai
	do
		local t = {}
		t.default = "day(s)"
		assetTranslation:loadTranslationTable("guard.msg.time_interval.days", t)
	end
	do
		local t = {}
		t.default = "hour(s)"
		assetTranslation:loadTranslationTable("guard.msg.time_interval.hours", t)
	end
	do
		local t = {}
		t.default = "minute(s)"
		assetTranslation:loadTranslationTable("guard.msg.time_interval.minutes", t)
	end
	do
		local t = {}
		t.default = "second(s)"
		assetTranslation:loadTranslationTable("guard.msg.time_interval.seconds", t)
	end
	do
		local t = {}
		t.default = "%d Race currency obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.dalant", t)
	end
	do
		local t = {}
		t.default = "%d Gold obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.gold", t)
	end
	do
		local t = {}
		t.default = "%d PvPCash point obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.pvp_cash", t)
	end
	do
		local t = {}
		t.default = "%d CP obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.cpt", t)
	end
	do
		local t = {}
		t.default = "%d Cash obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.cash_coin", t)
	end
	do
		local t = {}
		t.default = "%s of Premium service obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.premium", t)
	end
	do
		local t = {}
		t.default = "%d Processing point obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.proc_point", t)
	end
	do
		local t = {}
		t.default = "%d Hunting point obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.hunt_point", t)
	end
	do
		local t = {}
		t.default = "%d Gold point obtained"
		assetTranslation:loadTranslationTable("guard.msg.item_add.gold_point", t)
	end
	do
		local t = {}
		t.default = "Can't use this function. Too far from NPC."
		assetTranslation:loadTranslationTable("guard.msg.error.not_near_npc", t)
	end
	do
		local t = {}
		t.default = "Script format error."
		assetTranslation:loadTranslationTable("guard.msg.error.script_format", t)
	end
	do
		local t = {}
		t.default = "Script execution error."
		assetTranslation:loadTranslationTable("guard.msg.error.script_exec", t)
	end
	do
		local t = {}
		t.default = "Unknown error message (%d)"
		assetTranslation:loadTranslationTable("guard.msg.error.unk_msg", t)
	end
	do
		local t = {}
		t.default = "Your level does not meet the requirements."
		assetTranslation:loadTranslationTable("guard.msg.error.req_level", t)
	end
	do
		local t = {}
		t.default = "Your pvp rank does not meet the requirements."
		assetTranslation:loadTranslationTable("guard.msg.error.req_pvp_rank", t)
	end
	do
		local t = {}
		t.default = "You need to be in a Patriarch group to meet the requirements."
		assetTranslation:loadTranslationTable("guard.msg.error.req_archon_group", t)
	end
	do
		local t = {}
		t.default = "Your race does not meet the requirements."
		assetTranslation:loadTranslationTable("guard.msg.error.req_race", t)
	end
	do
		local t = {}
		t.default = "Your equipment does not meet the requirements."
		assetTranslation:loadTranslationTable("guard.msg.error.req_equip", t)
	end
	do
		local t = {}
		t.default = "You dont have required item(s) or amount not enough."
		assetTranslation:loadTranslationTable("guard.msg.error.req_item", t)
	end
	do
		local t = {}
		t.default = "You dont have required effect(s) or effect value does not meet the requirements."
		assetTranslation:loadTranslationTable("guard.msg.error.req_eff_have", t)
	end
	do
		local t = {}
		t.default = "You dont have enough race currency."
		assetTranslation:loadTranslationTable("guard.msg.error.req_dalant", t)
	end
	do
		local t = {}
		t.default = "You dont have enough gold currency."
		assetTranslation:loadTranslationTable("guard.msg.error.req_gold", t)
	end
	do
		local t = {}
		t.default = "You dont have enough processing points."
		assetTranslation:loadTranslationTable("guard.msg.error.req_actp_proc", t)
	end
	do
		local t = {}
		t.default = "You dont have enough hunting points."
		assetTranslation:loadTranslationTable("guard.msg.error.req_actp_hunt", t)
	end
	do
		local t = {}
		t.default = "You dont have enough golden points."
		assetTranslation:loadTranslationTable("guard.msg.error.req_actp_gold", t)
	end
	do
		local t = {}
		t.default = "You dont have enough pvp cash."
		assetTranslation:loadTranslationTable("guard.msg.error.req_pvp_cash", t)
	end
	do
		local t = {}
		t.default = "You dont have enough contribution points."
		assetTranslation:loadTranslationTable("guard.msg.error.req_cpt", t)
	end
	do
		local t = {}
		t.default = "You need to be a premium user to use this function."
		assetTranslation:loadTranslationTable("guard.msg.error.req_premium", t)
	end
	do
		local t = {}
		t.default = "%d Race currency consumed"
		assetTranslation:loadTranslationTable("guard.msg.item_sub.dalant", t)
	end
	do
		local t = {}
		t.default = "%d Gold consumed"
		assetTranslation:loadTranslationTable("guard.msg.item_sub.gold", t)
	end
	do
		local t = {}
		t.default = "%d PvPCash point consumed"
		assetTranslation:loadTranslationTable("guard.msg.item_sub.pvp_cash", t)
	end
	do
		local t = {}
		t.default = "%d CP consumed"
		assetTranslation:loadTranslationTable("guard.msg.item_sub.cpt", t)
	end
	do
		local t = {}
		t.default = "%d Processing point consumed"
		assetTranslation:loadTranslationTable("guard.msg.item_sub.proc_point", t)
	end
	do
		local t = {}
		t.default = "%d Hunting point consumed"
		assetTranslation:loadTranslationTable("guard.msg.item_sub.hunt_point", t)
	end
	do
		local t = {}
		t.default = "%d Gold point consumed"
		assetTranslation:loadTranslationTable("guard.msg.item_sub.gold_point", t)
	end
	do
		local t = {}
		t.default = "[%s] has appeared in [%s]"
		assetTranslation:loadTranslationTable("guard.msg.monster.create", t)
	end
	do
		local t = {}
		t.default = "Player [%s] has finished [%s] in [%s]"
		assetTranslation:loadTranslationTable("guard.msg.monster.destroy_by", t)
	end
	do
		local t = {}
		t.default = "[%s] was killed in [%s]"
		assetTranslation:loadTranslationTable("guard.msg.monster.destroy", t)
	end
	do
		local t = {}
		t.default = "Skin"
		assetTranslation:loadTranslationTable("guard.ui.tooltip.skin", t)
	end
	do
		local t = {}
		t.default = "Success rate: %.3f%%"
		assetTranslation:loadTranslationTable("guard.ui.upgradeUI.succ_rate", t)
	end
end

init()
