APP := koe.app
BIN := .build/release/koe
SIGN_IDENTITY ?= koe-dev

.PHONY: build test app run clean signing-cert

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

clean:
	rm -rf .build $(APP)
