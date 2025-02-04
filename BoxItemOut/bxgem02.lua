local t = {
bxgem02 = { false, true, {
	{ 0.5, true, { {"sklu001"}, {"sklu002"}, {"sklu005", 10000} } },
	{ 0.5, false, { { "ijccc01", 50 }, { "ijccc02", 50 }, { "ijccc03", 50 }, { "ijccc04", 50 }, } },
	{ 0.6, false, { { "iyyyy02", { 10, 40 } }, } },
	-- 1.0 - 0.6 = 0.4 40% of empty box. Empty box have no reward but box consumed.
}},
}

return t