//
//  PRArtworkView.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRArtworkController.h"

#import "PRUtils.h"
#import "PRAppDelegate.h"


@implementation PRArtworkController

- (void)awakeFromNib
{
	responseData = [[NSMutableData alloc] init];
	connection = nil;
	
	artworkData = nil;
	
	[imageView setImage:[NSImage imageNamed:@"nothingplaying"]];
}

- (NSData *)artworkData
{
	return artworkData;
}

- (void)loadImageFromSong:(PRSong *)song
{
	if (connection)
	{
		[connection cancel];
		RELEASE_MEMBER(connection);
	}
	
	RELEASE_MEMBER(artworkData);
	
	NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[song coverArtURL]] autorelease];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection start];
	
	[imageView setImage:[NSImage imageNamed:@"loadingcover"]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)e
{
	NSLog(@"Unable to load artwork: %@", [e localizedDescription]);
	[imageView setImage:[NSImage imageNamed:@"covererror"]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSImage *image = [[NSImage alloc] initWithData:responseData];
	[imageView setImage:image];
	[image release];
	
	artworkData = [[NSData alloc] initWithData:responseData];
	
	if ([[NSApp delegate] isPlaying])
	{
		[[NSApp delegate] pushGrowlNotification];
	}
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
	return [subview containsView:imageView];
}

- (BOOL)splitView:(NSSplitView *)splitView shouldCollapseSubview:(NSView *)subview forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
	return [subview containsView:imageView];
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSRect totalFrame = [splitView frame];
	NSRect firstFrame = [[[splitView subviews] objectAtIndex:0] frame];
	NSRect secondFrame = [[[splitView subviews] objectAtIndex:1] frame];
	
	firstFrame.size.width = totalFrame.size.width;
	secondFrame.size.width = totalFrame.size.width;
	
	secondFrame.size.height = secondFrame.size.width;
	firstFrame.size.height = totalFrame.size.height - secondFrame.size.height - [splitView dividerThickness];
	secondFrame.origin.y = firstFrame.size.height + [splitView dividerThickness];
	
	[[[splitView subviews] objectAtIndex:0] setFrame:firstFrame];
	[[[splitView subviews] objectAtIndex:1] setFrame:secondFrame];
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
	return [splitView frame].size.height - [splitView frame].size.width - [splitView dividerThickness];
}

- (void)dealloc
{
	RELEASE_MEMBER(responseData);
	RELEASE_MEMBER(artworkData);
	
	[super dealloc];
}


@end
