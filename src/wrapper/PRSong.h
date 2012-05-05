//
//  PRSong.h
//  Pandorita
//
//  Created by Chris O'Neill on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "piano.h"


typedef enum 
{
	PRAUDIOFORMAT_UNKNOWN = PIANO_AF_UNKNOWN, 
	PRAUDIOFORMAT_AACPLUS = PIANO_AF_AACPLUS, 
	PRAUDIOFORMAT_MP3 = PIANO_AF_MP3, 
	PRAUDIOFORMAT_MP3HI = PIANO_AF_MP3_HI
} PRAudioFormat;


typedef enum
{
	PRRATING_NONE = PIANO_RATE_NONE, 
	PRRATING_LOVE = PIANO_RATE_LOVE, 
	PRRATING_BAN = PIANO_RATE_BAN
} PRRating;



@interface PRSong : NSObject
{
	NSString *artist;
	NSString *stationId;
	NSString *album;
	NSURL *audioURL;
	NSURL *coverArtURL;
	NSString *musicId;
	NSString *title;
	NSString *seedId;
	NSString *feedbackId;
	NSURL *detailURL;
	NSString *trackToken;
	CGFloat fileGain;
//	PRRating rating;
	PRAudioFormat audioFormat;
	
	PianoSong_t *originalSong;
}

- (id)initWithSong:(PianoSong_t *)song;

- (NSString *)artist;
- (NSString *)stationId;
- (NSString *)album;
- (NSURL *)audioURL;
- (NSURL *)coverArtURL;
- (NSString *)musicId;
- (NSString *)title;
- (NSString *)seedId;
- (NSString *)feedbackId;
- (NSURL *)detailURL;
- (NSString *)trackToken;
- (PianoSong_t *)originalSong;

- (CGFloat)fileGain;
- (PRRating)rating;
- (PRAudioFormat)audioFormat;

// only checks ids, not artist/album/rating/etc.
- (BOOL)isEqual:(id)object;

@end
