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
	
}

#pragma mark UITableViewDelegate methods

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [VideoModel sharedInstance].numberOfVideos;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	VideoListTableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"VideoListTableViewCell"];
	if (!cell) {
		cell = [[VideoListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VideoListTableViewCell"];
	}
	
	/* Set the video ID */
	cell.videoId = [[VideoModel sharedInstance].videoOrder objectAtIndex:indexPath.row];
	
	/* Return the cell */
	return cell;
}

@end
