README for TyreeApps Streaming Player TapLynx Plugin

This project is a repackaging of the AudioStreamer project as a TapLynx plugin. 

The player is configured via the regular TapLynx configuration file (NGConfig.plist). Configuration parameters are:
"Title": The title of the player
"ShortTitle": The title to put on the tab
"TabImageName": The image to use for the tab
"customViewControllerClass": "TAStreamingPlayer"
"Streams": An array of dictionaries of streams. Each dictionary contains:
- "url": a string of the url of the stream
- "Title": a string of the title of the stream


To Install:
1) Add CFNetwork.framework and AudioToolbox.framework frameworks to your iPhone project.
To add an existing framework, right click on the Groups & Files tree and select Add -> Existing Frameworks...
then choose from the list.

2) Add the contents of the TAAudioStreamer folder to the project.
To add existing files to a framework, right click on the Groups & files tree and select Add -> Existing Files...
then find the TAAudioStreamer folder and click add.

3) Modify the NGConfig to add keys to hook in the View

4) Use Interface Builder to change the TAStreamingPlayer.xib if you want to change the look.

Notes:


Internationalization:
There is only one string in the plug in. It is called Time Played:. If you want to change that string or internationalize 
the string simply add a line like this one at the end of the main TapLynx localizable.strings file.

/* TA Audio Streamer */
"Time Played:" = "Tid spelat:";

If you don't add any entries to the localizable.strings file then the default of Time Played: will be displayed.

