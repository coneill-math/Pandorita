//
//  PRBaseInfoViewController.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/24/12.
//
//

#import "PRBaseInfoViewController.h"

#import "PRUtils.h"
#import "PRAppDelegate.h"


@interface PRBaseInfoViewController ()

+ (void)appendToAttributedString:(NSMutableAttributedString *)str withAttributes:(NSMutableDictionary *)attributes forElement:(TFHppleElement *)element;

@end

@implementation PRBaseInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self)
	{
		[self loadView];
		desiredHeight = [[self view] frame].size.height;
	}
	
	return self;
}

- (NSString *)title
{
	return @"";
}

- (CGFloat)desiredHeight
{
	return desiredHeight;
}

// call from a separate thread
- (BOOL)downloadData
{
	// nothing to do
	return YES;
}

// call from the main thread
- (void)displayData
{
	// nothing to do
}

+ (NSAttributedString *)attributedString:(NSAttributedString *)str forLink:(NSString *)link
{
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
	[attributes setValue:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
	[attributes setValue:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
	[attributes setValue:link forKey:NSLinkAttributeName];
	
	NSMutableAttributedString *ret = [[[NSMutableAttributedString alloc] initWithAttributedString:str] autorelease];
	[ret addAttributes:attributes range:NSMakeRange(0, [str length])];
	
	return [[[NSAttributedString alloc] initWithAttributedString:ret] autorelease];
}

+ (NSAttributedString *)attributedStringForElement:(TFHppleElement *)element
{
	NSMutableAttributedString *ret = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setValue:[NSFont fontWithName:@"Helvetica" size:12.0] forKey:NSFontAttributeName];
	[dict setValue:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	
	[PRBaseInfoViewController appendToAttributedString:ret withAttributes:dict forElement:element];
	
	return [[[NSAttributedString alloc] initWithAttributedString:ret] autorelease];
}

+ (void)appendToAttributedString:(NSMutableAttributedString *)str withAttributes:(NSMutableDictionary *)attributes forElement:(TFHppleElement *)element
{
	for(TFHppleElement *elem in [element children])
	{
		if ([[elem tagName] isEqualToString:@"text"])
		{
			NSString *content = [elem content];
		//	content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
			[str appendAttributedString:[NSAttributedString attributedString:content withAttributes:attributes]];
		}
		else if ([[elem tagName] isEqualToString:@"br"])
		{
			[str appendAttributedString:[NSAttributedString attributedString:@"\n" withAttributes:attributes]];
		}
		else if ([[elem tagName] isEqualToString:@"b"])
		{
			NSFont *oldFont = [attributes objectForKey:NSFontAttributeName];
			NSFont *newFont = [NSFont fontWithDescriptor:[[oldFont fontDescriptor] fontDescriptorWithSymbolicTraits:NSFontBoldTrait] size:[oldFont pointSize]];
			
			[attributes setValue:newFont forKey:NSFontAttributeName];
			[PRBaseInfoViewController appendToAttributedString:str withAttributes:attributes forElement:elem];
			[attributes setValue:oldFont forKey:NSFontAttributeName];
		}
		else if ([[elem tagName] isEqualToString:@"i"])
		{
			NSFont *oldFont = [attributes objectForKey:NSFontAttributeName];
			NSFont *newFont = [NSFont fontWithDescriptor:[[oldFont fontDescriptor] fontDescriptorWithSymbolicTraits:NSFontItalicTrait] size:[oldFont pointSize]];
			
			[attributes setValue:newFont forKey:NSFontAttributeName];
			[PRBaseInfoViewController appendToAttributedString:str withAttributes:attributes forElement:elem];
			[attributes setValue:oldFont forKey:NSFontAttributeName];
		}
		else if ([[elem tagName] isEqualToString:@"a"])
		{
			NSString *internalLink = [self pandoritaLinkForLink:[elem objectForKey:@"href"]];
			
			if (![internalLink isEqualToString:@""] && [attributes objectForKey:NSLinkAttributeName] == nil)
			{
				NSMutableAttributedString *tempStr = [[[NSMutableAttributedString alloc] init] autorelease];
				[self appendToAttributedString:tempStr withAttributes:attributes forElement:elem];
				[str appendAttributedString:[self attributedString:tempStr forLink:internalLink]];
			}
			else
			{
				[PRBaseInfoViewController appendToAttributedString:str withAttributes:attributes forElement:elem];
			}
		}
		else
		{
			NSLog(@"Odd HTML tag encountered: %@", [elem tagName]);
		}
	}
}

+ (NSString *)pandoritaLinkForLink:(NSString *)linkStr
{
	NSString *internalLink = @"";
	
	// otherwise its not one of our links link
	if ([linkStr hasPrefix:@"/"])
	{
		// otherwise its a dead link
		if (!([linkStr length] == 33 && [linkStr countOfCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdef"]] == 32))
		{
			NSUInteger numSlashes = [linkStr countOfCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
			if (numSlashes == 1)
			{
				// its an artist
				internalLink = [NSString stringWithFormat:@"artist:%@", linkStr];
			}
			else if (numSlashes == 2)
			{
				// its an album
				internalLink = [NSString stringWithFormat:@"album:%@", linkStr];
			}
			else
			{
				// its a song
				internalLink = [NSString stringWithFormat:@"song:%@", linkStr];
			}
		}
	}
	
	return internalLink;
}

+ (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
	// in case of chaos
	if ([link class] != [NSString class])
	{
		link = [link description];
	}
	
	if ([link hasPrefix:@"artist:"])
	{
		[[NSApp delegate] showInfoForArtistUrl:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.pandora.com%@", [link substringFromIndex:7]]]];
	}
	else if ([link hasPrefix:@"album:"])
	{
		[[NSApp delegate] showInfoForAlbumUrl:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.pandora.com%@", [link substringFromIndex:6]]]];
	}
	else if ([link hasPrefix:@"song:"])
	{
		[[NSApp delegate] showInfoForSongUrl:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.pandora.com%@", [link substringFromIndex:5]]]];
	}
	
	// dont want to accidentally open the browser
	return YES;
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
	return [PRBaseInfoViewController textView:aTextView clickedOnLink:link atIndex:charIndex];
}

@end
