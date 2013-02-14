//
//  ClipRecorderViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "ClipRecorderViewController.h"

@implementation ClipRecorderViewController

- (id) initWithVideo:(VideoID_t)videoId before:(BOOL)before; {
	if ((self = [super init])) {
		
		self.videoId = videoId;
		self.openedForBeforeClip = before;
		
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
		
		_topRContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)];
		_topRContainer.backgroundColor = [UIColor clearColor];
		[_interfaceContainer addSubview:_topRContainer];
		
		/* Set interface to portrait */
		[self positionSubcontainersForPortrait];
		_currentOrientation = UIDeviceOrientationPortrait;
		
		/* Cancel */
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(50,30,100,40);
		_cancelButton.backgroundColor = [UIColor whiteColor];
		[_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
		[_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[_cancelButton addTarget:self action:@selector(pressedCancel:) forControlEvents:UIControlEventTouchUpInside];
		_cancelButton.tintColor = [UIColor whiteColor];
		_cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
		_cancelButton.layer.cornerRadius = 16;
		_cancelButton.layer.borderWidth = 4;
		_cancelButton.layer.borderColor	= [UIColor blackColor].CGColor;
		_cancelButton.alpha = 0.65;
		[[ButtonEffectsExpander sharedInstance] attachToControl:_cancelButton];
		[_topLContainer addSubview:_cancelButton];
				
		/* Camera controls */
		_camLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 10, 130, 20)];
		_camLabel.text = @"Camera";
		_camLabel.textAlignment = NSTextAlignmentLeft;
		_camLabel.textColor = [UIColor lightGrayColor];
		_camLabel.font = [UIFont boldSystemFontOfSize:12];
		_camLabel.backgroundColor = [UIColor clearColor];
		
		_cameraChooser = [[UISegmentedControl alloc] initWithItems:@[@"Front", @"Back"]];
		_cameraChooser.segmentedControlStyle = UISegmentedControlStyleBar;
		_cameraChooser.tintColor = [UIColor lightGrayColor];
		_cameraChooser.frame = CGRectMake(10, 30, 130, 40);
		_cameraChooser.layer.borderColor = [UIColor blackColor].CGColor;
		_cameraChooser.layer.borderWidth = 4;
		_cameraChooser.layer.cornerRadius = 16;
		_cameraChooser.layer.masksToBounds = YES;
		_cameraChooser.alpha = 0.65;
		_cameraChooser.selectedSegmentIndex = [OptionsModel preferBackCamera] ? 1 : 0;
		[_cameraChooser setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]} forState:UIControlStateNormal];
		[_cameraChooser addTarget:self action:@selector(toggledCamera:) forControlEvents:UIControlEventValueChanged];
		
		if ([OptionsModel hasFrontAndBackVideo]) {
			[_topRContainer addSubview:_camLabel];
			[_topRContainer addSubview:_cameraChooser];
			_flashY = 80;
		} else {
			_flashY = 10;
		}
		
		_flashLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, _flashY, 130, 20)];
		_flashLabel.text = @"Flash";
		_flashLabel.textAlignment = NSTextAlignmentLeft;
		_flashLabel.textColor = [UIColor lightGrayColor];
		_flashLabel.font = [UIFont boldSystemFontOfSize:12];
		_flashLabel.backgroundColor = [UIColor clearColor];
		
		_flashChooser = [[UISegmentedControl alloc] initWithItems:@[@"Off", @"On"]];
		_flashChooser.segmentedControlStyle = UISegmentedControlStyleBar;
		_flashChooser.tintColor = [UIColor lightGrayColor];
		_flashChooser.frame = CGRectMake(10, _flashY + 20, 130, 40);
		_flashChooser.layer.borderColor = [UIColor blackColor].CGColor;
		_flashChooser.layer.borderWidth = 4;
		_flashChooser.layer.cornerRadius = 16;
		_flashChooser.layer.masksToBounds = YES;
		_flashChooser.alpha = 0.65;
		_flashChooser.selectedSegmentIndex = [OptionsModel flashOn] ? 1 : 0;
		[_flashChooser setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor blackColor]} forState:UIControlStateNormal];
		[_flashChooser addTarget:self action:@selector(toggledFlash:) forControlEvents:UIControlEventValueChanged];
		[_topRContainer addSubview:_flashChooser];
		[_topRContainer addSubview:_flashLabel];
		
		
		/* Main info stuff */
		_recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_recordButton.frame = CGRectMake(50,30,250,50);
		_recordButton.center = CGPointMake(_interfaceContainer.frame.size.width/2, _interfaceContainer.frame.size.height/2 + 40);
		_recordButton.backgroundColor = [UIColor redColor];
		[_recordButton setTitle:@"Tap Here To Begin Recording!" forState:UIControlStateNormal];
		[_recordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_recordButton addTarget:self action:@selector(pressedRecord:) forControlEvents:UIControlEventTouchUpInside];
		_recordButton.tintColor = [UIColor whiteColor];
		_recordButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
		_recordButton.layer.cornerRadius = 16;
		_recordButton.layer.borderWidth = 4;
		_recordButton.layer.borderColor	= [UIColor whiteColor].CGColor;
		_recordButton.alpha = 0.65;
		[[ButtonEffectsExpander sharedInstance] attachToControl:_recordButton];
		[_interfaceContainer addSubview:_recordButton];
		
		
		_timerSetupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		_timerSetupLabel.center = CGPointMake(_recordButton.center.x, _recordButton.center.y + 35);
		_timerSetupLabel.textColor = [UIColor whiteColor];
		_timerSetupLabel.font = [UIFont boldSystemFontOfSize:12];
		_timerSetupLabel.backgroundColor = [UIColor clearColor];
		_timerSetupLabel.alpha = 0.65;
		_timerSetupLabel.textAlignment = NSTextAlignmentCenter;
		if ([OptionsModel timerDelay]) {
			_timerSetupLabel.text = [NSString stringWithFormat:@"Recording timer set to %d seconds", [OptionsModel timerDelay]];
		} else {
			_timerSetupLabel.text = @"Recording will begin immediately (no timer)";
		}
		[_interfaceContainer addSubview:_timerSetupLabel];
		
		_contRecordLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		_contRecordLabel.center = CGPointMake(_timerSetupLabel.center.x, _timerSetupLabel.center.y + 20);
		_contRecordLabel.textColor = [UIColor whiteColor];
		_contRecordLabel.font = [UIFont boldSystemFontOfSize:12];
		_contRecordLabel.backgroundColor = [UIColor clearColor];
		_contRecordLabel.alpha = 0.65;
		_contRecordLabel.textAlignment = NSTextAlignmentCenter;
		if (!_openedForBeforeClip) {
			_contRecordLabel.text = @"Recording the \"After Drop\" clip only";
		} else {
			if ([OptionsModel recordBoth]) {
				_contRecordLabel.text = [NSString stringWithFormat:@"Also recording the \"After Drop\" clip after %d seconds", [OptionsModel recordBoth]];
			} else {
				_contRecordLabel.text = @"Recording the \"Before Drop\" clip only";
			}
		}
		[_interfaceContainer addSubview:_contRecordLabel];
		
		_audioOverlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		_audioOverlayLabel.center = CGPointMake(_contRecordLabel.center.x, _contRecordLabel.center.y + 20);
		_audioOverlayLabel.textColor = [UIColor whiteColor];
		_audioOverlayLabel.font = [UIFont boldSystemFontOfSize:12];
		_audioOverlayLabel.backgroundColor = [UIColor clearColor];
		_audioOverlayLabel.alpha = 0.65;
		_audioOverlayLabel.textAlignment = NSTextAlignmentCenter;
		_audioOverlayLabel.text = [NSString stringWithFormat:@"The app will%@ play the corresponding audio clip", [OptionsModel playSong] ? @"" : @" NOT"];
		[_interfaceContainer addSubview:_audioOverlayLabel];
		
		_flashPulseLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
		_flashPulseLabel.center = CGPointMake(_audioOverlayLabel.center.x, _audioOverlayLabel.center.y + 20);
		_flashPulseLabel.textColor = [UIColor whiteColor];
		_flashPulseLabel.font = [UIFont boldSystemFontOfSize:12];
		_flashPulseLabel.backgroundColor = [UIColor clearColor];
		_flashPulseLabel.alpha = 0.65;
		_flashPulseLabel.textAlignment = NSTextAlignmentCenter;
		_flashPulseLabel.text = [NSString stringWithFormat:@"Flash will%@ blink for last three seconds", [OptionsModel flashBlink] ? @"" : @" NOT"];
		_shouldBlink = [OptionsModel timerDelay] || ([OptionsModel recordBoth] && _openedForBeforeClip);
		if (!_shouldBlink) _flashPulseLabel.hidden = YES;
		[_interfaceContainer addSubview:_flashPulseLabel];
		
		
		/* Set the device for input into capture session */
		[self configInputDeviceBasedOnSettings];
		
		[_captureSession startRunning];
		
		/* Motion */
		_motionManager = [[CMMotionManager alloc] init];
		_motionManager.accelerometerUpdateInterval = 0.5;
	}
	return self;
}

- (void) enableAccellerometer {
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

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	
	[self enableAccellerometer];
}

- (void) viewWillDisappear:(BOOL)animated {
	[_motionManager stopAccelerometerUpdates];
	
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void) pressedCancel:(id)sender {
	[_captureSession stopRunning];
	[OptionsModel turnOffAllTorches];
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) toggledCamera:(id)sender {
	[OptionsModel setPreferBackCamera:(_cameraChooser.selectedSegmentIndex == 1) ? YES : NO];
	[self configInputDeviceBasedOnSettings];
}

- (void) toggledFlash:(id)sender {
	[OptionsModel setFlashOn:(_flashChooser.selectedSegmentIndex == 1) ? YES : NO];
	[self configInputDeviceBasedOnSettings];
}

- (void) pressedRecord:(id)sender {
	
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
	_topRContainer.frame = CGRectMake(leftMargin, 0, _topRContainer.frame.size.width, _topRContainer.frame.size.height);
}

- (void) positionSubcontainersForLandscape {
	float topMargin = (_screenH - _screenW) / 2;
	
	_topLContainer.frame = CGRectMake(_screenH - _topLContainer.frame.size.width, topMargin, _topLContainer.frame.size.width, _topLContainer.frame.size.height);
	_topRContainer.frame = CGRectMake(0, topMargin, _topRContainer.frame.size.width, _topRContainer.frame.size.height);
}


/* Camera settings */

- (void) configInputDeviceBasedOnSettings {
	
	[OptionsModel turnOffAllTorches];
	
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
	
	if ([OptionsModel flashOn]) {
		[OptionsModel turnFlashOn:YES forDevice:_captureDevice];
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
	
	/* Update UI */
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	if (_captureDevice.hasTorch) {
		_flashLabel.alpha = 1;
		_flashChooser.alpha = 0.65;
		_flashPulseLabel.alpha = 0.65;
		_flashChooser.userInteractionEnabled = YES;
	} else {
		_flashLabel.alpha = 0;
		_flashChooser.alpha = 0;
		_flashPulseLabel.alpha = 0;
		_flashChooser.userInteractionEnabled = NO;
	}
	[UIView commitAnimations];
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
