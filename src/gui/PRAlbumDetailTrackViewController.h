//
//  PRAlbumDetailTrackViewController.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/29/12.
//
//

#import <Cocoa/Cocoa.h>

#import "PRInfoAlbum.h"
#import "PRIsolatedTextView.h"


@interface PRAlbumDetailTrackViewController : NSViewController <NSTextViewDelegate>
{
	IBOutlet NSTextField *numberField;
	IBOutlet PRIsolatedTextView *titleView;
	IBOutlet NSButton *playButton;
	
	PRInfoTrack *track;
}

- (id)initWithTrack:(PRInfoTrack *)t;

- (IBAction)playClicked:(id)sender;

@end
