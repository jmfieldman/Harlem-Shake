//
//  ClipRecorderViewController.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClipRecorderViewController : UIViewController <AVCaptureFileOutputRecordingDelegate> {
	UIButton *_cancelButton;
	
	/* Recording */
	AVCaptureSession     *_captureSession;
	AVCaptureDevice      *_captureDevice;
	AVCaptureDeviceInput *_captureDeviceInput;
}

@property (nonatomic, strong) VideoID_t videoId;
@property (nonatomic, assign) BOOL openedForBeforeClip;

@end

