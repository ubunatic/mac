.PHONY: all clean build release

SOURCES = $(shell find Sources -name '*.swift')

all: build

clean:
	rm -rf .build script

build: $(SOURCES)
	swift build -c release --disable-sandbox

release: build
	# TODO: update version
	git tag mousepaste-v0.0.1

include Make.local.mk
