.PHONY: install uninstall script run

SOURCES ?= $(shell find Sources -name '*.swift')
SCRIPT   = script/mousepaste.swift

prefix ?= /usr/local
bindir ?= $(prefix)/bin

install:
	install -d "$(bindir)"
	install ".build/release/Mousepaste" "$(bindir)/Mousepaste"

uninstall:
	rm -rf "$(bindir)/Mousepaste"

# Produce XCode-free and workaround-free script version by
# cating all code to one file.
$(SCRIPT): $(SOURCES)
	mkdir -p script
	./generate.sh > $@
	chmod +x $@

script: $(SCRIPT)
run:    $(SCRIPT); $^
