//
//  PRUpdatesPrefsController.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/23/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <Sparkle/Sparkle.h>


@interface PRUpdatesPrefsController : NSViewController
{
	IBOutlet SUUpdater *updater;
	IBOutlet NSButton *autoCheckForUpdatesCheckbox;
	IBOutlet NSButton *checkNowButton;
}

- (IBAction)autoCheckForUpdatesValueChanged:(id)sender;

@end
