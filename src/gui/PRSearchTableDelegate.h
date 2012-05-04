//
//  PRSearchTableDelegate.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PRPianoWrapper.h"

@interface PRSearchTableDelegate : NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
	IBOutlet NSTableView *tableView;
	IBOutlet NSSearchField *searchField;
	
	PRPianoWrapper *pianoWrapper;
	
	NSMutableArray *songs;
	NSMutableArray *artists;
}

- (void)setPianoWrapper:(PRPianoWrapper *)wrapper;
- (void)setFoundArtists:(NSArray *)a songs:(NSArray *)s;

- (IBAction)tableDoubleClicked:(id)sender;

@end
