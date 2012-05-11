//
//  PRHotkeyManager.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRHotkeyManager.h"

#import "PRUserDefaults.h"
#import "PRAppDelegate.h"


#define PR_PAUSE_HOTKEY_KEY @"PRPauseHotkey"
#define PR_SKIP_HOTKEY_KEY @"PRSkipHotkey"
#define PR_LOVE_HOTKEY_KEY @"PRLoveHotkey"
#define PR_BAN_HOTKEY_KEY @"PRBanHotkey"
#define PR_VOLUMEUP_HOTKEY_KEY @"PRVolumeUpHotkey"
#define PR_VOLUMEDOWN_HOTKEY_KEY @"PRVolumeDownHotkey"


@interface PRHotkeyManager (PRHotkeyManager_Private)

- (KeyCombo)comboForHotkey:(SGHotKey *)rec;
- (void)setCombo:(KeyCombo)combo forKey:(NSString *)key hotkey:(SGHotKey *)hotkey;

- (void)registerHotkeys;
- (void)hotkeyPressed:(id)sender;

@end

@implementation PRHotkeyManager

- (id)init
{
	self = [super init];
	
	if (self)
	{
		NSString *key = nil;
		
		key = PR_PAUSE_HOTKEY_KEY;
		pauseHotkey = [[SGHotKey alloc] initWithIdentifier:key keyCombo:[NSUserDefaults hotKeyForKey:key] target:self action:@selector(hotkeyPressed:)];
		
		key = PR_SKIP_HOTKEY_KEY;
		skipHotkey = [[SGHotKey alloc] initWithIdentifier:key keyCombo:[NSUserDefaults hotKeyForKey:key] target:self action:@selector(hotkeyPressed:)];
		
		key = PR_LOVE_HOTKEY_KEY;
		loveHotkey = [[SGHotKey alloc] initWithIdentifier:key keyCombo:[NSUserDefaults hotKeyForKey:key] target:self action:@selector(hotkeyPressed:)];
		
		key = PR_BAN_HOTKEY_KEY;
		banHotkey = [[SGHotKey alloc] initWithIdentifier:key keyCombo:[NSUserDefaults hotKeyForKey:key] target:self action:@selector(hotkeyPressed:)];
		
		key = PR_VOLUMEUP_HOTKEY_KEY;
		volumeUpHotkey = [[SGHotKey alloc] initWithIdentifier:key keyCombo:[NSUserDefaults hotKeyForKey:key] target:self action:@selector(hotkeyPressed:)];
		
		key = PR_VOLUMEDOWN_HOTKEY_KEY;
		volumeDownHotkey = [[SGHotKey alloc] initWithIdentifier:key keyCombo:[NSUserDefaults hotKeyForKey:key] target:self action:@selector(hotkeyPressed:)];
		
		[self registerHotkeys];
	}
	
	return self;
}

- (void)registerHotkeys
{
	if ([NSUserDefaults shouldEnableHotkeys])
	{
		[[SGHotKeyCenter sharedCenter] registerHotKey:pauseHotkey];
		[[SGHotKeyCenter sharedCenter] registerHotKey:skipHotkey];
		[[SGHotKeyCenter sharedCenter] registerHotKey:loveHotkey];
		[[SGHotKeyCenter sharedCenter] registerHotKey:banHotkey];
		[[SGHotKeyCenter sharedCenter] registerHotKey:volumeUpHotkey];
		[[SGHotKeyCenter sharedCenter] registerHotKey:volumeDownHotkey];
	}
	else
	{
		[[SGHotKeyCenter sharedCenter] unregisterHotKey:pauseHotkey];
		[[SGHotKeyCenter sharedCenter] unregisterHotKey:skipHotkey];
		[[SGHotKeyCenter sharedCenter] unregisterHotKey:loveHotkey];
		[[SGHotKeyCenter sharedCenter] unregisterHotKey:banHotkey];
		[[SGHotKeyCenter sharedCenter] unregisterHotKey:volumeUpHotkey];
		[[SGHotKeyCenter sharedCenter] unregisterHotKey:volumeDownHotkey];
	}
}

- (void)setHotkeysEnabled:(BOOL)enabled
{
	[NSUserDefaults setShouldEnableHotkeys:enabled];
	[self registerHotkeys];
}

- (KeyCombo)comboForHotkey:(SGHotKey *)rec
{
	SGKeyCombo *keyCombo = [rec keyCombo];
	return SRMakeKeyCombo(keyCombo.keyCode, SRCarbonToCocoaFlags(keyCombo.modifiers));
}

- (void)setCombo:(KeyCombo)combo forKey:(NSString *)key hotkey:(SGHotKey *)hotkey
{
	// create the useful key combo wrapper
	SGKeyCombo *keyCombo = [SGKeyCombo keyComboWithKeyCode:combo.code modifiers:SRCocoaToCarbonFlags(combo.flags)];
	
	// update hotkey and register it
	[[SGHotKeyCenter sharedCenter] unregisterHotKey:hotkey];
	[hotkey setKeyCombo:keyCombo];
	[[SGHotKeyCenter sharedCenter] registerHotKey:hotkey];
	
	// update user defaults
	[NSUserDefaults setHotkey:keyCombo forKey:key];
}

- (KeyCombo)pauseHotkey
{
	return [self comboForHotkey:pauseHotkey];
}

- (void)setPauseHotkey:(KeyCombo)combo
{
	[self setCombo:combo forKey:PR_PAUSE_HOTKEY_KEY hotkey:pauseHotkey];
}

- (KeyCombo)skipHotkey
{
	return [self comboForHotkey:skipHotkey];
}

- (void)setSkipHotkey:(KeyCombo)combo
{
	[self setCombo:combo forKey:PR_SKIP_HOTKEY_KEY hotkey:skipHotkey];
}

- (KeyCombo)loveHotkey
{
	return [self comboForHotkey:loveHotkey];
}

- (void)setLoveHotkey:(KeyCombo)combo
{
	[self setCombo:combo forKey:PR_LOVE_HOTKEY_KEY hotkey:loveHotkey];
}

- (KeyCombo)banHotkey
{
	return [self comboForHotkey:banHotkey];
}

- (void)setBanHotkey:(KeyCombo)combo
{
	[self setCombo:combo forKey:PR_BAN_HOTKEY_KEY hotkey:banHotkey];
}

- (KeyCombo)volumeUpHotkey
{
	return [self comboForHotkey:volumeUpHotkey];
}

- (void)setVolumeUpHotkey:(KeyCombo)combo
{
	[self setCombo:combo forKey:PR_VOLUMEUP_HOTKEY_KEY hotkey:volumeUpHotkey];
}

- (KeyCombo)volumeDownHotkey
{
	return [self comboForHotkey:volumeDownHotkey];
}

- (void)setVolumeDownHotkey:(KeyCombo)combo
{
	[self setCombo:combo forKey:PR_VOLUMEDOWN_HOTKEY_KEY hotkey:volumeDownHotkey];
}

- (void)hotkeyPressed:(id)sender
{
	if (sender == pauseHotkey)
	{
		[[NSApp delegate] togglePause:pauseHotkey];
	}
	else if (sender == skipHotkey)
	{
		[[NSApp delegate] moveToNextSong:skipHotkey];
	}
	else if (sender == loveHotkey)
	{
		[[NSApp delegate] loveClicked:loveHotkey];
	}
	else if (sender == banHotkey)
	{
		[[NSApp delegate] banClicked:banHotkey];
	}
	else if (sender == volumeUpHotkey)
	{
		// TODO: volume control
	}
	else if (sender == volumeDownHotkey)
	{
		// TODO: volume control
	}
}

@end
