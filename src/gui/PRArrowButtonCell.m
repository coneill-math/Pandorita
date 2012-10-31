//
//  PRArrowButtonCell.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/21/12.
//
//

#import "PRArrowButtonCell.h"

#import "PRSongHistoryTableDelegate.h"


@implementation PRArrowButtonCell

- (BOOL)wasMouseClickInButtonForCellFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSPoint mouseLoc = [controlView convertPointFromBase:[[controlView window] mouseLocationOutsideOfEventStream]];
	NSRect imageBounds = [self imageRectForBounds:cellFrame];
	
	return NSMouseInRect(mouseLoc, imageBounds, [controlView isFlipped]);
}

- (NSUInteger)hitTestForEvent:(NSEvent *)event inRect:(NSRect)cellFrame ofView:(NSView *)controlView
{
	NSUInteger result = [super hitTestForEvent:event inRect:cellFrame ofView:controlView];
	
	if (result > NSCellHitNone)
	{
		if (![self wasMouseClickInButtonForCellFrame:cellFrame inView:controlView])
		{
			result = NSCellHitContentArea;
		}
	}
	
	return result;
}

@end
