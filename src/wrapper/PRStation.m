//
//  PRStation.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRStation.h"


@implementation PRStation

- (id)initWithStation:(PianoStation_t *)s
{
	self = [super init];
	
	if (self != nil)
	{
		name = [[NSString alloc] initWithFormat:@"%s", s->name];
		listId = [[NSString alloc] initWithFormat:@"%s", s->id];
		seedId = [[NSString alloc] initWithFormat:@"%s", s->seedId];
		
		isCreator = (BOOL)s->isCreator;
		isQuickMix = (BOOL)s->isQuickMix;
		useQuickMix = (BOOL)s->useQuickMix;
		
		pStation = s;
	}
	
	return self;
}

- (NSString *)name
{
	return name;
}

- (NSString *)listId
{
	return listId;
}

- (NSString *)seedId
{
	return seedId;
}

- (BOOL)isCreator
{
	return isCreator;
}

- (BOOL)isQuickMix
{
	return isQuickMix;
}

- (BOOL)useQuickMix
{
	return useQuickMix;
}

- (PianoStation_t *)internalStation
{
	return pStation;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ (%@, %@)", name, listId, seedId];
}

- (BOOL)equals:(id)station
{
	return [self class] == [station class] && [listId isEqualToString:[station listId]];
}

- (void)dealloc
{
	RELEASE_MEMBER(name);
	RELEASE_MEMBER(listId);
	RELEASE_MEMBER(seedId);
	
	pStation = NULL;
	
	[super dealloc];
}


@end
