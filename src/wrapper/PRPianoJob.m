//
//  PRPianoJob.m
//  Pandorita
//
//  Created by Chris O'Neill on 2/24/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoJob.h"

#import "PRPianoWrapper.h"

@interface NSError (PRPianoJob_private)

+ (id)errorWithPianoCode:(PianoReturn_t)ret;

@end

@implementation NSError (PRPianoJob_private)

+ (id)errorWithPianoCode:(PianoReturn_t)ret
{
	if (ret == PIANO_RET_OK)
	{
		return nil;
	}
	else
	{
		NSDictionary *userDict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%s", PianoErrorToStr(ret)] forKey:NSLocalizedDescriptionKey];
		return [NSError errorWithDomain:@"com.musicman.pandorita" code:ret userInfo:userDict];
	}
}

@end


@implementation PRPianoJob

@synthesize type;
@synthesize req;
@synthesize pRet;

- (id)initWithWrapper:(PRPianoWrapper *)w jobType:(PianoRequestType_t)t
{
	self = [super init];
	
	if (self != nil)
	{
		req = (PianoRequest_t *)malloc(sizeof(PianoRequest_t));
		memset(req, 0, sizeof(PianoRequest_t));
		
		pRet = PIANO_RET_OK;
		type = t;
		
		wrapper = [w retain];
		downloader = [[PRURLDownloader alloc] initWithFinishInvocation:[NSInvocation invocationWithTarget:self selector:@selector(handleJobResponse:)]];
	}
	
	return self;
}

- (void)startJob
{
	PRLog(@"Starting job");
	
//	ERROR_ON_FAIL(cUsername != NULL);
//	ERROR_ON_FAIL(cPassword != NULL);
	
	// create the request
	[wrapper createRequestForJob:self];
	ERROR_ON_FAIL(self.pRet == PIANO_RET_OK);
	
	// send request to server
	NSString *urlStr = [NSString stringWithFormat:@"%s://%s%s", (self.req->secure ? "https" : "http"), PIANO_RPC_HOST, self.req->urlPath];
	NSMutableURLRequest *urlRequest = [[[NSMutableURLRequest alloc] init] autorelease];
	[urlRequest setURL:[NSURL URLWithString:urlStr]];
	
	if (self.req->postData && self.req->postData[0])
	{
		NSData *postData = [[NSString stringWithFormat:@"%s", self.req->postData] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSString *postLength = [NSString stringWithFormat:@"%ld", (long)[postData length]];
		
		[urlRequest setHTTPMethod:@"POST"];
		[urlRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[urlRequest setValue:@"Content-Type: text/xml" forHTTPHeaderField:@"Content-Type"];
		[urlRequest setHTTPBody:postData];
	}
	
	[downloader setExtraData:self];
	[downloader startRequest:urlRequest];
	
	PRLog(@"Start job completed");
	
	return;
	
error:
	PRLog(@"Error: %s", PianoErrorToStr(self.pRet));
	[self finishJob];
}

- (void)handleJobResponse:(PRURLDownloader *)d
{
	ERROR_ON_FAIL([downloader success]);
	
	NSData *responseData = [downloader responseData];
	
	self.req->responseData = malloc([responseData length] + 1);
	memset(self.req->responseData, 0, [responseData length] + 1);
	[responseData getBytes:self.req->responseData length:[responseData length]];
	
	// parse the response
	[wrapper createResponseForJob:self];
	
	// we can destroy the request at this point, even when this call needs
	// more than one http request. persistent data (step counter, e.g.) is
	// stored in req.data
	FREE_MEMBER(self.req->responseData);
	
	// checking for request type avoids infinite loops
	if (self.pRet == PIANO_RET_P_INVALID_AUTH_TOKEN && self.type != PIANO_REQUEST_LOGIN)
	{
		// reauthenticate
		PRLog(@"Reauthentication required...");
		[wrapper login];
		
	//	PRLog(@"Trying again...");
	//	[self startJob:job];
	}
	else if (self.pRet == PIANO_RET_CONTINUE_REQUEST)
	{
		[self startJob];
	}
	else if (self.pRet == PIANO_RET_OK)
	{
		PRLog(@"Returned ok.");
		[self finishJob];
	}
	else
	{
		ERROR_ON_FAIL(NO);
	}
	
	PRLog(@"Handle response completed");
	
	return;
	
error:
	PRLog(@"Error: %s", PianoErrorToStr(self.pRet));
	[self finishJob];
}

- (void)finishJob
{
	NSError *error = [self lastError];
	[self jobCompletedWithError:error];
	
	[wrapper finishJob:self];
}

- (void)jobCompletedWithError:(NSError *)error
{
	// do nothing by default
}

- (NSError *)lastError
{
	if ([downloader success])
	{
		return [NSError errorWithPianoCode:pRet];
	}
	else
	{
		return [downloader lastError];
	}
}

- (void)dealloc
{
	// will only happen if not already freed
	FREE_MEMBER(req->data);
	
	PianoDestroyRequest(req);
	FREE_MEMBER(req);
	RELEASE_MEMBER(downloader);
	RELEASE_MEMBER(wrapper);
	
	[super dealloc];
}

@end
