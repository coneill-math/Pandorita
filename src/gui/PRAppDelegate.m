//
//  PandoritaAppDelegate.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//



#import "PRAppDelegate.h"

/*
P1 Blockers:
x Restructure PianoWrapper
x Create stations
x Cleanup menu bar
- Volume control
- Song progress/Now Playing
x Dock menu
- Error reporting
x Fix rename station
- Preferences window
  - Login info
  - Global hotkeys/media keys
  - Automatic updates (+Sparkle)
x Sourceforge/Github

Enhancements: 
- Additional Pandora functionality
- Last.fm
x Growl
*/

#define PR_GROWL_PLAYING_NOTIFICATION @"Pandorita - Now Playing"
#define PR_GROWL_PAUSED_NOTIFICATION @"Pandorita - Paused"

@implementation PRAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"Opened!");
	
	[NSUserDefaults registerPandoritaUserDefaults];
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:) name:QTMovieLoadStateDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidEnd:) name:QTMovieDidEndNotification object:nil];
	
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
	
	player = nil;
	
	NSTableColumn *column = [songHistoryTableView tableColumnWithIdentifier:@"rating"];
	[column setWidth:[[column dataCell] cellSize].width];
	
	[self updatePlayButton];
	
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
	if (player)
	{
		[player stop];
		RELEASE_MEMBER(player);
		[self updatePlayButton];
	}
	
	[pianoWrapper loginWithUsername:user password:pass];
	
	[stationTableView reloadData];
	[songHistoryTableView reloadData];
}

- (void)updatePlayButton
{
	if (player && [self isPlaying])
	{
		[playDockItem setTitle:@"Pause"];
		[playMenuItem setTitle:@"Pause"];
		[playButton setTitle:@"Pause"];
		[playButton setEnabled:YES];
	}
	else if (player)
	{
		[playDockItem setTitle:@"Play"];
		[playMenuItem setTitle:@"Play"];
		[playButton setTitle:@"Play"];
		[playButton setEnabled:YES];
	}
	else
	{
		[playDockItem setTitle:@"Play"];
		[playMenuItem setTitle:@"Play"];
		[playButton setTitle:@"Play"];
		[playButton setEnabled:NO];
	}
	
	// update dock menu
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
			if (player && [self isPlaying])
			{
				return YES;
			}
			else if (player)
			{
				return YES;
			}
			else
			{
				return NO;
			}
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
	if ([self isPlaying])
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
	if (player && [self isPlaying])
	{
		[player stop];
	}
	else if (player)
	{
		[player play];
	}
	
	[self updatePlayButton];
	[self pushGrowlNotification];
}

- (IBAction)moveToNextSong:(id)sender
{
	if (player)
	{
		[player stop];
		RELEASE_MEMBER(player);
		[self updatePlayButton];
	}
	
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

- (void)setRating:(PRRating)rating forSong:(PRSong *)song
{
	[pianoWrapper setRating:rating forSong:song];
}

- (void)pushGrowlNotification
{
	if ([NSUserDefaults shouldUseGrowl])
	{
		PRSong *song = [songHistoryTableDelegate currentSong];
		
		if (song)
		{
			NSData *data = [coverArtController artworkData];
			
			NSString *name = [NSString stringWithFormat:@"%@%@", [song title], ([self isPlaying] ? @"" : @" (Paused)")];
			NSString *desc = [NSString stringWithFormat:@"Artist: %@\nAlbum: %@", [song artist], [song album]];
			NSString *notif = ([self isPlaying] ? PR_GROWL_PLAYING_NOTIFICATION : PR_GROWL_PAUSED_NOTIFICATION);
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
	}
	
	[stationTableView reloadData];
}

- (void)didStartNextSong:(PRSong *)song error:(NSError *)error
{
	ERROR_ON_FAIL(!error);
	
	// play the new song
	player = [[QTMovie alloc] initWithURL:[song audioURL] error:&error];
	ERROR_ON_FAIL(!error);
	
	// update the table view
	[songHistoryTableDelegate addSong:song];
	[songHistoryTableView reloadData];
	
	// update cover art
	[coverArtController loadImageFromSong:song];
	
	// update buttons
	[self updatePlayButton];
	
	return;
	
error:
	NSLog(@"Error playing next song: %@!", error);
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
		if (player)
		{
			[player stop];
			RELEASE_MEMBER(player);
		}
		
		[self updatePlayButton];
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

- (void)movieLoadStateDidChange:(NSNotification *)notification
{
	// First make sure that this notification is for our movie.
	if ([notification object] == player)
	{
		if ([player rate] == 0)
		{
			// if ([[player attributeForKey:QTMovieLoadStateAttribute] longValue] >= kMovieLoadStatePlaythroughOK)
			// {
			[player play];
			[self updatePlayButton];
			[self pushGrowlNotification];
			// }
		}
	}
}

- (void)movieDidEnd:(NSNotification *)notification
{
	// First make sure that this notification is for our movie.
	if ([notification object] == player && [player rate] == 0)
	{
		[self moveToNextSong:self];
	}
}

- (BOOL)isPlaying
{
	return (player && [player rate] > 0);
}

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
#if 0
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
#endif
// NSSound delegate
- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)finishedPlaying
{
	[self moveToNextSong:self];
}

- (void)dealloc
{
	RELEASE_MEMBER(pianoWrapper);
	RELEASE_MEMBER(player);
	
	RELEASE_MEMBER(stationTableDelegate);
	RELEASE_MEMBER(songHistoryTableDelegate);
	
	[super dealloc];
}


@end
