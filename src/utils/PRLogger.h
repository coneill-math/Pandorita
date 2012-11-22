//
//  PRLogger.h
//  Pandorita
//
//  Created by Christopher ONeill on 11/8/12.
//
//

#import <Foundation/Foundation.h>

@interface PRLogger : NSObject
{
	
}

+ (PRLogger *)defaultLogger;

- (void)log:(NSString *)format, ...;
- (void)error:(NSString *)format, ...;

@end


#define PRLog(format, ...) [[PRLogger defaultLogger] log:format, ##__VA_ARGS__]
#define PRError(format, ...) [[PRLogger defaultLogger] error:format, ##__VA_ARGS__]
