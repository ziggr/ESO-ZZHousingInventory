.PHONY: send get csv

put:
	#git commit -am auto
	cp -f ./ZZHousingInventory.lua /Volumes/Elder\ Scrolls\ Online/live/AddOns/ZZHousingInventory/

get:
	cp -f /Volumes/Elder\ Scrolls\ Online/live/SavedVariables/ZZHousingInventory.lua ../../SavedVariables/
	cp -f ../../SavedVariables/ZZHousingInventory.lua data/

