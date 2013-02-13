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


+ (BOOL) playSong {
	NSNumber *playSongNum = [[PersistentDictionary dictionaryWithName:@"options"].dictionary objectForKey:@"playSong"];
	if (!playSongNum) return YES;
	return [playSongNum boolValue];
}

+ (void) setPlaySong:(BOOL)playSong {
	[[PersistentDictionary dictionaryWithName:@"options"].dictionary setObject:[NSNumber numberWithBool:playSong] forKey:@"playSong"];
	[[PersistentDictionary dictionaryWithName:@"options"] saveToFile];
}

+ (int) desiredQuality {
	NSNumber *qualNum = [[PersistentDictionary dictionaryWithName:@"options"].dictionary objectForKey:@"quality"];
	if (!qualNum) return QUAL_HIGH;
	return [qualNum intValue];
}

+ (void) setDesiredQuality:(int)quality {
	[[PersistentDictionary dictionaryWithName:@"options"].dictionary setObject:[NSNumber numberWithInt:quality] forKey:@"quality"];
	[[PersistentDictionary dictionaryWithName:@"options"] saveToFile];
}

+ (int) timerDelay {
	return [[[PersistentDictionary dictionaryWithName:@"options"].dictionary objectForKey:@"timerDelay"] intValue];
}

+ (void) setTimerDelay:(int)timerDelay {
	[[PersistentDictionary dictionaryWithName:@"options"].dictionary setObject:[NSNumber numberWithInt:timerDelay] forKey:@"timerDelay"];
	[[PersistentDictionary dictionaryWithName:@"options"] saveToFile];
}

+ (int) recordBoth {
	return [[[PersistentDictionary dictionaryWithName:@"options"].dictionary objectForKey:@"recordBoth"] intValue];
}

+ (void) setRecordBoth:(int)recordBoth {
	[[PersistentDictionary dictionaryWithName:@"options"].dictionary setObject:[NSNumber numberWithInt:recordBoth] forKey:@"recordBoth"];
	[[PersistentDictionary dictionaryWithName:@"options"] saveToFile];
}

+ (BOOL) flashBlink {
	NSNumber *flashBlinkNum = [[PersistentDictionary dictionaryWithName:@"options"].dictionary objectForKey:@"flashBlink"];
	if (!flashBlinkNum) return YES;
	return [flashBlinkNum boolValue];
}

+ (void) setFlashBlink:(BOOL)flashBlink {
	[[PersistentDictionary dictionaryWithName:@"options"].dictionary setObject:[NSNumber numberWithBool:flashBlink] forKey:@"flashBlink"];
	[[PersistentDictionary dictionaryWithName:@"options"] saveToFile];
}


/* Device abilities */

+ (BOOL) hasDeviceWithFlash {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if ([device hasTorch]) return YES;
	}
	return NO;
}


@end

