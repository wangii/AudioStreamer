XCB           = xcodebuild
CONFIGURATION = Release
XCBFLAGS      = -configuration $(CONFIGURATION)

all: framework

framework:
	$(XCB) $(XCBFLAGS) -target AudioStreamer

archive:
	$(XCB) -configuration Release -target 'Build sparkle metadata'

clean:
	$(XCB) clean
	rm -rf build
