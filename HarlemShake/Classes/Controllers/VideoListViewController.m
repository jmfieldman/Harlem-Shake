//
//  VideoListViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "VideoListViewController.h"
#import "VideoListTableViewCell.h"
#import "VideoInfoViewController.h"

@implementation VideoListViewController

SINGLETON_IMPL(VideoListViewController);


- (id) init {
	if ((self = [super init])) {
		
		/* title */
		self.title = @"Video List";
		
		/* Initialize the main view */
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
		self.view.backgroundColor = [UIColor clearColor];
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
				
		/* Initialize the nav bar buttons */
		UIBarButtonItem *addVideoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pressedAddVideo:)];
		self.navigationItem.rightBarButtonItem = addVideoButton;
		
		UIBarButtonItem *editVideosButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(pressedEditVideos:)];
		self.navigationItem.leftBarButtonItem = editVideosButton;
		
		/* Initialize the table */
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.rowHeight = 60;
		[self.view addSubview:_tableView];
		
		
		
	}
	return self;
}


/* When the view comes back into view, let's make sure we reload the table data */
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[_tableView reloadData];
}


#pragma mark Nav Bar Button handlers

- (void) pressedAddVideo:(id)sender {
	VideoID_t newId = [[VideoModel sharedInstance] createNewVideoId];
	
	VideoInfoViewController *vc = [[VideoInfoViewController alloc] init];
	vc.videoId = newId;
	
	[self.navigationController pushViewController:vc animated:YES];
}

- (void) pressedEditVideos:(id)sender {
	if ([_tableView isEditing]) {
		[_tableView setEditing:NO animated:YES];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(pressedEditVideos:)];
	} else {
		[_tableView setEditing:YES animated:YES];
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pressedEditVideos:)];
	}
}

#pragma mark UITableViewDelegate methods

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [VideoModel sharedInstance].numberOfVideos;
}

- (BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	EXLog(RENDER, DBG, @"move: from [%d] to [%d]", fromIndexPath.row, toIndexPath.row);
	
	[[VideoModel sharedInstance] moveVideoAtIndex:fromIndexPath.row toIndex:toIndexPath.row];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	EXLog(RENDER, DBG, @"commit: %d", indexPath.row);
	
	/* Wants to delete the video at this row */
	VideoID_t vid = [[VideoModel sharedInstance].videoOrder objectAtIndex:indexPath.row];
	[[VideoModel sharedInstance] deleteVideo:vid];
	
	/* Animate delete */
	[_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	VideoListTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"VideoListTableViewCell"];
	if (!cell) {
		cell = [[VideoListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"VideoListTableViewCell"];
	}
	
	/* Set the video ID */
	cell.videoId = [[VideoModel sharedInstance].videoOrder objectAtIndex:indexPath.row];
	
	/* Return the cell */
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	/* Go look at the info for that video */
	VideoID_t videoId = [[VideoModel sharedInstance].videoOrder objectAtIndex:indexPath.row];
	
	VideoInfoViewController *vc = [[VideoInfoViewController alloc] init];
	vc.videoId = videoId;
	
	[self.navigationController pushViewController:vc animated:YES];
}

@end
