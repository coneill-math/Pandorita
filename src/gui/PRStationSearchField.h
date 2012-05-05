//
//  PRStationSearchField.h
//  Pandorita
//
//  Created by Christopher O'Neill on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class PRSearchTableDelegate;

// temporarily not used...
@interface PRStationSearchField : NSSearchField
{
	IBOutlet PRSearchTableDelegate *searchTableDelegate;
}

@end
