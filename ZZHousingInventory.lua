local ZZHousingInventory = {}
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

-- GetCurrentZoneHouseId() constants that I cannot find defined yet
local COLOSSAL_ALDMERI_GROTTO = COLOSSAL_ALDMERI_GROTTO or 60

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
              , value_mm_gold       = nil
              , value_att_gold      = nil
              , value_ttc_gold      = nil
              , value_furc_gold     = nil
              , value_furc_crowns   = nil
              , value_furc_vouchers = nil
              , value_furc_ap       = nil
              , value_furc_desc     = nil
              }
    setmetatable(o, self)
    self.__index = self
    return o
end

                        -- Placed furniture while inside the house that it's
                        -- placed in.
function Row:FromFurnitureId(furniture_id, count_collectibles)
    local row = Row:New()
    row.container           = ZZHousingInventory.HouseKey()
    -- row.furniture_id        = furniture_id

    local r = { GetPlacedHousingFurnitureInfo(furniture_id) }
    row.item_name           = r[1]
    row.furniture_data_id   = r[3]

    r = { GetPlacedFurnitureLink(furniture_id, LINK_STYLE_DEFAULT) }
    row.item_link           = r[1]
    row.collectible_link    = r[2]
    row.item_id             = ZZHousingInventory.ItemLinkToItemID(row.item_link)
    row.item_name           = GetItemLinkName(row.item_link)
    row.item_ct             = 1

    r = { GetCollectibleInfo(row.collectible_id) }
    row.collectible_name    = r[1]
    row.collectible_desc    = r[2]

    row:FetchPrice()
    row:StringToNil()
    return row
end

                        -- Items, including furniture and non-furniture,
                        -- within a housing storage coffer (aka "bag")
function Row:FromBag(bag_id, slot_id)
    local row               = Row:New()
    row.item_name           = GetItemName(bag_id, slot_id)
    row.item_link           = GetItemLink(bag_id, slot_id)
    row.item_id             = ZZHousingInventory.ItemLinkToItemID(row.item_link)
    local r                 = { GetItemInfo(bag_id, slot_id) }
    row.item_ct             = r[2]
    row.furniture_data_id   = GetItemFurnitureDataId(bag_id, slot_id)
    row:FetchPrice()
    row:StringToNil()
    return row
end

function Row:FetchPrice()
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
    end
end

function Row:StringToNil()
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
    return string.format("bag %d", bag_id)
end

-- copied from Dolgubon's LibLazyCrafting functions.lua.
-- Isn't there an official ZOS copy of this now?
function ZZHousingInventory.ItemLinkToItemID(item_link)
    return tonumber(string.match(item_link,"|H%d:item:(%d+)"))
end

function ZZHousingInventory.ItemIDToItemLink(item_id)
                        -- I have no idea what the non-zero numbers here
                        -- mean, not sure they even matter.
    local template = "|H0:item:%d:24:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    return string.format(template, item_id)
end




-- HouseID -------------------------------------------------------------------
local HOUSE = {
                        -- all prices are for UNFURNISHED, even if we bought
                        -- the home furnished,  so that we can still
                        -- count the furnishings without double-counting.
  MARAS_KISS                    = { id =  1, cost = {gold =       0, crowns =   nil } }
, ROSY_LION                     = { id =  2, cost = {gold =       0, crowns =   nil } }
, EBONY_FLASK                   = { id =  3, cost = {gold =       0, crowns =   nil } }
, SAINT_DELYN_PENTHOUSE         = { id = 42, cost = {gold =       0, crowns =   nil } }
, KRAGENHOME                    = { id = 19, cost = {gold =   69000, crowns =   nil } }
, AUTUMNS_GATE                  = { id = 28, cost = {gold =   60000, crowns =   nil } }
, GRYMHEARTHS_WOE               = { id = 29, cost = {gold =  280000, crowns =   nil } }
, MATHIISEN_MANOR               = { id =  9, cost = {gold = 1025000, crowns =   nil } }
, OLD_MISTVEIL_MANOR            = { id = 30, cost = {gold = 1020000, crowns =   nil } }
, LINCHAL_MANOR                 = { id = 46, cost = {gold =     nil, crowns = 14000 } }
, COLDHARBOUR_SURREAL_ESTATE    = { id = 47, cost = {gold = 1000000, crowns =   nil } }
, ERSTWHILE_SANCTUARY           = { id = 56, cost = {gold =     nil, crowns = 13000 } }
, COLOSSAL_ALDMERI_GROTTO       = { id = 60, cost = {gold =     nil, crowns = 15000 } }
}

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

    -- local is_primary = house_id == GetHousingPrimaryHouse()

    self.saved_vars[house_key] = {}
    local rows          = self.saved_vars[house_key]
    local loop_limit    = 1000 -- avoid infinite loops in case GNPHFI() surprises us
    for furniture_id in self.EachFurniture() do
        local row = Row:FromFurnitureId(furniture_id)
        table.insert(rows, row)
        loop_limit = loop_limit - 1
        if loop_limit <= 0 then
            Error("Infinite loop in ScanNow().")
            break
        end
    end

                        -- Scan housing storage, too. But only for primary
                        -- house. No point in repeating this loop in other
                        -- houses to get the exact same data.
    if is_primary then
        local empty_bank_seen_ct = 0
        for bag_id = BAG_HOUSE_BANK_ONE,BAG_HOUSE_BANK_TEN do
            local bag_key = self.BagKey(bag_id)
            self.saved_vars[bag_key] = {}
            local bag_rows    = self.saved_vars[bag_key]
            local bag_item_ct = 0
            local slot_ct     = GetBagSize(bag_id)
            for slot_id = 1, slot_ct do
                local row = Row:FromBag(bag_id, slot_id)
                table.insert(bag_rows, row)
            end
            if bag_item_ct == 0 then
                empty_bank_seen_ct = empty_bank_seen_ct + 1
            end
        end
        if 0 < empty_bank_seen_ct then
            Info("Counted no items from %d housing storage containers."
                .."Perhaps you need to open them first?", empty_bank_seen_ct)
        end
    end
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
