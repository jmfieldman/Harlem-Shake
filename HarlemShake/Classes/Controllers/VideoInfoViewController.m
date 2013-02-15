//
//  VideoInfoViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "VideoInfoViewController.h"
#import "TextEditViewController.h"
#import "RecordingOptionsViewController.h"
#import "ClipRecorderViewController.h"

#import "UITableViewCellEx.h"
#import "ClipControlTableViewCell.h"

#define kCellTag_Title            1
#define kCellTag_Description      2
#define kCellTag_RecordingOptions 3
#define kCellTag_EncodeVideo      4
#define kCellTag_Watch            5
#define kCellTag_Share            6


@implementation VideoInfoViewController


- (id) init {
	if ((self = [super init])) {
		
		/* View title */
		self.title = @"Video Info";
		
		/* Initialize the main view */
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
		self.view.backgroundColor = [UIColor clearColor];
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		
		/* Initialize the table */
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100) style:UITableViewStyleGrouped];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.scrollEnabled = NO;
		[self.view addSubview:_tableView];
		
	}
	return self;
}


- (void) viewWillAppear:(BOOL)animated {
	if (!_videoId) return;
	[self initializeTableCells];
	[_tableView reloadData];
}


- (void) initializeTableCells {
	
	_tableCells = [NSMutableArray array];
	
	/* Basic settings */
	
	{
		NSMutableArray *currentSection = [NSMutableArray array];
		
		{
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Title";
			cell.detailTextLabel.text = [[[VideoModel sharedInstance] videoDic:_videoId] objectForKey:@"title"];
			if (![cell.detailTextLabel.text length]) cell.detailTextLabel.text = @"Untitled";
			cell.tag = kCellTag_Title;
			cell.shouldHighlight = YES;
			[currentSection addObject:cell];
		}
		
		{
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Description";
			cell.detailTextLabel.text = [[[VideoModel sharedInstance] videoDic:_videoId] objectForKey:@"description"];
			if (![cell.detailTextLabel.text length]) cell.detailTextLabel.text = @"None";
			cell.tag = kCellTag_Description;
			cell.shouldHighlight = YES;
			[currentSection addObject:cell];
		}
		
		{
			UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.textLabel.text = @"Recording Options";
			cell.tag = kCellTag_RecordingOptions;
			cell.shouldHighlight = YES;
			[currentSection addObject:cell];
		}
			
		[_tableCells addObject:currentSection];
	}
	
	/* Clip info */
	
	{
		NSMutableArray *currentSection = [NSMutableArray array];
		
		{
			ClipControlTableViewCell *cell = [[ClipControlTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
			cell.videoId = _videoId;
			cell.shouldHighlight = NO;
			cell.controlDelegate = self;
			[currentSection addObject:cell];
		}
				
		[_tableCells addObject:currentSection];
	}
	
	/* Dealing with the final video */
	
	{
		NSMutableArray *currentSection = [NSMutableArray array];
	
		if (_forceExistanceOfVideo || [[VideoModel sharedInstance] fullVideoExistsForVideo:_videoId]) {
			_forceExistanceOfVideo = NO;
			
			/* This is what happens if the full video is already encoded! */
			
			{
				UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = @"Watch Full Version";
				cell.tag = kCellTag_Watch;
				cell.shouldHighlight = YES;
				[currentSection addObject:cell];
			}

			{
				UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = @"Share!";
				cell.tag = kCellTag_Share;
				cell.shouldHighlight = YES;
				[currentSection addObject:cell];
			}

			
		} else {
			
			/* Video is not encoded. Can we encode yet? */
			
			if ([[VideoModel sharedInstance] clipExistsforVideo:_videoId beforeDrop:YES] && [[VideoModel sharedInstance] clipExistsforVideo:_videoId beforeDrop:NO]) {
				
				/* Both clips exist, so we can encode it */
				UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = @"Encode Video!";
				cell.tag = kCellTag_EncodeVideo;
				cell.shouldHighlight = YES;
				[currentSection addObject:cell];
				
			} else {
				
				/* Nope, a clip is missing */
				UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
				cell.sectionFooterText = @"Cannot encode the video until both \"Before Drop\" and \"After Drop\" clips have been recorded.";
				[currentSection addObject:cell];
				
			}
			
		}
		
		[_tableCells addObject:currentSection];
	}
	
}


- (void) setVideoId:(VideoID_t)videoId {
	_videoId = videoId;
}

#pragma mark Encoding

- (void) encodeMovie {
	EXLog(RENDER, INFO, @"Starting to encode");
	
	AVMutableComposition *mixComposition = [AVMutableComposition composition];
	
	/* Get assets */
	
	NSString *audioPath1 = [NSString stringWithFormat:@"%@/part1.m4a", [[NSBundle mainBundle] resourcePath]];
	NSURL *audioUrl1 = [NSURL fileURLWithPath:audioPath1];
	AVURLAsset *audioasset1 = [[AVURLAsset alloc] initWithURL:audioUrl1 options:nil];
	
	NSString *audioPath2 = [NSString stringWithFormat:@"%@/part2.m4a", [[NSBundle mainBundle] resourcePath]];
	NSURL *audioUrl2 = [NSURL fileURLWithPath:audioPath2];
	AVURLAsset *audioasset2 = [[AVURLAsset alloc] initWithURL:audioUrl2 options:nil];
	
	NSString *videoPath1 = [[VideoModel sharedInstance] pathToClipForVideo:_videoId beforeDrop:YES];
	NSURL *videoUrl1 = [NSURL fileURLWithPath:videoPath1];
	AVURLAsset *videoasset1 = [[AVURLAsset alloc] initWithURL:videoUrl1 options:nil];
	
	NSString *videoPath2 = [[VideoModel sharedInstance] pathToClipForVideo:_videoId beforeDrop:NO];
	NSURL *videoUrl2 = [NSURL fileURLWithPath:videoPath2];
	AVURLAsset *videoasset2 = [[AVURLAsset alloc] initWithURL:videoUrl2 options:nil];
	
	/* Output path */
	
	NSString *outputPath = [[VideoModel sharedInstance] pathToFullVideoTemp:_videoId];
	NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
	}

	/* Create composition */
	
	NSError *error;
	CMTime nextClipStartTime = kCMTimeZero;
	
	AVMutableCompositionTrack *compositionTrackB = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
	AVAssetTrack *clipVideoTrackB = [[videoasset1 tracksWithMediaType:AVMediaTypeVideo] lastObject];
	[compositionTrackB insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoasset1.duration)  ofTrack:clipVideoTrackB atTime:kCMTimeZero error:&error];
	if (error) { NSLog(@"ERRORA: %@", error); }
	
	nextClipStartTime = CMTimeAdd(nextClipStartTime, videoasset1.duration);
	
	AVAssetTrack *clipVideoTrackB2 = [[videoasset2 tracksWithMediaType:AVMediaTypeVideo] lastObject];
	[compositionTrackB insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoasset2.duration)  ofTrack:clipVideoTrackB2 atTime:nextClipStartTime error:&error];
	if (error) { NSLog(@"ERRORB: %@", error); }
	
	AVMutableCompositionTrack *compositionTrackA = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	AVAssetTrack *clipAudioTrackA = [[audioasset1 tracksWithMediaType:AVMediaTypeAudio] lastObject];
	[compositionTrackA insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioasset1.duration)  ofTrack:clipAudioTrackA atTime:kCMTimeZero error:nil];
	
	AVMutableCompositionTrack *compositionTrackA2 = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
	AVAssetTrack *clipAudioTrackA2 = [[audioasset2 tracksWithMediaType:AVMediaTypeAudio] lastObject];
	[compositionTrackA2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioasset2.duration)  ofTrack:clipAudioTrackA2 atTime:audioasset1.duration error:nil];
	
	/* Export session */
	
	_exportSession =[[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
	_exportSession.outputFileType = AVFileTypeMPEG4;
	_exportSession.outputURL = outputURL;
	
	/* Begin */
	
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	[_exportSession exportAsynchronouslyWithCompletionHandler:^{
		
		switch ([_exportSession status]) {
			case AVAssetExportSessionStatusFailed:
				EXLog(RENDER, ERR, @"Export failed: %@", [[_exportSession error] localizedDescription]);
				break;
			case AVAssetExportSessionStatusCancelled:
				EXLog(RENDER, ERR, @"Export canceled");
				break;
			case AVAssetExportSessionStatusCompleted:
				EXLog(RENDER, INFO, @"Export done");
				
				/* Move the file over */
				[[NSFileManager defaultManager] removeItemAtPath:[[VideoModel sharedInstance] pathToFullVideo:_videoId] error:nil];
				[[NSFileManager defaultManager] moveItemAtPath:[[VideoModel sharedInstance] pathToFullVideoTemp:_videoId] toPath:[[VideoModel sharedInstance] pathToFullVideo:_videoId] error:nil];
				_forceExistanceOfVideo = YES;
				
				break;
		}
		
		[_exportStatusTimer invalidate];
		_exportStatusTimer = nil;
		
		[SVProgressHUD dismiss];
		[self initializeTableCells];
		[_tableView reloadData];
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
		
	}];
	
	/* Start status timer */
	[_exportStatusTimer invalidate];
	_exportStatusTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(handleExportStatusTimer:) userInfo:nil repeats:YES];
}

- (void) handleExportStatusTimer:(NSTimer*)timer {
	[SVProgressHUD showProgress:_exportSession.progress status:@"Encoding" maskType:SVProgressHUDMaskTypeGradient];
}

#pragma mark ClipControlTableViewCellDelegate methods

- (void) clipControlPressedWatch:(BOOL)before {
	
}

- (void) clipControlPressedRecord:(BOOL)before {
	ClipRecorderViewController *crvc = [[ClipRecorderViewController alloc] initWithVideo:_videoId before:before];
	[self presentViewController:crvc animated:YES completion:nil];
}


#pragma mark UITableViewDelegate methods

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
	return [_tableCells count];
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[_tableCells objectAtIndex:section] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[_tableCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	UITableViewCell *cell = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
	switch (cell.tag) {
		case kCellTag_Title: {
			TextEditViewController *evc = [[TextEditViewController alloc] init];
			evc.title = @"Title";
			evc.videoId = _videoId;
			evc.attributeName = @"title";
			[self.navigationController pushViewController:evc animated:YES];
		}
		break;
			
		case kCellTag_Description: {
			TextEditViewController *evc = [[TextEditViewController alloc] init];
			evc.title = @"Description";
			evc.videoId = _videoId;
			evc.attributeName = @"description";
			[self.navigationController pushViewController:evc animated:YES];
		}
		break;
			
		case kCellTag_RecordingOptions: {
			RecordingOptionsViewController *rovc = [[RecordingOptionsViewController alloc] init];
			[self.navigationController pushViewController:rovc animated:YES];
		}
		break;
			
		case kCellTag_EncodeVideo: {
			[self encodeMovie];
		}
		break;
			
		default:
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEx *cell = [[_tableCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	return cell.cellHeight;
}

@end
