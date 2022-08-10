.PHONY: all clean build install publish app

SOURCES     = $(shell find Sources -name '*.swift')
VERSION     = v0.0.1
NAME        = Mousepaste
DEBUG      ?=
BUILD       = debug
APP         = $(NAME).app
BINARY      = .build/$(BUILD)/$(NAME)
RESOURCES   = .build/$(BUILD)/$(NAME)_$(NAME).bundle
RELEASE_TAG = mousepaste-$(VERSION)

export DEBUG

all: build app

clean:
	rm -rf .build
	rm -rf "$(APP)"

build: $(SOURCES)
	rm -f $(BINARY)
	$(MAKE) -C Icons
	swift build -c $(BUILD) --disable-sandbox

app: build
	rm -rf "$(APP)"
	mkdir -p $(APP)/Contents/{MacOS,Plugins}
	# mkdir -p $(APP)/Contents/Frameworks
	cp -r $(BINARY) $(APP)/Contents/MacOS/
	cp -r $(BINARY)_$(NAME).bundle $(APP)/Contents/Resources
	# copied resources:
	ls -la $(APP)/Contents/Resources

publish:
	# TODO: publish binaries
	@echo "releasing $(RELEASE_TAG), press Enter to continue or Ctrl-C to abort"
	@read key
	git add Makefile && git commit -m "release $(RELEASE_TAG)"
	git tag $(RELEASE_TAG)
	git push && git push --tags

include Make.local.mk
