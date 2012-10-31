//
//  PRAlbumLinkViewController.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/26/12.
//
//

#import <Cocoa/Cocoa.h>

#import "PRInfoAlbum.h"
#import "PRIsolatedTextView.h"


@interface PRAlbumLinkViewController : NSViewController <NSTextViewDelegate>
{
	IBOutlet NSImageView *artworkImageView;
	IBOutlet PRIsolatedTextView *albumInfoView;
	
	PRInfoAlbum *album;
}

- (id)initWithAlbum:(PRInfoAlbum *)a;

- (void)setAlbum:(PRInfoAlbum *)a;

@end
