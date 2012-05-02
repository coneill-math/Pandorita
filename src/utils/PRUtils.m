//
//  PRUtils.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRUtils.h"


@implementation NSView (PRUtils_Additions)

- (BOOL)containsView:(NSView *)subview
{
	NSView *superview = [subview superview];
	if (superview == nil)
	{
		return NO;
	}
	else if (self == superview)
	{
		return YES;
	}
	else
	{
		return [self containsView:superview];
	}
}

@end

