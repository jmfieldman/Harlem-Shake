//
//  OptionsModel.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum RecordingQuality {
	QUAL_LOW  = 0,
	QUAL_MED  = 1,
	QUAL_HIGH = 2,
} RecordingQuality_t;


@interface OptionsModel : NSObject

SINGLETON_INTR(OptionsModel);

+ (BOOL) playSong;
+ (void) setPlaySong:(BOOL)playSong;

+ (int) desiredQuality;
+ (void) setDesiredQuality:(int)quality;

+ (int) timerDelay;
+ (void) setTimerDelay:(int)timerDelay;

+ (int) recordBoth;
+ (void) setRecordBoth:(int)recordBoth;

+ (BOOL) flashBlink;
+ (void) setFlashBlink:(BOOL)flashBlink;

/* camera settings */

+ (BOOL) preferBackCamera;
+ (void) setPreferBackCamera:(BOOL)backCamera;

+ (BOOL) flashOn;
+ (void) setFlashOn:(BOOL)flashOn;


/* Device abilities */

+ (BOOL) hasDeviceWithFlash;
+ (AVCaptureDevice*) frontDevice;
+ (AVCaptureDevice*) backDevice;
+ (BOOL) hasFrontAndBackVideo;

@end
