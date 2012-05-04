//
//  PRPianoSetRatingJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoSetRatingJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoSetRatingJob

- (id)initWithWrapper:(PRPianoWrapper *)w withRating:(PRRating)r forSong:(PRSong *)s
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_RATE_SONG];
	
	if (self != nil)
	{
		rating = r;
		song = [s retain];
		
		PianoRequestDataRateSong_t *reqData = (PianoRequestDataRateSong_t *)malloc(sizeof(PianoRequestDataRateSong_t));
		memset(reqData, 0, sizeof(PianoRequestDataRateSong_t));
		
		reqData->song = [song originalSong];
		reqData->rating = (PianoSongRating_t)rating;
		
		req->data = reqData;
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		NSLog(@"Unable to set rating!");
		// try anyway?
	}
	
	[[wrapper delegate] didSetRating:rating forSong:song error:error];
}

- (void)dealloc
{
	FREE_MEMBER(req->data);
	
	[super dealloc];
}

@end
