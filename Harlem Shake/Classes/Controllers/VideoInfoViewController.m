//
//  VideoInfoViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "VideoInfoViewController.h"
#import "TextEditViewController.h"
#import "UITableViewCellEx.h"


#define kCellTag_Title       1
#define kCellTag_Description 2


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
	
	{
		UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = @"Title";
		cell.detailTextLabel.text = [[[VideoModel sharedInstance] videoDic:_videoId] objectForKey:@"title"];
		cell.tag = kCellTag_Title;
		[_tableCells addObject:cell];
	}
	
	{
		UITableViewCellEx *cell = [[UITableViewCellEx alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = @"Description";
		cell.detailTextLabel.text = [[[VideoModel sharedInstance] videoDic:_videoId] objectForKey:@"description"];
		cell.tag = kCellTag_Description;
		[_tableCells addObject:cell];
	}
	
}


- (void) setVideoId:(VideoID_t)videoId {
	_videoId = videoId;
}


#pragma mark UITableViewDelegate methods

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_tableCells count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [_tableCells objectAtIndex:indexPath.row];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	UITableViewCell *cell = [_tableCells objectAtIndex:indexPath.row];
	switch (cell.tag) {
		case kCellTag_Title: {
			TextEditViewController *evc = [[TextEditViewController alloc] init];
			evc.title = @"Title";
			evc.stringToEdit = [[[VideoModel sharedInstance] videoDic:_videoId] objectForKey:@"title"];
			
			NSLog(@"str: %@ type: %@", [[[VideoModel sharedInstance] videoDic:_videoId] objectForKey:@"title"], [[[[[VideoModel sharedInstance] videoDic:_videoId] objectForKey:@"title"] class] superclass]);
			
			[self.navigationController pushViewController:evc animated:YES];
		}
		break;
			
		default:
			break;
	}
}

@end
