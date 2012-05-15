//
//  PRPlaybackController.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PRSongProgressView.h"


@interface PRPlaybackController : NSObject
{
	IBOutlet NSTextField *leftField;
	IBOutlet NSTextField *rightField;
	
	IBOutlet PRSongProgressView *progressView;
	
	IBOutlet NSButton *playButton;
	IBOutlet NSButton *skipButton;
	IBOutlet NSButton *loveButton;
	IBOutlet NSButton *banButton;
	
	IBOutlet NSMenuItem *playDockItem;
	IBOutlet NSMenuItem *playMenuItem;
	
	QTMovie *player;
	
	NSTimer *updateTimer;
}

- (BOOL)isPlaying;
- (BOOL)isSongLoaded;

- (void)playURL:(NSURL *)url;
- (void)togglePause;
- (void)stopPlayback;

- (void)finishedLaunching;

- (void)updateControls;
- (void)updateProgress;

@end
