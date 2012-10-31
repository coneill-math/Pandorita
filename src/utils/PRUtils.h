//
//  PRUtils.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/2/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PRUserDefaults.h"


NSString *PRSongDurationFromInterval(NSTimeInterval interval);

@interface NSString (PRUtils_Additions)

- (NSUInteger)countOfCharactersInSet:(NSCharacterSet *)set;

@end

@interface NSAttributedString (PRUtils_Additions)

+ (id)attributedString:(NSString *)str withAttributes:(NSDictionary *)attributes;

@end

@interface NSView (PRUtils_Additions)

- (BOOL)containsView:(NSView *)subview;

@end


@interface NSSearchField (PRUtils_Additions)

- (IBAction)endEditingAndClear:(id)sender;

@end


@interface QTMovie (PRUtils_Additions)

- (NSTimeInterval)durationAsInterval;
- (NSTimeInterval)currentTimeAsInterval;

@end


