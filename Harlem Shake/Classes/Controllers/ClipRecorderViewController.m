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
		self.view.backgroundColor = [UIColor yellowColor];
		
		/* Create capture session */
		_captureSession = [[AVCaptureSession alloc] init];
		switch ([OptionsModel desiredQuality]) {
			case QUAL_LOW:  _captureSession.sessionPreset = AVCaptureSessionPresetLow;    break;
			case QUAL_MED:  _captureSession.sessionPreset = AVCaptureSessionPresetMedium; break;
			case QUAL_HIGH: _captureSession.sessionPreset = AVCaptureSessionPresetHigh;   break;
		}
		
		/* Add viewing layer */
		AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
		captureVideoPreviewLayer.frame = self.view.frame;
		//[self.view.layer addSublayer:captureVideoPreviewLayer];
		
		/* Set the device for input into capture session */
		//[self configInputDeviceBasedOnSettings];
		
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
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


/* Camera settings */

- (void) configInputDeviceBasedOnSettings {
	
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
	
	/* Create capture device input */
	_captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:nil];
	
	/* Remove existing inputs */
	if ([_captureSession.inputs count]) {
		[_captureSession removeInput:[_captureSession.inputs objectAtIndex:0]];
	}
	
	/* Now set it as the session input */
	[_captureSession addInput:_captureDeviceInput];
}

@end
