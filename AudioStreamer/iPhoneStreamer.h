//
//  iPhoneStreamer.h
//  AudioStreamer
//
//  Created by Bo Anderson on 07/09/2012.
//  Copyright (c) 2012. All rights reserved.
//

#import "AudioStreamer.h"

@interface iPhoneStreamer : AudioStreamer {
    BOOL pausedByInterruption;
}
- (BOOL)start;
- (void) stop;
@end
