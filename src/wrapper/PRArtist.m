//
//  PRArtist.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRArtist.h"

@implementation PRArtist

- (id)initWithArtist:(PianoArtist_t *)artist
{
	self = [super init];
	
	if (self)
	{
		name = [[NSString alloc] initWithFormat:@"%s", artist->name];
		musicId = [[NSString alloc] initWithFormat:@"%s", artist->musicId];
		seedId = [[NSString alloc] initWithFormat:@"%s", artist->seedId];
		score = artist->score;
		
		originalArtist = artist;
	}
	
	return self;
}

- (NSString *)name
{
	return name;
}

- (NSString *)musicId
{
	return musicId;
}

- (NSString *)seedId
{
	return seedId;
}

- (NSInteger)score
{
	return score;
}

- (PianoArtist_t *)originalArtist
{
	return originalArtist;
}

- (BOOL)isEqual:(id)object
{
	return [object class] == [self class] && [[object musicId] isEqualToString:musicId];
}

- (void)dealloc
{
	RELEASE_MEMBER(name);
	RELEASE_MEMBER(musicId);
	RELEASE_MEMBER(seedId);
	
	// cheating, but it works...
	PianoSearchResult_t tempResult;
	tempResult.songs = NULL;
	tempResult.artists = originalArtist;
	PianoDestroySearchResult(&tempResult);
	
	originalArtist = NULL;
	
	[super dealloc];
}

@end
