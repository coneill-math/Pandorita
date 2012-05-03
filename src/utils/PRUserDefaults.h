//
//  PRUserDefaults.h
//  Pandorita
//
//  Created by Chris O'Neill on 2/22/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSUserDefaults (PRUtils_Additions)

+ (void)registerPandoritaUserDefaults;

+ (BOOL)shouldAutoLogin;
+ (void)setShouldAutoLogin:(BOOL)should;

+ (BOOL)shouldUseGrowl;
+ (void)setShouldUseGrowl:(BOOL)should;

+ (NSString *)lastUsername;
+ (void)setLastUsername:(NSString *)last;

+ (NSString *)passwordFromKeychain;
+ (BOOL)writePasswordToKeychain:(NSString *)pass;

@end


