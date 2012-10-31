//
//  PRAudioStreamer.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/31/12.
//
//

#import "AudioStreamer.h"

@interface PRAudioStreamer : AudioStreamer <NSURLConnectionDelegate>
{
	NSOutputStream *writeStream;
	NSURLConnection *connection;
}



@end
