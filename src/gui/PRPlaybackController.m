//
//  PRPlaybackController.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPlaybackController.h"

#import "PRAppDelegate.h"


@interface PRPlaybackController (PRPlaybackController_Private)

- (void)movieLoadStateDidChange:(NSNotification *)notification;
- (void)movieDidEnd:(NSNotification *)notification;

@end


@implementation PRPlaybackController

- (void)awakeFromNib
{
	streamer = nil;
	hasSongLoaded = NO;
}

- (void)finishedLaunching
{
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieLoadStateDidChange:) name:QTMovieLoadStateDidChangeNotification object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieDidEnd:) name:QTMovieDidEndNotification object:nil];
	
	updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

- (BOOL)isPlaying
{
	return (streamer && [streamer isPlaying]);
}

- (BOOL)isSongLoaded
{
	if (streamer && ![streamer isWaiting])
	{
		return YES;
	}
	else
	{
		return NO;
	}
}

- (void)playSong:(PRSong *)song
{
	[self stopPlayback];
	hasSongLoaded = NO;
	
	RELEASE_MEMBER(loadedSong);
	loadedSong = [song retain];
	
	streamer = [[AudioStreamer alloc] initWithURL:[song audioURL]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:streamer];
	
	[streamer start];
	[self updateControls];
}

- (void)togglePause
{
	if ([self isPlaying])
	{
		[streamer pause];
	}
	else if (streamer)
	{
		[streamer start];
	}
	
	[self updateControls];
}

- (void)stopPlayback
{
	if (streamer)
	{
		[streamer stop];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:streamer];
		
		RELEASE_MEMBER(streamer);
		hasSongLoaded = NO;
	}
	
	[self updateControls];
}

- (void)updateControls
{
	if ([self isPlaying])
	{
		[playDockItem setTitle:@"Pause"];
		[playMenuItem setTitle:@"Pause"];
		
	//	[playButton setTitle:@"Pause"];
		[playButton setImage:[NSImage imageNamed:@"pause-off"]];
		[playButton setAlternateImage:[NSImage imageNamed:@"pause-on"]];
		[playButton setEnabled:YES];
		
		[skipButton setEnabled:YES];
		[loveButton setEnabled:YES];
		[banButton setEnabled:YES];
	}
	else if ([self isSongLoaded])
	{
		[playDockItem setTitle:@"Play"];
		[playMenuItem setTitle:@"Play"];
		
	//	[playButton setTitle:@"Play"];
		[playButton setImage:[NSImage imageNamed:@"play-off"]];
		[playButton setAlternateImage:[NSImage imageNamed:@"play-on"]];
		[playButton setEnabled:YES];
		
		[skipButton setEnabled:YES];
		[loveButton setEnabled:YES];
		[banButton setEnabled:YES];
	}
	else
	{
		[playDockItem setTitle:@"Play"];
		[playMenuItem setTitle:@"Play"];
		
	//	[playButton setTitle:@"Play"];
		[playButton setImage:[NSImage imageNamed:@"play-off"]];
		[playButton setAlternateImage:[NSImage imageNamed:@"play-on"]];
		[playButton setEnabled:NO];
		
		[skipButton setEnabled:NO];
		[loveButton setEnabled:NO];
		[banButton setEnabled:NO];
	}
}

- (void)updateProgress
{
	if (streamer)
	{
		NSTimeInterval total = (NSTimeInterval)[streamer duration];
		NSTimeInterval current = (NSTimeInterval)[streamer progress];
		
		[leftField setStringValue:PRSongDurationFromInterval(current)];
	//	[rightField setStringValue:PRSongDurationFromInterval(total - current)];
		[rightField setStringValue:PRSongDurationFromInterval(total)];
		
		[progressView setProgress:(CGFloat)(current / total)];
	}
	else
	{
		[leftField setStringValue:@"0:00"];
		[rightField setStringValue:@"0:00"];
		
		[progressView setProgress:0];
	}
}

- (void)playbackStateChanged:(NSNotification *)notification
{
	[self updateControls];
	
	if ([streamer state] == AS_PLAYING && !hasSongLoaded)
	{
		[[NSApp delegate] didBeginPlayingSong:loadedSong];
		hasSongLoaded = YES;
	}
	else if ([streamer state] == AS_STOPPING_ERROR || 
		 ([streamer state] == AS_STOPPED && [streamer errorCode] != AS_NO_ERROR))
	{
		NSLog(@"Error streaming song: %d", [streamer errorCode]);
		[[NSApp delegate] moveToNextSong:self];
	}
}

#if 0
- (void)movieLoadStateDidChange:(NSNotification *)notification
{
	// First make sure that this notification is for our movie.
	if ([notification object] ==  && !songInitialized)
	{
		if ([[player attributeForKey:QTMovieLoadStateAttribute] longValue] >= QTMovieLoadStatePlaythroughOK)
		{
			NSError *error = [player attributeForKey:QTMovieLoadStateErrorAttribute];
			if (!error)
			{
				[player play];
				songInitialized = YES;
				
				[self updateControls];
				[[NSApp delegate] didBeginPlayingSong:loadedSong];
			}
			else
			{
				NSLog(@"Error playing song: %@", error);
				[[NSApp delegate] moveToNextSong:self];
			}
		}
	}
}

- (void)movieDidEnd:(NSNotification *)notification
{
	// First make sure that this notification is for our movie.
	if ([notification object] == player && [player rate] == 0)
	{
		[[NSApp delegate] performSelectorOnMainThread:@selector(moveToNextSong:) withObject:self waitUntilDone:NO];
	//	[[NSApp delegate] moveToNextSong:self];
	}
}
#endif
- (void)dealloc
{
	[updateTimer invalidate];
	RELEASE_MEMBER(streamer);
	RELEASE_MEMBER(loadedSong);
	
	[super dealloc];
}

@end
