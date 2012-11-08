//
//  PRSongProgressView.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRSongProgressView.h"


@implementation PRSongProgressView

- (id)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self != nil)
	{
		backLeftImage = [[NSImage imageNamed:@"progress-back-left"] retain];
		backMiddleImage = [[NSImage imageNamed:@"progress-back-middle"] retain];
		backRightImage = [[NSImage imageNamed:@"progress-back-right"] retain];
		frontLeftImage = [[NSImage imageNamed:@"progress-front-left"] retain];
		frontMiddleImage = [[NSImage imageNamed:@"progress-front-middle"] retain];
		frontRightImage = [[NSImage imageNamed:@"progress-front-right"] retain];
		
		progress = 0;
	}
	
	return self;
}

- (void)setProgress:(CGFloat)prog
{
	progress = prog;
	
	if (progress > 1)
	{
		progress = 1;
	}
	else if (progress < 0)
	{
		progress = 0;
	}
	
	[self setNeedsDisplay:YES];
}

#if 0

#define PROGRESS_BORDER 2

- (void)drawRect:(NSRect)dirtyRect
{
	NSSize size = [self bounds].size;
	CGFloat edgeWidth = floor(size.height / 2);
	CGFloat progressWidth = floor((size.width - (2 * (edgeWidth + PROGRESS_BORDER))) * progress);
	
	NSRect backLeftRect = NSMakeRect(PROGRESS_BORDER, 0, edgeWidth, size.height);
	NSRect backMiddleRect = NSMakeRect(PROGRESS_BORDER + edgeWidth, 0, size.width - (2 * (edgeWidth + PROGRESS_BORDER)), size.height);
	NSRect backRightRect = NSMakeRect(size.width - edgeWidth - PROGRESS_BORDER, 0, edgeWidth, size.height);
	NSRect frontLeftRect = NSMakeRect(PROGRESS_BORDER, 0, edgeWidth, size.height);
	NSRect frontMiddleRect = NSMakeRect(PROGRESS_BORDER + edgeWidth, 0, progressWidth, size.height);
	NSRect frontRightRect = NSMakeRect(PROGRESS_BORDER + edgeWidth + progressWidth, 0, edgeWidth, size.height);
	
	[backLeftImage drawInRect:backLeftRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[backMiddleImage drawInRect:backMiddleRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[backRightImage drawInRect:backRightRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	if (progress > 0)
	{
		[frontLeftImage drawInRect:frontLeftRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		[frontMiddleImage drawInRect:frontMiddleRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		[frontRightImage drawInRect:frontRightRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
}

#else

#define PROGRESS_BORDER 2

- (void)drawRect:(NSRect)dirtyRect
{
	NSSize size = [self bounds].size;
	NSRect progressRect = NSMakeRect(PROGRESS_BORDER, PROGRESS_BORDER, (NSInteger)(progress * (size.width - (2 * PROGRESS_BORDER))), size.height - (2 * PROGRESS_BORDER));
	
	[[NSColor blackColor] set];
	NSFrameRect([self bounds]);
	
	[[NSColor grayColor] set];
	NSRectFill(progressRect);
	
	[[NSColor blackColor] set];
	NSFrameRect(progressRect);
}
#endif

- (void)dealloc
{
	RELEASE_MEMBER(backLeftImage);
	RELEASE_MEMBER(backMiddleImage);
	RELEASE_MEMBER(backRightImage);
	RELEASE_MEMBER(frontLeftImage);
	RELEASE_MEMBER(frontMiddleImage);
	RELEASE_MEMBER(frontRightImage);
	
	[super dealloc];
}

@end
