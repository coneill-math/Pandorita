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
/*
- (id)initWithPianoWrapper:(PRPianoWrapper *)wrapper forTable:(NSTableView *)table
{
	self = [super init];
	
	if (self != nil)
	{
		pianoWrapper = [wrapper retain];
		tableView = [table retain];
		
		RETAIN_MEMBER(pianoWrapper);
	}
	
	return self;
}
*/
- (void)awakeFromNib
{
	
}

- (void)setPianoWrapper:(PRPianoWrapper *)wrapper
{
	pianoWrapper = [wrapper retain];
}

- (IBAction)getStationInfo:(id)sender
{
	// coming soon...
}

- (IBAction)renameStation:(id)sender
{
	NSInteger row = [tableView clickedRow];
	
	if (row >= 0 && row < [[pianoWrapper stations] count])
	{
		[tableView editColumn:0 row:row withEvent:nil select:YES];
	}
}

- (IBAction)removeStation:(id)sender
{
	NSInteger row = [tableView clickedRow];
	
	if (row >= 0 && row < [[pianoWrapper stations] count])
	{
		PRStation *station = [[pianoWrapper stations] objectAtIndex:row];
		
		if (![station isQuickMix])
		{
			NSString *text = [NSString stringWithFormat:@"Are you sure you want to remove the playlist %@?", [station name]];
			NSString *inform = @"You cannot undo this action";
			NSAlert *alert = [NSAlert alertWithMessageText:text defaultButton:@"Remove" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:inform];
			
			NSInteger result = [alert runModal];
			if (result == NSAlertDefaultReturn)
			{
				[pianoWrapper removeStation:station];
			}
		}
	}
}

- (IBAction)toggleUsesQuickMix:(id)sender
{
	NSInteger row = [tableView clickedRow];
	
	if (row >= 0 && row < [[pianoWrapper stations] count])
	{
		PRStation *station = [[pianoWrapper stations] objectAtIndex:row];
		
		if (![station isQuickMix])
		{
			[station setUseQuickMix:![station useQuickMix]];
			[pianoWrapper updateQuickMix];
		}
	}
}

// informal protocol
// called by each menu item on the target of its action
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	NSInteger row = [tableView clickedRow];
	
	if (row >= 0 && row < [[pianoWrapper stations] count])
	{
		PRStation *station = [[pianoWrapper stations] objectAtIndex:row];
		
		if (([item action] == @selector(removeStation:) || [item action] == @selector(toggleUsesQuickMix:)) && [station isQuickMix])
		{
			return NO;
		}
		
		if ([item action] == @selector(toggleUsesQuickMix:))
		{
			[item setState:([station useQuickMix] ? NSOnState : NSOffState)];
		}
		
		return YES;
	}
	
	return NO;
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

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	[pianoWrapper setName:anObject forStation:[[pianoWrapper stations] objectAtIndex:rowIndex]];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return NO;
}

- (CGFloat)tableView:(NSTableView *)aTableView heightOfRow:(NSInteger)row
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

- (void)tableDoubleClicked:(id)sender
{
	NSArray *stations = [pianoWrapper stations];
	NSInteger row = [tableView clickedRow];
	
	if (stations && row >= 0 && row < [stations count])
	{
		[[NSApp delegate] playStation:[stations objectAtIndex:row]];
	}
}
/*
- (NSIndexSet *)tableView:(NSTableView *)aTableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
	return [NSIndexSet indexSet];
}
*/
- (void)dealloc
{
	RELEASE_MEMBER(pianoWrapper);
	RELEASE_MEMBER(tableView);
	
	[super dealloc];
}


@end
