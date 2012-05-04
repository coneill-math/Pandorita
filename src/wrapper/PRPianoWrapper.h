//
//  PRPianoWrapper.h
//  Pandorita
//
//  Created by Chris O'Neill on 1/29/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include "piano.h"

#import "PRURLDownloader.h"

#import "PRPianoJob.h"
#import "PRStation.h"
#import "PRSong.h"


@protocol PRPianoDelegate <NSObject>

- (void)didLoginWithError:(NSError *)error;
- (void)didUpdateStationsWithError:(NSError *)error;
- (void)didStartNextSong:(PRSong *)song error:(NSError *)error;
- (void)didSetRating:(PRRating)rating forSong:(PRSong *)song error:(NSError *)error;
- (void)didRenameStation:(PRStation *)station error:(NSError *)error;
- (void)didRemoveStationWithError:(NSError *)error;

@end


@interface PRPianoWrapper : NSObject
{
	NSMutableArray *stations;
	PRStation *currentStation;
	
	NSMutableArray *playlist;
	NSInteger currentSongIndex;
	
	PianoHandle_t pHandle;
	
	NSString *username;
	NSString *password;
	
	id <PRPianoDelegate> delegate;
	
	NSMutableArray *jobQueue;
}

- (id <PRPianoDelegate>)delegate;
- (void)setDelegate:(id <PRPianoDelegate>)d;

- (NSArray *)stations;
- (NSArray *)playlist;

- (PRStation *)currentStation;
- (void)setCurrentStation:(PRStation *)station;

- (void)loginWithUsername:(NSString *)user password:(NSString *)pass;

- (void)requestNextSong;

- (void)setRating:(PRRating)rating forSong:(PRSong *)song;

- (void)updateQuickMix;

- (void)setName:(NSString *)name forStation:(PRStation *)station;
- (void)removeStation:(PRStation *)station;

//////////////////////////////////
// Called from PRPianoJob only! //
//////////////////////////////////
- (void)createRequestForJob:(PRPianoJob *)job;
- (void)createResponseForJob:(PRPianoJob *)job;
- (void)setTimeOffsetForLoginHack:(time_t)offset;
- (void)finishJob:(PRPianoJob *)job;
- (void)login;

// for specific jobs
- (void)loadStationsFromPianoHandle;

- (void)stationRemoved:(PRStation *)station;

- (void)clearPlaylist;
- (void)addSongToPlaylist:(PRSong *)song;

- (void)removeAllJobs;

@end
