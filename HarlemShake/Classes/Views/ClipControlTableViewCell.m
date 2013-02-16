//
//  ClipControlTableViewCell.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/13/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "ClipControlTableViewCell.h"

#define kClipSize 80

#define HEADING_FONT [UIFont boldSystemFontOfSize:12]

@implementation ClipControlTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
	
		self.cellHeight = 175;
		
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
		
		/* Clip buttons */
		_befClip = [UIButton buttonWithType:UIButtonTypeCustom];
		_befClip.tag = 1;
		[_befClip setImage:[UIImage imageNamed:@"noclip"] forState:UIControlStateNormal];
		[_befClip addTarget:self action:@selector(pressedWatch:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_befClip];
		
		_aftClip = [UIButton buttonWithType:UIButtonTypeCustom];
		_aftClip.tag = 2;
		[_aftClip setImage:[UIImage imageNamed:@"noclip"] forState:UIControlStateNormal];
		[_aftClip addTarget:self action:@selector(pressedWatch:) forControlEvents:UIControlEventTouchUpInside];
		[self.contentView addSubview:_aftClip];
		
		/* Play overlay */
		_befPlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
		_befPlay.center = CGPointMake(40, 40);
		[_befClip addSubview:_befPlay];
		
		_aftPlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
		_aftPlay.center = CGPointMake(40, 40);
		[_aftClip addSubview:_aftPlay];
		
		/* Record buttons */
		_befRecord = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		_befRecord.tag = 1;
		[_befRecord addTarget:self action:@selector(pressedRecord:) forControlEvents:UIControlEventTouchUpInside];
		[_befRecord setTitle:@"Record" forState:UIControlStateNormal];
		[_befRecord setTitleColor:[UIColor colorWithRed:0.75 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
		[_befRecord setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
		[_befRecord setTintColor:[UIColor colorWithRed:0.75 green:0 blue:0 alpha:1]];
		[self.contentView addSubview:_befRecord];
		
		_aftRecord = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		_aftRecord.tag = 2;
		[_aftRecord addTarget:self action:@selector(pressedRecord:) forControlEvents:UIControlEventTouchUpInside];
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

- (void) pressedWatch:(id)sender {
	int tag = ((UIView*)sender).tag;
	
	if (tag == 1) {
		[_controlDelegate clipControlPressedWatch:YES];
	} else if (tag == 2) {
		[_controlDelegate clipControlPressedWatch:NO];
	}
}

- (void) pressedRecord:(id)sender {
	int tag = ((UIView*)sender).tag;
	
	if (tag == 1) {
		[_controlDelegate clipControlPressedRecord:YES];
	} else if (tag == 2) {
		[_controlDelegate clipControlPressedRecord:NO];
	}
}

- (void) setVideoId:(VideoID_t)videoId {
	_videoId = videoId;
	
	
	UIImage *befShot = [[VideoModel sharedInstance] screenshotForVideo:videoId beforeDrop:YES];
	UIImage *aftShot = [[VideoModel sharedInstance] screenshotForVideo:videoId beforeDrop:NO];
	
	if (befShot) {
		[_befClip setImage:befShot forState:UIControlStateNormal];
		_befClip.enabled = YES;
		_befPlay.alpha = 0.55;
	} else {
		[_befClip setImage:[UIImage imageNamed:@"noclip"] forState:UIControlStateNormal];
		_befClip.enabled = NO;
		_befPlay.alpha = 0.0;
	}	

	if (aftShot) {
		[_aftClip setImage:aftShot forState:UIControlStateNormal];
		_aftClip.enabled = YES;
		_aftPlay.alpha = 0.55;
	} else {
		[_aftClip setImage:[UIImage imageNamed:@"noclip"] forState:UIControlStateNormal];
		_aftClip.enabled = NO;
		_aftPlay.alpha = 0.0;
	}
}

- (void) layoutSubviews {
	[super layoutSubviews];
	
	float halfScreen = self.contentView.frame.size.width / 2;
	
	_befTitle.frame = CGRectMake(0, 0, halfScreen, 30);
	_aftTitle.frame = CGRectMake(halfScreen, 0, halfScreen, 30);
	
	float clipY = 30;
	
	_befClip.frame = CGRectMake( (halfScreen - kClipSize) / 2, clipY, kClipSize, kClipSize );
	_aftClip.frame = CGRectMake( halfScreen + (halfScreen - kClipSize) / 2, clipY, kClipSize, kClipSize );
	
	float recordY = 120;
	
	_befRecord.frame = CGRectMake(10, recordY, halfScreen - 20, 44 );
	_aftRecord.frame = CGRectMake(halfScreen + 10, recordY, halfScreen - 20, 44);
}


@end
