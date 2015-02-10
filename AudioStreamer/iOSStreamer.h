//
//  iOSStreamer.h
//  AudioStreamer
//
//  Created by Bo Anderson on 07/09/2012.
//

#import "AudioStreamer.h"
#import <AVFoundation/AVAudioSession.h>

/**
 * The iOSStreamer subclass is for those using <AudioStreamer> on iOS.
 * This class adds extra iOS features that are unavailable or not required
 * on OS X.
 *
 * This class adds:
 *
 * - Ability to play audio while your app is in the background
 * - Interruption handling (eg. phone calls)
 * - Ability to play concurrent streams
 *
 * You only need to replace "AudioStreamer" with "iOSStreamer" in your
 * code. Everything else is handled for you which is why there is little
 * additional properties and methods.
 */
@interface iOSStreamer : AudioStreamer <AVAudioSessionDelegate>

/** @name Properties */

/**
 * @brief Whether the stream is currently interrupted
 *
 * @details The stream may be interrupted for various reasons such as
 * a phone call. This property will be set to YES if the stream is currently
 * interrupted and will be set back to NO when the interruption is over
 */
@property (readonly, getter=isInterrupted) BOOL interrupted;

@end

@compatibility_alias iPhoneStreamer iOSStreamer; // Backwards compatibility
