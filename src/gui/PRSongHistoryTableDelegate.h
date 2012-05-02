//
//  PRPlaylistTableDelegate.h
//  Pandorita
//
//  Created by Chris O'Neill on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PRSong.h"
#import "PRRatingCell.h"


@interface PRSongHistoryTableDelegate : NSObject <NSTableViewDelegate, NSTableViewDataSource>
{
	NSMutableArray *songHistory;
}

-  (PRSong *)currentSong;

- (PRSong *)songForRow:(NSUInteger)index;

- (void)addSong:(PRSong *)song;
- (void)replaceSongAfterRating:(PRSong *)song;

@end
