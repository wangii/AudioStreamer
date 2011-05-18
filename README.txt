README for TyreeApps Streaming Player TapLynx Plugin

This project is a repackaging of Matt Gallagher's AudioStreamer project as a TapLynx plugin. 

The player is configured via the regular TapLynx configuration file (NGConfig.plist). This means
that you can use all of the regular NGConfig settings for title, tab icon, color, etc.

Configuration parameters specific to this plugin are:
"customViewControllerClass": "TAStreamingPlayer"
"Streams": An array of dictionaries of streams. Each dictionary contains:
- "url": a string of the url of the stream
- "Title": a string of the title of the stream
There is a sample file in this plugin called sample.plist which you can copy and paste into
an existing NGConfig tab entry.

Before you Install:
This is not a complete application it will not stand alone. You need to download and install a TapLynx
application first. You can find out all about TapLynx and download the library from www.taplynx.com

To Install:

1) Add CFNetwork.framework and AudioToolbox.framework frameworks to your TapLynx iPhone project.
XCode 3
To add an existing framework, right click on the Groups & Files tree and select Add -> Existing Frameworks...
then choose from the list.

XCode 4
To add an existing framework, right click on the Groups & Files tree and select Add -> Existing Frameworks...
then choose from the list.


2) Add the contents of the this repository folder to the project.
To add existing files to a framework, click the project icon -> Build Phases. Then expand the "Link binary with libraries" option and click the plus to add a new library. Choose from the list and find the folder for the repository and click add.

3) Modify the NGConfig to add keys to hook in the View

4) Use Interface Builder to change the TAStreamingPlayer.xib if you want to change the look.

Notes:
I have tested this with .mp3 streams only. Note well that the simulator will handle file types that a device
will not handle! You must test your streams on a device! A number of people have forked Matt's original project to
add support for other types of media. This library only makes calls to the AudioStreamer files so it is possible
that you can incorporate someone else's fork without a lot of work on your part.

The UIPicker only appears when there are multiple streams. If you only specify one stream then the UIPicker will
not appear and the title of the stream will be visible in the UITextView that is in the .xib file.

The scrubber and time only appear when you are streaming a file with a finite end. When streaming something
that goes on forever (like a radio station) the scrubber and time hide themselves since they are irrelevant.

Internationalization:
There is only one string in the plug in. It is called Time Played:. If you want to change that string or internationalize 
the string simply add a line like this one at the end of the main TapLynx localizable.strings file.

/* TA Audio Streamer */
"Time Played:" = "Tid spelat:";

If you don't add any entries to the localizable.strings file then the default of Time Played: will be displayed.

