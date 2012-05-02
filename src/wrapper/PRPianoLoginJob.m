//
//  PRPianoLoginJob.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoLoginJob.h"

#import "PRPianoWrapper.h"


#define USE_NEW_LOGIN_METHOD 0


@implementation PRPianoLoginJob

- (id)initWithWrapper:(PRPianoWrapper *)w username:(NSString *)user password:(NSString *)pass;
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_LOGIN];
	
	if (self != nil)
	{
		loginDownloader = nil;
		
		cUsername = (char *)malloc([user length] + 1);
		memset(cUsername, 0, [user length] + 1);
		[user getCString:cUsername maxLength:[user length] + 1 encoding:NSASCIIStringEncoding];
		
		cPassword = (char *)malloc([pass length] + 1);
		memset(cPassword, 0, [pass length] + 1);
		[pass getCString:cPassword maxLength:[pass length] + 1 encoding:NSASCIIStringEncoding];
		
		PianoRequestDataLogin_t *reqLoginData = (PianoRequestDataLogin_t *)malloc(sizeof(PianoRequestDataLogin_t));
		
		reqLoginData->user = cUsername;
		reqLoginData->password = cPassword;
		reqLoginData->step = 0; // skipping the first step via this new script
		
		req->data = reqLoginData;
		
#if USE_NEW_LOGIN_METHOD
		loginDownloader = [[PRURLDownloader alloc] initWithFinishInvocation:[NSInvocation invocationWithTarget:self selector:@selector(loginStep2:)]];
#endif
	}
	
	return self;
}

#if USE_NEW_LOGIN_METHOD
- (void)startJob
{
	// dont start just yet...
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] init] autorelease];
	[urlRequest setURL:[NSURL URLWithString:@"http://ridetheclown.com/s2/synctime.php"]];
	
	[loginDownloader startRequest:urlRequest];
}

- (void)loginStep2:(PRURLDownloader *)d
{
	if ([d success])
	{
		NSData *data = [d responseData];
		char *bytes = (char *)malloc([data length] + 1);
		memset(bytes, 0, [data length] + 1);
		memcpy(bytes, [data bytes], [data length]);
		((PianoRequestDataLogin_t *)(req->data))->step = 1; // skipping the first step via this new script
		[wrapper setTimeOffsetForLoginHack:(time(NULL) - (time_t)[[NSString stringWithCString:bytes encoding:NSASCIIStringEncoding] intValue])];
		FREE_MEMBER(bytes);
		
		NSLog(@"Logging in...");
		[super startJob];
	}
	else
	{
		[super startJob];
	}
}
#endif

// special implementation, since we will remove ourself from the queue
- (void)finishJob
{
	NSError *error = [self lastError];
	
	if (error)
	{
		NSLog(@"Unable to login!");
		
		// unable to login, these will be useless
		[wrapper removeAllJobs];
	}
	else
	{
		[wrapper finishJob:self];
	}
	
	[self jobCompletedWithError:error];
}

- (void)jobCompletedWithError:(NSError *)error
{
	[[wrapper delegate] didLoginWithError:error];
}

- (void)dealloc
{
	RELEASE_MEMBER(loginDownloader);
	
	FREE_MEMBER(cUsername);
	FREE_MEMBER(cPassword);
	FREE_MEMBER(req->data);
	
	[super dealloc];
}

@end
