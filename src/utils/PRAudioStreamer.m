//
//  PRAudioStreamer.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/31/12.
//
//

#import "PRAudioStreamer.h"

@implementation PRAudioStreamer

- (id)initWithURL:(NSURL *)aURL
{
	self = [super initWithURL:aURL];
	
	if (self)
	{
		CFStreamCreateBoundPair(NULL, (CFReadStreamRef *)&stream, (CFWriteStreamRef *)&writeStream, (CFIndex)32768);
		
		NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:aURL] autorelease];
		connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		[connection start];
		
		stream = nil;
	}
	
	return self;
}

- (void)start
{
	// start the connection here?  
	[super start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// already created the empty file
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[writeStream write:[data bytes] maxLength:[data length]];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)e
{
	NSLog(@"Unable to download file: %@", [e localizedDescription]);
	[writeStream close];
	RELEASE_MEMBER(writeStream);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Downloaded audio file successfully!");
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
