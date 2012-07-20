//
//  PRArtworkView.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PRSong.h"


@interface PRArtworkController : NSObject <NSURLConnectionDelegate, NSSplitViewDelegate>
{
	IBOutlet NSImageView *imageView;
	
	NSMutableData *responseData;
	NSURLConnection *connection;
	
	NSData *artworkData;
}

- (NSData *)artworkData;

- (void)loadImageFromSong:(PRSong *)song;
- (void)clearArtwork;

@end
