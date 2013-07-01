//
//  SVGKit.m
//  SVGKit-iOS
//
//  Created by Devon Blandin on 5/13/13.
//  Copyright (c) 2013 na. All rights reserved.
//

#import "SVGKit.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"

#if TARGET_OS_IPHONE
int ddLogLevel = LOG_LEVEL_WARN;
#define ddLogLevelInternal ddLogLevel
#else
static int ddLogLevelInternal = LOG_LEVEL_WARN;
int SVGCurrentLogLevel()
{
	return ddLogLevelInternal;
}
#endif

@implementation SVGKit : NSObject

+ (SVGKLoggingLevel) logLevel
{
	SVGKLoggingLevel retVal;
	switch (ddLogLevel) {
		case LOG_LEVEL_ERROR:
			retVal = SVGKLoggingError;
			break;
			
		case LOG_LEVEL_INFO:
			retVal = SVGKLoggingInfo;
			break;
			
		case LOG_LEVEL_OFF:
			retVal = SVGKLoggingOff;
			break;
			
		case LOG_LEVEL_VERBOSE:
			retVal = SVGKLoggingVerbose;
			break;
			
		case LOG_LEVEL_WARN:
			retVal = SVGKLoggingWarning;
			break;
			
		default:
			retVal = SVGKLoggingMixed;
			break;
	}
	return retVal;
}

static dispatch_once_t rawLogLevelToken;
#define RAWLEVELWARNSTR @"[%@] WARN: Only set/get the raw log level if you know what you're doing!"

+ (int) rawLogLevelWithWarning:(BOOL)warn
{
	if (warn) {
		dispatch_once(&rawLogLevelToken, ^{
			NSLog(RAWLEVELWARNSTR, self);
		});
	}
	
	return ddLogLevel;
}

+ (int) rawLogLevel
{
	return [self rawLogLevelWithWarning:YES];
}

+ (void) setRawLogLevel:(int)rawLevel withWarning:(BOOL)warn
{
#define LOGFLAGCHECK(theFlag, mutStr, logVal) \
if ((logVal & theFlag) == theFlag) { \
NSString *tmpStr = @(#theFlag); \
if (mutStr.length == 0) { \
[mutStr setString:tmpStr]; \
} else { \
[mutStr appendFormat:@" %@", tmpStr]; \
} \
}
	
	if (warn) {
		dispatch_once(&rawLogLevelToken, ^{
			NSLog(RAWLEVELWARNSTR, self);
		});
	}
	
	if ((rawLevel & ~((int)LOG_LEVEL_VERBOSE)) != 0) {
		int newLogLevel = rawLevel;
		newLogLevel &= ((int)LOG_LEVEL_VERBOSE);
		NSMutableString *valString = [[NSMutableString alloc] init];
		@autoreleasepool {
			LOGFLAGCHECK(LOG_FLAG_VERBOSE, valString, newLogLevel);
			LOGFLAGCHECK(LOG_FLAG_INFO, valString, newLogLevel);
			LOGFLAGCHECK(LOG_FLAG_WARN, valString, newLogLevel);
			LOGFLAGCHECK(LOG_FLAG_ERROR, valString, newLogLevel);
			if (valString.length == 0) {
				[valString setString:@"LOG_LEVEL_OFF"];
			}
		}
		LOG_OBJC_MAYBE(LOG_ASYNC_INFO, (ddLogLevelInternal | newLogLevel), LOG_FLAG_INFO, 0, @"[%@] WARN: The raw log level %i is invalid! The new raw log level is %i, or %@.", self, rawLevel, newLogLevel, valString);
		[valString release];
		ddLogLevelInternal = newLogLevel;
	}else {
		@autoreleasepool {
			NSMutableString *valStr = [NSMutableString string];
			
			LOGFLAGCHECK(LOG_FLAG_VERBOSE, valStr, rawLevel);
			LOGFLAGCHECK(LOG_FLAG_INFO, valStr, rawLevel);
			LOGFLAGCHECK(LOG_FLAG_WARN, valStr, rawLevel);
			LOGFLAGCHECK(LOG_FLAG_ERROR, valStr, rawLevel);
			if (valStr.length == 0) {
				[valStr setString:@"LOG_LEVEL_OFF"];
			}
			
			LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, (ddLogLevelInternal | rawLevel), LOG_FLAG_VERBOSE, 0, @"[%@] DEBUG: Current raw debug level has been set at %i, or %@", self, rawLevel, valStr);
		}
		ddLogLevelInternal = rawLevel;
	}
#undef LOGFLAGCHECK
}

+ (void) setRawLogLevel:(int)rawLevel
{
	[self setRawLogLevel:rawLevel withWarning:YES];
}

+ (void) setLogLevel:(SVGKLoggingLevel)newLevel
{
	switch (newLevel) {
		case SVGKLoggingMixed:
		{
			NSString *logName = nil;
#define ARG(theArg) case theArg: \
logName = @(#theArg); \
break
			switch ([self logLevel]) {
					ARG(SVGKLoggingOff);
					ARG(SVGKLoggingError);
					ARG(SVGKLoggingWarning);
					ARG(SVGKLoggingInfo);
					ARG(SVGKLoggingVerbose);
				default:
					ARG(SVGKLoggingMixed);
			}
			NSLog(@"[%@] WARN: SVGKLoggingMixed is an invalid value to set for the log level, staying at %@.", self, logName);
			static dispatch_once_t rawOnceInfoToken;
			dispatch_once(&rawOnceInfoToken, ^{
				NSLog(@"[%@] INFO: If you want a different value than what is available via SVGKLoggingLevel, look into setRawLogLevel.", self);
				NSLog(@"[%@] INFO: The raw log level values are based on the Lumberjack log levels. Look at their documentation for more info.", self);
			});
#undef ARG
		}
			break;
			
		case SVGKLoggingError:
			ddLogLevelInternal = LOG_LEVEL_ERROR;
			break;
			
		case SVGKLoggingInfo:
			ddLogLevelInternal = LOG_LEVEL_INFO;
			break;
			
		case SVGKLoggingVerbose:
			ddLogLevelInternal = LOG_LEVEL_VERBOSE;
			break;
			
		case SVGKLoggingWarning:
			ddLogLevelInternal = LOG_LEVEL_WARN;
			break;
			
		default:
		case SVGKLoggingOff:
			ddLogLevelInternal = LOG_LEVEL_OFF;
			break;
	}
}

+ (void) enableLogging {
#if DEBUG
	[self setLogLevel:SVGKLoggingVerbose];
#endif

    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

@end
