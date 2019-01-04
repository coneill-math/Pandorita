//
//  PRAudioStreamer.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/31/12.
//
//

#include <sys/socket.h>

#import "PRAudioStreamer.h"
#import "PRAppDelegate.h"


// the internal AudioStreamer callback
void ASReadStreamCallBack(CFReadStreamRef aStream, CFStreamEventType eventType, void *inClientInfo);

// leeched from Apple's sample code
// currently not used, but may need to be eventually...
static void CFStreamCreateBoundPairCompat(CFAllocatorRef alloc, CFReadStreamRef *readStreamPtr, CFWriteStreamRef *writeStreamPtr, CFIndex transferBufferSize)
// This is a drop-in replacement for CFStreamCreateBoundPair that is necessary because that
// code is broken on iOS versions prior to iOS 5.0 <rdar://problem/7027394> <rdar://problem/7027406>.
// This emulates a bound pair by creating a pair of UNIX domain sockets and wrapper each end in a
// CFSocketStream.  This won't give great performance, but it doesn't crash!
{
#pragma unused(transferBufferSize)
	int                 err;
	Boolean             success;
	CFReadStreamRef     readStream;
	CFWriteStreamRef    writeStream;
	int                 fds[2];
	
	assert(readStreamPtr != NULL);
	assert(writeStreamPtr != NULL);
	
	readStream = NULL;
	writeStream = NULL;
	
	// Create the UNIX domain socket pair.
	
	err = socketpair(AF_UNIX, SOCK_STREAM, 0, fds);
	if (err == 0) {
		CFStreamCreatePairWithSocket(alloc, fds[0], &readStream,  NULL);
		CFStreamCreatePairWithSocket(alloc, fds[1], NULL, &writeStream);
		
		// If we failed to create one of the streams, ignore them both.
		
		if ( (readStream == NULL) || (writeStream == NULL) ) {
			if (readStream != NULL) {
				CFRelease(readStream);
				readStream = NULL;
			}
			if (writeStream != NULL) {
				CFRelease(writeStream);
				writeStream = NULL;
			}
		}
		assert( (readStream == NULL) == (writeStream == NULL) );
		
		// Make sure that the sockets get closed (by us in the case of an error,
		// or by the stream if we managed to create them successfull).
		
		if (readStream == NULL) {
			err = close(fds[0]);
			assert(err == 0);
			err = close(fds[1]);
			assert(err == 0);
		} else {
			success = CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
			assert(success);
			success = CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
			assert(success);
		}
	}
	
	*readStreamPtr = readStream;
	*writeStreamPtr = writeStream;
}

@interface AudioStreamer (PRAudioStreamer_Private)

- (void)failWithErrorCode:(AudioStreamerErrorCode)anErrorCode;

@end

@implementation PRAudioStreamer

- (id)initWithURL:(NSURL *)aURL
{
	self = [super initWithURL:aURL];
	
	if (self)
	{
		shouldStart = NO;
		didStart = NO;
		
		NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:aURL] autorelease];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[connection start];
	}
	
	return self;
}

- (void)start
{
	// start the connection here?
	
	if (shouldStart)
	{
		[super start];
	}
	
	didStart = YES;
}

// we opened the stream
- (BOOL)openReadStream
{
	CFStreamCreateBoundPair(NULL, (CFReadStreamRef *)&stream, (CFWriteStreamRef *)&writeStream, fileLength > 0 ? (CFIndex)fileLength : 32768);
	
	[(NSInputStream *)stream open];
	[writeStream open];
	
	state = AS_WAITING_FOR_DATA;
	httpHeaders = [[NSDictionary alloc] init];
	
	// stolen from superclass
	// needs to be done
	CFStreamClientContext context = {0, self, NULL, NULL, NULL};
	CFReadStreamSetClient(stream,
			      kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered,
			      ASReadStreamCallBack,
			      &context);
	CFReadStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	
	return YES;
}

- (void)connection:(NSURLConnection *)c didReceiveResponse:(NSURLResponse *)response
{
	fileLength = [response expectedContentLength];

	if (fileLength == NSURLResponseUnknownLength)
	{
	//	PRLog(@"BAD!!!");
		// default to a really big number
		// SOOOOOO BAD!
		// fileLength = 20000000;
		
		[writeStream close];
		RELEASE_MEMBER(writeStream);
		
		[connection cancel];
		RELEASE_MEMBER(connection);
		
		[super failWithErrorCode:AS_AUDIO_BUFFER_TOO_SMALL];
		
		return;
	}
	
	shouldStart = YES;
	
	if (didStart)
	{
		[super start];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[writeStream write:[data bytes] maxLength:[data length]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)e
{
	PRError(@"Unable to download file: %@", [e localizedDescription]);
	[writeStream close];
	RELEASE_MEMBER(writeStream);
	[(PRAppDelegate *)[NSApp delegate] stopPlayback:[e localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	PRLog(@"Downloaded audio file successfully!");
	[writeStream close];
	RELEASE_MEMBER(writeStream);
}

- (void)dealloc
{
	if (writeStream)
	{
		[writeStream close];
		RELEASE_MEMBER(writeStream);
	}
	
	if (connection)
	{
		[connection cancel];
		RELEASE_MEMBER(connection);
	}
	
	[super dealloc];
}

@end
