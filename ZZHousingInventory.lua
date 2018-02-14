local LAM2 = LibStub("LibAddonMenu-2.0")

local ZZHousingInventory = {}
ZZHousingInventory.name            = "ZZHousingInventory"
ZZHousingInventory.version         = "3.3.1"
ZZHousingInventory.savedVarVersion = 1
ZZHousingInventory.NAME_BANK       = "bank"
ZZHousingInventory.NAME_CRAFT_BAG  = "craft bag"
ZZHousingInventory.char_index      = nil
ZZHousingInventory.default = {
    bag = {}
  , trading_house = {}
  , enable_guild_scan = false
}

-- Item ----------------------------------------------------------------------
--
-- The occupant of a single bag slot. This is a single item, or a stack of
-- items. In the BAG_BACKPACK, materials can occupy multiple slots, so they
-- will appear as multiple Item instances. This is expected.

local Item = {}
function Item:FromNothing()
    local o = { total_value = 0
              , ct          = 0
              , mm          = 0
              , npc         = 0  -- Value if sold to NPC Vendor
              , name        = ""
           -- , link        = "" -- Not retaining Link: makes data file too large.
              }
    setmetatable(o, self)
    self.__index = self
    return o
end

function max(a, b)
    if not a then return b end
    if not b then return a end
    return math.max(a, b)
end

function Item:FromBag(bag_id, slot_index)
    local item_name = GetItemName(bag_id, slot_index)
    local item_link = GetItemLink(bag_id, slot_index, LINK_STYLE_DEFAULT)
    local _, ct, npc_sell_price = GetItemInfo(bag_id, slot_index)
    if ct == 0 then return nil end
    local mm = ZZHousingInventory.MMPrice(item_link)
    local o = { total_value = Item.round(ct * max(npc_sell_price, mm))
              , ct          = ct
              , mm          = Item.round(mm)
              , npc         = npc_sell_price
              , name        = item_name
           -- , link        = item_link
              }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Item.round(f)
    if not f then return f end
    return math.floor(0.5+f)
end

function Item:ToDString()
    return "tot:" .. tostring(self.total_value)
      ..   " ct:" .. tostring(self.ct)
      ..   " mm:" .. tostring(self.mm)
      ..  " npc:" .. tostring(self.npc)
      .. " name:" .. tostring(self.name)
      -- .. " link:" .. tostring(self.link)
end

-- Bag -----------------------------------------------------------------------
--
-- One line in the summary display, with the itemized details that built
-- up to that line.
--
-- One "bag" is one of:
--    - a single character's items (BAG_BACKPACK + BAG_WORN)
--    - bank (BAG_BANK)
--    - craft bag (BAG_VIRTUAL)
--

local Bag = {}
function Bag:FromName(name)
    local o = { name = name
              , total = 0
              , gold  = 0
              , item_subtotal = 0
              , item_ct = 0
              , items = {}
              }
    setmetatable(o, self)
    self.__index = self
    return o
end

-- Main entry for a bag.
-- Fans out to specific bag-fetching subroutines.
function Bag:ReadFromServer()
    if self.name == ZZHousingInventory.NAME_BANK then
        self:ReadFromBagId(BAG_BANK)
        self:ReadFromBagId(BAG_SUBSCRIBER)
        self.gold = GetBankedMoney()
        self.total = self.gold + self.item_subtotal
        d(self.name .. " total:" .. ZO_CurrencyControl_FormatCurrency(self.total, false) .. " item_ct:" .. self.item_ct)
    elseif self.name == ZZHousingInventory.NAME_CRAFT_BAG then
        self:ReadFromCraftBag()
        self.total = self.gold + self.item_subtotal
        d(self.name .. " total:" .. ZO_CurrencyControl_FormatCurrency(self.total, false) .. " item_ct:" .. self.item_ct)
    else
        self:ReadFromBagId(BAG_BACKPACK)
        self:ReadFromBagId(BAG_WORN)
        self.gold = GetCurrentMoney()
        self.total = self.gold + self.item_subtotal
        d(self.name .. " total:" .. ZO_CurrencyControl_FormatCurrency(self.total, false) .. " item_ct:" .. self.item_ct)
    end
end

function Bag:ReadFromBagId(bag_id)
    local slot_ct = GetBagSize(bag_id)
    for slot_index = 0, slot_ct do
        local item = Item:FromBag(bag_id, slot_index)
        self:AddItem(item)
    end
end

function Bag:ReadFromCraftBag()
    slot_id = GetNextVirtualBagSlotId(slot_id)
    while slot_id do
        local item = Item:FromBag(BAG_VIRTUAL, slot_id)
        self:AddItem(item)
        slot_id = GetNextVirtualBagSlotId(slot_id)
    end
end

function Bag:AddItem(item)
    if not item then return end
    self.item_subtotal = self.item_subtotal + item.total_value
    self.item_ct = self.item_ct + 1

        -- We don't actually NEED itemized lists here, except for debugging
        -- or checking our work. ToDString() is sufficient, and allows us to
        -- fit all 8 characters + bank and craftbag all under 1MB.
        --
        -- 8x data compression just by omitting links and storing only
        -- strings instead of structured data:
        --
        -- 256KB structured, with links
        --  96KB structured, without links
        --  29KB as strings, without links
    table.insert(self.items, item:ToDString())
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
    self.char_index = self:FindCharIndex()
    self:CreateSettingsWindow()
    --EVENT_MANAGER:UnregisterForEvent(self.name, EVENT_ADD_ON_LOADED)
    EVENT_MANAGER:RegisterForEvent( ZZHousingInventory.name .. "TH"
                              , EVENT_OPEN_TRADING_HOUSE
                              , ZZHousingInventory.OnOpenTradingHouse
                              )

end

-- Return the bag index for this character, if it already has one, or a new
-- index if not.
function ZZHousingInventory:FindCharIndex()
    local char_name = GetUnitName("player")
    for i, bag in ipairs(self.savedVariables.bag) do
        if bag.name == char_name then return i end
    end
    return 1 + #self.savedVariables.bag
end

-- Trading House listings ----------------------------------------------------

local TH_DELAY_MS = 0.750 * 1000

-- Trading house listings can only be fetched while the trading house UI is
-- open. This means we have to do this when the Settings/ZZHousingInventory UI is closed.
-- Quietly do this on open of guild listings.

-- And there's a long chain of async calls that need clock time to complete (no
-- event notification? Boo!)

function ZZHousingInventory.OnOpenTradingHouse()
    if not ZZHousingInventory.savedVariables.enable_guild_scan then return end

                        -- How many times will we wait for
                        -- GetNumTradingHouseListings() to start returning results?
    ZZHousingInventory.th_retry_rem_ct = 3

                        -- Have we successfully switched guilds since
                        -- opening this one? If we never do, then we're probably
                        -- shopping at some other guild, and not at a bank
                        -- looking at our own guilds. Only want to reset our
    ZZHousingInventory.th_switched_successfully = false

    zo_callLater(function() ZZHousingInventory:TradingHouseAsync0StartGuild(1) end, TH_DELAY_MS)
end

-- Switch to guild N
function ZZHousingInventory:TradingHouseAsync0StartGuild(guild_index)
    local guild_ct = GetNumTradingHouseGuilds()
    if guild_ct < guild_index then
        ZZHousingInventory:TradingHouseScanComplete()
        return
    end

    -- Try to switch to that guild. If not, repeat attempt later.
    local is_switched = ZZHousingInventory:TradingHouseSwitchTo(guild_index)
    d("ZZHousingInventory:TradingHouseAsync0StartGuild idx:" .. tostring(guild_index)
        .. "  switched:" .. tostring(is_switched))
    if not is_switched then
        self.th_retry_rem_ct = self.th_retry_rem_ct - 1
        if self.th_retry_rem_ct < 0 then
            d("ZZHousingInventory:TradingHouseAsync0StartGuild giving up. Cannot switch guilds here.")
            return
        else
            zo_callLater(function() ZZHousingInventory:TradingHouseAsync0StartGuild(guild_index) end, TH_DELAY_MS)
            return
        end
    end

                        -- If this is our first switch to a guild, then we're
                        -- just starting and now would be a good time to erase
                        -- memory of guild totals, since guild indices change
                        -- from run to run and we end up double-counting guilds
                        -- if we don't forget previous runs.
    if not self.th_switched_successfully then
        self.th_switched_successfully = true
        -- self.trading_house = {}
        self.savedVariables.trading_house = {}
    end

    -- If this guild lacks a guild store, skip to next.
    local curr_guild_id = GetSelectedTradingHouseGuildId()
    if not CanSellOnTradingHouse(curr_guild_id) then
        -- if not self.trading_house then self.trading_house = {} end
        -- self.trading_house[guild_index] = 0
        -- self.savedVariables.trading_house[guild_index] = 0
        local next_guild_index = guild_index + 1
        zo_callLater(function() ZZHousingInventory:TradingHouseAsync0StartGuild(next_guild_index) end, TH_DELAY_MS)
        return
    end

    -- Request guild store listings.
    zo_callLater(function() ZZHousingInventory:TradingHouseAsync1Request(guild_index) end, TH_DELAY_MS)
end

-- If not already on the requested guild_index, switch.
-- Return true if now on that guild.
function ZZHousingInventory:TradingHouseSwitchTo(guild_index)
    local curr_guild_id = GetSelectedTradingHouseGuildId()
    local want_guild_id = GetTradingHouseGuildDetails(guild_index)
    if curr_guild_id == want_guild_id then
        return true
    end
    local is_switched = SelectTradingHouseGuildId(want_guild_id)
    return is_switched
end

-- Ask server to send us our sales listings.
function ZZHousingInventory:TradingHouseAsync1Request(guild_index)
    d("ZZHousingInventory.TradingHouseAsync1Request idx:" .. tostring(guild_index))
    RequestTradingHouseListings()

    zo_callLater(function() ZZHousingInventory:TradingHouseAsync2Scan(guild_index) end, TH_DELAY_MS)
end

-- Process sales listings that the server sent us.
function ZZHousingInventory:TradingHouseAsync2Scan(guild_index)
    d("ZZHousingInventory.TradingHouseAsync2Scan idx:" .. tostring(guild_index))
    local guild_total = ZZHousingInventory:TradingHouseScanOneGuild(guild_index)
    -- No results yet? Try again later.
    if 0 == guild_total and 0 < self.th_retry_rem_ct then
        self.th_retry_rem_ct = self.th_retry_rem_ct - 1
        zo_callLater(function() ZZHousingInventory:TradingHouseAsync2Scan(guild_index) end, TH_DELAY_MS)
        return
    end

    -- Store results.
    if not self.trading_house then self.trading_house = {} end
    -- self.trading_house[guild_index] = guild_total
    self.savedVariables.trading_house[guild_index] = guild_total

    -- Done with this guild. Start the next one.
    local next_guild_index = guild_index + 1
    zo_callLater(function() ZZHousingInventory:TradingHouseAsync0StartGuild(next_guild_index) end, TH_DELAY_MS)
end

-- Scan one guild's listings, return total listing price
-- (Listing price does NOT have guild/zos tax subtracted)
function ZZHousingInventory:TradingHouseScanOneGuild(guild_index)
    local listing_ct = GetNumTradingHouseListings()
    local guild_total = 0
    for listing_index = 1, listing_ct do
        local icon, item_name, quality, stack_ct, seller_name
            , time_remaining, purchase_price
                 = GetTradingHouseListingItemInfo(listing_index)
        if purchase_price then
            guild_total = guild_total + purchase_price
        end
    end
    d("ZZHousingInventory:TradingHouseScan idx:" .. guild_index
            .. " gold:" .. ZO_CurrencyControl_FormatCurrency(guild_total, false)
            .. "  listing_ct:" .. tostring(listing_ct))
    return guild_total
end

function ZZHousingInventory:TradingHouseScanComplete()
    local total = 0
    if not self.savedVariables.trading_house then return end
    for guild_index, listing_total in pairs(self.savedVariables.trading_house) do
        if listing_total then
            total = total + listing_total
            --d("idx: " .. tostring(guild_index) .. " " .. tostring(listing_total))
        end
    end
    d("ZZHousingInventory:TradingHouseScanComplete total:" .. ZO_CurrencyControl_FormatCurrency(total, false))
end

-- UI ------------------------------------------------------------------------

function ZZHousingInventory:CreateSettingsWindow()
    local panelData = {
          type                = "panel"
        , name                = "Net Worth"
        , displayName         = "Net Worth"
        , author              = "ziggr"
        , version             = self.version
        , slashCommand        = "/nn"
        , registerForRefresh  = true
        , registerForDefaults = false
    }
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel( self.name
                                                     , panelData
                                                     )
    local optionsData = {
        { type      = "button"
        , name      = "Scan Now"
        , tooltip   = "Fetch inventory data now."
        , func      = function() self:ScanNow() end
        },

        { type      = "description"
        , text      = ""
        , width     = "half"
        , reference = "ZZHousingInventory_desc_bags"
        },

        { type      = "description"
        , text      = ""
        , width     = "half"
        , reference = "ZZHousingInventory_desc_amounts"
        },

    }

    table.insert(optionsData,
        { type    = "header"
        , name    = "Knobs"
        })

    table.insert(optionsData,
        { type      = "checkbox"
        , name      = "Scan guild store listings"
        , tooltip   = "Scan all five guild stores for items you have for sale."
                      .." Very annoying."
        , getFunc   = function()
                        return self.savedVariables.enable_guild_scan
                      end
        , setFunc   = function(e)
                        self.savedVariables.enable_guild_scan = e
                      end
        })


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
    local bag_name   = {}
    local bag_amount = {}
    local total      = 0
    local total_gold = 0
    local total_item = 0
    for i, bag in ipairs(self.savedVariables.bag) do
        bag_name  [i] = bag.name
        bag_amount[i] = ZO_CurrencyControl_FormatCurrency(bag.gold + bag.item_subtotal, false)
        total = total + bag.gold + bag.item_subtotal
        total_gold = total_gold + bag.gold
        total_item = total_item + bag.item_subtotal
    end

    local total_listings = 0
    if self.savedVariables.trading_house then
        for i, guild_list_total in pairs(self.savedVariables.trading_house) do
            total_listings = total_listings + guild_list_total
            -- d(tostring(i) .. ":  + " .. tostring(guild_list_total)
            --         .. " = " .. tostring(total_listings))
        end
    end

    total = total + total_listings
    table.insert(bag_name,   "--")
    table.insert(bag_name,  "total")
    table.insert(bag_amount, "--")
    table.insert(bag_amount, ZO_CurrencyControl_FormatCurrency(total, false))
    table.insert(bag_name,   "")
    table.insert(bag_amount, "")
    table.insert(bag_name,   "in gold")
    table.insert(bag_name,   "in inventory")
    table.insert(bag_name,   "in listings")
    table.insert(bag_amount, ZO_CurrencyControl_FormatCurrency(total_gold, false))
    table.insert(bag_amount, ZO_CurrencyControl_FormatCurrency(total_item, false))
    table.insert(bag_amount, ZO_CurrencyControl_FormatCurrency(total_listings, false))

    local sn = table.concat(bag_name,   "\n")
    local sa = table.concat(bag_amount, "\n")

    ZZHousingInventory_desc_bags.data.text    = sn
    ZZHousingInventory_desc_amounts.data.text = sa
    ZZHousingInventory_desc_bags.desc:SetText(sn)
    ZZHousingInventory_desc_amounts.desc:SetText(sa)
end

-- Fetch Inventory Data from the server ------------------------------------------

function ZZHousingInventory:ScanNow()
    local char_name = GetUnitName("player")
    local ci = self.char_index
    self.bag = { [1 ] = Bag:FromName(ZZHousingInventory.NAME_BANK)
               , [2 ] = Bag:FromName(ZZHousingInventory.NAME_CRAFT_BAG)
               , [ci] = Bag:FromName(char_name)
               }
    self.bag[1 ]:ReadFromServer()
    self.bag[2 ]:ReadFromServer()
    self.bag[ci]:ReadFromServer()

    self.savedVariables.bag[1 ] = self.bag[1 ]
    self.savedVariables.bag[2 ] = self.bag[2 ]
    self.savedVariables.bag[ci] = self.bag[ci]

    self:UpdateDisplay()
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
