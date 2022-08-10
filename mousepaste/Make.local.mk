.PHONY: install uninstall run rund open run-open stop watch develop

SOURCES ?= $(shell find Sources -name '*.swift')
ARGS    ?= --debug
PREFIX  ?= /opt/mousepaste
BINDIR   = Mousepaste.app/Contents/MacOS
RESDIR   = Mousepaste.app/Contents/Resources

install: Mousepaste.app
	install -d "$(PREFIX)/$(BINDIR)"
	install -d "$(PREFIX)/$(RESDIR)"
	install $(BINDIR)/Mousepaste      "$(PREFIX)/$(BINDIR)"
	install $(RESDIR)/Mousepaste.icns "$(PREFIX)/$(RESDIR)"
	install $(RESDIR)/Mousepaste.svg  "$(PREFIX)/$(RESDIR)"
	# Please add $(PREFIX)/$(BINDIR) to your PATH.
	#
	#    export PATH="$$PATH:$(PREFIX)/$(BINDIR)"
	#
	# Then run the app using the `Mousepaste` binary (try `Mousepaste -h`)

uninstall:
	rm -rf "$(bindir)/Mousepaste"

open run-open: stop
	# running Mousepaste.app
	open Mousepaste.app -W || "app start failed"

run: stop
	# running Mousepaste binary directly
	./Mousepaste.app/Contents/MacOS/Mousepaste $(ARGS)

rund: stop
	# running Mousepaste detached
	@$(MAKE) run&
	# app started in background

stop:
	@pkill Mousepaste && echo "Mousepaste stopped" || echo "Mousepaste not running"

watch:
	# waiting for ./Sources changes...
	@fswatch -1 ./Sources

develop:
	make stop build app rund watch develop DEBUG=1
