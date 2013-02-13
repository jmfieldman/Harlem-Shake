//
//  VideoModel.m
//  Harlem Shake
//
//  Created by Jason Fieldman on 2/12/13.
//  Copyright (c) 2013 Jason Fieldman. All rights reserved.
//

#import "VideoModel.h"

@implementation VideoModel

SINGLETON_IMPL(VideoModel);


- (id) init {
	if ((self = [super init])) {
		
		/* Filesystem */
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
		_appSuppDir = [paths objectAtIndex:0];
		_videosDir = [NSString stringWithFormat:@"%@/videos", _appSuppDir];
		[[NSFileManager defaultManager] createDirectoryAtPath:_videosDir withIntermediateDirectories:YES attributes:nil error:nil];
		
		/* Video info init */
		
		PersistentDictionary *videoOrderDic = [PersistentDictionary dictionaryWithName:@"videoOrder"];
		
		_videoOrder = [videoOrderDic.dictionary objectForKey:@"videoOrder"];
		if (!_videoOrder) {
			_videoOrder = [NSMutableArray array];
			[videoOrderDic.dictionary setObject:_videoOrder forKey:@"videoOrder"];
		}
		
		_videos = [NSMutableDictionary dictionary];
		for (VideoID_t videoId in _videoOrder) {
			PersistentDictionary *vidDic = [self persistentDictionaryForVideo:videoId];
			NSMutableDictionary *videoInfo = [vidDic.dictionary objectForKey:@"info"];
			if (!videoInfo) {
				videoInfo = [NSMutableDictionary dictionary];
				[vidDic.dictionary setObject:videoInfo forKey:@"info"];
			}
			[_videos setObject:videoInfo forKey:videoId];
		}
		
	}
	return self;
}


- (NSString*) persistentDictionaryNameForVideo:(VideoID_t)videoId {
	return [NSString stringWithFormat:@"video_%@", videoId];
}

- (PersistentDictionary*) persistentDictionaryForVideo:(VideoID_t)videoId {
	return [PersistentDictionary dictionaryWithName:[self persistentDictionaryNameForVideo:videoId]];
}

- (void) saveDictionaryForVideo:(VideoID_t)videoId {
	[[self persistentDictionaryForVideo:videoId] saveToFile];
}

- (NSString*) dataDirectoryForVideo:(VideoID_t)videoId {
	return [NSString stringWithFormat:@"%@/%@", _videosDir, videoId];
}

- (int) numberOfVideos {
	return [_videoOrder count];
}


- (VideoID_t) createNewVideoId {
	CFTimeInterval curTime = CFAbsoluteTimeGetCurrent();
	NSString *newId = [NSString stringWithFormat:@"%lf", curTime];
	
	/* Create new entry for the video */
	NSMutableDictionary *newVideoInfo = [NSMutableDictionary dictionary];
	[newVideoInfo setObject:newId       forKey:@"videoId"];
	[newVideoInfo setObject:@"Untitled" forKey:@"title"];
	[newVideoInfo setObject:@""         forKey:@"description"];
	
	/* Create a persistent dictionary for the video */
	PersistentDictionary *nvd = [self persistentDictionaryForVideo:newId];
	[nvd.dictionary setObject:newVideoInfo forKey:@"info"];
	
	/* Add it to the videos lookup */
	[_videos setObject:newVideoInfo forKey:newId];
	
	/* And add it to the end of the order array */
	[_videoOrder addObject:newId];
	
	/* Done */
	return newId;
}


@end

