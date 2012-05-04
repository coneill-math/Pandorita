//
//  PRPianoUpdateQuickMixJob.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoUpdateQuickMixJob.h"

@implementation PRPianoUpdateQuickMixJob

- (id)initWithWrapper:(PRPianoWrapper *)w
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_SET_QUICKMIX];
	
	if (self != nil)
	{
		// no local data
		req->data = NULL;
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		NSLog(@"Unable to set quickmix!");
		// try anyway?
	}
}

- (void)dealloc
{
	req->data = NULL;
	
	[super dealloc];
}

@end
