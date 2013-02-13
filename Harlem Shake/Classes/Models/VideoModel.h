//
//  VideoModel.h
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NSString* VideoID_t;



@interface VideoModel : NSObject {
	
	/* Filesystem cache */
	NSString *_appSuppDir;
	NSString *_videosDir;
	
}

SINGLETON_INTR(VideoModel);

@property (nonatomic, assign, readonly) int numberOfVideos;

@property (nonatomic, strong, readonly) NSMutableArray      *videoOrder;
@property (nonatomic, strong, readonly) NSMutableDictionary *videos;


- (VideoID_t) createNewVideoId;
- (void) deleteVideo:(VideoID_t)videoId;
- (void) moveVideoAtIndex:(int)from toIndex:(int)to;

- (NSMutableDictionary*) videoDic:(VideoID_t)videoId;

@end
