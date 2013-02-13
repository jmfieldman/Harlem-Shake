//
//  TestCameraViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "TestCameraViewController.h"

@implementation TestCameraViewController

- (id) init {
	if ((self = [super init])) {
		
		self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
		self.view.backgroundColor = [UIColor yellowColor];
				
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		_testdir = [NSString stringWithFormat:@"%@/test", [paths objectAtIndex:0]];
		_testfile = [NSString stringWithFormat:@"%@/test.mp4", _testdir];
		_testfile2 = [NSString stringWithFormat:@"%@/test2.mp4", _testdir];
		_testfile3 = [NSString stringWithFormat:@"%@/test3.mp4", _testdir];
		//[[NSFileManager defaultManager] removeItemAtPath:_testdir error:nil];
		[[NSFileManager defaultManager] createDirectoryAtPath:_testdir withIntermediateDirectories:YES attributes:nil error:nil];
		
		UIButton *t = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[t setTitle:@"test" forState:UIControlStateNormal];
		[t addTarget:self action:@selector(pressedTest:) forControlEvents:UIControlEventTouchUpInside];
		t.frame = CGRectMake(50,50,50,50);
		[self.view addSubview:t];
		
		UIButton *t2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[t2 setTitle:@"test2" forState:UIControlStateNormal];
		[t2 addTarget:self action:@selector(pressedTest2:) forControlEvents:UIControlEventTouchUpInside];
		t2.frame = CGRectMake(125,50,50,50);
		[self.view addSubview:t2];
		
		UIButton *t3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[t3 setTitle:@"comb" forState:UIControlStateNormal];
		[t3 addTarget:self action:@selector(pressedTest3:) forControlEvents:UIControlEventTouchUpInside];
		t3.frame = CGRectMake(200,50,50,50);
		[self.view addSubview:t3];
		
	}
	return self;
}

- (void) pressedTest:(id)sender {
	
	_session = [[AVCaptureSession alloc] init];
	_session.sessionPreset = AVCaptureSessionPresetHigh;
	
	// audio that goes along with it
	NSString *audioPath = [NSString stringWithFormat:@"%@/part1.m4a", [[NSBundle mainBundle] resourcePath]];
	NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
	AVURLAsset *audioasset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
	
	//remove file
	[[NSFileManager defaultManager] removeItemAtPath:_testfile error:nil];
	
	NSArray *devices = [AVCaptureDevice devices];
	
	NSLog(@"test output");
	
	AVCaptureDevice *devToUse = nil;
	
	for (AVCaptureDevice *device in devices) {
		
		NSLog(@"Device name: %@", [device localizedName]);
		
		if ([device hasMediaType:AVMediaTypeVideo]) {
			
			if ([device position] == AVCaptureDevicePositionBack) {
				NSLog(@"> Device position : back");
				devToUse = device;
			}
			else {
				NSLog(@"> Device position : front");
			}
		}
	}
	
	// Device
	
	NSError *error;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:devToUse error:&error];
	if (!input) {
		NSLog(@"device error: %@", error);
	}
	
	// Add
	
	if ([_session canAddInput:input]) {
		[_session addInput:input];
	}
	else {
		NSLog(@"error: can't add device as input");
	}
	
	
	// Create output
	
	AVCaptureMovieFileOutput *movieOutput = [[AVCaptureMovieFileOutput alloc] init];
	movieOutput.maxRecordedDuration = audioasset.duration;
	
	// Attach
	
	if ([_session canAddOutput:movieOutput]) {
		[_session addOutput:movieOutput];
	}
	else {
		NSLog(@"error: can't add movie output");
	}
	
	// orientation ?
	
	NSLog(@"num connections: %d", [movieOutput.connections count]);
	AVCaptureConnection *conn = [movieOutput.connections objectAtIndex:0];
	conn.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
	
	// Add video layer
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
	captureVideoPreviewLayer.frame = CGRectMake(100, 150, 100, 100);
	[self.view.layer addSublayer:captureVideoPreviewLayer];
	
	// Audio ambiance
	
	_ambiancePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
	[_ambiancePlayer play];
	
	// Start the capture session
	
	[_session startRunning];
	
	// start recording
		
	NSURL *fileURL = [NSURL fileURLWithPath:_testfile];
	NSLog(@"strings: %@ <%@>", _testfile, fileURL);
	[movieOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
	
	
	
	
	
}


- (void) pressedTest2:(id)sender {
	
	_session = [[AVCaptureSession alloc] init];
	_session.sessionPreset = AVCaptureSessionPresetHigh;
	
	// audio that goes along with it
	NSString *audioPath = [NSString stringWithFormat:@"%@/part2.m4a", [[NSBundle mainBundle] resourcePath]];
	NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
	AVURLAsset *audioasset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
	
	//remove file
	[[NSFileManager defaultManager] removeItemAtPath:_testfile2 error:nil];
	
	NSArray *devices = [AVCaptureDevice devices];
	
	NSLog(@"test output");
	
	AVCaptureDevice *devToUse = nil;
	
	for (AVCaptureDevice *device in devices) {
		
		NSLog(@"Device name: %@", [device localizedName]);
		
		if ([device hasMediaType:AVMediaTypeVideo]) {
			
			if ([device position] == AVCaptureDevicePositionBack) {
				NSLog(@"> Device position : back");
				devToUse = device;
			}
			else {
				NSLog(@"> Device position : front");
			}
		}
	}
	
	// Device
	
	NSError *error;
	AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:devToUse error:&error];
	if (!input) {
		NSLog(@"device error: %@", error);
	}
	
	// Add
	
	if ([_session canAddInput:input]) {
		[_session addInput:input];
	}
	else {
		NSLog(@"error: can't add device as input");
	}
	
	
	// Create output
	
	AVCaptureMovieFileOutput *movieOutput = [[AVCaptureMovieFileOutput alloc] init];
	movieOutput.maxRecordedDuration = audioasset.duration;
	
	// Attach
	
	if ([_session canAddOutput:movieOutput]) {
		[_session addOutput:movieOutput];
	}
	else {
		NSLog(@"error: can't add movie output");
	}
	
	// orientation ?
	
	NSLog(@"num connections: %d", [movieOutput.connections count]);
	AVCaptureConnection *conn = [movieOutput.connections objectAtIndex:0];
	conn.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
	
	// Add video layer
	AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
	captureVideoPreviewLayer.frame = CGRectMake(100, 150, 100, 100);
	[self.view.layer addSublayer:captureVideoPreviewLayer];
	
	// Audio ambiance
	
	_ambiancePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioUrl error:nil];
	[_ambiancePlayer play];
	
	// Start the capture session
	
	[_session startRunning];
	
	// start recording
	
	NSURL *fileURL = [NSURL fileURLWithPath:_testfile2];
	NSLog(@"strings: %@ <%@>", _testfile2, fileURL);
	[movieOutput startRecordingToOutputFileURL:fileURL recordingDelegate:self];
	
	
	
	
	
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
	NSLog(@"did finish");
	
	BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }
	
	NSLog(@"recorded successfully: %d", recordedSuccessfully);
	
	if (recordedSuccessfully) {
		
		UISaveVideoAtPathToSavedPhotosAlbum([outputFileURL relativePath], self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
	}
	
	[_session stopRunning];
	[_ambiancePlayer stop];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections {
	NSLog(@"did start");
}

- (void)               video: (NSString *) videoPath
    didFinishSavingWithError: (NSError *) error
                 contextInfo: (void *) contextInfo {
	NSLog(@"SAVED [error: %@]", error);
}




- (void) pressedTest3:(id)sender {
	NSLog(@"Starting to put together all the files!");
	
	AVMutableComposition *mixComposition = [AVMutableComposition composition];
	
	NSString *audioPath = [NSString stringWithFormat:@"%@/part1.m4a", [[NSBundle mainBundle] resourcePath]];
	NSURL *audioUrl = [NSURL fileURLWithPath:audioPath];
	AVURLAsset *audioasset = [[AVURLAsset alloc] initWithURL:audioUrl options:nil];
	
	NSString *audioPath2 = [NSString stringWithFormat:@"%@/part2.m4a", [[NSBundle mainBundle] resourcePath]];
	NSURL *audioUrl2 = [NSURL fileURLWithPath:audioPath2];
	AVURLAsset *audioasset2 = [[AVURLAsset alloc] initWithURL:audioUrl2 options:nil];
	
	NSString *videoPath = _testfile;
	NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];
	AVURLAsset *videoasset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
	
	NSString *videoPath2 = _testfile2;
	NSURL *videoUrl2 = [NSURL fileURLWithPath:videoPath2];
	AVURLAsset *videoasset2 = [[AVURLAsset alloc] initWithURL:videoUrl2 options:nil];
	
	NSString *moviepath = _testfile3;
	NSURL *movieUrl = [NSURL fileURLWithPath:moviepath];
	
	if([[NSFileManager defaultManager] fileExistsAtPath:moviepath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:moviepath error:nil];
	}
	
	NSLog(@"vid dur: %lf %d %d %lld", (double)videoasset.duration.value, videoasset.duration.timescale, videoasset.duration.flags, videoasset.duration.epoch);
	
	NSError *error;
	CMTime nextClipStartTime = kCMTimeZero;
	AVMutableCompositionTrack *compositionTrackB = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVAssetTrack *clipVideoTrackB = [[videoasset tracksWithMediaType:AVMediaTypeVideo] lastObject];
	[compositionTrackB insertTimeRange:CMTimeRangeMake(      kCMTimeZero, videoasset.duration)  ofTrack:clipVideoTrackB atTime:kCMTimeZero error:&error];
	if (error) { NSLog(@"ERRORA: %@", error); }
	
	nextClipStartTime = CMTimeAdd(nextClipStartTime, videoasset.duration);
	
	//AVMutableCompositionTrack *compositionTrackB2 = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVAssetTrack *clipVideoTrackB2 = [[videoasset2 tracksWithMediaType:AVMediaTypeVideo] lastObject];
	[compositionTrackB insertTimeRange:CMTimeRangeMake(      kCMTimeZero, videoasset2.duration)  ofTrack:clipVideoTrackB2 atTime:nextClipStartTime error:&error];
	if (error) { NSLog(@"ERRORB: %@", error); }
	
	AVMutableCompositionTrack *compositionTrackA = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	AVAssetTrack *clipAudioTrackA = [[audioasset tracksWithMediaType:AVMediaTypeAudio] lastObject];
	[compositionTrackA insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioasset.duration)  ofTrack:clipAudioTrackA atTime:kCMTimeZero error:nil];
	
	AVMutableCompositionTrack *compositionTrackA2 = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	AVAssetTrack *clipAudioTrackA2 = [[audioasset2 tracksWithMediaType:AVMediaTypeAudio] lastObject];
	[compositionTrackA2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioasset2.duration)  ofTrack:clipAudioTrackA2 atTime:audioasset.duration error:nil];
	
	
	AVAssetExportSession *exporter =[[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
	//AVAssetExportSession *exporter =[AVAssetExportSession exportSessionWithAsset:mixComposition presetName:AVAssetExportPresetLowQuality];
	NSParameterAssert(exporter!=nil);
	exporter.outputFileType=AVFileTypeMPEG4;
	exporter.outputURL=movieUrl;
	//CMTime start=CMTimeMake(0, 600);
	//CMTime duration=CMTimeMake(600, 600);
	//CMTimeRange range=CMTimeRangeMake(start, duration);
	//exporter.timeRange=range;
	
	//AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
	//float seconds = CMTimeGetSeconds(videoasset.duration);
	//mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(seconds * 2, 30));
	
	
	//AVMutableVideoComposition *mainComposition = [AVMutableVideoComposition   videoComposition];
	//mainComposition.instructions = [NSArray arrayWithObjects:mainInstruction,nil];
	//mainComposition.frameDuration = CMTimeMake(1, 30);
	//mainComposition.renderSize = CGSizeMake(640, 480);
	
	//exporter.videoComposition = mainComposition;
	
	//exporter.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(6, 30));
	
	[exporter exportAsynchronouslyWithCompletionHandler:^{
		switch ([exporter status]) {
			case AVAssetExportSessionStatusFailed:
				NSLog(@"Export failed: %@", [[exporter error] localizedDescription]);
				break;
			case AVAssetExportSessionStatusCancelled:
				NSLog(@"Export canceled");
				break;
			default:
				NSLog(@"Export done");
				UISaveVideoAtPathToSavedPhotosAlbum(_testfile3, self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
				UILabel *done = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, 50, 50)];
				done.text = @"done!";
				[self.view addSubview:done];
				break;
		}
	}];
}



- (void) pressedTest4:(id)sender {

	_assetWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:_testfile2] fileType:AVFileTypeMPEG4 error:nil];
	if (!_assetWriter) {
		NSLog(@"assetwriter creation error");
	}
	
	// Create video input
	
	NSDictionary* compression =
		@{
			AVVideoAverageBitRateKey:[NSNumber numberWithInt:960000],
			AVVideoMaxKeyFrameIntervalKey:[NSNumber numberWithInt:1]
		};
	AVAssetWriterInput *vidInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{
																	  AVVideoCodecKey:AVVideoCodecH264,
													  AVVideoCompressionPropertiesKey:compression,
																	  AVVideoWidthKey:[NSNumber numberWithInt:480], // required
																	 AVVideoHeightKey:[NSNumber numberWithInt:320] // required
									 }];
	
	[_assetWriter addInput:vidInput];
	
	// Create audio input
	
	
	
}


@end
