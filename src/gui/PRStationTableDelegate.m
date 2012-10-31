//
//  PRStationTableDelegate.m
//  Pandorita
//
//  Created by Chris O'Neill on 1/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PRStationTableDelegate.h"

#import "PRAppDelegate.h"


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
	
	if ([sender class] == [NSMenuItem class] && [sender menu] != rightClickMenu)
	{
		row = [[tableView selectedRowIndexes] firstIndex];
	}
	
	if (row >= 0 && row < [[pianoWrapper stations] count])
	{
		[tableView editColumn:1 row:row withEvent:nil select:YES];
	}
}

- (IBAction)removeStation:(id)sender
{
	NSInteger row = [tableView clickedRow];
	
	if ([sender class] == [NSMenuItem class] && [sender menu] != rightClickMenu)
	{
		row = [[tableView selectedRowIndexes] firstIndex];
	}
	
	if (row >= 0 && row < [[pianoWrapper stations] count])
	{
		PRStation *station = [[pianoWrapper stations] objectAtIndex:row];
		
		if (![station isQuickMix])
		{
			NSString *text = [NSString stringWithFormat:@"Are you sure you want to remove the playlist %@?", [station name]];
			NSAlert *alert = [NSAlert alertWithMessageText:text defaultButton:@"Remove" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"You cannot undo this action"];
			
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
	
	if ([sender class] == [NSMenuItem class] && [sender menu] != rightClickMenu)
	{
		row = [[tableView selectedRowIndexes] firstIndex];
	}
	
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
	
	if ([item menu] != rightClickMenu)
	{
		row = [[tableView selectedRowIndexes] firstIndex];
	}
	
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

- (void)tableDoubleClicked:(id)sender
{
	NSArray *stations = [pianoWrapper stations];
	NSInteger row = [tableView clickedRow];
	
	if ([sender class] == [NSMenuItem class] && [sender menu] != rightClickMenu)
	{
		row = [[tableView selectedRowIndexes] firstIndex];
	}
	
	if (stations && row >= 0 && row < [stations count])
	{
		[[NSApp delegate] playStation:[stations objectAtIndex:row]];
	}
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	NSArray *stations = [pianoWrapper stations];
	return stations ? [stations count] : 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	NSArray *stations = [pianoWrapper stations];
	if ([[tableView tableColumns] indexOfObject:aTableColumn] > 0)
	{
		return stations ? [[stations objectAtIndex:rowIndex] name] : @"";
	}
	else
	{
		return ([stations objectAtIndex:rowIndex] == [pianoWrapper currentStation]) ? [NSImage imageNamed:@"Bullet"] : nil;
	}
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	[pianoWrapper setName:anObject forStation:[[pianoWrapper stations] objectAtIndex:rowIndex]];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return NO;
}
/*
// don't want any highlighting
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return NO;
}
*/
- (void)dealloc
{
	RELEASE_MEMBER(pianoWrapper);
	RELEASE_MEMBER(tableView);
	
	[super dealloc];
}


@end
