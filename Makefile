APP_NAME  := leanshot
BUNDLE_ID := com.kuberwastaken.leanshot
VERSION   := $(shell cat VERSION)
SRC       := src/leanshot.applescript
MASTER    := assets/leanshot-1024.png
ICON      := assets/leanshot.icns
BUILD     := build
APP       := $(BUILD)/$(APP_NAME).app
PREFIX    ?= $(HOME)/Applications

.PHONY: all build icon install uninstall dist run clean

all: build

## icon: (re)build assets/leanshot.icns from the 1024px master
icon: $(ICON)

$(MASTER):
	@echo "error: $(MASTER) is missing (it's a committed design asset)"; exit 1

$(ICON): $(MASTER) scripts/make-icon.sh
	scripts/make-icon.sh

## build: compile the AppleScript into build/leanshot.app
build: $(APP)

$(APP): $(SRC) $(ICON) VERSION
	@mkdir -p $(BUILD)
	rm -rf $(APP)
	osacompile -o $(APP) $(SRC)
	plutil -replace LSUIElement -bool true $(APP)/Contents/Info.plist
	plutil -replace CFBundleIdentifier -string $(BUNDLE_ID) $(APP)/Contents/Info.plist
	plutil -replace CFBundleName -string $(APP_NAME) $(APP)/Contents/Info.plist
	plutil -replace CFBundleShortVersionString -string $(VERSION) $(APP)/Contents/Info.plist
	cp $(ICON) $(APP)/Contents/Resources/applet.icns
	codesign --force -s - $(APP) >/dev/null 2>&1 || true
	@echo "built $(APP) (v$(VERSION))"

## install: copy to ~/Applications and launch it now + at every login
install: build
	@pkill -f '$(APP_NAME).app/Contents/MacOS' >/dev/null 2>&1 || true
	rm -rf "$(PREFIX)/$(APP_NAME).app"
	@mkdir -p "$(PREFIX)"
	cp -R $(APP) "$(PREFIX)/"
	osascript -e 'tell application "System Events" to if not (exists login item "$(APP_NAME)") then make login item at end with properties {name:"$(APP_NAME)", path:"$(PREFIX)/$(APP_NAME).app", hidden:true}'
	open "$(PREFIX)/$(APP_NAME).app"
	@echo "installed -> $(PREFIX)/$(APP_NAME).app  (running now, and at every login)"

## uninstall: stop it, remove the login item, delete the app
uninstall:
	-@pkill -f '$(APP_NAME).app/Contents/MacOS' >/dev/null 2>&1
	-osascript -e 'tell application "System Events" to if (exists login item "$(APP_NAME)") then delete login item "$(APP_NAME)"'
	rm -rf "$(PREFIX)/$(APP_NAME).app"
	@echo "uninstalled $(APP_NAME)"

## dist: package the app into build/leanshot-<version>.zip
dist: build
	cd $(BUILD) && ditto -c -k --keepParent $(APP_NAME).app $(APP_NAME)-$(VERSION).zip
	@echo "packaged $(BUILD)/$(APP_NAME)-$(VERSION).zip"

run: build
	open $(APP)

clean:
	rm -rf $(BUILD)
