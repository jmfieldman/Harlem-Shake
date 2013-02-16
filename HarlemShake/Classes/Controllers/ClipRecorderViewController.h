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
	UISegmentedControl *_cameraChooser;
	UISegmentedControl *_flashChooser;
	float               _flashY;
	UILabel            *_camLabel;
	UILabel            *_flashLabel;
	
	UIButton           *_recordButton;
	UILabel            *_timerSetupLabel;
	UILabel            *_audioOverlayLabel;
	UILabel            *_contRecordLabel;
	UILabel            *_flashPulseLabel;
	
	BOOL                _shouldBlink;
	
	/* Recording */
	AVCaptureSession     *_captureSession;
	AVCaptureDevice      *_captureDevice;
	AVCaptureDeviceInput *_captureDeviceInput;
	
	BOOL                  _shouldRecordBefore;
	NSTimer              *_recordingTimer;
	int                   _timerCountdown;
	
	UIProgressView       *_recordingProgress;
	NSTimer              *_progressTimer;
	CFTimeInterval        _recordingStartsAt;
	CFTimeInterval        _recordingDuration;
	
	BOOL                  _onSecondStep;
	BOOL                  _dontSave;
	
	AVCaptureMovieFileOutput *_movieOutput;
	
	AVPlayer                 *_assetPlayer;
	
	/* Asset stuff */
	AVURLAsset *_befAudioAsset;
	AVURLAsset *_aftAudioAsset;
	NSURL *_befClipURL;
	NSURL *_aftClipURL;
	NSURL *_befClipTempURL;
	NSURL *_aftClipTempURL;
	
	/* Orientation tracking */
	CMMotionManager    *_motionManager;
	UIDeviceOrientation _currentOrientation;
}

@property (nonatomic, strong) VideoID_t videoId;
@property (nonatomic, assign) BOOL openedForBeforeClip;

- (id) initWithVideo:(VideoID_t)videoId before:(BOOL)before;

@end

