//
//  PRPianoWrapper.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRPianoWrapper.h"

#import "PRPianoJob.h"
#import "PRPianoLoginJob.h"
#import "PRPianoGetStationsJob.h"
#import "PRPianoGetPlaylistJob.h"
#import "PRPianoSetRatingJob.h"
#import "PRPianoTiredTrackJob.h"
#import "PRPianoUpdateQuickMixJob.h"
#import "PRPianoCreateStationJob.h"
#import "PRPianoRenameStationJob.h"
#import "PRPianoRemoveStationJob.h"
#import "PRPianoSearchJob.h"


@interface PRPianoWrapper (PRPianoWrapper_Private)

- (void)queueJob:(PRPianoJob *)job;
- (void)updateStations;
- (void)updatePlaylist;

@end


@implementation PRPianoWrapper

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		jobQueue = [[NSMutableArray alloc] init];
		
		stations = [[NSMutableArray alloc] init];
		playlist = [[NSMutableArray alloc] init];
		
		currentSongIndex = 0;
		currentStation = nil;
		delegate = nil;
		
		username = NULL;
		password = NULL;
		
		PianoInit(&pHandle, "android", "AC7IBG09A3DTSYM4R41UJWL07VLN8JI7", "android-generic", "R=U!LH$O2B#", "6#26FRL$ZWD");
	}
	
	return self;
}

- (NSArray *)stations
{
	return stations;
}

- (NSArray *)playlist
{
	return playlist;
}

- (PRStation *)currentStation
{
	return currentStation;
}

- (void)setCurrentStation:(PRStation *)station
{
	RETAIN_MEMBER(station);
	RELEASE_MEMBER(currentStation);
	currentStation = station;
}

- (id <PRPianoDelegate>)delegate
{
	return delegate;
}

- (void)setDelegate:(id <PRPianoDelegate>)d
{
	RETAIN_MEMBER(d);
	RELEASE_MEMBER(delegate);
	delegate = d;
}

- (void)queueJob:(PRPianoJob *)job
{
	[jobQueue addObject:job];
	
	if ([jobQueue count] == 1)
	{
		[job startJob];
	}
}

- (void)updateStations
{
	PRPianoGetStationsJob *job = [[[PRPianoGetStationsJob alloc] initWithWrapper:self] autorelease];
	[self queueJob:job];
}

- (void)updatePlaylist
{
	if (!currentStation)
	{
		NSLog(@"No station selected!");
		return;
	}
	
	PRPianoGetPlaylistJob *job = [[[PRPianoGetPlaylistJob alloc] initWithWrapper:self station:currentStation] autorelease];
	[self queueJob:job];
}

- (void)loginWithUsername:(NSString *)user password:(NSString *)pass
{
	// clean up in case we were already logged in
	[playlist removeAllObjects];
	RELEASE_MEMBER(currentStation);
	[stations removeAllObjects];
	[jobQueue removeAllObjects];
	
	username = [user retain];
	password = [pass retain];
	
	// init Piano
	PianoDestroy(&pHandle);
	PianoInit(&pHandle, "android", "AC7IBG09A3DTSYM4R41UJWL07VLN8JI7", "android-generic", "R=U!LH$O2B#", "6#26FRL$ZWD");
	
	// init station gettingz
//	[self queueJobWithType:PIANO_REQUEST_GET_STATIONS data:NULL extraInfo:nil callback:@selector(updateStationsCompleted:) startImmediately:NO];
	
	// log in user
	[self login];
	
	// if we had to login, stations may have changed
	// not sure yet how to handle that situation...
	[self updateStations];
}

- (void)login
{
	// make sure we continue on to the next one
	PRPianoLoginJob *job = [[PRPianoLoginJob alloc] initWithWrapper:self username:username password:password];
	[jobQueue insertObject:job atIndex:0];
	[job release];
	
	NSLog(@"Logging in...");
	[job startJob];
}

- (void)requestNextSong
{
	currentSongIndex++;
	
	if (playlist && currentSongIndex < [playlist count])
	{
		// call the delegate method immediately
		// well, not immediately...
		[delegate performSelector:@selector(didReceiveNextSong:error:) withObject:[playlist objectAtIndex:currentSongIndex] withObject:nil];
//		[delegate didReceiveNextSong:[playlist objectAtIndex:currentSongIndex] error:nil];
	}
	else
	{
		[self updatePlaylist];
	}
}

- (void)setRating:(PRRating)rating forSong:(PRSong *)song
{
	PRPianoSetRatingJob *job = [[[PRPianoSetRatingJob alloc] initWithWrapper:self withRating:rating forSong:song] autorelease];
	[self queueJob:job];
}

- (void)markSongAsTired:(PRSong *)song
{
	PRPianoTiredTrackJob *job = [[[PRPianoTiredTrackJob alloc] initWithWrapper:self song:song] autorelease];
	[self queueJob:job];
}

- (void)updateQuickMix
{
	PRPianoUpdateQuickMixJob *job = [[[PRPianoUpdateQuickMixJob alloc] initWithWrapper:self] autorelease];
	[self queueJob:job];
}

- (void)createStationWithMusicId:(NSString *)musicId
{
	PRPianoCreateStationJob *job = [[[PRPianoCreateStationJob alloc] initWithWrapper:self musicId:musicId] autorelease];
	[self queueJob:job];
}

- (void)setName:(NSString *)name forStation:(PRStation *)station
{
	PRPianoRenameStationJob *job = [[[PRPianoRenameStationJob alloc] initWithWrapper:self withName:name forStation:station] autorelease];
	[self queueJob:job];
}

- (void)removeStation:(PRStation *)station
{
	PRPianoRemoveStationJob *job = [[[PRPianoRemoveStationJob alloc] initWithWrapper:self withStation:station] autorelease];
	[self queueJob:job];
}

- (void)submitSearch:(NSString *)search
{
	PRPianoSearchJob *job = [[[PRPianoSearchJob alloc] initWithWrapper:self search:search] autorelease];
	[self queueJob:job];
	NSLog(@"Searching: %@", search);
}

//////////////////////////////////
// Called from PRPianoJob only! //
//////////////////////////////////

- (void)createRequestForJob:(PRPianoJob *)job
{
	job.pRet = PianoRequest(&pHandle, job.req, job.type);
}

- (void)createResponseForJob:(PRPianoJob *)job
{
	job.pRet = PianoResponse(&pHandle, job.req);
}

- (void)setTimeOffsetForLoginHack:(time_t)offset
{
	pHandle.timeOffset = offset;
}

- (void)finishJob:(PRPianoJob *)job
{
	[jobQueue removeObject:job];
	
	NSLog(@"Finish job completed");
	
	if ([jobQueue count] > 0)
	{
		[[jobQueue objectAtIndex:0] startJob];
	}
}

- (void)loadStationsFromPianoHandle
{
//	RELEASE_MEMBER(currentStation);
	[stations removeAllObjects];
	
	PianoStation_t *cur = pHandle.stations;
	
	while(cur != NULL)
	{
		PRStation *s = [[PRStation alloc] initWithStation:cur];
		[stations addObject:s];
		[s release];
		
		cur = cur->next;
	}
	
	if (currentStation)
	{
		PRStation *old = currentStation;
		currentStation = nil;
		
		for(PRStation *s in stations)
		{
			if ([s isEqual:old])
			{
				currentStation = [s retain];
				break;
			}
		}
		
		RELEASE_MEMBER(old);
	}
}

- (void)stationRemoved:(PRStation *)station
{
	if (station == currentStation)
	{
		RELEASE_MEMBER(currentStation);
		[self clearPlaylist];
	}
	
	[stations removeObject:station];
}

- (void)clearPlaylist
{
	[playlist removeAllObjects];
	currentSongIndex = 0;
}

- (void)addSongToPlaylist:(PRSong *)song
{
	[playlist addObject:song];
}

- (void)removeAllJobs
{
	[jobQueue removeAllObjects];
}

- (void)dealloc
{
	RELEASE_MEMBER(delegate);
	RELEASE_MEMBER(currentStation);
	RELEASE_MEMBER(stations);
	RELEASE_MEMBER(playlist);
	RELEASE_MEMBER(jobQueue);
	RELEASE_MEMBER(username);
	RELEASE_MEMBER(password);
	PianoDestroy(&pHandle);
	
	[super dealloc];
}


@end
