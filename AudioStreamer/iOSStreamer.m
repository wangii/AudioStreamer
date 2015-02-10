//
//  iOSStreamer.m
//  AudioStreamer
//
//  Created by Bo Anderson on 07/09/2012.
//

#import "iOSStreamer.h"

#if defined(DEBUG) && 0
#define LOG(fmt, args...) NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##args)
#else
#define LOG(...)
#endif

@interface AudioStreamer (iOSStreamer)

- (void)createQueue;

@end

@implementation iOSStreamer

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

        _interrupted = YES;

        [self pause];
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

- (void)createQueue
{
    [super createQueue];

    /* "Prefer" hardware playback but not "require" it.
     * This means that streams can use software playback if hardware is unavailable.
     * This allows for concurrent streams */
    UInt32 propVal = kAudioQueueHardwareCodecPolicy_PreferHardware;
    AudioQueueSetProperty(audioQueue, kAudioQueueProperty_HardwareCodecPolicy, &propVal, sizeof(propVal));
}

@end
