XCB           = xcodebuild
CONFIGURATION = Release
XCBFLAGS      = -configuration $(CONFIGURATION)

.PHONY: doc

all: framework mac iphonelib iphone

framework:
	$(XCB) $(XCBFLAGS) -target AudioStreamer

mac:
	$(XCB) $(XCBFLAGS) -target 'Mac Streaming Player'

iphonelib: XCBFLAGS += -sdk iphoneos
iphonelib:
	$(XCB) $(XCBFLAGS) -target 'libAudioStreamer'

iphone: XCBFLAGS += -sdk iphoneos
iphone:
	$(XCB) $(XCBFLAGS) -target 'iPhone Streaming Player'

doc:
	appledoc --project-name AudioStreamer --project-company '_' \
		--company-id '_' --no-repeat-first-par -o doc \
		--docset-install-path doc --ignore AudioStreamer.m AudioStreamer

clean:
	$(XCB) clean
	rm -rf build
