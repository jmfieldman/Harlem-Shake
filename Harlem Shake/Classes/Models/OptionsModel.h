//
//  OptionsModel.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OptionsModel : NSObject

SINGLETON_INTR(OptionsModel);

+ (int) timerDelay;
+ (void) setTimerDelay:(int)timerDelay;



@end
