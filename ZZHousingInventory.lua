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

    local house_data = ZZHousingInventory.HOUSE[house_id]
    if house_data then
        row.value_house_gold   = house_data.gold
        row.value_house_crowns = house_data.crowns
    end

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

    local bag_id = GetCollectibleBankAccessBag(collectible_id)
    self.collectible_bag_key = ZZHousingInventory.BagKey(bag_id)
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


-- HouseID -------------------------------------------------------------------

                        -- all prices are for UNFURNISHED, even if we bought
                        -- the home furnished,  so that we can still
                        -- count the furnishings without double-counting.
                        --
                        -- table index === house_id for O(1) lookup.
ZZHousingInventory.HOUSE = {
  [ 1] = { house_id =  1, gold =    3000, crowns =   nil } -- Mara's Kiss Public House
, [ 2] = { house_id =  2, gold =       0, crowns =   nil } -- The Rosy Lion
, [ 3] = { house_id =  3, gold =    3000, crowns =   nil } -- Ebony Flask Inn Room
, [ 4] = { house_id =  4, gold =   11000, crowns =   600 } -- Barbed Hook Private Room
, [ 5] = { house_id =  5, gold =   12000, crowns =   640 } -- Sisters of the Sands Apartment
, [ 6] = { house_id =  6, gold =   13000, crowns =   660 } -- Flaming Nix Deluxe Garret
, [ 7] = { house_id =  7, gold =   54000, crowns =  2250 } -- Black Vine Villa
, [ 8] = { house_id =  8, gold =  255000, crowns =  3600 } -- Cliffshade
, [ 9] = { house_id =  9, gold = 1025000, crowns =  6400 } -- Mathiisen Manor
, [10] = { house_id = 10, gold =   40000, crowns =  2600 } -- Humblemud
, [11] = { house_id = 11, gold =  195000, crowns =  3520 } -- The Ample Domicile
, [12] = { house_id = 12, gold =  760000, crowns =  5500 } -- Stay-Moist Mansion
, [13] = { house_id = 13, gold =   45000, crowns =  2150 } -- Snugpod
, [14] = { house_id = 14, gold =  190000, crowns =  3500 } -- Bouldertree Refuge
, [15] = { house_id = 15, gold =  780000, crowns =  5600 } -- The Gorinir Estate
, [16] = { house_id = 16, gold =   56000, crowns =  2300 } -- Captain Margaux's Place
, [17] = { house_id = 17, gold =  260000, crowns =  3500 } -- Ravenhurst
, [18] = { house_id = 18, gold = 1015000, crowns =  5700 } -- Gardner House
, [19] = { house_id = 19, gold =   69000, crowns =  2500 } -- Kragenhome
, [20] = { house_id = 20, gold =  323000, crowns =  4200 } -- Velothi Reverie
, [21] = { house_id = 21, gold = 1265000, crowns =  6100 } -- Quondam Indorilia
, [22] = { house_id = 22, gold =   50000, crowns =  2200 } -- Moonmirth House
, [23] = { house_id = 23, gold =  335000, crowns =  4400 } -- Sleek Creek House
, [24] = { house_id = 24, gold = 1275000, crowns =  6200 } -- Dawnshadow
, [25] = { house_id = 25, gold =   71000, crowns =  2550 } -- Cyrodilic Jungle House
, [26] = { house_id = 26, gold =  295000, crowns =  4000 } -- Domus Phrasticus
, [27] = { house_id = 27, gold = 1280000, crowns =  6300 } -- Strident Springs Demesne
, [28] = { house_id = 28, gold =   60000, crowns =  2350 } -- Autumn's-Gate
, [29] = { house_id = 29, gold =  280000, crowns =  3800 } -- Grymharth's Woe
, [30] = { house_id = 30, gold = 1020000, crowns =  5800 } -- Old Mistveil Manor
, [31] = { house_id = 31, gold =   65000, crowns =  2400 } -- Hammerdeath Bungalow
, [32] = { house_id = 32, gold =  325000, crowns =  4300 } -- Mournoth Keep
, [33] = { house_id = 33, gold = 1285000, crowns =  6400 } -- Forsaken Stronghold
, [34] = { house_id = 34, gold =   73000, crowns =  2600 } -- Twin Arches
, [35] = { house_id = 35, gold =  320000, crowns =  4100 } -- House of the Silent Magnifico
, [36] = { house_id = 36, gold = 1295000, crowns =  6500 } -- Hunding's Palatial Hall
, [37] = { house_id = 37, gold = 3775000, crowns = 10000 } -- Serenity Falls Estate
, [38] = { house_id = 38, gold = 3780000, crowns = 11000 } -- Daggerfall Overlook
, [39] = { house_id = 39, gold = 3785000, crowns = 12000 } -- Ebonheart Chateau
, [40] = { house_id = 40, gold =     nil, crowns = 15000 } -- Grand Topal Hideaway
, [41] = { house_id = 41, gold =     nil, crowns = 13000 } -- Earthtear Cavern
, [42] = { house_id = 42, gold =    3000, crowns =   nil } -- Saint Delyn Penthouse
, [43] = { house_id = 43, gold = 1300000, crowns =  7000 } -- Amaya Lake Lodge
, [44] = { house_id = 44, gold =  332000, crowns =  4000 } -- Ald Velothi Harbor House
, [45] = { house_id = 45, gold =     nil, crowns =  8000 } -- Tel Galen
, [46] = { house_id = 46, gold =     nil, crowns = 14000 } -- Linchal Grand Manor
, [47] = { house_id = 47, gold = 1000000, crowns =  5600 } -- Coldharbour Surreal Estate
, [48] = { house_id = 48, gold = 3800000, crowns = 12000 } -- Hakkvild's High Hall
, [49] = { house_id = 49, gold =     nil, crowns =  3500 } -- Exorcised Coven Cottage
, [50] = { house_id = 50, gold =     nil, crowns =   nil } -- nil
, [51] = { house_id = 51, gold =     nil, crowns =   nil } -- nil
, [52] = { house_id = 52, gold =     nil, crowns =   nil } -- nil
, [53] = { house_id = 53, gold =     nil, crowns =   nil } -- nil
, [54] = { house_id = 54, gold =     nil, crowns = 13000 } -- Pariah's Pinnacle
, [55] = { house_id = 55, gold =     nil, crowns = 12000 } -- The Orbservatory Prior
, [56] = { house_id = 56, gold =     nil, crowns = 13000 } -- The Erstwhile Sanctuary
, [57] = { house_id = 57, gold =     nil, crowns = 14000 } -- Princely Dawnlight Palace
, [58] = { house_id = 58, gold =    3000, crowns =   nil } -- Golden Gryphon Garret
, [59] = { house_id = 59, gold = 1025000, crowns =  6000 } -- Alinor Crest Townhouse
, [60] = { house_id = 60, gold =     nil, crowns = 15000 } -- Colossal Aldmeri Grotto
, [61] = { house_id = 61, gold =     nil, crowns =  8000 } -- Hunter's Glade
, [62] = { house_id = 62, gold =     nil, crowns =   nil } -- Grand Psijic Villa
, [63] = { house_id = 63, gold =     nil, crowns =  4200 } -- Enchanted Snow Globe Home
, [64] = { house_id = 64, gold =     nil, crowns =   nil } -- Lakemire Xanmeer Manor
}

-- "|H0:collectible:267:|h|h"
local COLLECTIBLE = {
  { collectible_id =  267, name = "Tythis Andromo, the Banker", crowns = 5000 }
, { collectible_id =  301, name = "Nuzhimeh the Merchant"     , crowns = 5000 }
, { collectible_id = 5083, name = "Prong-Eared Grimalkin"     , crowns = 1000 }

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
is_primary = true -- TEMP HACK so that I can test containers in Old Mistveil Manor instead of The Craftorium
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
