APP := koe.app
BIN := .build/release/koe
SIGN_IDENTITY ?= koe-dev
INSTALL_DIR ?= /Applications

.PHONY: build test app run install clean signing-cert

build:
	swift build -c release

test:
	swift run KoeTests

signing-cert:
	./scripts/create-signing-cert.sh

app: build
	rm -rf $(APP)
	mkdir -p $(APP)/Contents/MacOS $(APP)/Contents/Resources
	cp $(BIN) $(APP)/Contents/MacOS/koe
	cp Resources/Info.plist $(APP)/Contents/Info.plist
	@if security find-identity -p codesigning | grep -q '"$(SIGN_IDENTITY)"'; then \
		codesign --force --sign "$(SIGN_IDENTITY)" $(APP) && \
		echo "Built $(APP) (signed: $(SIGN_IDENTITY) — permissions persist across rebuilds)"; \
	else \
		codesign --force --sign - $(APP) && \
		echo "Built $(APP) (ad-hoc — run 'make signing-cert' for stable permissions)"; \
	fi

run: app
	open $(APP)

# Install into /Applications so Spotlight / Raycast / Launchpad can launch it
# like any app. Override the location with: make install INSTALL_DIR=~/Applications
install: app
	rm -rf "$(INSTALL_DIR)/koe.app"
	cp -R $(APP) "$(INSTALL_DIR)/koe.app"
	@echo "Installed → $(INSTALL_DIR)/koe.app (launch via Spotlight / Raycast)"

clean:
	rm -rf .build $(APP)
