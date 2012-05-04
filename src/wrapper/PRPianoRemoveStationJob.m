//
//  PRPianoRemoveStationJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoRemoveStationJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoRemoveStationJob

- (id)initWithWrapper:(PRPianoWrapper *)w withStation:(PRStation *)s
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_DELETE_STATION];
	
	if (self != nil)
	{
		station = [s retain];
		
		req->data = [station internalStation];
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		NSLog(@"Unable to remove station!");
	}
	else
	{
		[wrapper stationRemoved:station];
	}
	
	[[wrapper delegate] didRemoveStationWithError:error];
}

- (void)dealloc
{
	RELEASE_MEMBER(station);
	req->data = NULL;
	
	[super dealloc];
}

@end
