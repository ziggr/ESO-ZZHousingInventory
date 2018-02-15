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

    o.mm                = ZZHousingInventory.MMPrice(o.link)

    setmetatable(o, self)
    self.__index = self
    return o
end

function Item.ToStorage(self)
    local key = Id64ToString(self.furniture_data_id)
    local store = { name  = self.item_name
                  , ct    = 0
                  , link  = self.link
                  , value = { }
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
    mm = MasterMerchant:itemStats(link, false)
    if not mm then return nil end
    --d("MM for link: "..tostring(link).." "..tostring(mm.avgPrice))
    return mm.avgPrice
end


-- Postamble -----------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent( ZZHousingInventory.name
                              , EVENT_ADD_ON_LOADED
                              , ZZHousingInventory.OnAddOnLoaded
                              )
