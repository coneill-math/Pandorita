//
//  PRPreferencesController.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPreferencesController.h"

#import "PRUserDefaults.h"

#import "PRGeneralPrefsController.h"
#import "PRHotkeyPrefsController.h"
#import "PRUpdatesPrefsController.h"
#import "PRAdvancedPrefsController.h"


@implementation PRPreferencesController

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		controllerClassList = [[NSArray alloc] initWithObjects:[PRGeneralPrefsController class], 
									[PRHotkeyPrefsController class], 
									[PRUpdatesPrefsController class], 
									[PRAdvancedPrefsController class], nil];
	}
	
	return self;
}

- (void)awakeFromNib
{
	currentController = nil;
	
	[toolbar setSelectedItemIdentifier:[[[toolbar items] objectAtIndex:0] itemIdentifier]];
	[self switchToPane:[[toolbar items] objectAtIndex:0]];
}

- (void)switchToView:(NSViewController *)controller
{
	if (currentController)
	{
		[[currentController view] removeFromSuperview];
	}
	
	currentController = [controller retain];
	
	NSRect contentRect = [[currentController view] bounds];
	NSRect windowFrame = [preferencesWindow frameRectForContentRect:contentRect];
	
	windowFrame.origin = [preferencesWindow frame].origin;
	windowFrame.origin.y += [preferencesWindow frame].size.height - windowFrame.size.height;
	
	[preferencesWindow setFrame:windowFrame display:YES animate:YES];
	
	[[preferencesWindow contentView] addSubview:[currentController view]];
//	[[currentController view] setFrame:contentRect];
}

- (void)showPreferences
{
	[preferencesWindow makeKeyAndOrderFront:self];
}

- (IBAction)switchToPane:(id)sender
{
	NSInteger index = [[toolbar items] indexOfObject:sender];
	if (index == NSNotFound || index >= [controllerClassList count])
	{
		index = 0;
	}
	
	[self switchToView:[[[[controllerClassList objectAtIndex:index] alloc] init] autorelease]];
}

- (void)dealloc
{
	RELEASE_MEMBER(controllerClassList);
	RELEASE_MEMBER(currentController);
	[super dealloc];
}


@end









