//
//  PRInfoViewController.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/21/12.
//
//

#import "PRInfoViewController.h"

#import "PRUtils.h"

#import "PRImageInfoViewController.h"
#import "PRLoadingInfoViewController.h"
#import "PRArtistInfoViewController.h"

#import "PRAppDelegate.h"


@interface PRInfoViewController (PRInfoViewController_Private)

- (void)setupController;
- (void)downloadControllerData:(id)controller;
- (void)downloadComplete:(id)controller;
- (void)setController:(id)controller;

- (CGFloat)heightOfLowerSplitView;

@end

@implementation PRInfoViewController

+ (NSURL *)songInfoUrlForSongUrl:(NSURL *)songUrl
{
	NSString *urlStr = [songUrl description];
	NSUInteger index = [urlStr rangeOfString:@"?"].location;
	if (index == NSNotFound)
	{
		index = [urlStr length];
	}
	
	urlStr = [urlStr substringToIndex:index];
	return [NSURL URLWithString:urlStr];
}

+ (NSURL *)artistInfoUrlForSongUrl:(NSURL *)songUrl
{
	NSString *urlStr = [songUrl description];
	NSUInteger index = [urlStr rangeOfString:@"?"].location;
	if (index == NSNotFound)
	{
		index = [urlStr length];
	}
	
	urlStr = [urlStr substringToIndex:index];
	urlStr = [urlStr stringByDeletingLastPathComponent];
	urlStr = [urlStr stringByDeletingLastPathComponent];
	return [NSURL URLWithString:urlStr];
}

+ (NSURL *)artistInfoUrlForAlbumUrl:(NSURL *)albumUrl
{
	NSString *urlStr = [albumUrl description];
	NSUInteger index = [urlStr rangeOfString:@"?"].location;
	if (index == NSNotFound)
	{
		index = [urlStr length];
	}
	
	urlStr = [urlStr substringToIndex:index];
	urlStr = [urlStr stringByDeletingLastPathComponent];
	return [NSURL URLWithString:urlStr];
}

+ (NSURL *)albumInfoUrlForSongUrl:(NSURL *)songUrl
{
	NSString *urlStr = [songUrl description];
	NSUInteger index = [urlStr rangeOfString:@"?"].location;
	if (index == NSNotFound)
	{
		index = [urlStr length];
	}
	
	urlStr = [urlStr substringToIndex:index];
	urlStr = [urlStr stringByDeletingLastPathComponent];
	return [NSURL URLWithString:urlStr];
}

- (void)awakeFromNib
{
	[self setController:[[[PRImageInfoViewController alloc] initWithBlankImage] autorelease]];
	[self collapseInfoView:self];
}

- (void)setupController:(id)controller
{
	[self setController:[[[PRLoadingInfoViewController alloc] init] autorelease]];
	[self performSelectorInBackground:@selector(downloadControllerData:) withObject:controller];
}

- (void)downloadControllerData:(id)controller
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (![controller downloadData])
	{
		// will automatically release
		controller = nil;
	}
	
	[pool release];
	
	[self performSelectorOnMainThread:@selector(downloadComplete:) withObject:controller waitUntilDone:NO];
}

- (void)downloadComplete:(id)controller
{
	if (controller)
	{
		[controller displayData];
		[self setController:controller];
	}
	else
	{
		[self setController:[[[PRImageInfoViewController alloc] initWithErrorImage] autorelease]];
	}
}

- (void)setController:(id)controller
{
	if (currentController)
	{
		[[currentController view] removeFromSuperview];
		RELEASE_MEMBER(currentController);
	}
	
	currentController = [controller retain];
	
	[titleField setStringValue:[controller title]];
	
	[infoView addSubview:[currentController view]];
	[self splitView:infoSplitView resizeSubviewsWithOldSize:[infoSplitView frame].size];
	
	NSRect frame = NSMakeRect(0, 0, [infoView bounds].size.width, [currentController desiredHeight]);
	[infoView setFrame:frame];
	[[currentController view] setFrame:frame];
}

- (void)showInfoForArtist:(NSURL *)artistUrl
{
	[self setupController:[[[PRArtistInfoViewController alloc] initWithArtist:artistUrl] autorelease]];
}

- (void)showInfoForAlbum:(NSURL *)albumUrl
{
	if ([currentController class] != [PRArtistInfoViewController class] || ![currentController showAlbumAtUrl:albumUrl])
	{
		[self setupController:[[[PRArtistInfoViewController alloc] initWithAlbum:albumUrl] autorelease]];
	}
}

- (IBAction)expandInfoView:(id)sender
{
	[[[infoSplitView subviews] objectAtIndex:1] setHidden:NO];
	[infoSplitView adjustSubviews];
	[self splitView:infoSplitView resizeSubviewsWithOldSize:[infoSplitView frame].size];
}

- (IBAction)collapseInfoView:(id)sender
{
	[[[infoSplitView subviews] objectAtIndex:1] setHidden:YES];
	[infoSplitView adjustSubviews];
	[self splitView:infoSplitView resizeSubviewsWithOldSize:[infoSplitView frame].size];
}

- (BOOL)isInfoViewCollapsed
{
	return [infoSplitView isSubviewCollapsed:[[infoSplitView subviews] objectAtIndex:1]];
}

- (IBAction)backPressed:(id)sender
{
	
}

- (IBAction)forwardPressed:(id)sender
{
	
}

- (CGFloat)heightOfLowerSplitView
{
	CGFloat height = 0;
	
	if (currentController)
	{
		height = [currentController desiredHeight];
		height += [titleBarImageView frame].size.height;
	}
	
	return height;
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	return NO;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
	return [subview containsView:infoView];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	return [subview containsView:infoView];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
	return YES;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSRect totalFrame = [splitView frame];
	NSRect firstFrame = [[[splitView subviews] objectAtIndex:0] frame];
	NSRect secondFrame = [[[splitView subviews] objectAtIndex:1] frame];
	
	CGFloat height = [self heightOfLowerSplitView];
	
	firstFrame.size.width = totalFrame.size.width;
	secondFrame.size.width = totalFrame.size.width;
	
	if ([self isInfoViewCollapsed])
	{
		firstFrame.size.height = totalFrame.size.height;
	}
	else
	{
		secondFrame.size.height = height;
		firstFrame.size.height = totalFrame.size.height - secondFrame.size.height - [splitView dividerThickness];
		secondFrame.origin.y = firstFrame.size.height + [splitView dividerThickness];
	}
	
	[[[splitView subviews] objectAtIndex:0] setFrame:firstFrame];
	[[[splitView subviews] objectAtIndex:1] setFrame:secondFrame];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
	CGFloat height = [self heightOfLowerSplitView];
	CGFloat fixed = [splitView frame].size.height - height - [splitView dividerThickness];
	
	return fixed;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
	[[NSApp delegate] updateInfoMenu];
}

- (void)dealloc
{
	RELEASE_MEMBER(currentController);
	[super dealloc];
}

@end
