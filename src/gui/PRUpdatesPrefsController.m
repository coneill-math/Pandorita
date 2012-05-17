//
//  PRUpdatesPrefsController.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRUpdatesPrefsController.h"

#import "PRUserDefaults.h"


@implementation PRUpdatesPrefsController

- (id)init
{
	self = [super initWithNibName:@"UpdatesPrefs" bundle:nil];
	
	if (self != nil)
	{
		
	}
	
	return self;
}

- (void)awakeFromNib
{
	[autoCheckForUpdatesCheckbox setState:([updater automaticallyChecksForUpdates] ? NSOnState : NSOffState)];
}

- (IBAction)autoCheckForUpdatesValueChanged:(id)sender
{
	[updater setAutomaticallyChecksForUpdates:([autoCheckForUpdatesCheckbox state] == NSOnState)];
}

- (void)dealloc
{
	[super dealloc];
}

@end
