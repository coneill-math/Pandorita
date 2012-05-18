//
//  PandoritaAppDelegate.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//



#import "PRAppDelegate.h"


#define PR_GROWL_PLAYING_NOTIFICATION @"Pandorita - Now Playing"
#define PR_GROWL_PAUSED_NOTIFICATION @"Pandorita - Paused"


@implementation PRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"Opened!");
	
	[NSUserDefaults registerPandoritaUserDefaults];
	[GrowlApplicationBridge setGrowlDelegate:self];
	/*
	LFWebService *lastfm = [LFWebService sharedWebService];
	[lastfm setDelegate:self];
	[lastfm setAPIKey:@"0cfd2e44230806a07104b63b1d4bcf6f"];
	[lastfm setSharedSecret:@"5654580e9a27f4a502012841bca2db2c"];
	
	[lastfm setClientID:@"Pandorita"];
	[lastfm setClientVersion:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
	*/
	hotkeyManager = [[PRHotkeyManager alloc] init];
	
	pianoWrapper = [[PRPianoWrapper alloc] init];
	[pianoWrapper setDelegate:self];
	
	[stationTableDelegate setPianoWrapper:pianoWrapper];
	[stationTableView setTarget:stationTableDelegate];
	[stationTableView setDoubleAction:@selector(tableDoubleClicked:)];
	
	[searchTableDelegate setPianoWrapper:pianoWrapper];
	[searchTableView setTarget:searchTableDelegate];
	[searchTableView setDoubleAction:@selector(tableDoubleClicked:)];
	
	[[searchTableView enclosingScrollView] setHidden:YES];
	[[stationTableView enclosingScrollView] setHidden:NO];
	
	NSTableColumn *column = [songHistoryTableView tableColumnWithIdentifier:@"rating"];
	[column setWidth:[[column dataCell] cellSize].width];
	
	[self updateDockPlayingInfo];
	
	[playbackController finishedLaunching];
	
	loginController = [[PRLoginController alloc] initWithMainWindow:window];
	[NSBundle loadNibNamed:@"Login" owner:loginController];
	
	[loginController runLoginScreen:NO];
	
	NSLog(@"Opening finished!");
	
	return;

error:
	NSLog(@"Startup failed!");
}

- (void)loginWithUsername:(NSString *)user password:(NSString *)pass
{
	[playbackController updateControls];
	[self updateDockPlayingInfo];
	
	[pianoWrapper loginWithUsername:user password:pass];
	
	[stationTableView reloadData];
	[songHistoryTableView reloadData];
}

- (PRHotkeyManager *)hotkeyManager
{
	return hotkeyManager;
}

- (void)updateDockPlayingInfo
{
	PRSong *currentSong = [songHistoryTableDelegate currentSong];
	if (currentSong != nil)
	{
		[songDockItem setTitle:[NSString stringWithFormat:@"%@", [currentSong title]]];
		[artistDockItem setTitle:[NSString stringWithFormat:@"Artist: %@", [currentSong artist]]];
		[albumDockItem setTitle:[NSString stringWithFormat:@"Album: %@", [currentSong album]]];
	}
	else
	{
		[songDockItem setTitle:@"Song"];
		[artistDockItem setTitle:@"Artist"];
		[albumDockItem setTitle:@"Album"];
	}
}

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	if ([item menu] == dockMenu || [item menu] == controlsMenu)
	{
		if ([item action] != nil)
		{
			return [playbackController isSongLoaded];
		}
		
		return NO;
	}
	
	return YES;
}

- (IBAction)showPreferences:(id)sender
{
	if (!prefsController)
	{
		prefsController = [[PRPreferencesController alloc] init];
		[NSBundle loadNibNamed:@"Preferences" owner:prefsController];
	}
	
	[prefsController showPreferences];
}

- (IBAction)switchAccounts:(id)sender
{
	if ([playbackController isPlaying])
	{
		[self togglePause:self];
	}
	
	[loginController runLoginScreen:YES];
}

- (IBAction)stationSearch:(id)sender
{
	NSString *searchString = [stationSearch stringValue];
	
	if ([searchString length] > 0)
	{
		[[searchTableView enclosingScrollView] setHidden:NO];
		[[stationTableView enclosingScrollView] setHidden:YES];
		[pianoWrapper submitSearch:searchString];
	}
	else
	{
		[[searchTableView enclosingScrollView] setHidden:YES];
		[[stationTableView enclosingScrollView] setHidden:NO];
		[searchTableDelegate setFoundArtists:nil songs:nil];
	}
}

- (IBAction)togglePause:(id)sender
{
	[playbackController togglePause];
	
	[self updateDockPlayingInfo];
	[self pushGrowlNotification];
}

- (IBAction)moveToNextSong:(id)sender
{
//	[playbackController updateControls];
//	[self updateDockPlayingInfo];
	
	[pianoWrapper requestNextSong];
	
	return;
}

- (IBAction)loveClicked:(id)sender
{
	PRSong *currentSong = [songHistoryTableDelegate currentSong];
	
	if (currentSong)
	{
		[self setRating:PRRATING_LOVE forSong:currentSong];
	}
}

- (IBAction)banClicked:(id)sender
{
	PRSong *currentSong = [songHistoryTableDelegate currentSong];
	
	if (currentSong)
	{
		[self setRating:PRRATING_BAN forSong:currentSong];
	}
}

- (IBAction)markAsTired:(id)sender
{
	PRSong *currentSong = [songHistoryTableDelegate currentSong];
	
	if (currentSong)
	{
		[pianoWrapper markSongAsTired:currentSong];
	}
}

- (void)playStation:(PRStation *)station
{
	if (station != [pianoWrapper currentStation])
	{
		[pianoWrapper clearPlaylist];
		[songHistoryTableDelegate clearHistory];
		[pianoWrapper setCurrentStation:station];
		
		[stationTableView reloadData];
		
		[self moveToNextSong:self];
	}
}

- (void)setRatingFromSegmentClick:(PRRating)rating
{
	NSInteger row = [songHistoryTableView clickedRow];
	if (row != NSNotFound)
	{
		PRSong *song = [songHistoryTableDelegate songForRow:row];
		[self setRating:rating forSong:song];
	}
}

- (void)setRating:(PRRating)rating
{
	[self setRating:rating forSong:[songHistoryTableDelegate currentSong]];
}

- (void)setRating:(PRRating)rating forSong:(PRSong *)song
{
	[pianoWrapper setRating:rating forSong:song];
}

- (BOOL)isPlaying
{
	return [playbackController isPlaying];
}

- (void)pushGrowlNotification
{
	if ([NSUserDefaults shouldUseGrowl])
	{
		PRSong *song = [songHistoryTableDelegate currentSong];
		
		if (song)
		{
			NSData *data = [coverArtController artworkData];
			
			NSString *name = [NSString stringWithFormat:@"%@%@", [song title], ([playbackController isPlaying] ? @"" : @" (Paused)")];
			NSString *desc = [NSString stringWithFormat:@"Artist: %@\nAlbum: %@", [song artist], [song album]];
			NSString *notif = ([playbackController isPlaying] ? PR_GROWL_PLAYING_NOTIFICATION : PR_GROWL_PAUSED_NOTIFICATION);
			NSString *ident = @"PandoritaNowPlaying";
			
			[GrowlApplicationBridge notifyWithTitle:name description:desc notificationName:notif iconData:data priority:0 isSticky:NO clickContext:nil identifier:ident];
		}
	}
}

- (void)didLoginWithError:(NSError *)error
{
	if (error)
	{
		NSLog(@"Error loggin in: %@!", error);
		[loginController runLoginScreen:NO];
	}
	else 
	{
		if ([loginController isRunning])
		{
			[loginController closeLoginScreen];
		}
	}
}

- (void)didUpdateStationsWithError:(NSError *)error
{
	if (error)
	{
		NSLog(@"Error getting station list: %@!", error);
		
		// if we cant load the station list, we probably need to login
		[loginController runLoginScreen:NO];
	}
	else
	{
		[stationTableView reloadData];
	}
}

- (void)didReceiveNextSong:(PRSong *)song error:(NSError *)error
{
	if (!error)
	{
		[playbackController playSong:song];
	}
	else
	{
		NSLog(@"Error playing next song: %@!", error);
		
		[pianoWrapper setCurrentStation:nil];
		
		[stationTableView reloadData];
		[songHistoryTableView reloadData];
	}
}

// notification from playback controller
- (void)didBeginPlayingSong:(PRSong *)song
{
	// update the table view
	[songHistoryTableDelegate addSong:song];
	[songHistoryTableView reloadData];
	
	// update cover art
	[coverArtController loadImageFromSong:song];
	
	[self updateDockPlayingInfo];
	[self pushGrowlNotification];
}

- (void)didSetRating:(PRRating)rating forSong:(PRSong *)song error:(NSError *)error
{
	if (error)
	{
		NSLog(@"Error setting song rating: %@!", error);
	}
	
	// this song may be a different object, 
	// so do a replacement
//	[songHistoryTableDelegate replaceSongAfterRating:song];
	[songHistoryTableView reloadData];
	
	// if the current song was banned, switch to the next one
	PRSong *currentSong = [songHistoryTableDelegate currentSong];
	
	// yes, thats right, pointer equality
	if (rating == PRRATING_BAN && currentSong == song)
	{
		[self moveToNextSong:self];
	}
	
	NSLog(@"Successfully set rating!");
}

- (void)didMarkSongAsTired:(PRSong *)song error:(NSError *)error
{
	if (error)
	{
		NSLog(@"Error marking song as tired: %@!", error);
	}
	
	// this song may be a different object, 
	// so do a replacement
//	[songHistoryTableDelegate replaceSongAfterRating:song];
	[songHistoryTableView reloadData];
	
	// if the current song was banned, switch to the next one
	PRSong *currentSong = [songHistoryTableDelegate currentSong];
	
	// yes, thats right, pointer equality
	if (currentSong == song)
	{
		[self moveToNextSong:self];
	}
	
	NSLog(@"Successfully marked as tired!");
}

- (void)didCreateStation:(PRStation *)station error:(NSError *)error
{
	if (!error)
	{
		[self playStation:station];
	}
}

- (void)didRenameStation:(PRStation *)station error:(NSError *)error
{
	[stationTableView reloadData];
}

- (void)didRemoveStationWithError:(NSError *)error
{
	[stationTableView reloadData];
	
	if ([pianoWrapper currentStation] == nil)
	{
		[playbackController stopPlayback];
		[self updateDockPlayingInfo];
		[songHistoryTableView reloadData];
	}
}

- (void)didGetSearchResultWithArtists:(NSArray *)artists songs:(NSArray *)songs withError:(NSError *)error
{
	if (!error)
	{
		[searchTableDelegate setFoundArtists:artists songs:songs];
	}
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSSize newSize = [splitView bounds].size;
	NSRect firstRect = [[[splitView subviews] objectAtIndex:0] frame];
	NSRect secondRect = [[[splitView subviews] objectAtIndex:0] frame];
	CGFloat divider = [splitView dividerThickness];
	
	firstRect.size.height = newSize.height;
	secondRect.size.height = newSize.height;
	
	if (newSize.width < firstRect.size.width)
	{
		firstRect.size.width = newSize.width - divider;
		secondRect.size.width = 0;
	}
	else
	{
		secondRect.origin.x = firstRect.size.width + divider;
		secondRect.size.width = newSize.width - divider - firstRect.size.width;
	}
	
	[[[splitView subviews] objectAtIndex:0] setFrame:firstRect];
	[[[splitView subviews] objectAtIndex:1] setFrame:secondRect];
}

// growl delegate methods
- (NSString *)applicationNameForGrowl
{
	return @"Pandorita";
}

- (NSDictionary *)registrationDictionaryForGrowl
{
	NSArray *notifications = [NSArray arrayWithObjects:PR_GROWL_PLAYING_NOTIFICATION, PR_GROWL_PAUSED_NOTIFICATION, nil];
	return [NSDictionary dictionaryWithObjectsAndKeys:notifications, GROWL_NOTIFICATIONS_ALL, notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

- (void)growlIsReady
{
	// nothing needed atm
}

//- (void) growlNotificationWasClicked:(id)clickContext;

#if 0
// for later...
- (float)playProgress
{
	if (player)
	{
		// typedef struct { long long timeValue; long timeScale; long flags; } QTTime
		QTTime qtCurrentTime = [player currentTime];
		QTTime qtDuration = [player duration];
		
		long long currentTime = qtCurrentTime.timeValue;
		long long duration = qtDuration.timeValue;
		
		if (duration > 0)
		{
			return ((float)currentTime) / ((float)duration);
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
}

- (float)loadProgress
{
	if (player)
	{
		// typedef long TimeValue;
		TimeValue loadProgress;
		GetMaxLoadedTimeInMovie([player quickTimeMovie], &loadProgress);
		
		// typedef struct { long long timeValue; long timeScale; long flags; } QTTime
		QTTime qtDuration = [player duration];
		long long duration = qtDuration.timeValue;
		
		if(duration > 0)
		{
			return ((float)loadProgress) / ((float)duration);
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
}

// NSSound delegate
- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
{
	[self moveToNextSong:self];
}
#endif
- (void)dealloc
{
	RELEASE_MEMBER(hotkeyManager);
	RELEASE_MEMBER(pianoWrapper);
	
	RELEASE_MEMBER(stationTableDelegate);
	RELEASE_MEMBER(songHistoryTableDelegate);
	
	[super dealloc];
}


@end
