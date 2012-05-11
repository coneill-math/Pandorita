//
//  PRUserDefaults.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRUserDefaults.h"

#define SERVICE_STRING @"Pandora"


NSString *PRReadKeychainPassword(NSString *username)
{
	void  *passwordData   = NULL;
	UInt32 passwordLength = 0;
	
	NSData *serviceData = [[NSString stringWithString:SERVICE_STRING] dataUsingEncoding:NSUTF8StringEncoding];
	NSData *accountData = [username dataUsingEncoding:NSUTF8StringEncoding];
	NSString *passwordString = nil;
	
	// If keychainRef is NULL, the users's default keychain search list will be used
	OSStatus err = SecKeychainFindGenericPassword(NULL,
						      [serviceData length],  [serviceData bytes],
						      [accountData length],  [accountData bytes],
						      &passwordLength,
						      &passwordData,
						      NULL);
	
	if (err == noErr)
	{
		passwordString = [[[NSString alloc] initWithBytes:passwordData length:passwordLength encoding:NSUTF8StringEncoding] autorelease];
	}
	
	SecKeychainItemFreeContent(NULL, passwordData);
	
	return passwordString;
}

BOOL PRWriteKeychainPassword(NSString *username, NSString *password)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	
	NSData *serviceData = [[NSString stringWithString:SERVICE_STRING] dataUsingEncoding:NSUTF8StringEncoding];
	NSData *accountData = [username dataUsingEncoding:NSUTF8StringEncoding];
	
	// If keychainRef is NULL, the default keychain will be used
	OSStatus err = SecKeychainAddGenericPassword(NULL,
						     [serviceData length],  [serviceData bytes],
						     [accountData length],  [accountData bytes],
						     [passwordData length], [passwordData bytes],
						     NULL);
	
	[pool release];
	
	if (err == noErr)
	{
		return YES;
	}
	else
	{
		return NO;
	}
}


@implementation NSUserDefaults (PRUtils_Additions)

+ (void)registerPandoritaUserDefaults
{
	NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

+ (BOOL)shouldAutoLogin
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"PRAutoLogin"];
}

+ (void)setShouldAutoLogin:(BOOL)should
{
	[[NSUserDefaults standardUserDefaults] setBool:should forKey:@"PRAutoLogin"];
}

+ (BOOL)shouldUseGrowl
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"PRUseGrowl"];
}

+ (void)setShouldUseGrowl:(BOOL)should
{
	[[NSUserDefaults standardUserDefaults] setBool:should forKey:@"PRUseGrowl"];
}

+ (NSString *)lastUsername
{
	return [[NSUserDefaults standardUserDefaults] stringForKey:@"PRLastUsername"];
}

+ (void)setLastUsername:(NSString *)last
{
	[[NSUserDefaults standardUserDefaults] setObject:last forKey:@"PRLastUsername"];
}

+ (NSString *)passwordFromKeychain
{
	if (![NSUserDefaults lastUsername])
	{
		return nil;
	}
	
	return PRReadKeychainPassword([NSUserDefaults lastUsername]);
}

+ (BOOL)writePasswordToKeychain:(NSString *)pass
{
	if (![NSUserDefaults lastUsername])
	{
		return NO;
	}
	
	return PRWriteKeychainPassword([NSUserDefaults lastUsername], pass);
}

+ (BOOL)shouldEnableHotkeys
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"PREnableHotkeys"];
}

+ (void)setShouldEnableHotkeys:(BOOL)should
{
	[[NSUserDefaults standardUserDefaults] setBool:should forKey:@"PREnableHotkeys"];
}

+ (SGKeyCombo *)hotKeyForKey:(NSString *)key
{
	id keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	return (keyComboPlist ? [[[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist] autorelease] : nil);
}

+ (void)setHotkey:(SGKeyCombo *)combo forKey:(NSString *)key
{
	if (!combo)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:[combo plistRepresentation] forKey:key];
	}
}
/*
+ (SGKeyCombo *)pauseHotkey
{
	id keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRPauseHotkey"];
	return (keyComboPlist ? [[[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist] autorelease] : nil);
}

+ (void)setPauseHotkey:(SGKeyCombo *)combo
{
	if (!combo)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PRPauseHotkey"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:[combo plistRepresentation] forKey:@"PRPauseHotkey"];
	}
}

+ (SGKeyCombo *)skipHotkey
{
	id keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRSkipHotkey"];
	return (keyComboPlist ? [[[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist] autorelease] : nil);
}

+ (void)setSkipHotkey:(SGKeyCombo *)combo
{
	if (!combo)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PRSkipHotkey"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:[combo plistRepresentation] forKey:@"PRSkipHotkey"];
	}
}

+ (SGKeyCombo *)loveHotkey
{
	id keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRLoveHotkey"];
	return (keyComboPlist ? [[[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist] autorelease] : nil);
}

+ (void)setLoveHotkey:(SGKeyCombo *)combo
{
	if (!combo)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PRLoveHotkey"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:[combo plistRepresentation] forKey:@"PRLoveHotkey"];
	}
}

+ (SGKeyCombo *)banHotkey
{
	id keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRBanHotkey"];
	return (keyComboPlist ? [[[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist] autorelease] : nil);
}

+ (void)setBanHotkey:(SGKeyCombo *)combo
{
	if (!combo)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PRBanHotkey"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:[combo plistRepresentation] forKey:@"PRBanHotkey"];
	}
}

+ (SGKeyCombo *)volumeUpHotkey
{
	id keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRVolumeUpHotkey"];
	return (keyComboPlist ? [[[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist] autorelease] : nil);
}

+ (void)setVolumeUpHotkey:(SGKeyCombo *)combo
{
	if (!combo)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PRVolumeUpHotkey"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:[combo plistRepresentation] forKey:@"PRVolumeUpHotkey"];
	}
}

+ (SGKeyCombo *)volumeDownHotkey
{
	id keyComboPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRVolumeDownHotkey"];
	return (keyComboPlist ? [[[SGKeyCombo alloc] initWithPlistRepresentation:keyComboPlist] autorelease] : nil);
}

+ (void)setVolumeDownHotkey:(SGKeyCombo *)combo
{
	if (!combo)
	{
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PRVolumeDownHotkey"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setObject:[combo plistRepresentation] forKey:@"PRVolumeDownHotkey"];
	}
}
*/
@end

