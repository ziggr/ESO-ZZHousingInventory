local LAM2 = LibStub("LibAddonMenu-2.0")

local ZZHousingInventory = {}
ZZHousingInventory.name            = "ZZHousingInventory"
ZZHousingInventory.version         = "3.3.1"
ZZHousingInventory.savedVarVersion = 1
ZZHousingInventory.default = {
    house = {}
}

-- Item ----------------------------------------------------------------------
--
-- The occupant of a placed housing slot. This is a single furnishing item.


local Item = {}
function Item:FromFurnitureId(furniture_id)
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

    o.mm                 = ZZHousingInventory.MMPrice(o.link)
    o.furc               = ZZHousingInventory.FurCPrice(o.link)

    setmetatable(o, self)
    self.__index = self
    return o
end

function Item.ToStorage(self)
    local key = Id64ToString(self.furniture_data_id)
    local store = { name       = self.item_name
                  , ct         = 0
                  , link       = self.link
                  , value_mm   = self.mm
                  , value_furc = self.furc
                  }
    return key, store
end

function max(a, b)
    if not a then return b end
    if not b then return a end
    return math.max(a, b)
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
        , func      = function() self:ScanNow() end
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
    local total                 = 0
    local total_gold            = 0
    local total_item            = 0
    local house_list            = {}
    for house_name, furn_list in pairs(self.savedVariables.house) do
        local mm_total = 0
        for i, furn in ipairs(furn_list) do
            mm_total = mm_total + (furn.mm or 0)
        end
        local house_row = { house_name   = house_name
                          , furniture_ct = #furn_list
                          , mm_total     = mm_total
                          }
        table.insert(house_list, house_row)
    end

    -- SORT HERE by house_row.mm descending

    local grand_mm_total        = 0
    local house_name_list       = {}
    local house_mm_list         = {}
    for i,house_row in pairs(house_list) do
        table.insert(house_name_list, house_row.house_name)
        table.insert(house_mm_list,   house_row.mm_total)
        grand_mm_total     = grand_mm_total     + house_row.mm_total
    end
    table.insert(house_name_list,   "--")
    table.insert(house_name_list,  "total")
    table.insert(house_mm_list, "--")
    table.insert(house_mm_list, ZO_CurrencyControl_FormatCurrency(grand_mm_total, false))

    local sn = table.concat(house_name_list, "\n")
    local sa = table.concat(house_mm_list,   "\n")

    ZZHousingInventory_desc_names.data.text   = sn
    ZZHousingInventory_desc_amounts.data.text = sa
    ZZHousingInventory_desc_names.desc:SetText(sn)
    ZZHousingInventory_desc_amounts.desc:SetText(sa)
end


-- Fetch Inventory Data from the server ------------------------------------------

function ZZHousingInventory:ScanNow()
    local house_id = GetCurrentZoneHouseId()
    if not (house_id and 0 < house_id) then
        d("ZZHousing: not in a house. Exiting.")
        return
    end

    local location_name  = GetPlayerLocationName()
    local save_furniture = {}

    local furniture_id = GetNextPlacedHousingFurnitureId(nil)
    local loop_limit   = 1000 -- avoid infinite loops in cause GNPHFI() surprises us
    while furniture_id and 0 < loop_limit do
        local item = Item:FromFurnitureId(furniture_id)
        local key, store = item:ToStorage()
        save_furniture[key]    = save_furniture[key] or store
        save_furniture[key].ct = save_furniture[key].ct + 1

        furniture_id = GetNextPlacedHousingFurnitureId(furniture_id)
        loop_limit = loop_limit - 1
    end

    self.savedVariables.house[location_name] = save_furniture
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

local function from_FurC_Generic(item_link, recipe_array, curr_type)
    local item_id      = FurC.GetItemId(item_link)
    local version_data = FurC.MiscItemSources[recipe_array.version]
    if not version_data then return nil, nil, nil end
    local origin_data  = version_data[recipe_array.origin]
    if not origin_data then return nil, nil, nil end
    local entry = origin_data[item_id]
    if type(entry) == "number" then
        return curr_type, entry, nil
    end
    if type(entry) == "string" then
        local n = string.match(entry, "%d+")
        if n and tonumber(n) then
            return curr_type, tonumber(n), nil
        end
    end
    if type(entry) == "table" then
        if entry.itemPrice then
            return curr_type, entry.itemPrice, nil
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

local function from_FurC_PVP(item_link, recipe_array, curr_type)
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

    local o = { origin    = origin
              , desc      = desc
              , curr_type = currency_type
              , curr_ct   = currency_ct
              , notes     = currency_notes
              }
    return o
end


-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( ZZHousingInventory.name
                              , EVENT_ADD_ON_LOADED
                              , ZZHousingInventory.OnAddOnLoaded
                              )
