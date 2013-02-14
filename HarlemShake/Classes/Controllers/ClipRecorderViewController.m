//
//  ClipRecorderViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "ClipRecorderViewController.h"

@implementation ClipRecorderViewController

- (id) init {
	if ((self = [super init])) {
		
		/* Initialize the main view */
		self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.view.backgroundColor = [UIColor clearColor];
		
		/* Create capture session */
		_captureSession = [[AVCaptureSession alloc] init];
		switch ([OptionsModel desiredQuality]) {
			case QUAL_LOW:  _captureSession.sessionPreset = AVCaptureSessionPresetLow;    break;
			case QUAL_MED:  _captureSession.sessionPreset = AVCaptureSessionPresetMedium; break;
			case QUAL_HIGH: _captureSession.sessionPreset = AVCaptureSessionPresetHigh;   break;
		}
						
		/* Set the device for input into capture session */
		[self configInputDeviceBasedOnSettings];
				
		/* Add viewing layer */
		AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
		captureVideoPreviewLayer.frame = [UIScreen mainScreen].bounds;
		captureVideoPreviewLayer.backgroundColor = [UIColor blackColor].CGColor;
		[self.view.layer addSublayer:captureVideoPreviewLayer];
				 
		/* Create containers */
		_screenW = self.view.frame.size.width;
		_screenH = self.view.frame.size.height;
		_interfaceContainer = [[UIView alloc] initWithFrame:CGRectMake(- (_screenH - _screenW) / 2, 0, _screenH, _screenH)];
		_interfaceContainer.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_interfaceContainer];
		
		_topLContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
		_topLContainer.backgroundColor = [UIColor clearColor];
		[_interfaceContainer addSubview:_topLContainer];
		
		/* Set interface to portrait */
		[self positionSubcontainersForPortrait];
		_currentOrientation = UIDeviceOrientationPortrait;
		
		/* Cancel */
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(50,10,100,50);
		_cancelButton.backgroundColor = [UIColor whiteColor];
		[_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
		[_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_cancelButton addTarget:self action:@selector(pressedCancel:) forControlEvents:UIControlEventTouchUpInside];
		_cancelButton.tintColor = [UIColor whiteColor];
		_cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
		_cancelButton.layer.cornerRadius = 20;
		_cancelButton.layer.borderWidth = 5;
		_cancelButton.layer.borderColor	= [UIColor blackColor].CGColor;
		_cancelButton.alpha = 0.75;
		[_topLContainer addSubview:_cancelButton];
				
		/* Motion */
		_motionManager = [[CMMotionManager alloc] init];
		_motionManager.accelerometerUpdateInterval = 0.5;
	}
	return self;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	
	[_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
										 withHandler:^(CMAccelerometerData *accData, NSError *error) {

											 /* 
											  port: y = -1
											  upside down port: y = 1
											  home button right: x = -1
											  home button left: x = 1
											  */
											 
											 UIDeviceOrientation curOrientation = UIDeviceOrientationUnknown;
											 
											 if (accData.acceleration.x > 0.7)  curOrientation = UIDeviceOrientationLandscapeRight;
											 if (accData.acceleration.x < -0.7) curOrientation = UIDeviceOrientationLandscapeLeft;
											 if (accData.acceleration.y > 0.7)  curOrientation = UIDeviceOrientationPortraitUpsideDown;
											 if (accData.acceleration.y < -0.7) curOrientation = UIDeviceOrientationPortrait;
											 
											 if (curOrientation == UIDeviceOrientationUnknown) return;
											 if (curOrientation == _currentOrientation) return;
											 
											 [self positionContainerForOrientation:curOrientation];
											 
											 
	}];
}

- (void) viewWillDisappear:(BOOL)animated {
	[_motionManager stopAccelerometerUpdates];
	
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void) pressedCancel:(id)sender {
	[_captureSession stopRunning];
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


/* Position subcontainers */

- (void) positionContainerForOrientation:(UIDeviceOrientation)orientation {
	_currentOrientation = orientation;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.25];

	switch (orientation) {
		case UIDeviceOrientationPortrait:           _interfaceContainer.transform = CGAffineTransformMakeRotation(0);            break;
		case UIDeviceOrientationPortraitUpsideDown: _interfaceContainer.transform = CGAffineTransformMakeRotation(M_PI);         break;
		case UIDeviceOrientationLandscapeLeft:      _interfaceContainer.transform = CGAffineTransformMakeRotation(1 * M_PI / 2); break;
		case UIDeviceOrientationLandscapeRight:     _interfaceContainer.transform = CGAffineTransformMakeRotation(3 * M_PI / 2); break;
		default: break;
	}
	
	if (UIDeviceOrientationIsPortrait(orientation)) {
		[self positionSubcontainersForPortrait];
	} else {
		[self positionSubcontainersForLandscape];
	}
	
	[UIView commitAnimations];
	
	
}

- (void) positionSubcontainersForPortrait {
	float leftMargin = (_screenH - _screenW) / 2;
	
	_topLContainer.frame = CGRectMake(leftMargin + (_screenW - _topLContainer.frame.size.width), 0, _topLContainer.frame.size.width, _topLContainer.frame.size.height);
}

- (void) positionSubcontainersForLandscape {
	float topMargin = (_screenH - _screenW) / 2;
	
	_topLContainer.frame = CGRectMake(_screenH - _topLContainer.frame.size.width, topMargin, _topLContainer.frame.size.width, _topLContainer.frame.size.height);
}


/* Camera settings */

- (void) configInputDeviceBasedOnSettings {
	
	[_captureSession stopRunning];
	
	if ([OptionsModel hasFrontAndBackVideo]) {
		/* Need to use option */
		BOOL preferBack = [OptionsModel preferBackCamera];

		if (preferBack) {
			_captureDevice = [OptionsModel backDevice];
		} else {
			_captureDevice = [OptionsModel frontDevice];
		}
		
	} else {
		/* No choice */
		AVCaptureDevice *dev = [OptionsModel backDevice];
		if (dev) {
			_captureDevice = dev;
		} else {
			_captureDevice = [OptionsModel frontDevice];
		}
	}
	
	EXLog(RENDER, INFO, @"captureSession is: %@", _captureSession);
	EXLog(RENDER, INFO, @"captureDevice is:  %@", _captureDevice);
	
	/* Create capture device input */
	NSError *error = nil;
	_captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&error];
	if (error || !_captureDeviceInput) {
		EXLog(RENDER, ERR, @"deviceInput error: %@", error);
	}
	
	/* Remove existing inputs */
	if ([_captureSession.inputs count]) {
		EXLog(RENDER, INFO, @"Removing existing input: %@", [_captureSession.inputs objectAtIndex:0]);
		[_captureSession removeInput:[_captureSession.inputs objectAtIndex:0]];
	}
	
	/* Now set it as the session input */
	if ([_captureSession canAddInput:_captureDeviceInput]) {
		[_captureSession addInput:_captureDeviceInput];
		EXLog(RENDER, INFO, @"Added device input: %@", _captureDeviceInput);
	} else {
		EXLog(RENDER, ERR, @"Cannot add device input");
	}

	[_captureSession startRunning];
}

#pragma mark AVCaptureFileOutputRecordingDelegate methods

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
	NSLog(@"did finish (%@)", outputFileURL);
	
	BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    } else {
		NSLog(@"ERROR: %@", error);
	}
	
	NSLog(@"recorded successfully: %d", recordedSuccessfully);
		
	[_captureSession stopRunning];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
	NSLog(@"did start");
}

- (void)               video: (NSString *) videoPath
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo {
	NSLog(@"SAVED [error: %@]", error);
}


@end
