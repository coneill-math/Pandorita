//
//  PRPlaylistTableDelegate.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRSongHistoryTableDelegate.h"

#import "PRArrowButtonCell.h"


@implementation PRSongHistoryTableDelegate
/*
- (id)init
{
	self = [super init];
	
	if (self != nil)
	{
		songHistory = [[NSMutableArray alloc] init];
	}
	
	return self;
}
*/
- (void)awakeFromNib
{
	songHistory = [[NSMutableArray alloc] init];
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
		if ([song isEqual:[songHistory objectAtIndex:i]])
		{
			[songHistory replaceObjectAtIndex:i withObject:song];
			return;
		}
	}
	
	PRLog(@"Error: Song not found for replacement in history: %@", song);
}

- (void)clearHistory
{
	[songHistory removeAllObjects];
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
		return [NSString stringWithFormat:@"%ld", (long)(rowIndex + 1)];
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
	else if ([[aTableColumn identifier] isEqualToString:@"artist"])
	{
		[aCell setTitle:[[self songForRow:rowIndex] artist]];
	}
	else if ([[aTableColumn identifier] isEqualToString:@"album"])
	{
		[aCell setTitle:[[self songForRow:rowIndex] album]];
	}
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView
{
	NSInteger clickedColumn = [aTableView clickedColumn];
	NSInteger clickedRow = [aTableView clickedRow];
	if (clickedColumn >= 0 && [[[[aTableView tableColumns] objectAtIndex:clickedColumn] identifier] isEqualToString:@"rating"])
	{
		return NO;
	}
	else if (clickedColumn >= 0 && [[[[aTableView tableColumns] objectAtIndex:clickedColumn] identifier] isEqualToString:@"artist"] &&
		 [[[[aTableView tableColumns] objectAtIndex:clickedColumn] dataCell] wasMouseClickInButtonForCellFrame:[aTableView frameOfCellAtColumn:clickedColumn row:clickedRow]
														inView:aTableView])
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
