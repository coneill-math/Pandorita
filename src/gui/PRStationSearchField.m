//
//  PRStationSearchField.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRStationSearchField.h"

#import "PRSearchTableDelegate.h"


@implementation PRStationSearchField
/*
- (void)moveDown:(id)sender
{
	[searchTableDelegate shiftSelection:1];
}

- (void)moveUp:(id)sender
{
	[searchTableDelegate shiftSelection:-1];
}

-(BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
	return [self tryToPerform:aSelector with:aTextView];
}
*/ /*
- (void)keyDown:(NSEvent *)theEvent
{
	unsigned short keyCode = [theEvent keyCode];
	
	if (keyCode == 0)
	{
		[searchTableDelegate shiftSelection:-1];
	}
	else if (keyCode == 0)
	{
		[searchTableDelegate shiftSelection:1];
	}
	else
	{
		[super keyDown:theEvent];
	}
}
*/
@end
