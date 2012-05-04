//
//  PRStation.h
//  Pandorita
//
//  Created by Chris O'Neill on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "piano.h"

@interface PRStation : NSObject
{
	NSString *name;
	NSString *listId;
	NSString *seedId;
	
	BOOL isCreator;
	BOOL isQuickMix;
	BOOL useQuickMix; // station will be included in quickmix
	
	PianoStation_t *pStation;
}

- (id)initWithStation:(PianoStation_t *)s;

- (void)reloadFromInternalStation;

- (NSString *)name;
- (NSString *)listId;
- (NSString *)seedId;

- (BOOL)isCreator;
- (BOOL)isQuickMix;
- (BOOL)useQuickMix;
- (void)setUseQuickMix:(BOOL)use;

- (PianoStation_t *)internalStation;

@end
