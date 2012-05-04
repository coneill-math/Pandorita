//
//  PRStationTableDelegate.h
//  Pandorita
//
//  Created by Chris O'Neill on 1/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PRPianoWrapper.h"


@interface PRStationTableDelegate : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate>
{
	IBOutlet NSTableView *tableView;
	IBOutlet NSMenu *rightClickMenu;
	
	PRPianoWrapper *pianoWrapper;
}

//- (id)initWithPianoWrapper:(PRPianoWrapper *)wrapper forTable:(NSTableView *)table;

- (void)setPianoWrapper:(PRPianoWrapper *)wrapper;

- (IBAction)tableDoubleClicked:(id)sender;

- (IBAction)getStationInfo:(id)sender;
- (IBAction)renameStation:(id)sender;
- (IBAction)removeStation:(id)sender;
- (IBAction)toggleUsesQuickMix:(id)sender;

@end
