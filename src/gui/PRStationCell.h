//
//  PRStationCell.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/20/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PRStationCell : NSTextFieldCell
{
	BOOL isMainStation;
}

- (BOOL)isMainStation;
- (void)setIsMainStation:(BOOL)main;

- (CGFloat)extraHeightForMainStation;

@end
