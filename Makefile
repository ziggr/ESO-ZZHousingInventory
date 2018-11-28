.PHONY: send get csv

put:
	cp -f ./ZZHousingInventory.lua /Volumes/Elder\ Scrolls\ Online/live/AddOns/ZZHousingInventory/

	rsync -vrt --delete --exclude=.git \
		--exclude=published \
		--exclude=doc \
		--exclude=data \
		--exclude=test \
		--exclude=Libs/LibPrice/.git \
		. /Volumes/Elder\ Scrolls\ Online/live/AddOns/ZZHousingInventory

get:
	cp -f /Volumes/Elder\ Scrolls\ Online/live/SavedVariables/ZZHousingInventory.lua data/

