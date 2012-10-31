//
//  PRBlankInfoViewController.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/21/12.
//
//

#import <Cocoa/Cocoa.h>

#import "PRBaseInfoViewController.h"


@interface PRImageInfoViewController : PRBaseInfoViewController
{
	IBOutlet NSImageView *imageView;
	
	NSString *imageName;
}

- (id)initWithBlankImage;
- (id)initWithErrorImage;

@end
