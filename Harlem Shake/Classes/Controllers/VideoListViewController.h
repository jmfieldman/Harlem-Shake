//
//  VideoListViewController.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
	UITableView *_tableView;
}

SINGLETON_INTR(VideoListViewController);

@end
