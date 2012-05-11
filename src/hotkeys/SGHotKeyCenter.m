//
//  SGHotKeyCenter.m
//  SGHotKeyCenter
//
//  Created by Justin Williams on 7/26/09.
//  Copyright 2009 Second Gear. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "SGHotKeyCenter.h"
#import "SGHotKey.h"
#import "SGKeyCombo.h"

OSType const kHotKeySignature = 'SGHk';

@interface SGHotKeyCenter ()

- (SGHotKey *)_hotKeyForCarbonHotKey:(EventHotKeyRef)carbonHotKey;
- (EventHotKeyRef)_carbonHotKeyForHotKey:(SGHotKey *)hotKey;

- (void)_updateEventHandler;
- (void)_hotKeyDown: (SGHotKey *)hotKey;

@end

static OSStatus hotKeyEventHandler(EventHandlerCallRef inHandlerRef, EventRef inEvent, void* refCon );
static SGHotKeyCenter *sharedCenter = nil;

@implementation SGHotKeyCenter

+ (void)initialize {
	if (!sharedCenter) {
		sharedCenter = [[self alloc] init];
	}	
}

- (void)dealloc {
	[hotKeys release];
	[super dealloc];
}

+ (SGHotKeyCenter *)sharedCenter {    
	return sharedCenter;
}

+ (id) allocWithZone:(NSZone *)zone {
	//Usually already set by +initialize.
	if (sharedCenter) {
		//The caller expects to receive a new object, so implicitly retain it to balance out the caller's eventual release message.
		return [sharedCenter retain];
	} else {
		//When not already set, +initialize is our caller—it's creating the shared instance. Let this go through.
		return [super allocWithZone:zone];
	}
}

- (id) init {
	if (!hasInited) {
		if ((self = [super init])) {
			//Initialize the instance here.
			hotKeys = [[NSMutableDictionary alloc] init];    
			hasInited = YES;
		}
	}
	
	return self;
}

- (BOOL)registerHotKey:(SGHotKey *)theHotKey {
	OSStatus error;
	EventHotKeyID hotKeyID;
	EventHotKeyRef carbonHotKey;
	NSValue *key = nil;
	
	if ([[self allHotKeys] containsObject:theHotKey])
		[self unregisterHotKey:theHotKey];
	
	if (![[theHotKey keyCombo] isValidHotKeyCombo])
		return YES;
	
	static UInt32 currentId = 0;
	hotKeyID.signature = kHotKeySignature;
	hotKeyID.id = ++currentId;
	
	theHotKey.hotKeyID = hotKeyID;
	
	error = RegisterEventHotKey((UInt32)theHotKey.keyCombo.keyCode,
								(UInt32)theHotKey.keyCombo.modifiers,
								hotKeyID,
								GetEventMonitorTarget(),
								// GetEventDispatcherTarget(),
								0,
								&carbonHotKey);
	
	if (error) 
		return NO;
	
	key = [NSValue valueWithPointer:carbonHotKey];
	
	if (theHotKey && key)
		[hotKeys setObject:theHotKey forKey:key];
	
	[self _updateEventHandler];
	
	return YES;
}


- (void)unregisterHotKey:(SGHotKey *)theHotKey {
	EventHotKeyRef carbonHotKey;
	NSValue *key = nil;
	
	if (![[self allHotKeys] containsObject:theHotKey])
		return;
	
	carbonHotKey = [self _carbonHotKeyForHotKey:theHotKey];
	NSAssert(carbonHotKey != nil, @"");
	
	UnregisterEventHotKey(carbonHotKey);
	
	key = [NSValue valueWithPointer:carbonHotKey];
	[hotKeys removeObjectForKey:key];
	
	[self _updateEventHandler];
}

- (NSArray *)allHotKeys {
	return [hotKeys allValues];
}


- (SGHotKey *)hotKeyWithIdentifier:(id)theIdentifier {
	if (!theIdentifier)
		return nil;
	
	for (SGHotKey *hotKey in [self allHotKeys]) {
		if([[hotKey identifier] isEqual:theIdentifier] )
			return hotKey;
	}
	
	return nil;
}

- (OSStatus)processCarbonEvent:(EventRef)event {
	OSStatus error;
	EventHotKeyID hotKeyID;
	SGHotKey *hotKey = nil;
	
	NSAssert(GetEventClass(event) == kEventClassKeyboard, @"Unknown event class");
	
	error = GetEventParameter(event,
							  kEventParamDirectObject, 
							  typeEventHotKeyID,
							  nil,
							  sizeof(EventHotKeyID),
							  nil,
							  &hotKeyID);
	if (error)
		return error;
	
	NSAssert(hotKeyID.signature == kHotKeySignature, @"Invalid hot key id");
	NSAssert(hotKeyID.id != 0, @"Invalid hot key id");
	
	for (SGHotKey *thisHotKey in [self allHotKeys]) {
		if ([thisHotKey matchesHotKeyID:hotKeyID]) {
			hotKey = thisHotKey;
			break;
		}
	}
	
	switch (GetEventKind(event)) {
		case kEventHotKeyPressed:
			[self _hotKeyDown:hotKey];
			break;
			
		default:
			NSAssert(0, @"Unknown event kind");
			break;
	}
	
	return eventNotHandledErr;
}

- (SGHotKey *)_hotKeyForCarbonHotKey:(EventHotKeyRef)carbonHotKey {
	NSValue *key = [NSValue valueWithPointer:carbonHotKey];
	return [hotKeys objectForKey:key];
}

- (EventHotKeyRef)_carbonHotKeyForHotKey:(SGHotKey *)hotKey {
	NSArray *values;
	NSValue *value;
	
	values = [hotKeys allKeysForObject:hotKey];
	NSAssert([values count] == 1, @"Failed to find Carbon Hotkey for SGHotKey");
	
	value = [values lastObject];
	
	return (EventHotKeyRef)[value pointerValue];
}

- (void)_updateEventHandler {  
	static EventHandlerUPP handler = NewEventHandlerUPP(hotKeyEventHandler);
	
	if ([hotKeys count] && eventHandlerInstalled == NO) {
		EventTypeSpec eventSpec[1] = {
			{ kEventClassKeyboard, kEventHotKeyPressed }
		};
		
		InstallEventHandler(GetEventMonitorTarget(), handler, 1, eventSpec, NULL, NULL);
		eventHandlerInstalled = YES;
	}  
}

- (void)_hotKeyDown:(SGHotKey *)hotKey {
	[hotKey invoke];
}

static OSStatus hotKeyEventHandler(EventHandlerCallRef theHandlerRef, EventRef theEvent, void *userData ) {
	OSStatus result = [[SGHotKeyCenter sharedCenter] processCarbonEvent:theEvent];
	return result;
}

@end
