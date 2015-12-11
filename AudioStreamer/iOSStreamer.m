//
//  iOSStreamer.m
//  AudioStreamer
//
//  Created by Bo Anderson on 07/09/2012.
//

#import "iOSStreamer.h"

#if defined(DEBUG)
#define LOG(fmt, args...) NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##args)
#else
#define LOG(...)
#endif

@interface AudioStreamer (iOSStreamer)

- (void)createQueue;

@end

@implementation iOSStreamer

@synthesize delegate=_delegate; // Required

- (BOOL)start {
    if (![super start]) return NO;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:audioSession];

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

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;

    BOOL success = [audioSession setActive:NO error:&error];
    if (!success)
    {
        LOG(@"Error deactivating AVAudioSession: %@", [error localizedDescription]);
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionInterruptionNotification
                                                  object:audioSession];
}

- (void)setDelegate:(id<iOSStreamerDelegate>)delegate
{
    [super setDelegate:delegate];
    _delegate = delegate;
}

- (void)handleInterruption:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    AVAudioSessionInterruptionType interruptionType = [userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan:
            if ([self isPlaying])
            {
                LOG(@"Interrupted");

                _interrupted = YES;

                __strong id <iOSStreamerDelegate> delegate = _delegate;
                BOOL override;
                if (delegate && [delegate respondsToSelector:@selector(streamerInterruptionDidBegin:)]) {
                    override = [delegate streamerInterruptionDidBegin:self];
                } else {
                    override = NO;
                }

                if (override) return;

                [self pause];
            }
            break;
        case AVAudioSessionInterruptionTypeEnded:
            if ([self isPaused] && _interrupted)
            {
                LOG(@"Interruption ended");

                _interrupted = NO;

                AVAudioSessionInterruptionOptions flags = [userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];

                __strong id <iOSStreamerDelegate> delegate = _delegate;
                BOOL override;
                if (delegate && [delegate respondsToSelector:@selector(streamer:interruptionDidEndWithFlags:)]) {
                    override = [delegate streamer:self interruptionDidEndWithFlags:flags];
                } else {
                    override = NO;
                }

                if (override) return;

                if (flags & AVAudioSessionInterruptionOptionShouldResume)
                {
                    LOG(@"Resuming after interruption...");
                    [self play];
                }
                else
                {
                    LOG(@"Not resuming after interruption");
                    [self stop];
                }
            }
            break;
        default:
            break;
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
