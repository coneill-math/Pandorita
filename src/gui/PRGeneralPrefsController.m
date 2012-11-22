//
//  PRGeneralPrefsController.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRGeneralPrefsController.h"

#import "PRUserDefaults.h"


@implementation PRGeneralPrefsController

- (id)init
{
	self = [super initWithNibName:@"GeneralPrefs" bundle:nil];
	
	if (self != nil)
	{
		
	}
	
	return self;
}

- (void)awakeFromNib
{
	[autoLoginCheckbox setState:([NSUserDefaults shouldAutoLogin] ? NSOnState : NSOffState)];
	[useGrowlCheckbox setState:([NSUserDefaults shouldUseGrowl] ? NSOnState : NSOffState)];
}

- (IBAction)autoLoginChanged:(id)sender
{
	[NSUserDefaults setShouldAutoLogin:([autoLoginCheckbox state] != NSOffState)];
}

- (IBAction)useGrowlChanged:(id)sender
{
	[NSUserDefaults setShouldShowNotifications:([useGrowlCheckbox state] != NSOffState)];
}

@end
