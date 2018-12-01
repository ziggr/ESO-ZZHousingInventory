dofile("data/ZZHousingInventory.lua")

account_wide = ZZHousingInventoryVars.Default["@ziggr"]["$AccountWide"]

reported = {}

FIELD_LIST = {
    "value_mm_gold"
,   "value_att_gold"
,   "value_ttc_gold"
,   "value_furc_gold"
,   "value_coll_gold"
,   "value_coll_crowns"
}
function check(container_key, index, furn)
    if furn.item_id then
        if reported[furn.item_id] then return end
        reported[furn.item_id] = 1
    end

    for _,field_name in ipairs(FIELD_LIST) do
        if furn[field_name] then return true end
    end
    print(string.format("%s [%s]: %s"
            , container_key
            , tostring(index)
            , furn.item_name or furn.collectible_name or "?"
            ))
end

for k,furn_list in pairs(account_wide) do
    if k == "collectible" then
        for collectible_id, furn in pairs(furn_list) do
            check(k,collectible_id,furn)
        end
    elseif k:lower():find("house ") or k:lower():find("bag ") then
        for i,furn in ipairs(furn_list) do
            check(k,i,furn)
        end
    end
end

