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
		
		_shouldRecordBefore = before;
		
		/* Configure asset and URLs */
		_befAudioAsset  = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/part1.m4a", [[NSBundle mainBundle] resourcePath]]] options:nil];
		_aftAudioAsset  = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/part2.m4a", [[NSBundle mainBundle] resourcePath]]] options:nil];
		
		_befClipURL     = [NSURL fileURLWithPath:[[VideoModel sharedInstance] pathToClipForVideo:videoId     beforeDrop:YES]];
		_aftClipURL     = [NSURL fileURLWithPath:[[VideoModel sharedInstance] pathToClipForVideo:videoId     beforeDrop:NO]];
		_befClipTempURL = [NSURL fileURLWithPath:[[VideoModel sharedInstance] pathToClipForVideoTemp:videoId beforeDrop:YES]];
		_aftClipTempURL = [NSURL fileURLWithPath:[[VideoModel sharedInstance] pathToClipForVideoTemp:videoId beforeDrop:NO]];
		
		/* Remove temp files if they exist */
		[[NSFileManager defaultManager] removeItemAtURL:_befClipTempURL error:nil];
		[[NSFileManager defaultManager] removeItemAtURL:_aftClipTempURL error:nil];
		
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

- (void) shutdown {
	[_assetPlayer pause];
	[_recordingTimer invalidate];
	[_captureSession stopRunning];
	[OptionsModel turnOffAllTorches];
}

- (void) pressedCancel:(id)sender {
	[self shutdown];
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
	_recordButton.userInteractionEnabled = NO;
	[_motionManager stopAccelerometerUpdates];
	
	/* Hide the camera controls! */
	[UIView beginAnimations:nil context:NULL];
	_topRContainer.alpha = 0;
	_topRContainer.userInteractionEnabled = NO;
	[UIView commitAnimations];
	
	
	if ([OptionsModel timerDelay]) {
		[_recordingTimer invalidate];
		_timerCountdown = [OptionsModel timerDelay];
		_recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(recordingTimerHandler:) userInfo:nil repeats:YES];
		[_recordingTimer fire];
	} else {
		[self startRecording];
	}
	

}

- (void) recordingTimerHandler:(NSTimer*)timer {
	if (_timerCountdown <= 0) {
		[self startRecording];
		[_recordingTimer invalidate];
		_recordingTimer = nil;
		return;
	}
	
	[_recordButton setTitle:[NSString stringWithFormat:@"Timer: %d second%@", _timerCountdown, (_timerCountdown == 1) ? @"" : @"s"] forState:UIControlStateNormal];
	if (_timerCountdown <= 3 && [OptionsModel flashBlink]) {
		[self blinkFlash];
	}
	
	_timerCountdown--;
}

- (void) startRecording {
	
	/* Select assets */
	AVURLAsset *audioAsset = _shouldRecordBefore ? _befAudioAsset : _aftAudioAsset;
	NSURL *destTempURL = _shouldRecordBefore ? _befClipTempURL : _aftClipTempURL;
	//NSURL *destURL     = _shouldRecordBefore ? _befClipURL : _aftClipURL;
	
	/* Setup movie output */
	_movieOutput = [[AVCaptureMovieFileOutput alloc] init];
	_movieOutput.maxRecordedDuration = audioAsset.duration;

	/* Remove existing outputs */
	if ([_captureSession.outputs count]) {
		EXLog(RENDER, INFO, @"Removing existing output: %@", [_captureSession.outputs objectAtIndex:0]);
		[_captureSession removeOutput:[_captureSession.outputs objectAtIndex:0]];
	}
	
	/* Attach movie output to session */
	if ([_captureSession canAddOutput:_movieOutput]) {
		[_captureSession addOutput:_movieOutput];
	}
	
	/* Set orientation */
	if ([_movieOutput.connections count]) {
		AVCaptureConnection *conn = [_movieOutput.connections objectAtIndex:0];
		if (_currentOrientation == UIDeviceOrientationPortrait)           conn.videoOrientation = AVCaptureVideoOrientationPortrait;
		if (_currentOrientation == UIDeviceOrientationPortraitUpsideDown) conn.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
		if (_currentOrientation == UIDeviceOrientationLandscapeLeft)      conn.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
		if (_currentOrientation == UIDeviceOrientationLandscapeRight)     conn.videoOrientation = AVCaptureVideoOrientationLandscapeRight;		
	}

	/* Play audio? */
	if ([OptionsModel playSong]) {
		[_assetPlayer pause];
		AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:audioAsset];
		_assetPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
		[_assetPlayer play];
	}
	
	/* Start movie output */
	[_movieOutput startRecordingToOutputFileURL:destTempURL recordingDelegate:self];
}

- (void) blinkFlash {
	if (!_captureDevice.hasTorch) return;
	int curOn = _captureDevice.torchActive;
	[OptionsModel turnFlashOn:!curOn forDevice:_captureDevice];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[OptionsModel turnFlashOn:curOn forDevice:_captureDevice];
	});
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
	EXLog(RENDER, INFO, @"did finish (%@)", outputFileURL);
	
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
	
	if (!recordedSuccessfully) {
		[[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Video not recorded! Error: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		[self pressedCancel:nil];
	} else {
		/* Move the file */
		if (_shouldRecordBefore) {
			[[NSFileManager defaultManager] removeItemAtURL:_befClipURL error:nil];
			[[NSFileManager defaultManager] moveItemAtURL:_befClipTempURL toURL:_befClipURL error:nil];
			[[VideoModel sharedInstance] deleteScreenshotForVideo:_videoId beforeDrop:YES];
		} else {
			[[NSFileManager defaultManager] removeItemAtURL:_aftClipURL error:nil];
			[[NSFileManager defaultManager] moveItemAtURL:_aftClipTempURL toURL:_aftClipURL error:nil];
			[[VideoModel sharedInstance] deleteScreenshotForVideo:_videoId beforeDrop:NO];
		}
		
		/* We also need to remove the fully encoded movie if it was there */
		[[NSFileManager defaultManager] removeItemAtPath:[[VideoModel sharedInstance] pathToFullVideo:_videoId] error:nil];
		
		/* Record the next piece? */
		if ([OptionsModel recordBoth]) {
			
		} else {
			/* Otherwise we're done! */
			[self pressedCancel:nil];
		}
	}
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
	EXLog(RENDER, INFO, @"did start");
}



@end
