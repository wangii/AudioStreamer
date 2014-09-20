//
//  iPhoneStreamer.m
//  AudioStreamer
//
//  Created by Bo Anderson on 07/09/2012.
//  Copyright (c) 2012. All rights reserved.
//

#import "iPhoneStreamer.h"

#if defined(DEBUG) && 0
#define LOG(fmt, args...) NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##args)
#else
#define LOG(...)
#endif

@implementation iPhoneStreamer

- (BOOL)start {
    if (![super start]) return NO;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setDelegate:self];
    
    NSError *error;
    
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!success)
    {
        LOG(@"Error setting AVAudioSession category: %@", [error localizedDescription]);
        return YES; // The stream can still continue, but we don't get interruption handling.
    }
    
    success = [audioSession setActive:YES error:&error];
    if (!success)
    {
        LOG(@"Error activating AVAudioSession: %@", [error localizedDescription]);
    }
    
    return YES;
}

- (void)stop {
    [super stop];
    
    NSError *error;
    
    BOOL success = [[AVAudioSession sharedInstance] setActive:NO error:&error];
    if (!success)
    {
        LOG(@"Error deactivating AVAudioSession: %@", [error localizedDescription]);
    }
}

- (void)beginInterruption
{
    if ([self isPlaying])
    {
        LOG(@"Interrupted");
        
        [self pause];
        
        _interrupted = YES;
    }
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
    if ([self isPaused] && _interrupted)
    {
        LOG(@"Interruption ended");
        
        if (flags & AVAudioSessionInterruptionFlags_ShouldResume)
        {
            LOG(@"Resuming after interruption...");
            [self play];
        }
        else
        {
            LOG(@"Not resuming after interruption");
            [self stop];
        }
        
        _interrupted = NO;
    }
}

@end
