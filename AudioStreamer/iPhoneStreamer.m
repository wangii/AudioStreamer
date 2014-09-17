//
//  iPhoneStreamer.m
//  AudioStreamer
//
//  Created by Bo Anderson on 07/09/2012.
//  Copyright (c) 2012. All rights reserved.
//

#import "iPhoneStreamer.h"

/* Default number and size of audio queue buffers */
#define kDefaultNumAQBufs 16
#define kDefaultAQDefaultBufSize 2048

@interface iPhoneStreamer ()
- (void)handleInterruptionChangeToState:(AudioQueuePropertyID)inInterruptionState;
@end

@implementation iPhoneStreamer

//
// MyAudioSessionInterruptionListener
//
// Invoked if the audio session is interrupted (like when the phone rings)
//
static void ASAudioSessionInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
    iPhoneStreamer* streamer = (__bridge iPhoneStreamer *)inClientData;
    [streamer handleInterruptionChangeToState:inInterruptionState];
}

+ (instancetype)streamWithURL:(NSURL *)url {
    assert(url != nil);
    iPhoneStreamer *stream = [[iPhoneStreamer alloc] init];
    stream->url = url;
    stream->bufferCnt = kDefaultNumAQBufs;
    stream->bufferSize = kDefaultAQDefaultBufSize;
    stream->timeoutInterval = 10;
    return stream;
}

- (BOOL)start {
    if (stream != NULL) return NO;
    [super start];
    //
    // Set the audio session category so that we continue to play if the
    // iPhone/iPod auto-locks.
    //
    AudioSessionInitialize (
                            NULL,                          // 'NULL' to use the default (main) run loop
                            NULL,                          // 'NULL' to use the default run loop mode
                            ASAudioSessionInterruptionListener,  // a reference to your interruption callback
                            (__bridge void*)self                       // data to pass to your interruption listener callback
                            );
    
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
    AudioSessionSetActive(true);
    return YES;
}

- (void) stop {
    [super stop];
    AudioSessionSetActive(false);
}

//
// handleInterruptionChangeForQueue:propertyID:
//
// Implementation for MyAudioQueueInterruptionListener
//
// Parameters:
//    inAQ - the audio queue
//    inID - the property ID
//
- (void)handleInterruptionChangeToState:(AudioQueuePropertyID)inInterruptionState
{
    if (inInterruptionState == kAudioSessionBeginInterruption)
    {
        if ([self isPlaying]) {
            [self pause];
            
            pausedByInterruption = YES;
        }
    }
    else if (inInterruptionState == kAudioSessionEndInterruption)
    {
        AudioSessionSetActive(true);
        
        if ([self isPaused] && pausedByInterruption) {
            [self play];
            
            pausedByInterruption = NO;
        }
    }
}

@end
