//
//  PRPianoRenameStationJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoRenameStationJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoRenameStationJob

- (id)initWithWrapper:(PRPianoWrapper *)w withName:(NSString *)name forStation:(PRStation *)s
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_RENAME_STATION];
	
	if (self != nil)
	{
		station = [s retain];
		cName = (char *)malloc(([name length] + 1) * sizeof(char));
		memset(cName, 0, [name length] + 1);
		[name getCString:cName maxLength:([name length]+1) encoding:NSASCIIStringEncoding];
		
		PianoRequestDataRenameStation_t *reqData = (PianoRequestDataRenameStation_t *)malloc(sizeof(PianoRequestDataRenameStation_t));
		memset(reqData, 0, sizeof(PianoRequestDataRenameStation_t));
		
		reqData->station = [station internalStation];
		reqData->newName = cName;
		
		req->data = reqData;
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		PRLog(@"Unable to rename station!");
	}
	
	[station reloadFromInternalStation];
	[[wrapper delegate] didRenameStation:station error:error];
}

- (void)dealloc
{
	FREE_MEMBER(cName);
	FREE_MEMBER(req->data);
	RELEASE_MEMBER(station);
	
	[super dealloc];
}

@end
