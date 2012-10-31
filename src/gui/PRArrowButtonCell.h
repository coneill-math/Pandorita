//
//  PRArrowButtonCell.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/21/12.
//
//

#import <Cocoa/Cocoa.h>

@interface PRArrowButtonCell : NSButtonCell
{
	IBOutlet id songHistoryDelegate;
}

- (BOOL)wasMouseClickInButtonForCellFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end
