//
//  PRPianoSetRatingJob.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoJob.h"

#import "PRStation.h"


@interface PRPianoSetRatingJob : PRPianoJob
{
	PRSong *song;
	PRRating rating;
}

- (id)initWithWrapper:(PRPianoWrapper *)w withRating:(PRRating)r forSong:(PRSong *)s;

@end
