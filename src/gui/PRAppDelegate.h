//
//  PandoritaAppDelegate.h
//  Pandorita
//
//  Created by Chris O'Neill on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <Scribbler/Scribbler.h>
#import <Growl/Growl.h>

#import "PRURLDownloader.h"
#import "PRPianoWrapper.h"
#import "PRHotkeyManager.h"

#import "PRRatingCell.h"
#import "PRStationTableDelegate.h"
#import "PRSongHistoryTableDelegate.h"
#import "PRSearchTableDelegate.h"

#import "PRPlaybackController.h"

#import "PRPreferencesController.h"
#import "PRLoginController.h"
#import "PRArtworkController.h"

#import "PRUtils.h"


@interface PRAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSSoundDelegate, PRPianoDelegate, GrowlApplicationBridgeDelegate, LFWebServiceDelegate>
{
	IBOutlet NSWindow *window;
	
	IBOutlet NSTableView *stationTableView;
	IBOutlet NSTableView *songHistoryTableView;
	IBOutlet PRArtworkController *coverArtController;
	
	IBOutlet NSSearchField *stationSearch;
	IBOutlet NSTableView *searchTableView;
	IBOutlet PRSearchTableDelegate *searchTableDelegate;
	
	IBOutlet PRPlaybackController *playbackController;
	
	IBOutlet NSSplitView *mainSplitView;
	IBOutlet NSSplitView *imageSplitView;
	
	IBOutlet PRStationTableDelegate *stationTableDelegate;
	IBOutlet PRSongHistoryTableDelegate *songHistoryTableDelegate;
	
	IBOutlet NSMenu *dockMenu;
	IBOutlet NSMenuItem *playDockItem;
	
	IBOutlet NSMenu *controlsMenu;
	IBOutlet NSMenuItem *playMenuItem;
	
	IBOutlet NSMenuItem *songDockItem;
	IBOutlet NSMenuItem *artistDockItem;
	IBOutlet NSMenuItem *albumDockItem;
	
	PRLoginController *loginController;
	PRPreferencesController *prefsController;
	
	PRHotkeyManager *hotkeyManager;
	
	PRPianoWrapper *pianoWrapper;
}

- (PRHotkeyManager *)hotkeyManager;

- (void)updateDockPlayingInfo;
- (void)playStation:(PRStation *)station;
- (void)stopPlayback:(NSString *)errorMessage;

- (void)loginWithUsername:(NSString *)user password:(NSString *)pass;

- (void)setRatingFromSegmentClick:(PRRating)rating;
- (void)setRating:(PRRating)rating;
- (void)setRating:(PRRating)rating forSong:(PRSong *)song;

- (BOOL)isPlaying;
- (void)pushGrowlNotification;

// notification from playback controller
- (void)didBeginPlayingSong:(PRSong *)song;

- (IBAction)showPreferences:(id)sender;

- (IBAction)switchAccounts:(id)sender;

- (IBAction)stationSearch:(id)sender;

- (IBAction)togglePause:(id)sender;
- (IBAction)moveToNextSong:(id)sender;
- (IBAction)loveClicked:(id)sender;
- (IBAction)banClicked:(id)sender;
- (IBAction)markAsTired:(id)sender;


@end
