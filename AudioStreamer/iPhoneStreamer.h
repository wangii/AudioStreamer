//
//  iPhoneStreamer.h
//  AudioStreamer
//
//  Created by Bo Anderson on 07/09/2012.
//  Copyright (c) 2012. All rights reserved.
//

#import "AudioStreamer.h"
#import <AVFoundation/AVAudioSession.h>

@interface iPhoneStreamer : AudioStreamer <AVAudioSessionDelegate> {
    BOOL pausedByInterruption;
}
@end
