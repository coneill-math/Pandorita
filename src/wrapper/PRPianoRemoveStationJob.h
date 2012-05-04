//
//  PRPianoRemoveStationJob.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoJob.h"

@interface PRPianoRemoveStationJob : PRPianoJob
{
	PRStation *station;
}

- (id)initWithWrapper:(PRPianoWrapper *)w withStation:(PRStation *)s;

@end
