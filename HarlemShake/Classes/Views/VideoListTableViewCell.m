//
//  VideoListTableViewCell.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "VideoListTableViewCell.h"

@implementation VideoListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {

	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

- (void) setVideoId:(VideoID_t)videoId {
	_videoId = videoId;
	
	
	NSDictionary *vidInfo = [[VideoModel sharedInstance] videoDic:_videoId];
	
	self.textLabel.text = [[vidInfo objectForKey:@"title"] length] ? [vidInfo objectForKey:@"title"] : @"Untitled";
	self.detailTextLabel.text = [[vidInfo objectForKey:@"description"] length] ? [vidInfo objectForKey:@"description"] : @"No description";
	
	UIImage *clip = [[VideoModel sharedInstance] screenshotForVideo:_videoId beforeDrop:YES];
	if (!clip) clip = [[VideoModel sharedInstance] screenshotForVideo:_videoId beforeDrop:NO];
	UIImage *clipToUse = clip ? clip : [UIImage imageNamed:@"noclip"];
	
	self.imageView.image = squareImageCutout(clipToUse, 60, 0.5, 0.5);
}

@end
