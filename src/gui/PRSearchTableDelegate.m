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
	
	[tableView reloadData];
}

- (IBAction)tableDoubleClicked:(id)sender
{
	NSInteger row = [tableView clickedRow];
	
	if (row >= 0 && row < [artists count])
	{
		PRArtist *artist = [artists objectAtIndex:row];
		[pianoWrapper createStationWithMusicId:[artist musicId]];
		
		[searchField endEditingAndClear:self];
	}
	else if (row >= [artists count] && row < [artists count] + [songs count])
	{
		PRSong *song = [songs objectAtIndex:row];
		[pianoWrapper createStationWithMusicId:[song musicId]];
		
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
		return [NSString stringWithFormat:@"%@ (Artist)", [[artists objectAtIndex:rowIndex] name]];
	}
	else
	{
		return [[songs objectAtIndex:(rowIndex - [artists count])] title];
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
