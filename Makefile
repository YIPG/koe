APP := koe.app
BIN := .build/release/koe

.PHONY: build test app run clean

build:
	swift build -c release

test:
	swift run KoeTests

app: build
	rm -rf $(APP)
	mkdir -p $(APP)/Contents/MacOS $(APP)/Contents/Resources
	cp $(BIN) $(APP)/Contents/MacOS/koe
	cp Resources/Info.plist $(APP)/Contents/Info.plist
	codesign --force --sign - $(APP)
	@echo "Built $(APP)"

run: app
	open $(APP)

clean:
	rm -rf .build $(APP)
