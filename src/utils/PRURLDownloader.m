//
//  PRURLDownloader.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRURLDownloader.h"


@implementation NSInvocation (PRURLDownloader_Private)

+ (id)invocationWithTarget:(id)target selector:(SEL)selector
{
	NSInvocation *ret = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
	[ret setTarget:target];
	[ret setSelector:selector];
	return ret;
}

@end


@implementation PRURLDownloader

- (id)initWithFinishInvocation:(NSInvocation *)i
{
	self = [super init];
	
	if (self != nil)
	{
		invocation = [i retain];
		
		// worst object ever
		[invocation setArgument:&self atIndex:2];
		
		request = nil;
		resultError = nil;
		responseData = nil;
		connection = nil;
		extraData = nil;
	}
	
	return self;
}

- (void)startRequest:(NSURLRequest *)req
{
	RELEASE_MEMBER(connection);
	RELEASE_MEMBER(responseData);
	RELEASE_MEMBER(resultError);
	RELEASE_MEMBER(request);
	
	request = [req retain];
	responseData = [[NSMutableData alloc] init];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[connection start];
}

- (BOOL)success
{
	return resultError == nil;
}

- (NSError *)lastError
{
	return resultError;
}

- (NSData *)responseData
{
	return responseData;
}

- (id)extraData
{
	return extraData;
}

- (void)setExtraData:(id)d
{
	RETAIN_MEMBER(d);
	RELEASE_MEMBER(extraData);
	extraData = d;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)e
{
//	[[NSAlert alertWithError:error] runModal];
	resultError = [e retain];
	[invocation invoke];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Once this method is invoked, "responseData" contains the complete result
	[invocation invoke];
}

- (void)dealloc
{
	RELEASE_MEMBER(extraData);
	RELEASE_MEMBER(resultError);
	RELEASE_MEMBER(connection);
	RELEASE_MEMBER(responseData);
	RELEASE_MEMBER(request);
	RELEASE_MEMBER(invocation);
	[super dealloc];
}


@end
