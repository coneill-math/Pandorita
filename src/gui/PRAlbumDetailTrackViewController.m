//
//  PRAlbumDetailTrackViewController.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/29/12.
//
//

#import "PRAlbumDetailTrackViewController.h"
#import "PRBaseInfoViewController.h"

@interface PRAlbumDetailTrackViewController ()

@end

@implementation PRAlbumDetailTrackViewController

- (id)initWithTrack:(PRInfoTrack *)t
{
	self = [super initWithNibName:@"AlbumDetailTrackView" bundle:nil];
	
	if (self)
	{
		[self loadView];
		track = [t retain];
		
		NSAttributedString *titleStr = [[[NSAttributedString alloc] initWithString:[track trackName]] autorelease];
		
		[[titleView textStorage] setAttributedString:titleStr];
		[numberField setStringValue:[NSString stringWithFormat:@"%02d", [track trackNumber]]];
		
		[titleView setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	
	return self;
}

- (IBAction)playClicked:(id)sender
{
	NSLog(@"Samples coming soon!");
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
	return [PRBaseInfoViewController textView:aTextView clickedOnLink:link atIndex:charIndex];
}

- (void)dealloc
{
	RELEASE_MEMBER(track);
	[super dealloc];
}

@end
