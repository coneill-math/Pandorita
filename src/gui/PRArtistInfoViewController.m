//
//  PRArtistInfoViewController.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/21/12.
//
//

#import "PRArtistInfoViewController.h"

#import "PRAlbumLinkViewController.h"
#import "PRAppDelegate.h"


@interface PRArtistInfoViewController (PRArtistInfoViewController_Private)

- (void)updateMiddleView;

@end

@implementation PRArtistInfoViewController

- (id)initWithArtist:(NSURL *)artist
{
	self = [super initWithNibName:@"ArtistInfoView" bundle:nil];
	
	if (self)
	{
		[self loadView];
		
		[descriptionView setDisplaysLinkToolTips:NO];
		[descriptionView setHorizontallyResizable:NO];
		[descriptionView setDelegate:self];
		RETAIN_MEMBER(outerDescriptionView);
		
		albumDetailController = [[PRAlbumDetailViewController alloc] init];
		
		artistUrl = [artist retain];
		albumUrl = nil;
		currentAlbum = NSNotFound;
		
	//	PRLog(@"ArtistUrl: %@", artistUrl);
	}
	
	return self;
}

- (id)initWithAlbum:(NSURL *)album
{
	self = [super initWithNibName:@"ArtistInfoView" bundle:nil];
	
	if (self)
	{
		[self loadView];
		
		[descriptionView setDisplaysLinkToolTips:NO];
		[descriptionView setHorizontallyResizable:NO];
		[descriptionView setDelegate:self];
		RETAIN_MEMBER(outerDescriptionView);
		
		albumDetailController = [[PRAlbumDetailViewController alloc] init];
		
		albumUrl = [album retain];
		artistUrl = [[PRInfoViewController artistInfoUrlForAlbumUrl:albumUrl] retain];
		currentAlbum = NSNotFound;
		
	//	PRLog(@"AlbumUrl: %@", albumUrl);
	}
	
	return self;
}

- (NSString *)title
{
	return [NSString stringWithFormat:@"Artist: %@", artistName];
}

// call from a separate thread
- (BOOL)downloadData
{
	NSData *data = nil;
	TFHpple *hpple = nil;
	TFHppleElement *element = nil;
	TFHppleElement *musicIdElement = nil;
	TFHppleElement *artistElement = nil;
	TFHppleElement *descElement = nil;
	NSAttributedString *descStr = [[[NSMutableAttributedString alloc] initWithString:@"No description available."] autorelease];
	TFHppleElement *imageElement = nil;
	NSData *imageData = nil;
	NSArray *albumElementArray = nil;
	NSMutableArray *infoAlbumArray = nil;
	NSAttributedString *emptyString = [[[NSAttributedString alloc] initWithString:@""] autorelease];
	NSMutableArray *similarArtistStrings = [NSMutableArray arrayWithObjects:emptyString, emptyString, emptyString, emptyString, emptyString, nil];
	NSUInteger i = 0, j = 0;
	
	BOOL didLoad = NO;
	
	// Initialization code here.
	ERROR_ON_FAIL(artistUrl);
	
	data = [NSData dataWithContentsOfURL:artistUrl];
	ERROR_ON_FAIL(data);
	
	hpple = [[TFHpple alloc] initWithHTMLData:data];
	
	// music id
	musicIdElement = [hpple peekAtSearchWithXPathQuery:@"//img[@class='img_artist']/../.."];
	ERROR_ON_FAIL(musicIdElement);
	
	// artist name
	artistElement = [hpple peekAtSearchWithXPathQuery:@"//h1[@itemprop='name']"];
	ERROR_ON_FAIL(artistElement);
	
	// artist image
	imageElement = [hpple peekAtSearchWithXPathQuery:@"//img[@class='img_artist']"];
	ERROR_ON_FAIL(imageElement);
	
	imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[imageElement objectForKey:@"src"]]];
	
	// artist descriptoin
	descElement = [hpple peekAtSearchWithXPathQuery:@"//div[@class='artist_bio_inner']"];
	
	if (descElement)
	{
		descStr = [PRBaseInfoViewController attributedStringForElement:descElement];
	}
	
	// album list
	albumElementArray = [hpple searchWithXPathQuery:@"//div[@class='discography']//div[@class='meta']/../a|//div[@class='discography']//div[@class='meta']/../a/img|//div[@class='discography']//div[@class='meta']/..//div[@class='year']"];
	ERROR_ON_FAIL(albumElementArray);
	
	infoAlbumArray = [NSMutableArray arrayWithCapacity:[albumElementArray count]];
	
	for(i = 0;i < [albumElementArray count];i++)
	{
		element = [albumElementArray objectAtIndex:i];
		if (![[element tagName] isEqualToString:@"a"])
		{
			continue;
		}
		
		NSString *link = [element objectForKey:@"href"];
		NSString *musicId = [element objectForKey:@"data-musicid"];
		
		i++;
		element = [albumElementArray objectAtIndex:i];
		if (![[element tagName] isEqualToString:@"img"])
		{
			i--;
			continue;
		}
		
		NSString *albumName = [element objectForKey:@"title"];
		NSData *artworkData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[element objectForKey:@"src"]]];
		NSImage *artworkImage = [[[NSImage alloc] initWithData:artworkData] autorelease];
		
		PRInfoAlbum *infoAlbum = [[[PRInfoAlbum alloc] init] autorelease];
		[infoAlbum setLinkStr:link];
		[infoAlbum setMusicId:musicId];
		[infoAlbum setAlbumName:albumName];
		[infoAlbum setAlbumArtwork:artworkImage];
		[infoAlbum setAlbumYear:@""];
		[infoAlbumArray addObject:infoAlbum];
		
		i++;
		element = [albumElementArray objectAtIndex:i];
		
		// no year tag
		if (![[element tagName] isEqualToString:@"div"])
		{
			i--;
			continue;
		}
		
		NSString *yearStr = [[[PRBaseInfoViewController attributedStringForElement:element] string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		[infoAlbum setAlbumYear:yearStr];
	}
	
	[infoAlbumArray sortUsingSelector:@selector(compareToInfoAlbum:)];
	
	// track lists
	for(i = 0;i < [infoAlbumArray count];i++)
	{
		PRInfoAlbum *infoAlbum = [infoAlbumArray objectAtIndex:i];
		
		NSArray *elements = [hpple searchWithXPathQuery:[NSString stringWithFormat:@"//div[@class='album_detail' and @data-musicid='%@']//a[@class='track_link']", [infoAlbum musicId]]];
		
		for(j = 0;j < [elements count];j++)
		{
			element = [elements objectAtIndex:j];
			PRInfoTrack *track = [[[PRInfoTrack alloc] init] autorelease];
			
			[track setTrackName:[element objectForKey:@"title"]];
			
			NSString *link = [PRBaseInfoViewController pandoritaLinkForLink:[element objectForKey:@"href"]];
			if (![link isEqualToString:@""])
			{
				[track setLinkStr:link];
			}
			
			[infoAlbum addTrack:track];
		}
		
		elements = [hpple searchWithXPathQuery:[NSString stringWithFormat:@"//div[@class='album_detail' and @data-musicid='%@']//div[@class='track clearfix']/meta[itemprop='audio']", [infoAlbum musicId]]];
		
		// in case some don't have samples
		if ([elements count] == [infoAlbum trackCount])
		{
			for(j = 0;j < [elements count];j++)
			{
				element = [elements objectAtIndex:j];
				PRInfoTrack *track = [infoAlbum trackAtIndex:j];
				[track setSampleLinkStr:[element objectForKey:@"content"]];
				PRLog(@"%@", track);
			}
		}
	}
	
	// similar artists
	NSArray *similarElementArray = [hpple searchWithXPathQuery:@"//a[@class='similar_artist hash']"];
	
	for(i = 0;i < 5 && i < [similarElementArray count];i++)
	{
		element = [similarElementArray objectAtIndex:i];
		
		NSAttributedString *name = [PRBaseInfoViewController attributedStringForElement:element];
		NSString *link = [PRBaseInfoViewController pandoritaLinkForLink:[element objectForKey:@"href"]];
		
		if (![link isEqualToString:@""])
		{
			name = [PRBaseInfoViewController attributedString:name forLink:link];
		}
		
		[similarArtistStrings replaceObjectAtIndex:i withObject:name];
	}
	
	// save for the GUI
	@synchronized(self)
	{
		artistMusicId = [[musicIdElement objectForKey:@"data-musicid"] retain];
		artistName = [[artistElement objectForKey:@"title"] retain];
		artistDesc = [[NSAttributedString alloc] initWithAttributedString:descStr];
		
		artistImage = [[NSImage alloc] initWithData:imageData];
		similarArtistTexts = [[NSArray alloc] initWithArray:similarArtistStrings];
		infoAlbums = [[NSArray alloc] initWithArray:infoAlbumArray];
	}
	
	didLoad = YES;
	
error:
	RELEASE_MEMBER(hpple);
	return didLoad;
}

// call from the main thread
- (void)displayData
{
	NSUInteger i = 0;
	
	@synchronized(self)
	{
		// now setup the GUI
		[[descriptionView textStorage] setAttributedString:artistDesc];
		
		if (artistImage)
		{
			[artistImageView setImage:artistImage];
		}
		
		[[similarArtist1 textStorage] setAttributedString:[similarArtistTexts objectAtIndex:0]];
		[[similarArtist2 textStorage] setAttributedString:[similarArtistTexts objectAtIndex:1]];
		[[similarArtist3 textStorage] setAttributedString:[similarArtistTexts objectAtIndex:2]];
		[[similarArtist4 textStorage] setAttributedString:[similarArtistTexts objectAtIndex:3]];
		[[similarArtist5 textStorage] setAttributedString:[similarArtistTexts objectAtIndex:4]];
		
		albumLinkControllers = [[NSMutableArray alloc] init];
		
		if ([infoAlbums count] > 0)
		{
			for(i = 0;i < [infoAlbums count];i++)
			{
				PRAlbumLinkViewController *controller = [[[PRAlbumLinkViewController alloc] initWithAlbum:[infoAlbums objectAtIndex:i]] autorelease];
				[albumLinkControllers addObject:controller];
			}
			
			CGFloat height = [[[albumLinkControllers objectAtIndex:0] view] frame].size.height;
			CGFloat totalHeight = height * [albumLinkControllers count];
			[discographyView setFrameSize:NSMakeSize([discographyView frame].size.width, totalHeight)];
			
			CGFloat y = totalHeight - height;
			for(i = 0;i < [albumLinkControllers count];i++)
			{
				PRAlbumLinkViewController *controller = [albumLinkControllers objectAtIndex:i];
			//	[controller displayAlbumInfo];
				
				[discographyView addSubview:[controller view]];
				[[controller view] setFrameOrigin:NSMakePoint(0, y)];
				
				y -= height;
			}
			
			[discographyView scrollPoint:NSMakePoint(0, totalHeight)];
		}
		else
		{
			// what to do if there are no albums?
		}
		
		if (albumUrl)
		{
			[self showAlbumAtUrl:albumUrl];
		}
	}
}

- (void)updateMiddleView
{
	NSView *fromView = nil;
	NSView *toView = nil;
	NSImage *image = nil;
	
	if ([outerDescriptionView superview])
	{
		fromView = outerDescriptionView;
	}
	else
	{
		fromView = [albumDetailController view];
	}
	
	// album to display
	if (currentAlbum != NSNotFound)
	{
		toView = [albumDetailController view];
		image = [[infoAlbums objectAtIndex:currentAlbum] albumArtwork];
	}
	// description
	else if (!albumUrl)
	{
		toView = outerDescriptionView;
		image = artistImage;
	}
	// unable to show (find) load album
	else
	{
		// handle this case later
		return;
		
		// be sure to update fromView code with third option
	}
	
	if (toView != fromView)
	{
		NSRect frame = [fromView frame];
		[fromView removeFromSuperview];
		
		[[self view] addSubview:toView];
		[toView setFrame:frame];
	}
	
	if (image)
	{
		[artistImageView setImage:image];
	}
}

- (BOOL)showAlbumAtUrl:(NSURL *)album
{
	NSUInteger i = 0;
	
	if (![artistUrl isEqual:[PRInfoViewController artistInfoUrlForAlbumUrl:album]])
	{
		return NO;
	}
	
	RETAIN_MEMBER(album);
	RELEASE_MEMBER(albumUrl);
	albumUrl = album;
	
	for(i = 0;i < [infoAlbums count];i++)
	{
		NSString *linkStr = [NSString stringWithFormat:@"http://www.pandora.com%@", [[infoAlbums objectAtIndex:i] linkStr]];
		if ([albumUrl isEqual:[NSURL URLWithString:linkStr]])
		{
			currentAlbum = i;
			[albumDetailController setAlbum:[infoAlbums objectAtIndex:currentAlbum]];
			[self updateMiddleView];
			
			return YES;
		}
	}
	
	return YES;
}

- (IBAction)createStation:(id)sender
{
	[[NSApp delegate] createStationWithMusicId:artistMusicId];
}

- (IBAction)addSeed:(id)sender
{
	[[NSApp delegate] addSeedToCurrentStation:artistMusicId];
}

- (void)dealloc
{
	RELEASE_MEMBER(outerDescriptionView);
	RELEASE_MEMBER(artistMusicId);
	RELEASE_MEMBER(artistName);
	RELEASE_MEMBER(artistDesc);
	RELEASE_MEMBER(artistImage);
	RELEASE_MEMBER(similarArtistTexts);
	RELEASE_MEMBER(infoAlbums);
	RELEASE_MEMBER(albumLinkControllers);
	RELEASE_MEMBER(albumDetailController);
	RELEASE_MEMBER(artistUrl);
	RELEASE_MEMBER(albumUrl);
	[super dealloc];
}

@end
