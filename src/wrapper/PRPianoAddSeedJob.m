//
//  PRPianoAddSeedJob.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/28/12.
//
//

#import "PRPianoAddSeedJob.h"

#import "PRPianoWrapper.h"


@implementation PRPianoAddSeedJob

- (id)initWithWrapper:(PRPianoWrapper *)w station:(PRStation *)station musicId:(NSString *)musicId
{
	self = [super initWithWrapper:w jobType:PIANO_REQUEST_ADD_SEED];
	
	if (self != nil)
	{
		cMusicId = (char *)malloc(([musicId length] + 1) * sizeof(char));
		memset(cMusicId, 0, [musicId length] + 1);
		[musicId getCString:cMusicId maxLength:([musicId length]+1) encoding:NSASCIIStringEncoding];
		
		PianoRequestDataAddSeed_t *reqData = (PianoRequestDataAddSeed_t *)malloc(sizeof(PianoRequestDataAddSeed_t));
		memset(reqData, 0, sizeof(PianoRequestDataAddSeed_t));
		
		reqData->station = [station internalStation];
		reqData->musicId = cMusicId;
		
		req->data = reqData;
	}
	
	return self;
}

- (void)jobCompletedWithError:(NSError *)error
{
	if (error)
	{
		PRLog(@"Unable to add seed with id: %s!", cMusicId);
		// try anyway?
	}
	
	[wrapper loadStationsFromPianoHandle];
	
	// right now, always appended at the end
	[[wrapper delegate] didCreateStation:[[wrapper stations] lastObject] error:error];
}

- (void)dealloc
{
	FREE_MEMBER(cMusicId);
	FREE_MEMBER(req->data);
	
	[super dealloc];
}

@end
