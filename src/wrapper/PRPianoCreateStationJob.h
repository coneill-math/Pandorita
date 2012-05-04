//
//  PRPianoCreateStationJob.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoJob.h"

@interface PRPianoCreateStationJob : PRPianoJob
{
	char *cMusicId;
}

- (id)initWithWrapper:(PRPianoWrapper *)w musicId:(NSString *)musicId;

@end
