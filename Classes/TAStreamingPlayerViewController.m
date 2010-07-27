//
//  iPhoneStreamingPlayerViewController.m
//  iPhoneStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Copyright Matt Gallagher 2008. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "TAStreamingPlayerViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@implementation TAStreamingPlayerViewController

@synthesize streams;

#pragma mark -
#pragma mark Initialize for TapLynx

-(id)initWithTabInfo:(NSDictionary *)tabInfo topLevelTab:(NSDictionary *)topLevelTab {
	NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:1]; 
	
	for (NSDictionary *dict in [tabInfo objectForKey:@"Streams"]) {
		[tempArray addObject:[NSArray arrayWithObjects:[dict objectForKey:@"url"],[dict objectForKey:@"Title"],nil ]];
	}
	//The picker doesn't like a dictionary but the dictionary is easier to handle in the plist. So, we convert the dictionary to an array.
	self.streams = [NSArray arrayWithArray:tempArray];
	currentStream = [[self.streams objectAtIndex:0] objectAtIndex:0];
	streamTitle = [[self.streams objectAtIndex:0] objectAtIndex:1];
	return [self initWithNibName:@"TAStreamingPlayerViewController" bundle:nil];
}

#pragma mark -
#pragma mark Picker View Delegate Methods
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	currentStream = [[self.streams objectAtIndex:row] objectAtIndex:0];
	
}

#pragma mark -
#pragma mark picker datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
		return 1;
}

// this will return the count for my data array for the number of rows
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [self.streams count];
}

#pragma mark -
#pragma mark picker delegate

// This will populate the UIPickerView.  We can use the row and component arguments to sift through our datasource
// and populate the rows and columns (components) with data.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
	
		
	NSString *title    = [NSString stringWithFormat:@"%@", [[self.streams objectAtIndex:row] objectAtIndex:1]];
	return title;
	
}



#pragma mark -
#pragma mark AudioStreamer Methods
//
// setButtonImage:
//
// Used to change the image on the playbutton. This method exists for
// the purpose of inter-thread invocation because
// the observeValueForKeyPath:ofObject:change:context: method is invoked
// from secondary threads and UI updates are only permitted on the main thread.
//
// Parameters:
//    image - the image to set on the play button.
//
- (void)setButtonImage:(UIImage *)image
{
	[button.layer removeAllAnimations];
	if (!image)
	{
		[button setImage:[UIImage imageNamed:@"playbutton.png"] forState:0];
	}
	else
	{
		[button setImage:image forState:0];
		
	}
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
			removeObserver:self
			name:ASStatusChangedNotification
			object:streamer];
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
	if (streamer)
	{
		return;
	}

	[self destroyStreamer];
	
	NSString *escapedValue =
		[(NSString *)CFURLCreateStringByAddingPercentEscapes(
			nil,
			(CFStringRef)currentStream,
			NULL,
			NULL,
			kCFStringEncodingUTF8)
		autorelease];

	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	progressUpdateTimer =
		[NSTimer
			scheduledTimerWithTimeInterval:0.1
			target:self
			selector:@selector(updateProgress:)
			userInfo:nil
			repeats:YES];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(playbackStateChanged:)
		name:ASStatusChangedNotification
		object:streamer];
}

//
// viewDidLoad
//
// If there are multiple streams it will set up a picker for the streams.
// If there is only one stream it puts the title into the UITextview
// 
//
- (void)viewDidLoad
{
	[super viewDidLoad];
	//If there are multiple streams then we will make a picker and the user can select any one to play
	if ([self.streams count] > 1) {
		UIPickerView *pv = [[[UIPickerView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,120.0)] autorelease];
		pv.dataSource = self;
		pv.delegate = self;
		pv.showsSelectionIndicator = YES;
		[self.view addSubview:pv];
	
	} else {
		streamTitle.text = [[self.streams objectAtIndex:0] objectAtIndex:1];
	}

	/* Adding the picker makes it so that we cannot really fit the Volume slider. Leaving the code in
	 for anyone who wants to reimplement this functionality 
	MPVolumeView *volumeView = [[[MPVolumeView alloc] initWithFrame:volumeSlider.bounds] autorelease];
	[volumeSlider addSubview:volumeView];
	[volumeView sizeToFit];
	*/
	
	[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
}


//
// buttonPressed:
//
// Handles the play/stop button. Creates, observes and starts the
// audio streamer when it is a play button. Stops the audio streamer when
// it isn't.
//
// Parameters:
//    sender - normally, the play/stop button.
//
- (IBAction)buttonPressed:(id)sender
{
	if ([button.currentImage isEqual:[UIImage imageNamed:@"playbutton.png"]])
	{
		[self createStreamer];
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		bufferingLabel.hidden = NO;
		[streamer start];
		
	}
	else
	{
		[streamer stop];
	}
}

//
// sliderMoved:
//
// Invoked when the user moves the slider
//
// Parameters:
//    aSlider - the slider (assumed to be the progress slider)
//	This will let us scrub time back and forth in an file.
- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (streamer.duration)
	{
		[streamer seekToTime:aSlider.value];
	}
}

//
// playbackStateChanged:
//
// Invoked when the AudioStreamer
// reports that its playback status has changed.
//
- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		[self setButtonImage:[UIImage imageNamed:@"loadingbutton.png"]];
		bufferingLabel.hidden = NO;

	}
	else if ([streamer isPlaying])
	{
		[self setButtonImage:[UIImage imageNamed:@"stopbutton.png"]];
		streamDuration = streamer.duration;
		bufferingLabel.hidden = YES;

	}
	else if ([streamer isIdle])
	{
		[self destroyStreamer];
		[self setButtonImage:[UIImage imageNamed:@"playbutton.png"]];
		bufferingLabel.hidden = YES;

	}
}

//
// updateProgress:
//
// Invoked when the AudioStreamer
// reports that its playback progress has changed.
//
- (void)updateProgress:(NSTimer *)updatedTimer
{
	if (streamer.bitRate != 0.0)
	{
		double progress = streamer.progress;
				
		if (streamDuration > 0)
		{
			//If duration is greater than 0 then we are dealing with a finite file so we can show the slider and track time
			progressSlider.maximumValue = streamDuration;
			NSDate *position = [NSDate dateWithTimeIntervalSinceReferenceDate:progress];
			NSDate *songEnd = [NSDate dateWithTimeIntervalSinceReferenceDate:streamDuration];
			NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
			[formatter setDateFormat:@"HH:mm:ss"]; //In the formatter setting the HH instead of hh uses 24 hour time
			[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]]; //Set this to GMT so that we get 00:00:00 as our start time
			
			[positionLabel setText:
			
			 [NSString stringWithFormat:@"%@ %@/%@",
					NSLocalizedString(@"Time Played:", @"Time Played:"),
					[formatter stringFromDate: position],
					[formatter stringFromDate:songEnd]]];
			
			[progressSlider setEnabled:YES];
			[progressSlider setValue:progress];
			positionLabel.hidden = NO;
			progressSlider.hidden = NO;
		}
		else
			//If duration is unknown or 0 then hide the slider and the time tracker
		{
			[progressSlider setEnabled:NO];
			progressSlider.hidden = YES;
			positionLabel.hidden = YES;
		}
	}

}

//
// textFieldShouldReturn:
//
// Dismiss the text field when done is pressed
//
// Parameters:
//    sender - the text field
//
// returns YES
//
- (BOOL)textFieldShouldReturn:(UITextField *)sender
{
	[sender resignFirstResponder];
	[self createStreamer];
	return YES;
}

//
// dealloc
//
// Releases instance memory.
//
- (void)dealloc
{
	[self destroyStreamer];
	if (progressUpdateTimer)
	{
		[progressUpdateTimer invalidate];
		progressUpdateTimer = nil;
	}
	[super dealloc];
}

@end
