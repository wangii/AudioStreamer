//
//  ASPlaylist.h
//  AudioStreamer
//
//  Created by Alex Crichton on 8/21/12.
//

#import "AudioStreamer.h"

extern NSString * const ASNewSongPlaying;
extern NSString * const ASNoSongsLeft;
extern NSString * const ASRunningOutOfSongs;
extern NSString * const ASCreatedNewStream;
extern NSString * const ASStreamError;
extern NSString * const ASAttemptingNewSong;

/**
 * The ASPlaylist class is intended to be a wrapper around the <AudioStreamer>
 * class for a more robust interface if one is desired. It also manages a queue
 * of songs to play and automatically switches from one song to the next when
 * playback finishes.
 */
@interface ASPlaylist : NSObject {
  BOOL retrying;              /* Are we retrying the current url? */
  BOOL nexting;               /* Are we in the middle of nexting? */
  BOOL stopping;              /* Are we in the middle of stopping? */
  BOOL volumeSet;             /* YES if the volume has been set on the stream */
  double lastKnownSeekTime;   /* time to seek to */
  float volume;               /* volume for all streams on this playlist */

  NSInteger tries;            /* # of retry attempts */
}

/**
 * @brief The playlist array.
 *
 * @details This array contains the list of URLs that ASPlaylist runs upon.
 */
@property (readonly) NSMutableArray *playlist;

/**
 * @brief The currently playing URL.
 *
 * @details This is nil of no url has ever been playing.
 */
@property (readonly) NSURL *playing;

/**
 * @brief The streamer that is playing the current song.
 *
 * @details This gets replaced with a new one before every song.
 *
 * @warning You should always use ASPlaylist's methods over the streamer's.
 */
@property (readonly) AudioStreamer *streamer;

/** @name Initializers */

/**
 * @brief Creates a new ASPlaylist instance with the given capacity.
 *
 * @param capacity How many songs the ASPlaylist should be able to hold
 * @return The created ASPlaylist object
 */
- (id)initWithCapacity:(NSUInteger)capacity;

/** @name Managing the playlist */

/**
 * @brief Adds a new song to the playlist, optionally starting playback.
 *
 * @param url The URL to add to the playlist
 * @param play Whether playback should start immediately
 */
- (void)addSong:(NSURL*)url play:(BOOL)play;

/**
 * @brief Removes a song from the playlist at the specified index.
 *
 * @details
 * @warning This will raise a NSRangeException if the index is beyond the end of the
 * playlist array.
 *
 * @param idx The index of the song to remove
 */
- (void)removeSongAtIndex:(NSUInteger)idx;

/**
 * @brief Removes all songs from the internal list of songs.
 *
 * @details This does not trigger notifications about songs running low.
 */
- (void)clearSongList;

/**
 * @brief Start playing songs on the playlist, or resume playback.
 *
 * @details This will send out notifications for more songs if we're running low on songs
 * or are out of songs completely to play.
 */
- (void)play;

/**
 * @brief Pause playback on the playlist.
 *
 * @details This has no effect if the playlist is already paused or wasn't playing a song
 */
- (void)pause;

/**
 * @brief Stops playing the current song and forgets about it.
 *
 * @details The song is stopped and internally all state about the song is thrown away
 */
- (void)stop;

/**
 * @brief Goes to the next song in the playlist
 *
 * @details This can trigger notifications about songs running low or associated events.
 */
- (void)next;

/** @name Interface to AudioStreamer */

/**
 * @brief Tests if the stream is paused
 * @return YES if the stream is paused, NO otherwise
 * @see [AudioStreamer isPaused]
 */
- (BOOL)isPaused;
/**
 * @brief Tests if the stream is playing
 * @return YES if the stream is playing, NO otherwise
 * @see [AudioStreamer isPlaying]
 */
- (BOOL)isPlaying;
/**
 * @brief Tests if the stream is idle
 * @return YES if the stream is idle, NO otherwise
 * @see [AudioStreamer isDone]
 */
- (BOOL)isIdle;
/**
 * @brief Tests if the stream has encountered an error
 * @return YES if the stream has encountered an error, NO otherwise
 * @see [AudioStreamer doneReason]
 */
- (BOOL)isError;
/**
 * @brief Attempts to set the stream volume
 * @param volume The volume to set the stream to in the range 0.0 to 1.0 where 1.0
 *        is the loudest and 0.0 is silent
 * @see [AudioStreamer setVolume:]
 */
- (void)setVolume:(float)volume;
/**
 * @brief Calculates the duration of the audio stream in seconds
 * @param ret The variable to fill with the duration of the stream
 * @return YES if the duration was calculated successfully, NO otherwise
 * @see [AudioStreamer duration:]
 */
- (BOOL)duration:(double*)ret;
/**
 * @brief Calculates the current progress of the audio stream in seconds
 * @param ret The variable to fill with the progress of the stream
 * @return YES if the progress was calculated successfully, NO otherwise
 * @see [AudioStreamer progress:]
 */
- (BOOL)progress:(double*)ret;

/** @name Miscellaneous */

/**
 * @brief Attempts to retry connecting
 *
 * @details If the stream has stopped for a network error, this retries playing the
 * stream
 */
- (void)retry;

@end
