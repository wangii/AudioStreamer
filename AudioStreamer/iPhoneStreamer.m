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

#if defined(DEBUG) && 0
#define LOG(fmt, args...) NSLog(@"%s " fmt, __PRETTY_FUNCTION__, ##args)
#else
#define LOG(...)
#endif

@implementation iPhoneStreamer

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
        
        pausedByInterruption = YES;
    }
}

- (void)endInterruptionWithFlags:(NSUInteger)flags
{
    if ([self isPaused] && pausedByInterruption)
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
        
        pausedByInterruption = NO;
    }
}

@end
