//
//  PRPianoTiredTrackJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoTiredTrackJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoTiredTrackJob

- (id)initWithWrapper:(PRPianoWrapper *)w song:(PRSong *)s
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_ADD_TIRED_SONG];
	
	if (self != nil)
	{
		song = [s retain];
		
		req->data = [song originalSong];
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		PRLog(@"Unable to mark song as tired: %@!", song);
		// try anyway?
	}
	
	// right now, always appended at the end
	[[wrapper delegate] didMarkSongAsTired:song error:error];
}

- (void)dealloc
{
	RELEASE_MEMBER(song);
	req->data = NULL;
	
	[super dealloc];
}

@end
