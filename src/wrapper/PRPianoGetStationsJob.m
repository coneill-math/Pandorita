//
//  PRPianoGetStationsJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoGetStationsJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoGetStationsJob

- (id)initWithWrapper:(PRPianoWrapper *)w
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_GET_STATIONS];
	
	if (self != nil)
	{
		
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		PRLog(@"Unable to get station list!");
		// continue anyway
		// delegate will handle error
	}
	
	[wrapper loadStationsFromPianoHandle];
	
	// notify the delegate
	[[wrapper delegate] didUpdateStationsWithError:error];
}

- (void)dealloc
{
	[super dealloc];
}

@end
