dofile("data/ZZHousingInventory.lua")

account_wide = ZZHousingInventoryVars.Default["@ziggr"]["$AccountWide"]

reported = {}

FIELD_LIST = {
    "value_mm_gold"
,   "value_att_gold"
,   "value_ttc_gold"
,   "value_furc_gold"
,   "value_furc_crowns"
,   "value_furc_vouchers"
,   "value_coll_gold"
,   "value_coll_crowns"
,   "value_rolis_vouchers"
,   "value_crowns"
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

function report_priceless(container_key, index, furn)
    if furn.item_id then
        if reported[furn.item_id] then return end
        reported[furn.item_id] = 1
    end
    print(string.format("%s [%s]: %s"
            , container_key
            , tostring(index)
            , furn.item_name or furn.collectible_name or "?"
            ))
end

function price(container_key, index, furn)
    for _,field_name in ipairs(FIELD_LIST) do
        if furn[field_name] then
            return furn[field_name], field_name
        end
    end
    -- report_priceless(container_key, index, furn)
end

function curr(p,field_name)
    if not p then return end
    if field_name:find("gold") then
        return { gold = p }
    elseif field_name:find("crown") then
        return { crowns = p }
    elseif field_name:find("voucher") then
        return { vouchers = p }
    end
end

function cell(c)
    if c then return tostring(c) else return "" end
end

function row(container_key, index, furn)
    local p, field_name = price(container_key, index, furn)
    local t = curr(p, field_name)

    local total = {}
    for _,fldnm in ipairs({"gold", "crowns", "vouchers"}) do
        if t and t[fldnm] then
            total[fldnm] = (furn.item_ct or 1) * t[fldnm]
        end
    end

    local cells = {
            cell(container_key)
        ,   cell(index)
        ,   cell(furn.item_ct or 1)
        ,   cell(t and t.gold)
        ,   cell(t and t.crowns)
        ,   cell(t and t.vouchers)
        ,   cell(furn.item_name or furn.collectible_name)
        ,   cell(total.gold)
        ,   cell(total.crowns)
        ,   cell(total.vouchers)
        }
    local row_str = table.concat(cells, "\t")
    print(row_str)
end

function header()
    local cells = {
            "container"
        ,   "index"
        ,   "ct"
        ,   "gold"
        ,   "crowns"
        ,   "vouchers"
        ,   "name"
        ,   "total gold"
        ,   "total crowns"
        ,   "total vouchers"
        }
    local row_str = table.concat(cells, "\t")
    print("# "..row_str)
end

-- TOTAL = { gold = 0, crowns = 0, vouchers = 0 }

function sorted_keys(t)
    local kk = {}
    for k,_ in pairs(t) do table.insert(kk,k) end
    table.sort(kk)
    return kk
end

header()
source_keys = sorted_keys(account_wide)
for _,k in ipairs(source_keys) do
    furn_list = account_wide[k]
    if k == "collectible" then
        keys = sorted_keys(furn_list)
        for _,collectible_id in ipairs(keys) do
            furn = furn_list[collectible_id]
            row(k,collectible_id,furn)
        end
    elseif k:lower():find("house ") or k:lower():find("bag ") then
        for i,furn in ipairs(furn_list) do
            row(k,i,furn)
        end
    end
end

-- print(string.format( "Total gold:%d  crowns:%d  vouchers:%d"
--                    , TOTAL.gold, TOTAL.crowns, TOTAL.vouchers
--                    ))
