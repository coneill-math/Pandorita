//
//  PandoritaAppDelegate.h
//  Pandorita
//
//  Created by Chris O'Neill on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <Growl/Growl.h>

#import "PRURLDownloader.h"
#import "PRPianoWrapper.h"

#import "PRRatingCell.h"
#import "PRStationTableDelegate.h"
#import "PRSongHistoryTableDelegate.h"

#import "PRPreferencesController.h"
#import "PRLoginController.h"
#import "PRArtworkController.h"

#import "PRUtils.h"


@interface PRAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSSoundDelegate, GrowlApplicationBridgeDelegate, PRPianoDelegate>
{
	IBOutlet NSWindow *window;
	
	IBOutlet NSTableView *stationTableView;
	IBOutlet NSTableView *songHistoryTableView;
	IBOutlet PRArtworkController *coverArtController;
	
	IBOutlet NSButton *playButton;
	IBOutlet NSButton *skipButton;
	IBOutlet NSButton *loveButton;
	IBOutlet NSButton *banButton;
	
	IBOutlet NSSplitView *mainSplitView;
	IBOutlet NSSplitView *imageSplitView;
	
	IBOutlet PRStationTableDelegate *stationTableDelegate;
	IBOutlet PRSongHistoryTableDelegate *songHistoryTableDelegate;
	
	IBOutlet NSMenu *dockMenu;
	IBOutlet NSMenuItem *playDockItem;
	
	PRLoginController *loginController;
	PRPreferencesController *prefsController;
	
	PRPianoWrapper *pianoWrapper;
	QTMovie *player;
}

- (void)updatePlayButton;
- (void)playStation:(PRStation *)station;
- (BOOL)isPlaying;

- (void)loginWithUsername:(NSString *)user password:(NSString *)pass;

- (void)setRatingFromSegmentClick:(PRRating)rating;
- (void)setRating:(PRRating)rating forSong:(PRSong *)song;

- (void)pushGrowlNotification;

- (IBAction)showPreferences:(id)sender;

- (IBAction)switchAccounts:(id)sender;

- (IBAction)togglePause:(id)sender;
- (IBAction)moveToNextSong:(id)sender;
- (IBAction)loveClicked:(id)sender;
- (IBAction)banClicked:(id)sender;


@end
