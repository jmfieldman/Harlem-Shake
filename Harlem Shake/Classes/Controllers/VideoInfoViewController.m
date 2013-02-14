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
	
		if ([[VideoModel sharedInstance] fullVideoExistsForVideo:_videoId]) {
			
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


#pragma mark ClipControlTableViewCellDelegate methods

- (void) clipControlPressedWatch:(BOOL)before {
	
}

- (void) clipControlPressedRecord:(BOOL)before {
	ClipRecorderViewController *crvc = [[ClipRecorderViewController alloc] init];
	crvc.videoId = _videoId;
	crvc.openedForBeforeClip = before;
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
			
		default:
			break;
	}
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEx *cell = [[_tableCells objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	return cell.cellHeight;
}

@end
