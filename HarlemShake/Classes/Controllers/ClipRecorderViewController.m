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
				 
		/* Cancel */
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(150,150,100,50);
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
		[self.view addSubview:_cancelButton];
				
	}
	return self;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void) pressedCancel:(id)sender {
	[_captureSession stopRunning];
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
