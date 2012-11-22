//
//  PRLogger.m
//  Pandorita
//
//  Created by Christopher ONeill on 11/8/12.
//
//

#import "PRLogger.h"


#define PR_DO_LOGGING 1

static PRLogger *g_Logger = nil;

@implementation PRLogger

+ (PRLogger *)defaultLogger
{
	if (!g_Logger)
	{
		g_Logger = [[PRLogger alloc] init];
	}
	
	return g_Logger;
}

- (void)log:(NSString *)format, ...
{
#if PR_DO_LOGGING
	va_list args;
	va_start(args, format);
	NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	NSLog(@"%@", str);
	RELEASE_MEMBER(str);
#endif
}

- (void)error:(NSString *)format, ...
{
	va_list args;
	va_start(args, format);
	NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);
	
	NSLog(@"%@", str);
	RELEASE_MEMBER(str);
}

@end
