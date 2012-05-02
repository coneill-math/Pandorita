//
//  PRPianoLoginJob.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PRPianoJob.h"


@interface PRPianoLoginJob : PRPianoJob
{
	char *cUsername;
	char *cPassword;
	
	PRURLDownloader *loginDownloader;
}

- (id)initWithWrapper:(PRPianoWrapper *)w username:(NSString *)user password:(NSString *)pass;

@end
