//
//  PRStationTableDelegate.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRStationTableDelegate.h"

#import "PRAppDelegate.h"
#import "PRStationCell.h"


@implementation PRStationTableDelegate

- (id)initWithPianoWrapper:(PRPianoWrapper *)wrapper
{
	self = [super init];
	
	if (self != nil)
	{
		pianoWrapper = [wrapper retain];
		
		RETAIN_MEMBER(pianoWrapper);
	}
	
	return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSArray *stations = [pianoWrapper stations];
	return stations ? [stations count] : 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSArray *stations = [pianoWrapper stations];
	return stations ? [[stations objectAtIndex:rowIndex] name] : @"";
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	NSArray *stations = [pianoWrapper stations];
	if ([stations objectAtIndex:row] == [pianoWrapper currentStation])
	{
		return [tableView rowHeight] + [[[[tableView tableColumns] objectAtIndex:0] dataCell] extraHeightForMainStation];
	}
	else
	{
		return [tableView rowHeight];
	}
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSArray *stations = [pianoWrapper stations];
	if ([stations objectAtIndex:rowIndex] == [pianoWrapper currentStation])
	{
		[aCell setIsMainStation:YES];
	//	[aCell setBackgroundStyle:NSBackgroundStyleRaised];
	}
	else
	{
		[aCell setIsMainStation:NO];
	}
}

- (void)tableDoubleClicked:(id)view
{
	NSArray *stations = [pianoWrapper stations];
	NSInteger row = [view clickedRow];
	
	if (stations && row >= 0 && row < [stations count])
	{
		[[NSApp delegate] playStation:[stations objectAtIndex:row]];
	}
}
/*
- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
	return [NSIndexSet indexSet];
}
*/
- (void)dealloc
{
	RELEASE_MEMBER(pianoWrapper);
	
	[super dealloc];
}


@end
