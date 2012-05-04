//
//  PRPianoSearchJob.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoJob.h"

@interface PRPianoSearchJob : PRPianoJob
{
	char *cSearch;
}

- (id)initWithWrapper:(PRPianoWrapper *)w search:(NSString *)s;

@end
