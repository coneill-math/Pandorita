//
//  PRArtist.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "piano.h"


@interface PRArtist : NSObject
{
	NSString *name;
	NSString *musicId;
	NSString *seedId;
	NSInteger score;
	
	PianoArtist_t *originalArtist;
}

- (id)initWithArtist:(PianoArtist_t *)artist;

- (NSString *)name;
- (NSString *)musicId;
- (NSString *)seedId;
- (NSInteger)score;

- (PianoArtist_t *)originalArtist;

@end
