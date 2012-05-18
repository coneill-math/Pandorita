//
//  PRPianoGetPlaylistJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoGetPlaylistJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoGetPlaylistJob

- (id)initWithWrapper:(PRPianoWrapper *)w station:(PRStation *)s
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_GET_PLAYLIST];
	
	if (self != nil)
	{
		station = [s retain];
		
		PianoRequestDataGetPlaylist_t *reqData = (PianoRequestDataGetPlaylist_t *)malloc(sizeof(PianoRequestDataGetPlaylist_t));
		memset(reqData, 0, sizeof(PianoRequestDataGetPlaylist_t));
		
		reqData->station = [station internalStation];
		reqData->format = PIANO_AF_MP3;
		
		req->data = reqData;
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		NSLog(@"Error in piano call for playlist");
		
		// the rest will work fine, even if this fails
		[[wrapper delegate] didReceiveNextSong:nil error:error];
		return;
	}
	
	PianoRequestDataGetPlaylist_t *reqData = self.req->data;
	PianoSong_t *node = reqData->retPlaylist;
	
	[wrapper clearPlaylist];
	
	PRSong *firstSong = nil;
	while(node != NULL)
	{
		PianoSong_t *cur = node;
		node = node->next;
		cur->next = NULL;
		
		PRSong *s = [[PRSong alloc] initWithSong:cur];
		NSLog(@"New song in playlist: %@", s);
		
		if (!firstSong)
		{
			firstSong = s;
		}
		
		[wrapper addSongToPlaylist:s];
		[s release];
	}
	
	if (firstSong)
	{
		[[wrapper delegate] didReceiveNextSong:firstSong error:error];
	}
}

- (void)dealloc
{
	RELEASE_MEMBER(station);
	FREE_MEMBER(req->data);
	
	[super dealloc];
}

@end
