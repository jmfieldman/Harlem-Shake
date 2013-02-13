//
//  OptionsModel.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "OptionsModel.h"

@implementation OptionsModel

SINGLETON_IMPL(OptionsModel);


+ (int) timerDelay {
	return [[[PersistentDictionary dictionaryWithName:@"options"].dictionary objectForKey:@"timerDelay"] intValue];
}

+ (void) setTimerDelay:(int)timerDelay {
	[[PersistentDictionary dictionaryWithName:@"options"].dictionary setObject:[NSNumber numberWithInt:timerDelay] forKey:@"timerDelay"];
	[[PersistentDictionary dictionaryWithName:@"options"] saveToFile];
}



@end

