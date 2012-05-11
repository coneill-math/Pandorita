//
//  PRUserDefaults.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SGKeyCombo.h"

@interface NSUserDefaults (PRUtils_Additions)

+ (void)registerPandoritaUserDefaults;

+ (BOOL)shouldAutoLogin;
+ (void)setShouldAutoLogin:(BOOL)should;

+ (BOOL)shouldUseGrowl;
+ (void)setShouldUseGrowl:(BOOL)should;

+ (NSString *)lastUsername;
+ (void)setLastUsername:(NSString *)last;

+ (NSString *)passwordFromKeychain;
+ (BOOL)writePasswordToKeychain:(NSString *)pass;

+ (BOOL)shouldEnableHotkeys;
+ (void)setShouldEnableHotkeys:(BOOL)should;


// hotkeys
+ (SGKeyCombo *)hotKeyForKey:(NSString *)key;
+ (void)setHotkey:(SGKeyCombo *)combo forKey:(NSString *)key;

/*
+ (SGKeyCombo *)pauseHotkey;
+ (void)setPauseHotkey:(SGKeyCombo *)combo;

+ (SGKeyCombo *)skipHotkey;
+ (void)setSkipHotkey:(SGKeyCombo *)combo;

+ (SGKeyCombo *)loveHotkey;
+ (void)setLoveHotkey:(SGKeyCombo *)combo;

+ (SGKeyCombo *)banHotkey;
+ (void)setBanHotkey:(SGKeyCombo *)combo;

+ (SGKeyCombo *)volumeUpHotkey;
+ (void)setVolumeUpHotkey:(SGKeyCombo *)combo;

+ (SGKeyCombo *)volumeDownHotkey;
+ (void)setVolumeDownHotkey:(SGKeyCombo *)combo;
*/
@end


