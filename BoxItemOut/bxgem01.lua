--[[
example
multiline
comment

File structure:
t = {
boxcode1 = {
...
}, <- necessary comma between sections 
boxcode2 = {
...
}, <- optional trailing comma after last section
}
return t


Data structure:
boxcode1 = {
	isSameRaceDrop = false ; Type: bool. If true, then items of other race excluded from drop list.
	isAllowEmptyBox = false ; Type: bool. If true and no suitable drop found then box consumed else error send to client.
	boxOutList = { ; Type: table. List of all possible drop records.
		{ ; Drop group object
			dropRateUpperMargin = 0.1 ; Type: float. Possible values 1/32768 to 1.0 responsible for group drop rate
			multiDrop = false ; Type bool. Drop all items from group?
			dropGroupData = { ; Type table. Drop records array
				{ ; Drop item object
					itemCode = "iyyyy01" ; Type string. Item code.
					durability_or_upgrade = 1 ; Optional. Type: integer or string or table.
											; For stackable items - size of stack, for animus/force item - level, for armour/weapon - upgrade,
											; siege kit/ammo - durability.
											; If table then represents range for random choice. If missing - default value applied.
											; See examples below.
				}, ; necessary comma between table sections
				{
					... ; Next drop item object
				}, 	; trailing comma optional
			}
		},
		{
			... ; Next drop group object
		},
	}
},

-- function execution on box use example.
boxcode2 = function(pPlayer, pCon, pBoxItemFld) CPlayer, _STORAGE_LIST___db_con, _BoxItem_fld
	-- you are respoonsible to decrement box stack using pCon pointer
end,

--]]
local t = {
bxgem01 = { -- example single line comment
	false, false, {
		-- chance 10% (0.1 - 0 = 0.1). This is multiline drop, all items in this section will drop out.
		{ 0.1, true, { { "ihbwb65", { "5fffff55", "7f555555"} }, { "iubwb65", { "5fffff55", "7f555555"} }, { "ilbwb65", { "5fffff55", "7f555555"} }, { "igbwb65", { "5fffff55", "7f555555"} }, { "isbwb65", { "5fffff55", "7f555555"} },
		{ "ihcwb65", { "5fffff55", "7f555555"} }, { "iucwb65", { "5fffff55", "7f555555"} }, { "ilcwb65", { "5fffff55", "7f555555"} }, { "igcwb65", { "5fffff55", "7f555555"} }, { "iscwb65", { "5fffff55", "7f555555"} }, } },
		-- chance 40% (0.5 - 0.1 (nearest less before 0.5) = 0.4. 
		{ 0.5, false, { { "iwspb65", "3f" }, } }, -- fixed upgrade slots. 3f is shorten of 3fffffff
		-- If drop rate is same then it extends existing drop list like it was inone line : { { "iwspb65", "3f" }, { "iwspb55" }, }
		{ 0.5, false, { { "iwspb55" }, } }, -- random upgrade slots
		-- chance 50% (1.0 - 0.5) = 0.5
		{ 1.0, false, {
			{ "iyyyy01", 15 }, -- fixed amount
			{ "iyyyy02", { 15, 50 } }, -- random amount in given range
			{ "iyyyy03" }, -- default amount is 1
		} },
	}
},
}

return t