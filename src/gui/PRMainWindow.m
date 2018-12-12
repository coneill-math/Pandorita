//
//  PRMainWindow.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRMainWindow.h"

#import "PRAppDelegate.h"


@implementation PRMainWindow

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *str = [theEvent charactersIgnoringModifiers];
	NSInteger i;
	
	for(i = 0;i < [str length];i++)
	{
		if ([str characterAtIndex:i] == ' ')
		{
			[(PRAppDelegate *)[NSApp delegate] togglePause:self];
		}
	}
	
	[super keyDown:theEvent];
}

@end
