local LAM2 = LibStub("LibAddonMenu-2.0")

local ZZHousingInventory = {}
ZZHousingInventory.name            = "ZZHousingInventory"
ZZHousingInventory.version         = "3.3.1"
ZZHousingInventory.savedVarVersion = 1
ZZHousingInventory.default = {
    house = {}
}


-- cost ----------------------------------------------------------------------
-- A cost in gold, crowns, or vouchers
local Cost = {}
function Cost:New(args)
    local o = { gold     = 0
              , crowns   = 0
              , vouchers = 0
              }
    if args then
        if args.gold then o.gold = args.gold end
        if args.crowns then o.crowns = args.crowns end
        if args.vouchers then o.vouchers = args.vouchers end
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

function Cost:Add(b)
    if b then
        if b.gold     then self.gold     = (self.gold     or 0) + b.gold     end
        if b.crowns   then self.crowns   = (self.crowns   or 0) + b.crowns   end
        if b.vouchers then self.vouchers = (self.vouchers or 0) + b.vouchers end
    end
    return self
end

function Cost:ToStorage()
    local tm = ZZHousingInventory.ToMoney
    local s = "%sg %sc %sv"
    return string.format( s
                        , tm(self.gold     or 0)
                        , tm(self.crowns   or 0)
                        , tm(self.vouchers or 0)
                        )
end

-- Item ----------------------------------------------------------------------
--
-- The occupant of a placed housing slot. This is a single furnishing item.


local Item = {}
function Item:FromFurnitureId(furniture_id, count_collectibles)
    local o = { furniture_id = furniture_id }

    local r = { GetPlacedHousingFurnitureInfo(furniture_id) }
    o.item_name             = r[1]
    o.texture_name          = r[2]
    o.furniture_data_id     = r[3]
    local furniture_data_id = r[3]

    o.quality           = GetPlacedHousingFurnitureQuality(furniture_id)
    o.link              = GetPlacedFurnitureLink(
                                furniture_id, LINK_STYLE_DEFAULT)
    o.collectible_id    = GetCollectibleIdFromFurnitureId(furniture_id)
    o.unique_id         = GetItemUniqueIdFromFurnitureId(furniture_id)

    r = { GetFurnitureDataInfo(furniture_data_id) }
    o.furniture_category_id     = r[1]
    o.furniture_subcategory_id  = r[2]
    o.furniture_theme_type      = r[3]

                        -- De-attune before fetching price
                        -- so that MM and FurC can supply
                        -- pre-bound prices.
    Item.Unattune(o)

    o.mm                 = ZZHousingInventory.MMPrice(o.link)
    o.furc               = ZZHousingInventory.FurCPrice(o.link)

                        -- Supply Zig data for things we know
                        -- but neither MM nor Furniture Catalog do.
    Item.SupplyZigCost(o, count_collectibles)

    setmetatable(o, self)
    self.__index = self
    return o
end

function Item.Unattune(item)
    if not item and item.name then return end

                        -- Remove the "attuning" that makes these
                        -- crafting stations unique, preventing FurC
                        -- and MM from coming up with prices, AND
                        -- preventing us from combining them into a single
                        -- stack of count 41 instead of 41 unique items.
                        --
                        -- Note trailing space after each station name!
                        -- Required to avoid false match on non-attunable
                        -- stations.
    if string.find(item.item_name, "Blacksmithing Station ") then
        d("Un-attuning: "..item.item_name)
        item.item_name = "Attunable Blacksmithing Station"
        item.link = "|H1:item:119594:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"
        item.furniture_data_id = 4050
    elseif string.find(item.item_name, "Clothing Station ") then
        d("Un-attuning: "..item.item_name)
        item.item_name = "Attunable Clothier Station"
        item.link      = "|H1:item:119821:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"
        item.furniture_data_id = 4051
    elseif string.find(item.item_name, "Woodworking Station ") then
        d("Un-attuning: "..item.item_name)
        item.item_name = "Attunable Woodworking Station"
        item.link     = "|H1:item:119822:364:50:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:10000:0|h|h"
        item.furniture_data_id = 4052
    end
end

Item.ZIG_COST = {
  ["The Apprentice"                         ] = Cost:New({ crowns = 250 })
, ["The Atronach"                           ] = Cost:New({ crowns = 250 })
, ["The Tower"                              ] = Cost:New({ crowns = 250 })
, ["The Thief"                              ] = Cost:New({ crowns = 250 })
, ["The Serpent"                            ] = Cost:New({ crowns = 250 })
, ["The Ritual"                             ] = Cost:New({ crowns = 250 })
, ["The Mage"                               ] = Cost:New({ crowns = 250 })
, ["The Lady"                               ] = Cost:New({ crowns = 250 })
, ["The Lord"                               ] = Cost:New({ crowns = 250 })
, ["The Warrior"                            ] = Cost:New({ crowns = 250 })
, ["The Lover"                              ] = Cost:New({ crowns = 250 })
, ["The Steed"                              ] = Cost:New({ crowns = 250 })
, ["The Shadow"                             ] = Cost:New({ crowns = 250 })

, ["Transmute Station"                      ] = Cost:New({ crowns = 1250 })
, ["Statue of Azura, Queen of Dawn and Dusk"] = Cost:New({ crowns = 4000 })
, ["Hedge, Dense High Wall"                 ] = Cost:New({ crowns =   45 })
, ["Topiary, Strong Cypress"                ] = Cost:New({ crowns =   45 })
, ["Seal of Molag Bal"                      ] = Cost:New({ crowns = 5000 })
}
-- Things that appear in multiple houses. Count these collectibles only once,
-- in the Grand Linchal Manor
Item.ZIG_COST_COLLECTIBLE = {
   --torage Coffer, Fortified"              ] = Cost:New({ crowns =  100 }) one of these was free for reaching level 18
  ["Storage Coffer, Secure"                 ] = Cost:New({ crowns =  100 })
, ["Storage Coffer, Sturdy"                 ] = Cost:New({ crowns =  100 })
, ["Storage Coffer, Oaken"                  ] = Cost:New({ crowns =  100 })
, ["Storage Chest, Fortified"               ] = Cost:New({ crowns =  200 })
, ["Storage Chest, Oaken"                   ] = Cost:New({ crowns =  200 })
, ["Storage Chest, Secure"                  ] = Cost:New({ crowns =  200 })
, ["Storage Chest, Sturdy"                  ] = Cost:New({ crowns =  200 })

, ["Nuzhimeh the Merchant"                  ] = Cost:New({ crowns = 5000 })
--["Pirharri the Smuggler"                  ] = Cost:New() -- Free for completing Thieves Guild quest line
, ["Tythis Andromo, the Banker"             ] = Cost:New({ crowns = 5000 })
}

function Item.SupplyZigCost(item, count_collectibles)

                        -- Flag things without prices so that I can
                        -- easily find them in SavedVariables
    if not (o.mm or o.furc) then
        o.missing_price = 1
    end

                        -- Supply costs for things we know but
                        -- Furniture Catalogue does not.
    if item.mm or item.furc then return end

    local zc = Item.ZIG_COST[item.item_name]
    if (not zc) and count_collectibles then
        zc = Item.ZIG_COST_COLLECTIBLE[item.item_name]
    end
    if zc then
        if 0 < zc.gold then
            item.furc = { currency_type = "gold"
                        , currency_ct   = zc.gold
                        }
        elseif 0 < zc.crowns then
            item.furc = { currency_type = "crowns"
                        , currency_ct   = zc.crowns
                        }
        elseif 0 < zc.vouchers then
            item.furc = { currency_type = "vouchers"
                        , currency_ct   = zc.vouchers
                        }
        end
        if item.furc then
            item.furc.notes = "Zig data"
        end
    end
end


function Item:Cost()
                        -- Lazy calc and cache.
    if self.cost then return self.cost end

                        -- Prefer recent MM to original FurC cost.
    if self.mm then
        self.cost = Cost:New({gold = self.mm})
    elseif (self.furc and self.furc.currency_type) then
-- d("self.furc:"..tostring(self.furc))
-- d("self.furc.currency_type:"..tostring(self.furc.currency_type))
-- d("self.furc.currency_ct:"..tostring(self.furc.currency_ct))
-- d("self.furc:"..tostring(self.furc))
        self.cost = Cost:New({[self.furc.currency_type] = self.furc.currency_ct})
    end
    return self.cost
end

function link_to_item_id(link)
    local x = { ZO_LinkHandler_ParseLink(link) }
    local item_id = tonumber(x[ 4])
    return item_id
end

function Item.ToStorage(self)
    local key   = self.furniture_data_id -- link_to_item_id(self.link)
    if not key then
        d("no key?")
        for k,v in pairs(self) do
            d("k:"..tostring(k).." v:"..tostring(v))
        end
    end
    local store = { name       = self.item_name
                  , ct         = 0
                  , link       = self.link
                  , value_mm   = ZZHousingInventory.Round(self.mm)
                  , value_furc = self.furc
                  }
                        -- Flag items with no price data so that I can
                        -- search for them in savedVariables later and
                        -- supply a price if I want.
    if not (store.value_mm or store.value_furc) then
        store.no_cost = 1
    end
    return key, store
end

function ZZHousingInventory.Round(f)
    if not f then return f end
    return math.floor(0.5+f)
end

function ZZHousingInventory.ToMoney(x)
    if not x then return "?" end
    return ZO_CurrencyControl_FormatCurrency(ZZHousingInventory.Round(x), false)
end


-- Init ----------------------------------------------------------------------

function ZZHousingInventory.OnAddOnLoaded(event, addonName)
    if addonName ~= ZZHousingInventory.name then return end
    if not ZZHousingInventory.version then return end
    if not ZZHousingInventory.default then return end
    ZZHousingInventory:Initialize()
end

function ZZHousingInventory:Initialize()

    self.savedVariables = ZO_SavedVars:NewAccountWide(
                              "ZZHousingInventoryVars"
                            , self.savedVarVersion
                            , nil
                            , self.default
                            )
    self:CreateSettingsWindow()

end

-- UI ------------------------------------------------------------------------

function ZZHousingInventory:CreateSettingsWindow()
    local panelData = {
          type                = "panel"
        , name                = "ZZHousingInventory"
        , displayName         = "ZZHousingInventory"
        , author              = "ziggr"
        , version             = self.version
        , slashCommand        = "/zhou"
        , registerForRefresh  = true
        , registerForDefaults = false
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel( self.name
                                                     , panelData
                                                     )
    local optionsData = {
        { type      = "button"
        , name      = "Scan Now"
        , tooltip   = "Fetch placed furniture data now."
        , func      = function()
                        self:ScanNow()
                        self:UpdateDisplay()
                      end
        },

        { type      = "description"
        , text      = ""
        , width     = "half"
        , reference = "ZZHousingInventory_desc_names"
        },

        { type      = "description"
        , text      = ""
        , width     = "half"
        , reference = "ZZHousingInventory_desc_amounts"
        },

    }

    LAM2:RegisterOptionControls("ZZHousingInventory", optionsData)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated"
            , self.OnPanelControlsCreated)
end

-- Delay initialization of options panel: don't waste time fetching
-- guild names until a human actually opens our panel.
function ZZHousingInventory.OnPanelControlsCreated(panel)
    self = ZZHousingInventory
    if not (ZZHousingInventory_desc_amounts and ZZHousingInventory_desc_amounts.desc) then return end
    if ZZHousingInventory_desc_amounts.desc then
        ZZHousingInventory_desc_amounts.desc:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    end
    self:UpdateDisplay()
end

function ZZHousingInventory:UpdateDisplay()
    local total                 = Cost:New()
    local house_list            = {}
    for house_name, house in pairs(self.savedVariables.house) do
        local c = Cost:New()
        c:Add(house.house.cost)
        c:Add(house.furn_cost)
        total:Add(c)
        local house_row = { house_name   = house_name
                          , furniture_ct = #house.furniture
                          , cost         = c
                          }
        table.insert(house_list, house_row)
    end

    local house_name_list = {}
    local house_cost_list = {}
    for i,house_row in pairs(house_list) do
        table.insert(house_name_list, house_row.house_name)
        table.insert(house_cost_list, house_row.cost:ToStorage())
    end
    table.insert(house_name_list,   "--")
    table.insert(house_name_list,  "total")
    table.insert(house_cost_list, "--")
    table.insert(house_cost_list, total:ToStorage())

    local sn = table.concat(house_name_list, "\n")
    local sa = table.concat(house_cost_list, "\n")

    ZZHousingInventory_desc_names.data.text   = sn
    ZZHousingInventory_desc_amounts.data.text = sa
    ZZHousingInventory_desc_names.desc:SetText(sn)
    ZZHousingInventory_desc_amounts.desc:SetText(sa)
end

-- HouseID -------------------------------------------------------------------
local HOUSE = {
                        -- all prices are for UNFURNISHED, even if we bought
                        -- the home furnished,  so that we can still
                        -- count the furnishings without double-counting.
  MARAS_KISS                    = { id =  1, cost = Cost:New({gold =       0, crowns =   nil }) }
, ROSY_LION                     = { id =  2, cost = Cost:New({gold =       0, crowns =   nil }) }
, EBONY_FLASK                   = { id =  3, cost = Cost:New({gold =       0, crowns =   nil }) }
, SAINT_DELYN_PENTHOUSE         = { id = 42, cost = Cost:New({gold =       0, crowns =   nil }) }
, KRAGENHOME                    = { id = 19, cost = Cost:New({gold =   69000, crowns =   nil }) }
, AUTUMNS_GATE                  = { id = 28, cost = Cost:New({gold =   60000, crowns =   nil }) }
, GRYMHEARTHS_WOE               = { id = 29, cost = Cost:New({gold =  280000, crowns =   nil }) }
, MATHIISEN_MANOR               = { id =  9, cost = Cost:New({gold = 1025000, crowns =   nil }) }
, OLD_MISTVEIL_MANOR            = { id = 30, cost = Cost:New({gold = 1020000, crowns =   nil }) }
, LINCHAL_MANOR                 = { id = 46, cost = Cost:New({gold =     nil, crowns = 14000 }) }
, COLDHARBOUR_SURREAL_ESTATE    = { id = 47, cost = Cost:New({gold = 1000000, crowns =   nil }) }
, ERSTWHILE_SANCTUARY           = { id = 56, cost = Cost:New({gold =     nil, crowns = 13000 }) }
}

-- Fetch Inventory Data from the server ------------------------------------------

function ZZHousingInventory:ScanNow()
    local house_id = GetCurrentZoneHouseId()
    if not (house_id and 0 < house_id) then
        d("ZZHousing: not in a house. Exiting.")
        return
    end
    local is_linchal = house_id == HOUSE.LINCHAL_MANOR.id

                        -- Find the HOUSE constant from above for this
                        -- current house.
    local house = nil
    for _,v in pairs(HOUSE) do
        if v.id == house_id then
            house = v
        end
    end

    local location_name   = GetPlayerLocationName()
    local save_furniture  = {}
    local total_furn_cost = Cost:New()

    local furniture_id = GetNextPlacedHousingFurnitureId(nil)
    local loop_limit   = 1000 -- avoid infinite loops in case GNPHFI() surprises us
    while furniture_id and 0 < loop_limit do
        local item = Item:FromFurnitureId(furniture_id, is_linchal)
        local key, store = item:ToStorage()
        save_furniture[key]    = save_furniture[key] or store
        save_furniture[key].ct = save_furniture[key].ct + 1
        total_furn_cost:Add(item:Cost())
        furniture_id = GetNextPlacedHousingFurnitureId(furniture_id)
        loop_limit = loop_limit - 1
    end

    self.savedVariables.house[location_name] = { furniture = save_furniture
                                               , house     = house
                                               , furn_cost = total_furn_cost
                                               }
    d("House: "..location_name)
    d("House purchase:"..house.cost:ToStorage())
    d("Furnishings ct:"..tostring(#save_furniture)
        .." cost:"..total_furn_cost:ToStorage())
end

function ZZHousingInventory.MMPrice(link)
    if not MasterMerchant then return nil end
    if not link then return nil end
    local mm = MasterMerchant:itemStats(link, false)
    if not mm then return nil end
    return mm.avgPrice
end

local kCurrType_Gold           = "gold"
local kCurrType_WritVouchers   = "vouchers"
local kCurrType_AlliancePoints = "ap"
local kCurrType_Crowns         = "crowns"

-- Dig deep into the data model of Furniture Catalogue,
-- because there's no public API for this (Furniture Catalogue
-- was never intended to become a public database).
--
local function from_FurC_Crafting(item_link, recipe_array)
    if not recipe_array.blueprint then return nil, nil end
    local total_mat_cost = 0

    local notes = "crafting cost"
    local blueprint_link = FurC.GetItemLink(recipe_array.blueprint)
    local ingredient_ct = GetItemLinkRecipeNumIngredients(blueprint_link)
    for ingr_i = 1, ingredient_ct do
        local _, _, ct  = GetItemLinkRecipeIngredientInfo(blueprint_link, ingr_i )
        local ingr_link  = GetItemLinkRecipeIngredientItemLink(blueprint_link, ingr_i )
        local mm = ZZHousingInventory.MMPrice(ingr_link)
        if mm then
            total_mat_cost = total_mat_cost + ct * mm
        else
            notes = "crafting cost, partial"
        end
    end
    return kCurrType_Gold, total_mat_cost, notes
end

local function from_FurC_Rollis(item_link, recipe_array)
    local item_id       = FurC.GetItemId(item_link)
    local seller_list   = { FurC.Rollis, FurC.Faustina }
    local seller_names  = { "Rollis", "Faustina" }
    for i, seller in ipairs(seller_list) do
        local version_data = seller[recipe_array.version]
        if version_data and version_data[item_id] then
            local ct = version_data[item_id]
            return kCurrType_WritVouchers, ct, seller_names[i]
        end
    end
    return nil, nil, nil
end

local function from_FurC_Luxury(item_link, recipe_array)
    local version_data = FurC.LuxuryFurnisher[recipe_array.version]
    if not version_data then return nil, nil, nil end
    local item_id   = FurC.GetItemId(item_link)
    local item_data = version_data[item_id]
    if not item_data then return nil, nil, nil end
    return kCurrType_Gold, item_data.itemPrice, "luxury vendor"
end

local function from_FurC_AchievementVendor(item_link, recipe_array)
    local item_id      = FurC.GetItemId(item_link)
    local version_data = FurC.AchievementVendors[recipe_array.version]
    if not version_data then return nil, nil, nil end
    for zone_name, zone_data in pairs(version_data) do
        for vendor_name, vendor_data in pairs(zone_data) do
            local entry = vendor_data[item_id]
            if entry then
                local notes = vendor_name .. " in " .. zone_name
                return kCurrType_Gold, entry.itemPrice, notes
            end
        end
    end
    return nil, nil, nil
end

local function from_FurC_Generic(item_link, recipe_array, currency_type)
    local item_id      = FurC.GetItemId(item_link)
    local version_data = FurC.MiscItemSources[recipe_array.version]
    if not version_data then return nil, nil, nil end
    local origin_data  = version_data[recipe_array.origin]
    if not origin_data then return nil, nil, nil end
    local entry = origin_data[item_id]
    if type(entry) == "number" then
        return currency_type, entry, nil
    end
    if type(entry) == "string" then
        local n = string.match(entry, "%d+")
        if n and tonumber(n) then
            return currency_type, tonumber(n), nil
        end
    end
    if type(entry) == "table" then
        if entry.itemPrice then
            return currency_type, entry.itemPrice, nil
        end
    end
    return nil, nil, nil
end

local function from_FurC_Crown(item_link, recipe_array)
    return from_FurC_Generic(item_link, recipe_array, kCurrType_Crowns)
end

local function from_FurC_Misc(item_link, recipe_array)
    return from_FurC_Generic(item_link, recipe_array, kCurrType_Gold)
end

-- Rumor table and others lack any per-item details.
-- No point in wasting time in the Misc tables.
local function from_FurC_NoPrice(item_link, recipe_array)
    return nil, nil, nil
end

local function from_FurC_PVP(item_link, recipe_array, currency_type)
    local item_id      = FurC.GetItemId(item_link)
    local version_data = FurC.PVP[recipe_array.version]
    if not version_data then return nil, nil, nil end
    for vendor_name, vendor_data in pairs(version_data) do
        for location_name, location_data in pairs(vendor_data) do
            local entry = location_data[item_id]
            if entry then
                local notes = vendor_name .. " in " .. location_name
                return kCurrType_AlliancePoints, entry.itemPrice, notes
            end
        end
    end
    return nil, nil, nil
end

function ZZHousingInventory.FurCPrice(item_link)
    if not FurC then return nil end

    local item_id       = FurC.GetItemId(item_link)
    local recipe_array  = FurC.Find(item_link)
    if not recipe_array then return nil end
    local origin        = recipe_array.origin
    if not origin then return nil end

    local desc           = FurC.GetItemDescription(item_id, recipe_array)
    local currency_type  = nil
    local currency_ct    = nil
    local currency_notes = nil

    local func_table = { [FURC_CRAFTING     ] = from_FurC_Crafting           --  3
                       , [FURC_VENDOR       ] = from_FurC_AchievementVendor  --  6
                       , [FURC_PVP          ] = from_FurC_PVP                --  7
                       , [FURC_CROWN        ] = from_FurC_Crown              --  8
                       , [FURC_LUXURY       ] = from_FurC_Luxury             -- 10
                       , [FURC_ROLLIS       ] = from_FurC_Rollis             -- 12
                       , [FURC_DROP         ] = from_FurC_Misc               -- 14
                       , [FURC_JUSTICE      ] = from_FurC_Misc               -- 15

                       -- These tables never have per-item price data.
                       , [FURC_RUMOUR       ] = from_FurC_NoPrice            --  9
                       , [FURC_FESTIVAL_DROP] = from_FurC_NoPrice            -- 18

                       }
    local func = func_table[origin] or from_FurC_Misc
    if func then  currency_type, currency_ct, currency_notes
            = func(item_link, recipe_array)
    end

    local o = { origin        = origin
              , desc          = desc
              , currency_type = currency_type
              , currency_ct   = currency_ct
              , notes         = currency_notes
              }
    return o
end




-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( ZZHousingInventory.name
                              , EVENT_ADD_ON_LOADED
                              , ZZHousingInventory.OnAddOnLoaded
                              )
