//
//  TAStreamingPlayerViewController.h
//  TAStreamingPlayer
//
//  Created by Matt Gallagher on 28/10/08.
//  Portions copyright Matt Gallagher 2008. All rights reserved.
//	Adapted for TapLynx by Walter Tyree on 26/07/2010
//	Copyright Tyree Apps 2010. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface TAStreamingPlayerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{

	IBOutlet UIButton *button;
	IBOutlet UIView *volumeSlider;
	IBOutlet UILabel *positionLabel;
	IBOutlet UIActivityIndicatorView *bufferingActivity;
	IBOutlet UISlider *progressSlider;
	IBOutlet UITextView *streamTitle;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
	NSArray *streams;
	
	double streamDuration;
	NSString *currentStream;
}


@property (nonatomic,retain) NSArray *streams;


- (IBAction)buttonPressed:(id)sender;
- (void)updateProgress:(NSTimer *)aNotification;
- (IBAction)sliderMoved:(UISlider *)aSlider;

-(id)initWithTabInfo:(NSDictionary *)tabInfo topLevelTab:(NSDictionary *)topLevelTab;

@end

