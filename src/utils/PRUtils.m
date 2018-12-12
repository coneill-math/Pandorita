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
	
	return [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];
}

@implementation NSString (PRUtils_Additions)

- (NSUInteger)countOfCharactersInSet:(NSCharacterSet *)set
{
	NSUInteger ret = 0;
	NSUInteger i = 0;
	
	for(i = 0;i < [self length];i++)
	{
		if ([set characterIsMember:[self characterAtIndex:i]])
		{
			ret++;
		}
	}
	
	return ret;
}

@end

@implementation NSURL (PRUtils_Additions)

- (NSURL *)URLByDeletingQuery
{
	return [[[NSURL alloc] initWithScheme:[self scheme]
					 host:[self host]
					 path:[self path]] autorelease];
}

- (NSURL *)URLByDeletingStringLastPathComponent
{
	return [[[NSURL alloc] initWithScheme:[self scheme]
					 host:[self host]
					 path:[[self path] stringByDeletingLastPathComponent]] autorelease];
}

@end

@implementation NSAttributedString (PRUtils_Additions)

+ (id)attributedString:(NSString *)str withAttributes:(NSDictionary *)attributes
{
	return [[[NSAttributedString alloc] initWithString:str attributes:attributes] autorelease];
}

@end

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

#if 0
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
#endif

