XCB           = xcodebuild
CONFIGURATION = Release
XCBFLAGS      = -configuration $(CONFIGURATION)

.PHONY: doc

all: framework mac iphone

framework:
	$(XCB) $(XCBFLAGS) -target AudioStreamer

mac:
	$(XCB) $(XCBFLAGS) -target 'Mac Streaming Player'

iphone: XCBFLAGS += -sdk iphonesimulator5.0
iphone:
	$(XCB) $(XCBFLAGS) -target 'iPhone Streaming Player'

doc:
	appledoc --project-name AudioStreamer --project-company '_' \
		--company-id '_' --no-repeat-first-par -o doc \
		--docset-install-path doc --ignore AudioStreamer.m AudioStreamer

clean:
	$(XCB) clean
	rm -rf build
