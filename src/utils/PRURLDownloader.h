//
//  PRURLDownloader.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSInvocation (PRURLDownloader_Private)

+ (id)invocationWithTarget:(id)target selector:(SEL)selector;

@end


@interface PRURLDownloader : NSObject <NSURLConnectionDelegate>
{
	NSURLRequest *request;
	
	NSInvocation *invocation;
	
	id extraData;
	
	NSURLConnection *connection;
	NSMutableData *responseData;
	
	NSError *resultError;
}

- (id)initWithFinishInvocation:(NSInvocation *)i;

- (id)extraData;
- (void)setExtraData:(id)d;

- (void)startRequest:(NSURLRequest *)req;

- (BOOL)success;
- (NSError *)lastError;
- (NSData *)responseData;

@end
