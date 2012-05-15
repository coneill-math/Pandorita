//
//  PRUtils.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRUtils.h"


NSString *PRSongDurationFromInterval(NSTimeInterval interval)
{
	NSInteger minutes = (NSInteger)(interval / 60);
	NSInteger seconds = (NSInteger)(interval - (60*minutes));
	
	return [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}


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


@implementation NSSearchField (PRUtils_Additions)

- (IBAction)endEditingAndClear:(id)sender
{
	[self setStringValue:@""];
	[[[self cell] cancelButtonCell] performClick:self];
}

@end


@implementation QTMovie (PRUtils_Additions)

- (NSTimeInterval)durationAsInterval
{
	NSTimeInterval interval = 0;
	
	QTGetTimeInterval([self duration], &interval);
	
	return interval;
}

- (NSTimeInterval)currentTimeAsInterval
{
	NSTimeInterval interval = 0;
	
	QTGetTimeInterval([self currentTime], &interval);
	
	return interval;
}

@end

