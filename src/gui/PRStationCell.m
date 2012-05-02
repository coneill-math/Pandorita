//
//  PRStationCell.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRStationCell.h"


@implementation PRStationCell

- (BOOL)isMainStation
{
	return isMainStation;
}

- (void)setIsMainStation:(BOOL)main
{
	isMainStation = main;
}

- (CGFloat)extraHeightForMainStation
{
	return 0.0;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect baseFrame = cellFrame;
	NSRect addonFrame = cellFrame;
	
	if (isMainStation)
	{
		baseFrame.size.height -= [self extraHeightForMainStation];
	}
	
	[super drawInteriorWithFrame:baseFrame inView:controlView];
	
	if (isMainStation)
	{
		addonFrame.origin.y += addonFrame.size.height - [self extraHeightForMainStation];
		addonFrame.size.height = [self extraHeightForMainStation];
		
//		[[NSColor blackColor] set];
//		NSRectFill(addonFrame);
	}
}

@end
