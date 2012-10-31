//
//  PRBlankInfoViewController.m
//  Pandorita
//
//  Created by Chris O'Neill on 10/21/12.
//
//

#import "PRImageInfoViewController.h"

@interface PRImageInfoViewController (PRImageInfoViewController_Private)

@end

@implementation PRImageInfoViewController

- (id)initWithImage:(NSString *)image
{
	self = [super initWithNibName:@"ImageInfoView" bundle:nil];
	
	if (self)
	{
		imageName = [[NSString alloc] initWithString:image];
		[imageView setImage:[NSImage imageNamed:imageName]];
	}
	
	return self;
}

- (id)initWithBlankImage
{
	return [self initWithImage:@"nothingtoshow"];
}

- (id)initWithErrorImage
{
	return [self initWithImage:@"infoerror"];
}

- (void)dealloc
{
	RELEASE_MEMBER(imageName);
	[super dealloc];
}

@end
