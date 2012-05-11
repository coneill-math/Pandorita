//
//  PRHotkeyPrefsController.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <ShortcutRecorder/ShortcutRecorder.h>
#import "PRHotkeyManager.h"


@interface PRHotkeyPrefsController : NSViewController
{
	IBOutlet NSButton *enableCheckbox;
	
	IBOutlet NSTextField *pauseLabel;
	IBOutlet NSTextField *skipLabel;
	IBOutlet NSTextField *loveLabel;
	IBOutlet NSTextField *banLabel;
	IBOutlet NSTextField *volumeUpLabel;
	IBOutlet NSTextField *volumeDownLabel;
	
	IBOutlet SRRecorderControl *pauseRecorder;
	IBOutlet SRRecorderControl *skipRecorder;
	IBOutlet SRRecorderControl *loveRecorder;
	IBOutlet SRRecorderControl *banRecorder;
	IBOutlet SRRecorderControl *volumeUpRecorder;
	IBOutlet SRRecorderControl *volumeDownRecorder;
	
	PRHotkeyManager *hotkeyManager;
}

- (IBAction)enableHotkeysChanged:(id)sender;

@end
