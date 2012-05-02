//
//  PRLoginController.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRLoginController.h"


#import "PRPreferencesController.h"
#import "PRAppDelegate.h"


@implementation PRLoginController

- (id)initWithMainWindow:(NSWindow *)window
{
	self = [super init];
	
	if (self != nil)
	{
		ASSIGN_MEMBER(mainWindow, window);
		isRunning = NO;
	}
	
	return self;
}

- (void)awakeFromNib
{
	[loginWindow setDefaultButtonCell:[loginButton cell]];
	
	[autoLoginCheckbox setState:([NSUserDefaults shouldAutoLogin] ? NSOnState : NSOffState)];
	
	[quitButton setHidden:NO];
	[cancelButton setHidden:YES];
	
	NSString *username = [NSUserDefaults lastUsername];
	if (username)
	{
		[usernameField setStringValue:username];
		[passwordField becomeFirstResponder];
	}
}

- (BOOL)isRunning
{
	return isRunning;
}

- (void)setEnabledForAll:(BOOL)enabled
{
	[usernameField setEnabled:enabled];
	[passwordField setEnabled:enabled];
	[autoLoginCheckbox setEnabled:enabled];
	[loginButton setEnabled:enabled];
	[cancelButton setEnabled:enabled];
	[quitButton setEnabled:enabled];
}

- (void)runLoginScreen:(BOOL)canCancel
{
	if (canCancel)
	{
		[quitButton setHidden:YES];
		[cancelButton setHidden:NO];
	}
	else
	{
		[quitButton setHidden:NO];
		[cancelButton setHidden:YES];
	}
	
	if (isRunning)
	{
		[loginProgress stopAnimation:self];
		[errorMessage setHidden:NO];
		[self setEnabledForAll:YES];
		
		[passwordField becomeFirstResponder];
	}
	else
	{
		NSString *username = [NSUserDefaults lastUsername];
		
		// second condition ensures we only try this once...
		if (username && [NSUserDefaults shouldAutoLogin] && [[passwordField stringValue] isEqualToString:@""])
		{
			NSString *password = [NSUserDefaults passwordFromKeychain];
			if (password)
			{
				[passwordField setStringValue:password];
				[[NSApp delegate] loginWithUsername:username password:password];
				return;
			}
		}
		
		isRunning = YES;
		[loginProgress stopAnimation:self];
		[errorMessage setHidden:YES];
		[self setEnabledForAll:YES];
		
		[NSApp beginSheet:loginWindow modalForWindow:mainWindow modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:NULL];
	}
}

- (void)closeLoginScreen
{
	if (isRunning)
	{
		isRunning = NO;
		[loginProgress stopAnimation:self];
		[errorMessage setHidden:YES];
		[self setEnabledForAll:YES];
		
		[NSApp endSheet:loginWindow];
	}
}

- (IBAction)loginClicked:(id)sender
{
	NSString *username = [usernameField stringValue];
	NSString *password = [passwordField stringValue];
	
	if (![username isEqualToString:@""] && ![password isEqualToString:@""])
	{
		[loginProgress startAnimation:self];
		[errorMessage setHidden:YES];
		[self setEnabledForAll:NO];
		
		[NSUserDefaults setShouldAutoLogin:[autoLoginCheckbox state]];
		[NSUserDefaults setLastUsername:username];
		
		if ([autoLoginCheckbox state])
		{
			if (![NSUserDefaults writePasswordToKeychain:password])
			{
				NSLog(@"Unable to save password to keychain!");
			}
		}
		
		[[NSApp delegate] loginWithUsername:username password:password];
	}
}

- (IBAction)cancelClicked:(id)sender
{
	isRunning = NO;
	[loginProgress stopAnimation:self];
	[errorMessage setHidden:YES];
	[self setEnabledForAll:YES];
	
	[NSApp endSheet:loginWindow];
}

- (IBAction)quitClicked:(id)sender
{
	isRunning = NO;
	[loginProgress stopAnimation:self];
	[errorMessage setHidden:YES];
	[self setEnabledForAll:YES];
	
	[NSApp endSheet:loginWindow];
	[NSApp terminate:self];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:self];
}

- (void)dealloc
{
	RELEASE_MEMBER(mainWindow);
	[super dealloc];
}


@end
