.PHONY: all

RESOURCES=../Sources/Mousepaste/Resources

all: $(RESOURCES)/Mousepaste.icns $(RESOURCES)/Mousepaste.svg

# TODO: find how to safely and effectively load SVGs
# requires support for tinting and scaling as NSImage or Image)
$(RESOURCES)/Mousepaste.svg: Mousepaste.svg
	cp $^ $@

SIZES=512 256 128 32
$(RESOURCES)/Mousepaste.icns: Mousepaste.svg
	mkdir -p Mousepaste.iconset
	for w in $(SIZES); do \
	s=$$w"x"$$w; convert -background none -filter lagrange -resize "$$s" $^ "Mousepaste.iconset/icon_$$s.png"& \
	done && wait
	@test $(SIZES) = "32 16" || echo # use SIZES="32 16" to regenerate small-pixel images
	iconutil -c icns -o $@ Mousepaste.iconset
