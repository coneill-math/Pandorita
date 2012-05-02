//
//  PRPlaylistTableDelegate.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRSongHistoryTableDelegate.h"


@implementation PRSongHistoryTableDelegate

- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		songHistory = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-  (PRSong *)currentSong
{
	return [songHistory count] > 0 ? [self songForRow:0] : nil;
}

- (PRSong *)songForRow:(NSUInteger)index
{
	return [songHistory objectAtIndex:([songHistory count] - 1 - index)];
}

- (void)addSong:(PRSong *)song
{
	[songHistory addObject:song];
}

- (void)replaceSongAfterRating:(PRSong *)song
{
	NSInteger i;
	
	for(i = 0;i < [songHistory count];i++)
	{
		if ([[songHistory objectAtIndex:i] representsSong:song])
		{
			[songHistory replaceObjectAtIndex:i withObject:song];
			return;
		}
	}
	
	NSLog(@"Error: Song not found for replacement in history: %@", song);
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [songHistory count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	PRSong *song = [self songForRow:rowIndex];
	
	if ([[aTableColumn identifier] isEqualToString:@"counter"])
	{
		return [NSString stringWithFormat:@"%d", rowIndex + 1];
	}
	else if ([[aTableColumn identifier] isEqualToString:@"artist"])
	{
		return [song artist];
	}
	else if ([[aTableColumn identifier] isEqualToString:@"album"])
	{
		return [song album];
	}
	else if ([[aTableColumn identifier] isEqualToString:@"rating"])
	{
		// handled in willDisplayCell
		return @"";
	}
	else // if ([[aTableColumn identifier] isEqualToString:@"title"])
	{
		return [song title];
	}
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return NO;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if ([[aTableColumn identifier] isEqualToString:@"rating"])
	{
		[aCell setRating:[[self songForRow:rowIndex] rating]];
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	NSInteger clickedColumn = [aTableView clickedColumn];
	if (clickedColumn >= 0 && [[[[aTableView tableColumns] objectAtIndex:clickedColumn] identifier] isEqualToString:@"rating"])
	{
		return NO;
	}
	else
	{
		return YES;
	}
}

- (void)dealloc
{
	RELEASE_MEMBER(songHistory);
	[super dealloc];
}


@end
