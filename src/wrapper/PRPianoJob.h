//
//  PRPianoJob.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "piano.h"

#import "PRURLDownloader.h"
#import "PRStation.h"
#import "PRSong.h"


@class PRPianoWrapper;

@interface PRPianoJob : NSObject
{
	PRPianoWrapper *wrapper;
	PRURLDownloader *downloader;
	
	PianoRequestType_t type;
	PianoRequest_t *req;
	PianoReturn_t pRet;
}

@property PianoRequestType_t type;
@property PianoRequest_t *req;
@property PianoReturn_t pRet;

- (id)initWithWrapper:(PRPianoWrapper *)w jobType:(PianoRequestType_t)t;

- (void)startJob;
- (void)handleJobResponse:(PRURLDownloader *)d;
- (void)finishJob;

- (NSError *)lastError;

// overridden by subclasses to customize response
- (void)jobCompletedWithError:(NSError *)error;

@end
