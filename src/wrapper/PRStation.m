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
		pStation = s;
		[self reloadFromInternalStation];
	}
	
	return self;
}

- (void)reloadFromInternalStation
{
	RELEASE_MEMBER(name);
	RELEASE_MEMBER(listId);
	RELEASE_MEMBER(seedId);
	
	name = [[NSString alloc] initWithFormat:@"%s", pStation->name];
	listId = [[NSString alloc] initWithFormat:@"%s", pStation->id];
	seedId = [[NSString alloc] initWithFormat:@"%s", pStation->seedId];
	
	isCreator = (BOOL)pStation->isCreator;
	isQuickMix = (BOOL)pStation->isQuickMix;
	useQuickMix = (BOOL)pStation->useQuickMix;
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
