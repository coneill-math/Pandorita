//
//  PRBaseInfoViewController.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/24/12.
//
//

#import <Cocoa/Cocoa.h>

#import "TFHpple.h"


@interface PRBaseInfoViewController : NSViewController <NSTextViewDelegate>
{
	CGFloat desiredHeight;
}

- (NSString *)title;
- (CGFloat)desiredHeight;

// call from a separate thread
- (BOOL)downloadData;

// call from the main thread
- (void)displayData;

+ (NSString *)pandoritaLinkForLink:(NSString *)linkStr;
+ (NSAttributedString *)attributedString:(NSAttributedString *)str forLink:(NSString *)link;
+ (NSAttributedString *)attributedStringForElement:(TFHppleElement *)element;
+ (BOOL)textView:(NSTextView *)aTextView clickedOnLink:(id)link atIndex:(NSUInteger)charIndex;

@end
