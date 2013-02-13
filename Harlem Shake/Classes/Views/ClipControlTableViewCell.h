//
//  ClipControlTableViewCell.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCellEx.h"


@protocol ClipControlTableViewCellDelegate <NSObject>
- (void) clipControlPressedWatch:(BOOL)before;
- (void) clipControlPressedRecord:(BOOL)before;
@end


@interface ClipControlTableViewCell : UITableViewCellEx {
	UILabel *_befTitle;
	UILabel *_aftTitle;
	
	UIButton *_befRecord;
	UIButton *_aftRecord;
	
	
}

@property (nonatomic, strong) VideoID_t videoId;

@property (nonatomic, weak) id<ClipControlTableViewCellDelegate> controlDelegate;


@end
