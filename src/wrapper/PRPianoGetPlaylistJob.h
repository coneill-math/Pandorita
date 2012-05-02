//
//  PRPianoGetPlaylistJob.h
//  Pandorita
//
//  Created by Christopher O'Neill on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoJob.h"

#import "PRStation.h"


@interface PRPianoGetPlaylistJob : PRPianoJob
{
	PRStation *station;
}

- (id)initWithWrapper:(PRPianoWrapper *)w station:(PRStation *)s;

@end
