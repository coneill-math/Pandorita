//
//  PRRatingCell.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRRatingCell.h"

#import "PRAppDelegate.h"

@implementation PRRatingCell

- (void)initializeRatingCell
{
	[self setTrackingMode:NSSegmentSwitchTrackingSelectAny];
	[self setControlSize:NSMiniControlSize];
	[self setSegmentCount:2];
	
	[self setLabel:@"Like" forSegment:0]; // (unichar)0x263a
	[self setLabel:@"Ban" forSegment:1]; // (unichar)0x2639
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	
	if (self != nil)
	{
		[self initializeRatingCell];
	}
	
	return self;
}

- (id)initTextCell:(NSString *)str
{
	self = [super initTextCell:str];
	
	if (self != nil)
	{
		[self initializeRatingCell];
	}
	
	return self;
}

- (id)initImageCell:(NSImage *)image
{
	self = [super initImageCell:image];
	
	if (self != nil)
	{
		[self initializeRatingCell];
	}
	
	return self;
}

- (PRRating)selectedRating
{
	NSInteger segment = [self selectedSegment];
	if (segment == 0)
	{
		return PRRATING_LOVE;
	}
	else if (segment == 1)
	{
		return PRRATING_BAN;
	}
	else
	{
		return PRRATING_NONE;
	}
}

- (void)setRating:(PRRating)rating
{
	if (rating == PRRATING_LOVE)
	{
		[super setSelected:YES forSegment:0];
		[super setSelected:NO forSegment:1];
	}
	else if (rating == PRRATING_BAN)
	{
		[super setSelected:NO forSegment:0];
		[super setSelected:YES forSegment:1];
	}
	else
	{
		[super setSelected:NO forSegment:0];
		[super setSelected:NO forSegment:1];
	}
}

- (void)segmentSelectedByMouseClick:(NSUInteger)segment
{
	if (segment == 0)
	{
		PRLog(@"Loving");
		[(PRAppDelegate *)[NSApp delegate] setRatingFromSegmentClick:PRRATING_LOVE];
	}
	else if (segment == 1)
	{
		PRLog(@"Banning");
		[(PRAppDelegate *)[NSApp delegate] setRatingFromSegmentClick:PRRATING_BAN];
	}
}

- (BOOL)trackMouse:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp;
{ 
	NSPoint loc = [controlView convertPoint:[event locationInWindow] fromView:nil];
	NSRect segmentFrame = cellFrame;
	NSUInteger i = 0;
	
	for(i = 0;i < [self segmentCount] && segmentFrame.origin.x < cellFrame.origin.x + cellFrame.size.width;i++)
	{ 
		segmentFrame.size.width = [self widthForSegment:i];
		
		// this is pathetic, I should not have to do this myself...
		if (segmentFrame.size.width == 0.0)
		{
			segmentFrame.size.width = (cellFrame.origin.x + cellFrame.size.width - segmentFrame.origin.x) / ([self segmentCount] - i); 
		}
		
		if (NSPointInRect(loc, segmentFrame))
		{
			[self segmentSelectedByMouseClick:i];
			break;
		}
		
		segmentFrame.origin.x += segmentFrame.size.width;
	}
	
	[controlView setNeedsDisplay:YES];
 	
	return [super trackMouse:event inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
}
/*
- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag;
{
	[self setHighlightedSegment:-1];
	[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}
*/
- (void)dealloc
{
	[super dealloc];
}


@end
