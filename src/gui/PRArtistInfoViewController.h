//
//  PRArtistInfoViewController.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/21/12.
//
//

#import <Cocoa/Cocoa.h>

#import "PRBaseInfoViewController.h"
#import "PRAlbumDetailViewController.h"


@interface PRArtistInfoViewController : PRBaseInfoViewController
{
	IBOutlet NSScrollView *outerDescriptionView;
	IBOutlet NSTextView *descriptionView;
	IBOutlet NSImageView *artistImageView;
	IBOutlet NSButton *createStationButton;
	IBOutlet NSButton *likeArtistButton;
	IBOutlet NSView *discographyView;
	
	// need a better way to do this...
	IBOutlet NSTextView *similarArtist1;
	IBOutlet NSTextView *similarArtist2;
	IBOutlet NSTextView *similarArtist3;
	IBOutlet NSTextView *similarArtist4;
	IBOutlet NSTextView *similarArtist5;
	
	NSURL *artistUrl;
	NSString *artistMusicId;
	
	NSString *artistName;
	NSAttributedString *artistDesc;
	NSImage *artistImage;
	NSArray *similarArtistTexts;
	
	NSURL *albumUrl;
	NSArray *infoAlbums;
	NSUInteger currentAlbum;
	NSMutableArray *albumLinkControllers;
	PRAlbumDetailViewController *albumDetailController;
}

- (id)initWithArtist:(NSURL *)artistUrl;
- (id)initWithAlbum:(NSURL *)albumUrl;

- (BOOL)showAlbumAtUrl:(NSURL *)albumUrl;

- (IBAction)createStation:(id)sender;
- (IBAction)addSeed:(id)sender;

@end
