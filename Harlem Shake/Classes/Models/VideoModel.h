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
	
	/* Video info */
	NSMutableArray *_videoOrder;
	NSMutableDictionary *_videos;
	
	/* Filesystem cache */
	NSString *_appSuppDir;
	NSString *_videosDir;
	
}

SINGLETON_INTR(VideoModel);



@end
