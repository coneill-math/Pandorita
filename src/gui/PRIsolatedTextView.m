//
//  PRIsolatedTextView.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/27/12.
//
//

#import "PRIsolatedTextView.h"

#import "PRBaseInfoViewController.h"

@implementation PRIsolatedTextView

- (void)awakeFromNib
{
	NSScrollView *scrollView = [self enclosingScrollView];
	NSView *mainView = [scrollView superview];
	
	// remove the enclosing scroll view
	[self retain];
	[self removeFromSuperview];
	[self setFrame:[scrollView frame]];
	[scrollView removeFromSuperview];
	[mainView addSubview:self];
	[self release];
	
	// tweak other settings
	[self setDelegate:self];
	[self setDisplaysLinkToolTips:NO];
	[self setVerticallyResizable:NO];
//	[self setLineBreakMode:NSLineBreakByTruncatingMiddle];
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode
{
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[style setLineBreakMode:lineBreakMode];
	[[self textStorage] addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [[self textStorage] length])];
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
	return [PRBaseInfoViewController textView:aTextView clickedOnLink:link atIndex:charIndex];
}

@end
