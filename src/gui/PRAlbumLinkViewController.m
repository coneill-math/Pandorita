//
//  PRAlbumLinkViewController.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/26/12.
//
//

#import "PRAlbumLinkViewController.h"

#import "PRArtistInfoViewController.h"



@interface PRAlbumLinkViewController ()

- (void)manuallyLineBreakAlbumName;

@end

@implementation PRAlbumLinkViewController

- (id)initWithAlbum:(PRInfoAlbum *)a
{
	self = [super initWithNibName:@"AlbumLinkView" bundle:nil];
	
	if (self)
	{
		[self loadView];
		[self setAlbum:a];
	}
	
	return self;
}

- (void)setAlbum:(PRInfoAlbum *)a
{
	RETAIN_MEMBER(a);
	RELEASE_MEMBER(album);
	album = a;
	
	NSMutableAttributedString *str = [[[NSMutableAttributedString alloc] initWithString:[album albumName]] autorelease];
	NSString *link = [PRBaseInfoViewController pandoritaLinkForLink:[album linkStr]];
	NSString *albumYear = [album albumYear];
	NSImage *albumArtwork = [album albumArtwork];
	
	if (![link isEqualToString:@""])
	{
		[str setAttributedString:[PRBaseInfoViewController attributedString:str forLink:link]];
	}
	
	[[albumInfoView textStorage] setAttributedString:str];
	[self manuallyLineBreakAlbumName];
	
	if (![albumYear isEqualToString:@""])
	{
		NSDictionary *yearAttrs = [NSDictionary dictionary];
		[[albumInfoView textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@", albumYear] attributes:yearAttrs] autorelease]];
	}
	
	if (albumArtwork)
	{
		[artworkImageView setImage:albumArtwork];
	}
}

- (void)manuallyLineBreakAlbumName
{
	// walk through each line from the top and find the first one that is not fully visible
	NSUInteger lineIndex = 0;
	NSUInteger glyphIndex = 0;
	NSRange lineRange = NSMakeRange(0,0);
	
	NSMutableParagraphStyle *style = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
	[style setLineBreakMode:NSLineBreakByWordWrapping];
	[[albumInfoView textStorage] addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [[albumInfoView textStorage] length])];
	
	for(lineIndex = 0;glyphIndex < [[albumInfoView layoutManager] numberOfGlyphs] && lineIndex < 3-1; lineIndex++)
	{
		//NSRect lineRect =
		[[albumInfoView layoutManager] lineFragmentUsedRectForGlyphAtIndex:glyphIndex effectiveRange:&lineRange];
	//	PRLog(@"Line range: %@", NSStringFromRange(lineRange));
		
		// no need to truncate this line
		if (NSMaxRange(lineRange) >= [[albumInfoView textStorage] length])
	//	if (NSContainsRect([albumInfoView visibleRect], lineRect))
		{
			break;
		}
		
		[[albumInfoView textStorage] replaceCharactersInRange:NSMakeRange(NSMaxRange(lineRange), 0) withString:@"\n"];
		
		glyphIndex = NSMaxRange(lineRange) + 1;
	}
	
	[style setLineBreakMode:NSLineBreakByTruncatingTail];
	NSRange lastLineRange = NSMakeRange(lineRange.location, [[albumInfoView textStorage] length] - lineRange.location);
	[[albumInfoView textStorage] addAttribute:NSParagraphStyleAttributeName value:style range:lastLineRange];
}

- (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex
{
	return [PRBaseInfoViewController textView:aTextView clickedOnLink:link atIndex:charIndex];
}

- (void)dealloc
{
	RELEASE_MEMBER(album);
	[super dealloc];
}

@end
