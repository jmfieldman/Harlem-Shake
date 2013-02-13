//
//  VideoListViewController.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "VideoListViewController.h"

@implementation VideoListViewController

SINGLETON_IMPL(VideoListViewController);


- (id) init {
	if ((self = [super init])) {
		
		self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
		self.view.backgroundColor = [UIColor clearColor];
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
				
		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_tableView.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_tableView];
		
		
		
	}
	return self;
}


@end
