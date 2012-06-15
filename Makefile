XCB           = xcodebuild
CONFIGURATION = Release
XCBFLAGS      = -configuration $(CONFIGURATION)

all: framework library

framework:
	$(XCB) $(XCBFLAGS) -target AudioStreamer

library:
	$(XCB) $(XCBFLAGS) -target libAudioStreamer

archive:
	$(XCB) -configuration Release -target 'Build sparkle metadata'

clean:
	$(XCB) clean
	rm -rf build
