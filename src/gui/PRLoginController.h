//
//  PRLoginController.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/18/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PRLoginController : NSObject
{
	IBOutlet NSWindow *loginWindow;
	
	IBOutlet NSTextField *usernameField;
	IBOutlet NSTextField *passwordField;
	IBOutlet NSButton *autoLoginCheckbox;
	
	IBOutlet NSProgressIndicator *loginProgress;
	IBOutlet NSTextField *errorMessage;
	
	IBOutlet NSButton *loginButton;
	IBOutlet NSButton *cancelButton;
	IBOutlet NSButton *quitButton;
	
	NSWindow *mainWindow;
	BOOL isRunning;
}

- (id)initWithMainWindow:(NSWindow *)window;

- (BOOL)isRunning;

- (void)runLoginScreen:(BOOL)canCancel;
- (void)closeLoginScreen;

- (IBAction)loginClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)quitClicked:(id)sender;

//- (IBAction)fieldChanged:(id)sender;

@end
