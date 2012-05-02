//
//  PRRatingCell.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PRSong.h"

@interface PRRatingCell : NSSegmentedCell
{

}

- (PRRating)selectedRating;
- (void)setRating:(PRRating)rating;

@end
