//
//  PRPianoRenameStationJob.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoJob.h"

@interface PRPianoRenameStationJob : PRPianoJob
{
	PRStation *station;
	char *cName;
}

- (id)initWithWrapper:(PRPianoWrapper *)w withName:(NSString *)name forStation:(PRStation *)s;

@end
