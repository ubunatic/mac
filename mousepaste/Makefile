.PHONY: all clean build release

SOURCES = $(shell find Sources -name '*.swift')
VERSION = v0.0.1
NAME    = mousepaste
RELEASE_TAG = $(NAME)-$(VERSION)

all: build

clean:
	rm -rf .build script

build: $(SOURCES)
	swift build -c release --disable-sandbox

release: build
	# TODO: publish binaries
	git diff
	@echo "release $(RELEASE_TAG) (y/N)?"
	git add Makefile && git commit -m "release $(RELEASE_TAG)"
	git tag $(RELEASE_TAG)
	read key && test "$$key"=y && git push && git push --tags

include Make.local.mk
