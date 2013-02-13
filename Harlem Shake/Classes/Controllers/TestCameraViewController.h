//
//  TestCameraViewController.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestCameraViewController : UIViewController <AVCaptureFileOutputRecordingDelegate> {
	
	AVCaptureSession *_session;

	NSString *_testdir;
	NSString *_testfile;
	NSString *_testfile2;
	
	AVAssetWriter *_assetWriter;
}

@end
