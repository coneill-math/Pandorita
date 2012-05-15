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
		progress = 0.5;
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

@end
