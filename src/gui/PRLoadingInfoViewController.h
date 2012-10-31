//
//  PRLoadingInfoViewController.h
//  Pandorita
//
//  Created by Chris O'Neill on 10/23/12.
//
//

#import <Cocoa/Cocoa.h>

#import "PRBaseInfoViewController.h"


@interface PRLoadingInfoViewController : PRBaseInfoViewController
{
	IBOutlet NSProgressIndicator *progressIndicator;
}

@end
