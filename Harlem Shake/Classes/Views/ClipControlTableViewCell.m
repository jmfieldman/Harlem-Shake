//
//  ClipControlTableViewCell.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "ClipControlTableViewCell.h"


#define HEADING_FONT [UIFont boldSystemFontOfSize:12]

@implementation ClipControlTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
	
		self.cellHeight = 160;
		
		/* Titles */
		_befTitle = [[UILabel alloc] initWithFrame:CGRectZero];
		_befTitle.text = @"Before Drop";
		_befTitle.backgroundColor = [UIColor clearColor];
		_befTitle.font = HEADING_FONT;
		_befTitle.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_befTitle];
		
		_aftTitle = [[UILabel alloc] initWithFrame:CGRectZero];
		_aftTitle.text = @"After Drop";
		_aftTitle.backgroundColor = [UIColor clearColor];
		_aftTitle.font = HEADING_FONT;
		_aftTitle.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_aftTitle];
		
		/* Record buttons */
		_befRecord = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_befRecord setTitle:@"Record" forState:UIControlStateNormal];
		[_befRecord setTitleColor:[UIColor colorWithRed:0.75 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
		[_befRecord setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
		[_befRecord setTintColor:[UIColor colorWithRed:0.75 green:0 blue:0 alpha:1]];
		[self.contentView addSubview:_befRecord];
		
		_aftRecord = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[_aftRecord setTitle:@"Record" forState:UIControlStateNormal];
		[_aftRecord setTitleColor:[UIColor colorWithRed:0.75 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
		[_aftRecord setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
		[_aftRecord setTintColor:[UIColor colorWithRed:0.75 green:0 blue:0 alpha:1]];
		[self.contentView addSubview:_aftRecord];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void) setVideoId:(VideoID_t)videoId {
	_videoId = videoId;
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	float halfScreen = self.contentView.frame.size.width / 2;
	
	_befTitle.frame = CGRectMake(0, 0, halfScreen, 30);
	_aftTitle.frame = CGRectMake(halfScreen, 0, halfScreen, 30);
	
	float recordY = 105;
	
	_befRecord.frame = CGRectMake(10, recordY, halfScreen - 20, 44 );
	_aftRecord.frame = CGRectMake(halfScreen + 10, recordY, halfScreen - 20, 44);
}


@end
