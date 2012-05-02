//
//  PRStationTableDelegate.h
//  Pandorita
//
//  Created by Chris O'Neill on 1/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PRPianoWrapper.h"


@interface PRStationTableDelegate : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
	PRPianoWrapper *pianoWrapper;
}

- (id)initWithPianoWrapper:(PRPianoWrapper *)wrapper;

- (void)tableDoubleClicked:(id)view;

@end
