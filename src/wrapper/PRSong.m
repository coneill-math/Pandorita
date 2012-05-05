//
//  PRSong.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRSong.h"


@implementation PRSong

- (id)initWithSong:(PianoSong_t *)song
{
	self = [super init];
	
	if (self != nil)
	{
		char c = 0;
		artist = [[NSString alloc] initWithCString:(song->artist ? song->artist : &c) encoding:NSASCIIStringEncoding];
		stationId = [[NSString alloc] initWithCString:(song->stationId ? song->stationId : &c) encoding:NSASCIIStringEncoding];
		album = [[NSString alloc] initWithCString:(song->album ? song->album : &c) encoding:NSASCIIStringEncoding];
		audioURL = [[NSURL alloc] initWithString:[NSString stringWithCString:(song->audioUrl ? song->audioUrl : &c) encoding:NSASCIIStringEncoding]];
		coverArtURL = [[NSURL alloc] initWithString:[NSString stringWithCString:(song->coverArt ? song->coverArt : &c) encoding:NSASCIIStringEncoding]];
		musicId = [[NSString alloc] initWithCString:(song->musicId ? song->musicId : &c) encoding:NSASCIIStringEncoding];
		title = [[NSString alloc] initWithCString:(song->title ? song->title : &c) encoding:NSASCIIStringEncoding];
		seedId = [[NSString alloc] initWithCString:(song->seedId ? song->seedId : &c) encoding:NSASCIIStringEncoding];
		feedbackId = [[NSString alloc] initWithCString:(song->feedbackId ? song->feedbackId : &c) encoding:NSASCIIStringEncoding];
		detailURL = [[NSURL alloc] initWithString:[NSString stringWithCString:(song->detailUrl ? song->detailUrl : &c) encoding:NSASCIIStringEncoding]];
		trackToken = [[NSString alloc] initWithCString:(song->trackToken ? song->trackToken : &c) encoding:NSASCIIStringEncoding];
		
		fileGain = (CGFloat)song->fileGain;
		
		audioFormat = (PRAudioFormat)song->audioFormat;
		
		originalSong = song;
	}
	
	return self;
}
/*
- (id)copyWithZone:(NSZone *)zone
{
	PRSong *ret = [[[PRSong alloc] initWithSong:originalSong] autorelease];
	
	return ret;
}
*/
- (NSString *)artist
{
	return artist;
}

- (NSString *)stationId
{
	return stationId;
}

- (NSString *)album
{
	return album;
}

- (NSURL *)audioURL
{
	return audioURL;
}

- (NSURL *)coverArtURL
{
	return coverArtURL;
}

- (NSString *)musicId
{
	return musicId;
}

- (NSString *)title
{
	return title;
}

- (NSString *)seedId
{
	return seedId;
}

- (NSString *)feedbackId
{
	return feedbackId;
}

- (NSURL *)detailURL
{
	return detailURL;
}

- (NSString *)trackToken
{
	return trackToken;
}

- (CGFloat)fileGain
{
	return fileGain;
}

- (PRRating)rating
{
	return (PRRating)originalSong->rating;
}

- (PRAudioFormat)audioFormat
{
	return audioFormat;
}

- (PianoSong_t *)originalSong
{
	return originalSong;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ - %@ - %@", artist, album, title];
}

- (BOOL)isEqual:(id)object
{
	return [object class] == [self class] && [[object musicId] isEqualToString:musicId];
}

- (void)dealloc
{
	RELEASE_MEMBER(artist);
	RELEASE_MEMBER(stationId);
	RELEASE_MEMBER(album);
	RELEASE_MEMBER(audioURL);
	RELEASE_MEMBER(coverArtURL);
	RELEASE_MEMBER(musicId);
	RELEASE_MEMBER(title);
	RELEASE_MEMBER(seedId);
	RELEASE_MEMBER(feedbackId);
	RELEASE_MEMBER(detailURL);
	RELEASE_MEMBER(trackToken);
	
	PianoDestroyPlaylist(originalSong);
	
	[super dealloc];
}


@end
