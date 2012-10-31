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

- (void)playbackStateChanged:(NSNotification *)notification;
- (void)playbackError:(NSNotification *)notification;

@end


@implementation PRPlaybackController

- (void)awakeFromNib
{
	streamer = nil;
	hasSongLoaded = NO;
}

- (void)finishedLaunching
{
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) name:ASStatusChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackError:) name:ASErrorNotification object:nil];
	
	streamer = [[PRAudioStreamer alloc] initWithURL:[song audioURL]];
	
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
		// we are stopping it manually, no need to be notified...
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ASErrorNotification object:nil];
		
		[streamer stop];
		
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

- (void)playbackError:(NSNotification *)notification
{
	NSLog(@"Error streaming song: %d", [streamer errorCode]);
	if (hasSongLoaded)
	{
		[[NSApp delegate] performSelectorOnMainThread:@selector(moveToNextSong:) withObject:self waitUntilDone:NO];
	}
	else
	{
		[[NSApp delegate] performSelectorOnMainThread:@selector(stopPlayback:) withObject:@"Network error" waitUntilDone:NO];
//		[[NSApp delegate] performSelectorOnMainThread:@selector(moveToNextSong:) withObject:self waitUntilDone:NO];
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
	else if (hasSongLoaded && [streamer state] == AS_STOPPED && [streamer errorCode] == AS_NO_ERROR)
	{
		NSLog(@"Moving to next song naturally...");
		[[NSApp delegate] moveToNextSong:self];
	}
#if 0
	// this is now reported by ASErrorNotification
	else if ([streamer state] == AS_STOPPING_ERROR || [streamer state] == AS_STOPPED)
	{
		NSLog(@"Error streaming song: %d", [streamer errorCode]);
		if (hasSongLoaded)
		{
			[[NSApp delegate] performSelectorOnMainThread:@selector(moveToNextSong:) withObject:self waitUntilDone:NO];
		}
		else
		{
			[[NSApp delegate] performSelectorOnMainThread:@selector(stopPlayback:) withObject:@"Network error" waitUntilDone:NO];
//			[[NSApp delegate] performSelectorOnMainThread:@selector(moveToNextSong:) withObject:self waitUntilDone:NO];
		}
	}
#endif
}

- (void)dealloc
{
	[updateTimer invalidate];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ASStatusChangedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ASErrorNotification object:nil];
	RELEASE_MEMBER(streamer);
	
	RELEASE_MEMBER(loadedSong);
	
	[super dealloc];
}

@end
