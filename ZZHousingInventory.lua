ZZHousingInventory = ZZHousingInventory or {}
ZZHousingInventory.name            = "ZZHousingInventory"
ZZHousingInventory.savedVarVersion = 1
ZZHousingInventory.default = {
}


local function Error(msg, ...)
    d("|cFF6666ZZHousingInventory: "..string.format(msg, ...))
end

local function Info(msg, ...)
    d("|c999999ZZHousingInventory: "..string.format(msg, ...))
end

-- New 2018 schema -----------------------------------------------------------

-- Row -----------------------------------------------------------------------
--
-- A stack of one or more idendical items within a single container.
--
-- Yes, fill in multiple fields whenever available. List ALL the prices from
-- ALL the sources. If an item is purchaseable by gold or vouchers, list BOTH.
-- Retain as much data as possible. You can filter it down later.
--
-- And skip all the adding/multiplying/total work here. Just get the inventory
-- out and we can combine and tally later.
--
local Row = {}
function Row:New()
    local o = { container           = nil
              , item_id             = nil
              , item_name           = nil
              , item_link           = nil
              , item_ct             = nil
           -- , furniture_id        = nil  DO NOT STORE THIS, it's a uint64id that does not serialize without additional string work.
              , furniture_data_id   = nil
              , collectible_link    = nil
              , collectible_name    = nil
              , collectible_desc    = nil
              , value_mm_gold       = nil   -- mm.avgPrice
              , value_att_gold      = nil   -- att.avgPrice
              , value_ttc_gold      = nil   -- ttc.Avg
              , value_furc_gold     = nil   -- furc.currency_ct
              , value_furc_crowns   = nil
              , value_furc_vouchers = nil
              , value_furc_ap       = nil
              , value_furc_desc     = nil
              , value_coll_gold     = nil
              , value_coll_crowns   = nil
              }
    setmetatable(o, self)
    self.__index = self
    return o
end

                        -- Placed furniture while inside the house that it's
                        -- placed in.
function Row:CreateFromFurnitureId(furniture_id, count_collectibles)
    local row = Row:New()
    row.container           = ZZHousingInventory.HouseKey()
    -- row.furniture_id        = furniture_id

    local r = { GetPlacedHousingFurnitureInfo(furniture_id) }
    row.item_name           = r[1]
    row.furniture_data_id   = r[3]
    r = { GetPlacedFurnitureLink(furniture_id, LINK_STYLE_DEFAULT) }
    local collectible_id    = ZZHousingInventory.CollectibleLinkToCollectibleID(r[2])
    row.item_link           = r[1]
    row.collectible_link    = r[2]

    row.item_id             = ZZHousingInventory.ItemLinkToItemID(row.item_link)
    row.item_name           = GetItemLinkName(row.item_link)
    row.item_ct             = 1

    row:AddCollectibleData(collectible_id)
    row:AddPriceData()
    row:RemoveEmptyStringValues()
    return row
end

                        -- Return a row that shows how much it cost to
                        -- purchase this house.
function Row:CreateHouseRow(house_id)
    local row = Row:New()
    local coll_id        = GetCollectibleIdForHouse(house_id)
    row.container        = ZZHousingInventory.HouseKey(house_id)
    row.house_id         = house_id

    -- local house_data = ZZHousingInventory.HOUSE[house_id]
    -- if house_data then
    --     row.value_house_gold   = house_data.gold
    --     row.value_house_crowns = house_data.crowns
    -- end

    row:AddCollectibleData(coll_id)
    return row
end

                        -- Items, including furniture and non-furniture,
                        -- within a housing storage coffer (aka "bag")
function Row:CreateFromBag(bag_id, slot_id)
    local row               = Row:New()
    row.item_name           = GetItemName(bag_id, slot_id)
    row.item_link           = GetItemLink(bag_id, slot_id)
    row.item_id             = ZZHousingInventory.ItemLinkToItemID(row.item_link)
    local r                 = { GetItemInfo(bag_id, slot_id) }
    row.item_ct             = r[2]
    row.furniture_data_id   = GetItemFurnitureDataId(bag_id, slot_id)
    row:AddPriceData()
    row:RemoveEmptyStringValues()
    return row
end

function Row:AddCollectibleData(collectible_id)
    if not collectible_id then return nil end
    local coll_data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(collectible_id)
    local coll_info = { GetCollectibleInfo(collectible_id) }

    self.collectible_id   = collectible_id
    self.collectible_link = ZZHousingInventory.CollectibleIDToCollectibleLink(collectible_id)
    self.collectible_name = coll_data:GetFormattedName()
    self.collectible_desc = coll_info[2]

                        -- If this is a collectible housing storage container,
                        -- record its own bag_key, just to help Zig navigate
                        -- SavedVariables.
    local bag_id = GetCollectibleBankAccessBag(collectible_id)
    self.collectible_bag_key = ZZHousingInventory.BagKey(bag_id)

                        -- Record cost, if any.
    local c = ZZHousingInventory.CollectibleData(collectible_id)
    if c then
        self.value_coll_gold   = c.gold
        self.value_coll_crowns = c.crowns
    end
end

function Row:AddPriceData()
                        -- I BET THIS WON'T WORK FOR bankers and
                        -- mounts and chickens.
    local price = LibPrice.ItemLinkToPriceData(self.item_link)
    if price.mm then
        self.value_mm_gold   = price.mm.avgPrice
    end
    if price.att then
        self.value_att_gold  = price.att.avgPrice
    end
    if price.furc then
        if not Row.FURC_TO_FIELD then
            Row.FURC_TO_FIELD = {
              ["gold"    ] = "value_furc_gold"
            , ["vouchers"] = "value_furc_vouchers"
            , ["crowns"  ] = "value_furc_crowns"
            , ["ap"      ] = "value_furc_ap"
            }
        end
        local field_name = Row.FURC_TO_FIELD[price.furc.currency_type]
        if field_name then
            self[field_name] = price.furc.currency_ct
        end
        self.value_furc_desc = price.furc.desc
        if price.furc.ingredient_list then
            self.value_furc_ingr = {}
            local template = "%1.1f = %dx%1.1f %s from %s.%s"
            for _,v in ipairs(price.furc.ingredient_list) do
                local total = 0
                if v.ingr_gold_ea then total = v.ingr_gold_ea * v.ingr_ct end
                local s = template:format( total
                                         , v.ingr_ct or 0
                                         , v.ingr_gold_ea or 0
                                         , v.ingr_name
                                         , v.ingr_gold_source_key
                                         , v.ingr_gold_field_name
                                         )
                table.insert(self.value_furc_ingr, s)
            end
        end
    end
end

function Row:RemoveEmptyStringValues()
                        -- Convert any empty strings to nil
                        -- to significantly reduce the size of SavedVariables
    local key_list = {}
    for k,v in pairs(self) do
        if v == "" then table.insert(key_list,k) end
    end
    for _,k in ipairs(key_list) do
        self[k] = nil
    end
end


-- ZZHousingInventory --------------------------------------------------------

function ZZHousingInventory.HouseKey()
    local house_id = GetCurrentZoneHouseId()
    if not (house_id and 0 < house_id) then
        Error("not in a house. Exiting.")
        return nil
    end
    return string.format("House %d", house_id)
end

function ZZHousingInventory.BagKey(bag_id)
    if not bag_id then return nil end
    return string.format("bag %d", bag_id)
end

-- copied from Dolgubon's LibLazyCrafting functions.lua.
-- Isn't there an official ZOS copy of this now?
function ZZHousingInventory.ItemLinkToItemID(item_link)
    return tonumber(string.match(item_link,"|H%d:item:(%d+)"))
end

function ZZHousingInventory.CollectibleLinkToCollectibleID(collectible_link)
    return tonumber(string.match(collectible_link,"|H%d:collectible:(%d+)"))
end

function ZZHousingInventory.ItemIDToItemLink(item_id)
                        -- I have no idea what the non-zero numbers here
                        -- mean, not sure they even matter.
    local template = "|H0:item:%d:24:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    return string.format(template, item_id)
end

function ZZHousingInventory.CollectibleIDToCollectibleLink(collectible_id)
    local template = "|H0:collectible:%d|h|h"
    return string.format(template, collectible_id)
end

function ZZHousingInventory.CollectibleData(collectible_id)
    for _,c in ipairs(ZZHousingInventory.COLLECTIBLES) do
        if c.collectible_id == collectible_id then
            return c
        end
    end
    return nil
end


-- Fetch Inventory Data from the server ------------------------------------------

                        -- Iterator/generator for all placed furnishings.
function ZZHousingInventory.EachFurniture()
    local furniture_id = nil
    local function next()
        furniture_id = GetNextPlacedHousingFurnitureId(furniture_id)
        return furniture_id
    end
    return next
end

function ZZHousingInventory.ScanNow()
    local self = ZZHousingInventory
    local house_key = self.HouseKey()
    if not house_key then return end
                        -- Start with a clear furniture list every time.
                        -- That way we don't have to deal with merging new
                        -- and old, or detecting removed furniture.
    self.saved_vars[house_key] = {}
    local rows      = self.saved_vars[house_key]
                        -- First row is always the house's own row, to
                        -- reflect the purchase price of the real estate.
    local house_id  = GetCurrentZoneHouseId()
    local house_row = Row:CreateHouseRow(house_id)
    table.insert(rows, house_row)
                        -- Add one row for each furnishing in the house.
    local loop_limit    = 1000 -- avoid infinite loops in case GNPHFI() surprises us
    for furniture_id in self.EachFurniture() do
        local row = Row:CreateFromFurnitureId(furniture_id)
        if row.collectible_id then
                        -- Collectibles go into their own special hash map,
                        -- since they are unique by collectible_id, but NOT
                        -- unique by house: you can place Tythis the Banker
                        -- in each house if you like. Don't want to count
                        -- Tythis' 5000-crown purchase price multiple times,
                        -- just once.
            self.saved_vars.collectible = self.saved_vars.collectible or {}
            self.saved_vars.collectible[row.collectible_id] = row
        else
                        -- Normal furniture goes in this house's table.
            table.insert(rows, row)
        end
        loop_limit = loop_limit - 1
        if loop_limit <= 0 then
            Error("Infinite loop in ScanNow().")
            break
        end
    end

                        -- Scan housing storage, too. But only for primary
                        -- house. No point in repeating this loop in other
                        -- houses to get the exact same data.
    local is_primary = IsPrimaryHouse(house_id)
-- is_primary = true -- TEMP HACK so that I can test containers in Old Mistveil Manor instead of The Craftorium
    if is_primary then
        local empty_bank_seen_ct = 0
        for bag_id = BAG_HOUSE_BANK_ONE,BAG_HOUSE_BANK_TEN do
            local bag_item_ct = self:ScanBag(bag_id)
            if bag_item_ct == 0 then
                empty_bank_seen_ct = empty_bank_seen_ct + 1
            end
        end
        if 2 < empty_bank_seen_ct then
            Info("Counted no items from %d housing storage containers."
                .."Perhaps you need to open them first?", empty_bank_seen_ct)
        end
    end

    --                     -- TEMP data mine
    self.saved_vars.house = nil
    -- self.saved_vars.house = self.saved_vars.house or {}
    -- for _,h in ipairs(ZZHousingInventory.HOUSE) do
    --     local coll_id = GetCollectibleIdForHouse(h.house_id)
    --     self.saved_vars.house[h.house_id] = { collectible_id = coll_id }
    -- end
    --
    self.saved_vars.coll = nil
    -- self.saved_vars.coll = {}
    -- for coll_id = 1,6000 do
    --     local data = ZO_COLLECTIBLE_DATA_MANAGER:GetCollectibleDataById(coll_id)
    --     if data and (data:IsPlaceableFurniture() or data:IsHouse()) then
    --         self.saved_vars.coll[coll_id] =
    --                     { name           = data:GetFormattedName()
    --                     , desc           = data:GetDescription()
    --                     , is_purchasable = data:IsPurchasable()
    --                     , is_house       = data:IsHouse()
    --                     , is_placeable_furniture = data:IsPlaceableFurniture()
    --                     , is_owned       = data:IsOwned()
    --                     }
    --     end
    -- end
end

                        -- Scan a housing storage container.
                        -- Return number of items seen within.
function ZZHousingInventory:ScanBag(bag_id)
    local bag_key = self.BagKey(bag_id)
    self.saved_vars[bag_key] = {}
    local bag_rows    = self.saved_vars[bag_key]
    local bag_item_ct = 0
    local slot_ct     = GetBagSize(bag_id)
    for slot_id = 1, slot_ct do
        local row = Row:CreateFromBag(bag_id, slot_id)
        if row.item_id or row.collectible_id then
            table.insert(bag_rows, row)
            bag_item_ct = bag_item_ct + 1
        end
    end
    return bag_item_ct
end


-- Init ----------------------------------------------------------------------

function ZZHousingInventory.OnAddOnLoaded(event, addonName)
    if addonName ~= ZZHousingInventory.name then return end
    local self = ZZHousingInventory
    self.saved_vars = ZO_SavedVars:NewAccountWide(
                              "ZZHousingInventoryVars"
                            , self.savedVarVersion
                            , nil
                            , self.default
                            )
end

EVENT_MANAGER:RegisterForEvent( ZZHousingInventory.name
                              , EVENT_ADD_ON_LOADED
                              , ZZHousingInventory.OnAddOnLoaded
                              )

SLASH_COMMANDS["/zhou"] = function() ZZHousingInventory.ScanNow() end
