//
//  PRLoadingInfoViewController.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/23/12.
//
//

#import "PRLoadingInfoViewController.h"

@interface PRLoadingInfoViewController ()

@end

@implementation PRLoadingInfoViewController

- (id)init
{
	self = [super initWithNibName:@"LoadingInfoView" bundle:nil];
	
	if (self)
	{
		[progressIndicator startAnimation:self];
	}
	
	return self;
}

- (void)dealloc
{
//	[progressIndicator stopAnimation:self];
	[super dealloc];
}

@end
