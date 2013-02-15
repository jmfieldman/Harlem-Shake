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
	if (!qualNum) return QUAL_MED;
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

/* Camera settings */

+ (BOOL) preferBackCamera {
	NSNumber *preferBackCameraNum = [[PersistentDictionary dictionaryWithName:@"options"].dictionary objectForKey:@"preferBackCamera"];
	if (!preferBackCameraNum) return YES;
	return [preferBackCameraNum boolValue];
}

+ (void) setPreferBackCamera:(BOOL)backCamera {
	[[PersistentDictionary dictionaryWithName:@"options"].dictionary setObject:[NSNumber numberWithBool:backCamera] forKey:@"preferBackCamera"];
	[[PersistentDictionary dictionaryWithName:@"options"] saveToFile];
}

+ (BOOL) flashOn {
	NSNumber *flashOnNum = [[PersistentDictionary dictionaryWithName:@"options"].dictionary objectForKey:@"flashOn"];
	if (!flashOnNum) return NO;
	return [flashOnNum boolValue];
}

+ (void) setFlashOn:(BOOL)flashOn {
	[[PersistentDictionary dictionaryWithName:@"options"].dictionary setObject:[NSNumber numberWithBool:flashOn] forKey:@"flashOn"];
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

+ (AVCaptureDevice*) frontDevice {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionFront) return device;
	}
	return nil;
}

+ (AVCaptureDevice*) backDevice {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		if ([device position] == AVCaptureDevicePositionBack) return device;
	}
	return nil;
}

+ (BOOL) hasFrontAndBackVideo {
	return ([OptionsModel frontDevice] && [OptionsModel backDevice]);
}

+ (void) turnOffAllTorches {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices) {
		[OptionsModel turnFlashOn:NO forDevice:device];
	}
}

+ (void) turnFlashOn:(BOOL)on forDevice:(AVCaptureDevice*)device {
	AVCaptureTorchMode mode = on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
	if ([device isTorchModeSupported:mode]) {
		BOOL gotLock = [device lockForConfiguration:nil];
		if (gotLock) {
			device.torchMode = mode;
			[device unlockForConfiguration];
		}
	}
}


@end

