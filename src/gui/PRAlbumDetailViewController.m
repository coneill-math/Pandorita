//
//  PRAlbumDetailViewController.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/28/12.
//
//

#import "PRAlbumDetailViewController.h"

@interface PRAlbumDetailViewController ()

@end

@implementation PRAlbumDetailViewController

- (id)init
{
	self = [super initWithNibName:@"AlbumDetailView" bundle:nil];
	
	if (self)
	{
		[self loadView];
		trackControllers = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)setAlbum:(PRInfoAlbum *)a
{
	RETAIN_MEMBER(a);
	RELEASE_MEMBER(album);
	album = a;
	
	// update info for new album
	NSUInteger i = 0;
	
	[[albumTitleView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:[album albumName]] autorelease]];
	[[albumYearView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:[album albumYear]] autorelease]];
	
	for(i = 0;i < [trackControllers count];i++)
	{
		[[[trackControllers objectAtIndex:i] view] removeFromSuperview];
	}
	
	[trackControllers removeAllObjects];
	
	for(i = 0;i < [album trackCount];i++)
	{
		PRAlbumDetailTrackViewController *controller = [[[PRAlbumDetailTrackViewController alloc] initWithTrack:[album trackAtIndex:i]] autorelease];
		[trackControllers addObject:controller];
	}
	
	CGFloat height = [[[trackControllers objectAtIndex:0] view] frame].size.height;
	CGFloat totalHeight = height * [trackControllers count];
	[trackListView setFrameSize:NSMakeSize([trackListView frame].size.width, totalHeight)];
	
	CGFloat y = totalHeight - height;
	for(i = 0;i < [trackControllers count];i++)
	{
		PRAlbumDetailTrackViewController *controller = [trackControllers objectAtIndex:i];
		
		[trackListView addSubview:[controller view]];
		[[controller view] setFrameOrigin:NSMakePoint(0, y)];
		
		y -= height;
	}
	
	[trackListView scrollPoint:NSMakePoint(0, totalHeight)];
	[[trackListView enclosingScrollView] tile];
}

- (void)dealloc
{
	RELEASE_MEMBER(album);
	RELEASE_MEMBER(trackControllers);
	[super dealloc];
}

@end
