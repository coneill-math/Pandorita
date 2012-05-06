//
//  PRPianoTiredTrackJob.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoJob.h"

@interface PRPianoTiredTrackJob : PRPianoJob
{
	PRSong *song;
}

- (id)initWithWrapper:(PRPianoWrapper *)w song:(PRSong *)s;

@end
