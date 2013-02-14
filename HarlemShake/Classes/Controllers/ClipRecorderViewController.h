//
//  ClipRecorderViewController.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClipRecorderViewController : UIViewController <AVCaptureFileOutputRecordingDelegate> {
	
	float _screenH;
	float _screenW;
	
	UIView *_interfaceContainer;
	
	UIView *_topRContainer;
	UIView *_topLContainer;
	UIView *_botLContainer;
	
	UIButton *_cancelButton;
	
	/* Recording */
	AVCaptureSession     *_captureSession;
	AVCaptureDevice      *_captureDevice;
	AVCaptureDeviceInput *_captureDeviceInput;
	
	/* Orientation tracking */
	CMMotionManager    *_motionManager;
	UIDeviceOrientation _currentOrientation;
}

@property (nonatomic, strong) VideoID_t videoId;
@property (nonatomic, assign) BOOL openedForBeforeClip;

@end

