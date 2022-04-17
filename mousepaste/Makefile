.PHONY: all clean build release

SOURCES = $(shell find Sources -name '*.swift')
VERSION = v0.0.1
NAME    = mousepaste
RELEASE_TAG = $(NAME)-$(VERSION)

all: build

clean:
	rm -rf .build script

build: $(SOURCES)
	swift build --disable-sandbox

release: build
	swift build -c release --disable-sandbox
	# TODO: publish binaries
	@echo "releasing $(RELEASE_TAG), press Enter to continue or Ctrl-C to abort"
	@read key
	git add Makefile && git commit -m "release $(RELEASE_TAG)"
	git tag $(RELEASE_TAG)
	git push && git push --tags

include Make.local.mk
