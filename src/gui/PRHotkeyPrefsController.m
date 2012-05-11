//
//  PRHotkeyPrefsController.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRHotkeyPrefsController.h"

#import "PRUserDefaults.h"
#import "PRAppDelegate.h"


@interface PRHotkeyPrefsController (PRHotkeyPrefsController_Private)

- (void)updateEnabled;

@end


@implementation PRHotkeyPrefsController

- (id)init
{
	self = [super initWithNibName:@"HotkeyPrefs" bundle:nil];
	
	if (self != nil)
	{
		hotkeyManager = [[[NSApp delegate] hotkeyManager] retain];
	}
	
	return self;
}

- (void)awakeFromNib
{
	[pauseRecorder setKeyCombo:[hotkeyManager pauseHotkey]];
	[skipRecorder setKeyCombo:[hotkeyManager skipHotkey]];
	[loveRecorder setKeyCombo:[hotkeyManager loveHotkey]];
	[banRecorder setKeyCombo:[hotkeyManager banHotkey]];
	[volumeUpRecorder setKeyCombo:[hotkeyManager volumeUpHotkey]];
	[volumeDownRecorder setKeyCombo:[hotkeyManager volumeDownHotkey]];
	
	[enableCheckbox setState:([NSUserDefaults shouldEnableHotkeys] ? NSOnState : NSOffState)];
	
	[self updateEnabled];
}

- (void)updateEnabled
{
	NSColor *color = nil;
	BOOL enabled = NO;
	
	if ([enableCheckbox state] == NSOnState)
	{
		color = [NSColor controlTextColor];
		enabled = YES;
	}
	else
	{
		color = [NSColor disabledControlTextColor];
		enabled = NO;
	}
	
	[pauseLabel setTextColor:color];
	[skipLabel setTextColor:color];
	[loveLabel setTextColor:color];
	[banLabel setTextColor:color];
	[volumeUpLabel setTextColor:color];
	[volumeDownLabel setTextColor:color];
	
	[pauseRecorder setEnabled:enabled];
	[skipRecorder setEnabled:enabled];
	[loveRecorder setEnabled:enabled];
	[banRecorder setEnabled:enabled];
	[volumeUpRecorder setEnabled:enabled];
	[volumeDownRecorder setEnabled:enabled];
}

- (IBAction)enableHotkeysChanged:(id)sender
{
	BOOL enabled = ([enableCheckbox state] == NSOnState) ? YES : NO;
	[hotkeyManager setHotkeysEnabled:enabled];
	[self updateEnabled];
}

- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder isKeyCode:(NSInteger)keyCode andFlagsTaken:(NSUInteger)flags reason:(NSString **)aReason
{
	return NO;
}

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
	if (aRecorder == pauseRecorder)
	{
		[hotkeyManager setPauseHotkey:newKeyCombo];
	}
	else if (aRecorder == skipRecorder)
	{
		[hotkeyManager setSkipHotkey:newKeyCombo];
	}
	else if (aRecorder == loveRecorder)
	{
		[hotkeyManager setLoveHotkey:newKeyCombo];
	}
	else if (aRecorder == banRecorder)
	{
		[hotkeyManager setBanHotkey:newKeyCombo];
	}
	else if (aRecorder == volumeUpRecorder)
	{
		[hotkeyManager setVolumeUpHotkey:newKeyCombo];
	}
	else if (aRecorder == volumeDownRecorder)
	{
		[hotkeyManager setVolumeDownHotkey:newKeyCombo];
	}
}

- (void)dealloc
{
	RELEASE_MEMBER(hotkeyManager);
	[super dealloc];
}

@end
