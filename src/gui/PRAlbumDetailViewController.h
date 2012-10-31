//
//  PRAlbumDetailViewController.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/28/12.
//
//

#import <Cocoa/Cocoa.h>

#import "PRInfoAlbum.h"
#import "PRIsolatedTextView.h"
#import "PRAlbumDetailTrackViewController.h"

@interface PRAlbumDetailViewController : NSViewController
{
	IBOutlet PRIsolatedTextView *albumTitleView;
	IBOutlet PRIsolatedTextView *albumYearView;
	IBOutlet NSView *trackListView;
	
	PRInfoAlbum *album;
	NSMutableArray *trackControllers;
}

- (id)init;

- (void)setAlbum:(PRInfoAlbum *)a;

@end
