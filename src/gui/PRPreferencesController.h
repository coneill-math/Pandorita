//
//  PRPreferencesController.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PRPreferencesController : NSObject
{
	IBOutlet NSWindow *preferencesWindow;
	IBOutlet NSToolbar *toolbar;
	
	NSViewController *currentController;
	NSArray *controllerClassList;
}

- (void)showPreferences;

- (IBAction)switchToPane:(id)sender;

@end
