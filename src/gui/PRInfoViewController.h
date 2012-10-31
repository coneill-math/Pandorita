//
//  PRInfoViewController.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/21/12.
//
//

#import <Cocoa/Cocoa.h>

@interface PRInfoViewController : NSObject <NSSplitViewDelegate>
{
	IBOutlet NSView *infoView;
	IBOutlet NSSplitView *infoSplitView;
	
	IBOutlet NSImageView *titleBarImageView;
	IBOutlet NSTextField *titleField;
	
	IBOutlet NSButton *backButton;
	IBOutlet NSButton *forwardButton;
	IBOutlet NSButton *closeButton;
	
	id currentController;
}

+ (NSURL *)songInfoUrlForSongUrl:(NSURL *)songUrl;
+ (NSURL *)artistInfoUrlForSongUrl:(NSURL *)songUrl;
+ (NSURL *)artistInfoUrlForAlbumUrl:(NSURL *)albumUrl;
+ (NSURL *)albumInfoUrlForSongUrl:(NSURL *)songUrl;

- (void)showInfoForArtist:(NSURL *)artistUrl;
- (void)showInfoForAlbum:(NSURL *)albumUrl;

- (IBAction)expandInfoView:(id)sender;
- (IBAction)collapseInfoView:(id)sender;
- (BOOL)isInfoViewCollapsed;

- (IBAction)backPressed:(id)sender;
- (IBAction)forwardPressed:(id)sender;

@end
