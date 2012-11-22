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
	
	NSData *serviceData = [SERVICE_STRING dataUsingEncoding:NSUTF8StringEncoding];
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
	
	if (passwordData)
	{
		SecKeychainItemFreeContent(NULL, passwordData);
		passwordData = NULL;
	}
	
	return passwordString;
}

BOOL PRWriteKeychainPassword(NSString *username, NSString *password)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
	
	NSData *serviceData = [SERVICE_STRING dataUsingEncoding:NSUTF8StringEncoding];
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

+ (BOOL)shouldShowNotifications
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"PRShowNotification"];
}

+ (void)setShouldShowNotifications:(BOOL)should
{
	[[NSUserDefaults standardUserDefaults] setBool:should forKey:@"PRShowNotification"];
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

@end

