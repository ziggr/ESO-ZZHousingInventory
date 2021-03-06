# 2018 Rewrite

Flat rows, no tree.

```
fields
	container	house_id
				coffer_id
				"collectibles" to hold
					the actual coffers themselves,
					banker,
					merchant
	item_id
	item_name
	item_link
	furniture_id
	furniture_data_id
	item_ct 	for this container only

	value_mm
		gold 	mm.avgPrice
	value_att
		gold 	att.avgPrice
	value_ttc
		gold 	ttc.Avg
	value_furc
		gold
		crowns
		vouchers
		desc
```

And a special row that we put into houses:
	"item_name" = "house itself"
	and set the purchase value accordingly in value_furc sub-fields

YES do fill in multiple fields for gold, crowns, vouchers when items
are purchasable that way.


# 2018 todo

## FurC parse failures
- [x] Why is LibPrice.FurC not parsing out prices for some items?
	- [x] Rolis name typo
	- [x] achievement vendor logic failure
	- [x] [Craftable Furniture](#Craftable%20Furniture) below

## House Purchase Row
- [x] Need house purchase row, for the name if nothing else. Make that row #1 !


## Collectibles
- [x] How to detect Tythis and other collectibles? We have their link, could convert that to a collectible ID trivially. Lookup table of known crown costs?
- [x] I want a collectible_id column. Extract here so that later code doesn't have to think.

## Containers
- [x] Have not yet tested diving into containers

## Craftable Furniture
Going to have to do something about craftable furnishings.
Probably parse out the ingredient list from furc_desc, and sum it up

```
"15x |H0:item:33254:30:1:0:0:0:0:0:0:0:0:0:0:0:0:34:0:0:0:0:0|h|h,
 8x |H0:item:114892:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h,
 11x |H0:item:114893:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h,
  7x |H0:item:114894:30:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
```
could convert to:
```
value_furc_mat_list = {
	{ item_ct = 12, item_id = 33254 }
,   { item_ct =  8, item_id = 114892 }
,   { item_ct = 11, item_id = 114893 }
,   { item_ct =  7, item_id = 114894 }
}
```
Then we could accumulate material item_id in a separate table and output it with LibPrice data just like any other rows
```
["materials"] = { rows just as above, but for mats }
```
Now it's up to later code to sum up all the item_ct by matching item_id, then choose a price lookup.

## Not a lot of MM/ATT data

Probably because I'm no longer in three top-tier trading guilds.
Oh well. I'm not re-joining just to get new data.


# Relevant API

GetCurrentZoneHouseId()
Returns: number houseId

GetPlayerLocationName()
Returns: string mapName

--
GetNextPlacedHousingFurnitureId(id64:nilable lastFurnitureId)
Returns: id64:nilable nextFurnitureId

GetPlacedHousingFurnitureInfo(id64 furnitureId)
Returns: string itemName, textureName icon, number furnitureDataId

GetPlacedHousingFurnitureQuality(id64 furnitureId)
Returns: number ItemQuality quality

GetPlacedFurnitureLink(id64 placedFurnitureId, number LinkStyle linkStyle)
Returns: string itemLink, string collectibleLink

-- furnitureId:
GetFurnitureIdFromCollectibleId(number collectibleId)
Returns: id64 furnitureId

GetCollectibleIdFromFurnitureId(id64 furnitureId)
Returns: number collectibleId

GetItemUniqueIdFromFurnitureId(id64 furnitureId)
Returns: id64 itemUniqueId

GetFurnitureIdFromItemUniqueId(id64 itemUniqueId)
Returns: id64 furnitureId

-- furnitureDataId
GetItemFurnitureDataId(number Bag bagId, number slotIndex)
Returns: number furnitureDataId

GetItemLinkFurnitureDataId(string itemLink)
Returns: number furnitureDataId

GetCollectibleFurnitureDataId(number collectibleId)
Returns: number furnitureDataId

GetFurnitureDataInfo(number furnitureDataId)
Returns: number:nilable categoryId, number:nilable subcategoryId, number FurnitureThemeType furnitureTheme

GetFurnitureDataCategoryInfo(number furnitureDataId)
Returns: number:nilable categoryId, number:nilable subcategoryId

# Furniture Catalogue

```lua
	itemId 		= FurC.GetItemId(itemLink)
	recipeArray = FurC.Find(itemLink)
	sourceString = FurC.GetItemDescription(itemId, recipeArray)
```
sourceString is "Sold by Rohzika (Rivenspire, Shornhelm, Dead Wolf Inn, 250)"

But need to dig deeper if I want to fetch that "250" as an integer gold amount

```lua
function FurC.GetItemDescription(recipeKey, recipeArray, stripColor)
	recipeArray = recipeArray or FurC.Find(recipeKey, recipeArray)
	if not recipeArray then return "" end
	local origin = recipeArray.origin
	if origin == FURC_CRAFTING then
		return FurC.GetMats(recipeKey, recipeArray, stripColor)
	elseif origin == FURC_ROLLIS then
		return FurC.getRollisSource(recipeKey, recipeArray, stripColor)
	elseif origin == FURC_LUXURY then
		return FurC.getLuxurySource(recipeKey, recipeArray, stripColor)
	elseif origin == FURC_GUILDSTORE then
		return FURC_STRING_TRADINGHOUSE
	elseif origin == FURC_VENDOR then
		return FurC.getAchievementVendorSource(recipeKey, recipeArray, stripColor)
	elseif origin == FURC_FESTIVAL_DROP then
		return FurC.getEventDropSource(recipeKey, recipeArray, stripColor)
	elseif origin == FURC_PVP then
		return FurC.getPvpSource(recipeKey, recipeArray, stripColor)
	elseif origin == FURC_RUMOUR then
		return FurC.getRumourSource(recipeKey, recipeArray), stripColor
	else
		itemSource = FurC.GetMiscItemSource(recipeKey, recipeArray, stripColor)
	end
	return itemSource or GetString(SI_FURC_ITEMSOURCE_EMPTY)
end
```
For the most part, the look seems to be
	specific data table
		[recipeKey] = integer cost (in gold, vouchers, whatever)
		or
		[recipeKey].itemPrice = integer cost

FurC.LuxuryFurnisher[FURC_MORROWIND] = {
	-- August 5+6
	[126573] = { -- Velothi Candle, Mourning
		itemPrice 	= 5417,
		itemDate	= "2017-08-11",
	},
	...

FurC.PVP[FURC_HOMESTEAD] = {
	[FURC_ITEMSOURCE_VENDOR] = {
		[FURC_CYRO] = {
			[119656] = {	-- Pennant, Small
				itemPrice 	= 200,
				achievement = 92,	-- Volunteer
			},
	...

Many are priceless, have just an empty table

FurC.EventItems[FURC_HOMESTEAD] = {
	["Jester Festival"] = {
		["Jester Boxes"] = {
			[120995] = {}, 	-- Banner, Jester's Standard
		}
	}

FurC.Rollis[FURC_HOMESTEAD] = {
	-- Alchemy station
	[118328] = 35,
...
	-- Attunable Blacksmithing station
	[119594] = 250,
...

FurC.Faustina[FURC_DRAGONS] = {
	[134675] = 1500,
}

Misc items are strings (!) of varying format.
No chance for a consistent parse. Sorry.

FurC.MiscItemSources 	= {
	[FURC_DRAGONS] = { -- Reach
		[FURC_CROWN] 	= {
			[130212] = FURC_CROWNSTORE_ONEK, 		-- Daedric Worship: The Ayleids
			[134970] = FURC_CROWNSTORE_ONEHUNDRED, 	-- Mushrooms, Glowing Sprawl
			[134947] = FURC_CROWNSTORE_ONEHUNDRED, 	-- Mushrooms, Glowing Field
			[134948] = FURC_CROWNSTORE_FOURHUNDRED,	-- Mushrooms, Glowing Cluster
			...
	[FURC_CLOCKWORK] = { -- Reach
		[FURC_DROP] = {
			[134407] = FURC_AUTOMATON_CC,			-- Torso, Obsolete
			[134404] = FURC_AUTOMATON_CC,			-- Factotum Knee, Obsolete

local FURC_CROWNSTORESOURCE				= "Crown Store "
local FURC_CROWNSTORE_ONEHUNDRED		= FURC_CROWNSTORESOURCE .. "(100)"
local FURC_CROWNSTORE_FOURHUNDRED		= FURC_CROWNSTORESOURCE .. "(400)"
local FURC_CROWNSTORE_ONEK				= FURC_CROWNSTORESOURCE .. "(1000)"

local FURC_AUTOMATON 					= "from automatons"
local FURC_AUTOMATON_CC					= FURC_AUTOMATON .. " in Clockwork City"



So for FurC parsing, I think it goes
	-- if val is number, use that
	-- if val is table and val.itemPrice is number, use that
	-- units (gold, crown, tv, ap) inferred from source (need source->unit table)
	-- if val is string, try to parse out a single r'\d+' number?

