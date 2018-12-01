dofile("ZZHousingInventory.lua")
COLL = ZZHousingInventoryVars.Default["@ziggr"]["$AccountWide"].coll

    -- coll_id is_furn is_house is_purch  name  desc
template = ", { collectible_id=%4d, is_purchasable=%-5s is_house=%-5s, name=%-40s }"
for coll_id = 1,6000 do
    data = COLL[coll_id]
    if data then
        msg = template:format(
              coll_id
            , tostring(data.is_purchasable        )
            , tostring(data.is_house              )
            , '"'..data.name..'"'
            )
        print(msg)
    end
end

