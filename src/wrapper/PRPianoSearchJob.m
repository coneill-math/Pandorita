//
//  PRPianoSearchJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoSearchJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoSearchJob

- (id)initWithWrapper:(PRPianoWrapper *)w search:(NSString *)search
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_SEARCH];
	
	if (self != nil)
	{
		cSearch = (char *)malloc(([search length] + 1) * sizeof(char));
		memset(cSearch, 0, [search length] + 1);
		[search getCString:cSearch maxLength:([search length]+1) encoding:NSASCIIStringEncoding];
		
		PianoRequestDataSearch_t *reqData = (PianoRequestDataSearch_t *)malloc(sizeof(PianoRequestDataSearch_t));
		memset(reqData, 0, sizeof(PianoRequestDataSearch_t));
		
		reqData->searchStr = cSearch;
		
		req->data = reqData;
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		NSLog(@"Unable to perform search: %s!", cSearch);
		// try anyway?
	}
	
	NSMutableArray *songs = [NSMutableArray array];
	NSMutableArray *artists = [NSMutableArray array];
	PianoRequestDataSearch_t *reqData = self.req->data;
	
	PianoSong_t *nextSong = reqData->searchResult.songs;
	while(nextSong != NULL)
	{
		PianoSong_t *curSong = nextSong;
		nextSong = nextSong->next;
		curSong->next = NULL;
		
		PRSong *song = [[PRSong alloc] initWithSong:curSong];
		[songs addObject:song];
		[song release];
	}
	
	PianoArtist_t *nextArtist = reqData->searchResult.artists;
	while(nextArtist != NULL)
	{
		PianoArtist_t *curArtist = nextArtist;
		nextArtist = nextArtist->next;
		curArtist->next = NULL;
		
		PRArtist *artist = [[PRArtist alloc] initWithArtist:curArtist];
		[artists addObject:artist];
		[artist release];
	}
	
	[[wrapper delegate] didGetSearchResultWithArtists:artists songs:songs withError:error];
}

- (void)dealloc
{
	FREE_MEMBER(cSearch);
	
	// we will destroy these individually
//	PianoDestroySearchResult(&((PianoRequestDataSearch_t *)req->data)->searchResult);
	
	FREE_MEMBER(req->data);
	
	[super dealloc];
}

@end
