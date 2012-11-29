//
//  PRSearchTableDelegate.m
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PRSearchTableDelegate.h"

#import "PRArtist.h"
#import "PRSong.h"

#import "PRUtils.h"


@interface PRSearchTableDelegate (PRSearchTableDelegate_Private)

- (NSString *)musicIdForRow:(NSInteger)rowIndex;
- (NSInteger)indexOfMusicId:(NSString *)musicId;

@end

@implementation PRSearchTableDelegate

- (id)init
{
	self = [super init];
	
	if (self)
	{
		songs = [[NSMutableArray alloc] init];
		artists = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)setPianoWrapper:(PRPianoWrapper *)wrapper
{
	pianoWrapper = [wrapper retain];
}

- (NSString *)musicIdForRow:(NSInteger)rowIndex
{
	if (rowIndex >= 0 && rowIndex < [artists count])
	{
		return [[artists objectAtIndex:rowIndex] musicId];
	}
	else if (rowIndex >= [artists count] && rowIndex < [artists count] + [songs count])
	{
		return [[songs objectAtIndex:(rowIndex - [artists count])] musicId];
	}
	else
	{
		return nil;
	}
}

- (NSInteger)indexOfMusicId:(NSString *)musicId
{
	NSInteger i;
	
	for(i = 0;i < [artists count];i++)
	{
		if ([[[artists objectAtIndex:i] musicId] isEqualToString:musicId])
		{
			return i;
		}
	}
	
	for(i = 0;i < [songs count];i++)
	{
		if ([[[songs objectAtIndex:i] musicId] isEqualToString:musicId])
		{
			return i + [artists count];
		}
	}
	
	return NSNotFound;
}

- (void)setFoundArtists:(NSArray *)a songs:(NSArray *)s
{
	if (s)
	{
		[songs setArray:s];
	}
	else
	{
		[songs removeAllObjects];
	}
	
	if (a)
	{
		[artists setArray:a];
	}
	else
	{
		[artists removeAllObjects];
	}
	/*
	NSIndexSet *indexes = [tableView selectedRowIndexes];
	NSString *musicId = nil;
	
	if ([indexes count] > 0)
	{
		musicId = [self musicIdForRow:[indexes firstIndex]];
	}
	*/
	[tableView reloadData];
	/*
	if ([tableView numberOfRows] > 0 && musicId != nil)
	{
		NSInteger rowIndex = [self indexOfMusicId:musicId];
		
		if (rowIndex == NSNotFound)
		{
			rowIndex = 0;
		}
		
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:NO];
	}
	*/
}
/*
- (void)shiftSelection:(NSInteger)shift
{
	NSIndexSet *indexes = [tableView selectedRowIndexes];
	NSInteger index = 0;
	
	if ([indexes count] > 0)
	{
		index = [indexes firstIndex] + shift;
	}
	
	if (index >= 0 && index < [tableView numberOfRows])
	{
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
		[tableView scrollRowToVisible:index];
	}
}
*/
- (IBAction)tableDoubleClicked:(id)sender
{
	NSInteger row = [tableView clickedRow];
	NSString *musicId = [self musicIdForRow:row];
	
	if (musicId)
	{
		[pianoWrapper createStationWithMusicId:musicId];
		
		[searchField endEditingAndClear:self];
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [artists count] + [songs count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	if (rowIndex < [artists count])
	{
		return [NSAttributedString attributedString:[NSString stringWithFormat:@"%@ (Artist)", [[artists objectAtIndex:rowIndex] name]] withAttributes:[NSDictionary dictionary]];
	}
	else
	{
		PRSong *song = [songs objectAtIndex:(rowIndex - [artists count])];
		return [NSAttributedString attributedString:[NSString stringWithFormat:@"%@ - %@", [song title], [song artist]] withAttributes:[NSDictionary dictionary]];
	}
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	// do nothing
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return NO;
}

- (void)dealloc
{
	RELEASE_MEMBER(artists);
	RELEASE_MEMBER(songs);
	RELEASE_MEMBER(pianoWrapper);
	
	[super dealloc];
}

@end
