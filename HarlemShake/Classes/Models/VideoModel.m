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
			
			/* Make sure directory exists */
			[[NSFileManager defaultManager] createDirectoryAtPath:[self dataDirectoryForVideo:videoId] withIntermediateDirectories:YES attributes:nil error:nil];
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

- (NSMutableDictionary*) videoDic:(VideoID_t)videoId {
	return [_videos objectForKey:videoId];
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
	[newVideoInfo setObject:[NSMutableString stringWithString:@"Untitled"] forKey:@"title"];
	[newVideoInfo setObject:[NSMutableString stringWithString:@""        ] forKey:@"description"];
		
	/* Create a persistent dictionary for the video */
	PersistentDictionary *nvd = [self persistentDictionaryForVideo:newId];
	[nvd.dictionary setObject:newVideoInfo forKey:@"info"];
	
	/* Add it to the videos lookup */
	[_videos setObject:newVideoInfo forKey:newId];
	
	/* And add it to the end of the order array */
	[_videoOrder addObject:newId];
	
	/* Save video info */
	[[PersistentDictionary dictionaryWithName:@"videoOrder"] saveToFile];
	[nvd saveToFile];
	
	/* Done */
	return newId;
}


- (void) deleteVideo:(VideoID_t)videoId {
	
	EXLog(MODEL, INFO, @"Removing video [%@]", videoId);
	
	[_videoOrder removeObject:videoId];
	[_videos     removeObjectForKey:videoId];
	
	[PersistentDictionary deleteDictionaryNamed:[self persistentDictionaryNameForVideo:videoId]];
	
	/* Save video order */
	[[PersistentDictionary dictionaryWithName:@"videoOrder"] saveToFile];
}


- (void) moveVideoAtIndex:(int)from toIndex:(int)to {
	
	VideoID_t vid = [_videoOrder objectAtIndex:from];
	[_videoOrder removeObjectAtIndex:from];
	[_videoOrder insertObject:vid atIndex:to];
	
	/* Save video order */
	[[PersistentDictionary dictionaryWithName:@"videoOrder"] saveToFile];
}


- (NSString*) pathToClipForVideo:(VideoID_t)videoId beforeDrop:(BOOL)before {
	return [NSString stringWithFormat:@"%@/%@.mov", [self dataDirectoryForVideo:videoId], before ? @"before" : @"after"];
}

- (NSString*) pathToClipForVideoTemp:(VideoID_t)videoId beforeDrop:(BOOL)before {
	return [NSString stringWithFormat:@"%@/%@_temp.mov", [self dataDirectoryForVideo:videoId], before ? @"before" : @"after"];
}

- (NSString*) pathToFullVideo:(VideoID_t)videoId {
	return [NSString stringWithFormat:@"%@/full.mp4", [self dataDirectoryForVideo:videoId]];
}

- (NSString*) pathToFullVideoTemp:(VideoID_t)videoId {
	return [NSString stringWithFormat:@"%@/full_temp.mp4", [self dataDirectoryForVideo:videoId]];
}

- (UIImage*) screenshotForVideo:(VideoID_t)videoId beforeDrop:(BOOL)before {
	/* Make sure we have the actual clip.. */
	NSString *moviePath = [self pathToClipForVideo:videoId beforeDrop:before];
	if (![[NSFileManager defaultManager] fileExistsAtPath:moviePath]) {
		return nil;
	}
	
	NSString *path = [NSString stringWithFormat:@"%@/%@.png", [self dataDirectoryForVideo:videoId], before ? @"before" : @"after"];
	
	/* Return the image if it exists */
	UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
	if (img) return img;
	
	/* Otherwise we need to make it */
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil]; /* Could be corrupt? */
	
	AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:moviePath]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMake(1, 1);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
	
	/* Write to disk */
	[UIImagePNGRepresentation(thumbnail) writeToFile:path atomically:YES];
	
	return thumbnail;
}


- (void) deleteScreenshotForVideo:(VideoID_t)videoId beforeDrop:(BOOL)before {
	NSString *path = [NSString stringWithFormat:@"%@/%@.png", [self dataDirectoryForVideo:videoId], before ? @"before" : @"after"];
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}


- (BOOL) clipExistsforVideo:(VideoID_t)videoId beforeDrop:(BOOL)before {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self pathToClipForVideo:videoId beforeDrop:before]];
}

- (BOOL) fullVideoExistsForVideo:(VideoID_t)videoId {
	return [[NSFileManager defaultManager] fileExistsAtPath:[self pathToFullVideo:videoId]];
}


@end

