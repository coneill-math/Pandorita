//
//  PRHotkeyManager.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ShortcutRecorder/ShortcutRecorder.h>
#import "SGHotKeyCenter.h"
#import "SGHotKey.h"

@interface PRHotkeyManager : NSObject
{
	SGHotKey *pauseHotkey;
	SGHotKey *skipHotkey;
	SGHotKey *loveHotkey;
	SGHotKey *banHotkey;
	SGHotKey *volumeUpHotkey;
	SGHotKey *volumeDownHotkey;
}

- (void)setHotkeysEnabled:(BOOL)enabled;

- (KeyCombo)pauseHotkey;
- (void)setPauseHotkey:(KeyCombo)combo;

- (KeyCombo)skipHotkey;
- (void)setSkipHotkey:(KeyCombo)combo;

- (KeyCombo)loveHotkey;
- (void)setLoveHotkey:(KeyCombo)combo;

- (KeyCombo)banHotkey;
- (void)setBanHotkey:(KeyCombo)combo;

- (KeyCombo)volumeUpHotkey;
- (void)setVolumeUpHotkey:(KeyCombo)combo;

- (KeyCombo)volumeDownHotkey;
- (void)setVolumeDownHotkey:(KeyCombo)combo;

@end
