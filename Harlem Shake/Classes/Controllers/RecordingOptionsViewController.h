//
//  RecordingOptionsViewController.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordingOptionsViewController : UITableViewController {
	/* Array that contains the table cells */
	NSMutableArray *_tableCells;
	
	/* Table view */
	UITableView *_tableView;
}

@end
