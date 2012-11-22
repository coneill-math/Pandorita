//
//  PRPianoCreateStationJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoCreateStationJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoCreateStationJob

- (id)initWithWrapper:(PRPianoWrapper *)w musicId:(NSString *)musicId
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_CREATE_STATION];
	
	if (self != nil)
	{
		cMusicId = (char *)malloc(([musicId length] + 1) * sizeof(char));
		memset(cMusicId, 0, [musicId length] + 1);
		[musicId getCString:cMusicId maxLength:([musicId length]+1) encoding:NSASCIIStringEncoding];
		
		PianoRequestDataCreateStation_t *reqData = (PianoRequestDataCreateStation_t *)malloc(sizeof(PianoRequestDataCreateStation_t));
		memset(reqData, 0, sizeof(PianoRequestDataCreateStation_t));
		
		reqData->type = "mi";
		reqData->id = cMusicId;
		
		req->data = reqData;
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		PRLog(@"Unable to create station with id: %s!", cMusicId);
		// try anyway?
	}
	
	[wrapper loadStationsFromPianoHandle];
	
	// right now, always appended at the end
	[[wrapper delegate] didCreateStation:[[wrapper stations] lastObject] error:error];
}

- (void)dealloc
{
	FREE_MEMBER(cMusicId);
	FREE_MEMBER(req->data);
	
	[super dealloc];
}

@end
