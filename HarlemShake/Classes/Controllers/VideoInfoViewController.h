//
//  VideoInfoViewController.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClipControlTableViewCell.h"

@interface VideoInfoViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ClipControlTableViewCellDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	/* Array that contains the table cells */
	NSMutableArray *_tableCells;
	
	/* Table view */
	UITableView *_tableView;
	
	/* Export encoder */
	AVAssetExportSession *_exportSession;
	NSTimer *_exportStatusTimer;
	BOOL _forceExistanceOfVideo;
	
	/* Movie player */
	MPMoviePlayerController *_moviePlayer;
	UILabel *_audioWarning;
	
	/* Upload */
	NSTimer *_uploadProgressTimer;
}

@property (nonatomic, strong) VideoID_t videoId;

@end
