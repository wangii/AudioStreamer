XCB           = xcodebuild
CONFIGURATION = Release
XCBFLAGS      = -configuration $(CONFIGURATION)

all: framework mac iphone

framework:
	$(XCB) $(XCBFLAGS) -target AudioStreamer

mac:
	$(XCB) $(XCBFLAGS) -target 'Mac Streaming Player'

iphone:
	$(XCB) $(XCBFLAGS) -target 'iPhone Streaming Player'

clean:
	$(XCB) clean
	rm -rf build
