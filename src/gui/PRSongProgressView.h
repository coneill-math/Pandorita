//
//  PRSongProgressView.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PRSongProgressView : NSView
{
	NSImage *backLeftImage;
	NSImage *backMiddleImage;
	NSImage *backRightImage;
	NSImage *frontLeftImage;
	NSImage *frontMiddleImage;
	NSImage *frontRightImage;
	
	CGFloat progress;
}

- (void)setProgress:(CGFloat)prog;

@end
