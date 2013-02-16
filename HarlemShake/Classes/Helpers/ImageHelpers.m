//
//  ImageHelpers.m
//  ExperimentF
//
//  Created by Jason Fieldman on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageHelpers.h"


UIImage *rotateImage90(UIImage *image) {
	int kMaxResolution = (image.size.height > image.size.width) ? image.size.height : image.size.width;
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	boundHeight = bounds.size.height;
	bounds.size.height = bounds.size.width;
	bounds.size.width = boundHeight;
	transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
	transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextScaleCTM(context, -scaleRatio, scaleRatio);
	CGContextTranslateCTM(context, -height, 0);
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}


UIImage *scaleAndRotateImage(UIImage *image, int maxDimension) {
	int kMaxResolution = maxDimension;
	
	CGImageRef imgRef = image.CGImage;
	
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	
	
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	if (width > kMaxResolution || height > kMaxResolution) {
		CGFloat ratio = width/height;
		if (ratio > 1) {
			bounds.size.width = kMaxResolution;
			bounds.size.height = bounds.size.width / ratio;
		}
		else {
			bounds.size.height = kMaxResolution;
			bounds.size.width = bounds.size.height * ratio;
		}
	}
	
	CGFloat scaleRatio = bounds.size.width / width;
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	CGFloat boundHeight;
	UIImageOrientation orient = image.imageOrientation;
	switch(orient) {
			
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
			
	}
	
	UIGraphicsBeginImageContext(bounds.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	
	CGContextConcatCTM(context, transform);
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return imageCopy;
}




/* Add rounded rect path to context */
void CGContextAddRoundedRectToPath(CGContextRef context, CGRect rect, float radius) {
	CGContextBeginPath(context);
	CGContextSaveGState(context);
	
	if (radius == 0) {
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextAddRect(context, rect);
	} else {
		CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
		CGContextScaleCTM(context, radius, radius);
		float fw = CGRectGetWidth(rect) / radius;
		float fh = CGRectGetHeight(rect) / radius;
		
		CGContextMoveToPoint(context, fw, fh/2);
		CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
		CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
		CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
		CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	}
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}



UIImage *squareImageCutout(UIImage *image, int squareSize, float xCentering, float yCentering) {
	CGSize finalSquareSize = CGSizeMake(squareSize, squareSize);
	
	CGSize scaledRectSize = image.size;
	if (scaledRectSize.width < squareSize || scaledRectSize.height < squareSize) {
		/* We need to scale up! */
		float ratio = scaledRectSize.width / scaledRectSize.height;
		if (ratio > 1) {
			scaledRectSize.height = squareSize;
			scaledRectSize.width = scaledRectSize.height * ratio;
		} else {
			scaledRectSize.width = squareSize;
			scaledRectSize.height = scaledRectSize.width / ratio;
		}
	} else {
		/* We need to scale down! */
		float ratio = scaledRectSize.width / scaledRectSize.height;
		if (ratio > 1) {
			scaledRectSize.height = squareSize;
			scaledRectSize.width = scaledRectSize.height * ratio;
		} else {
			scaledRectSize.width = squareSize;
			scaledRectSize.height = scaledRectSize.width / ratio;
		}
	}
	
	float extrax = scaledRectSize.width - squareSize;
	float extray = scaledRectSize.height - squareSize;
	
	float startx = 0 - (extrax * xCentering);
	float starty = 0 - (extray * yCentering);
	
	UIGraphicsBeginImageContext(finalSquareSize);
	
	[image drawInRect:CGRectMake(startx, starty, scaledRectSize.width, scaledRectSize.height)];
	
	UIImage *retImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return retImg;
}



UIImage *sizedImageCutout(UIImage *image, CGSize finalSize, float xCentering, float yCentering) {
	
	CGSize scaledRectSize = image.size;
	
	/* Size to width first */
	{
		float scaleratio = finalSize.width / scaledRectSize.width;
		scaledRectSize.width *= scaleratio;
		scaledRectSize.height *= scaleratio;		
	}
	
	/* then scale height if it's shorter than expected */
	if (scaledRectSize.height < (finalSize.height-1)) {
		float scaleratio = finalSize.height / image.size.height;
		scaledRectSize = CGSizeMake(image.size.width * scaleratio, image.size.height * scaleratio);
	}
	
	float extrax = scaledRectSize.width - finalSize.width;
	float extray = scaledRectSize.height - finalSize.height;
	
	float startx = 0 - (extrax * xCentering);
	float starty = 0 - (extray * yCentering);
	
	UIGraphicsBeginImageContext(finalSize);
	
	[image drawInRect:CGRectMake(startx, starty, scaledRectSize.width, scaledRectSize.height)];
	
	UIImage *retImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return retImg;
}





#define extraMargin 7
#define shadowBlur 5
#define shadowPass 4
#define cornerRadius 6
#define shadowOffset CGSizeMake(0,2)



/* Return an image with round corners and a drop shadow */
UIImage* imageWithRoundCornersAndShadow(UIImage *img) {
	CGSize originalImageSize = img.size;
	CGSize newImageSize = CGSizeMake(originalImageSize.width + (extraMargin<<1), originalImageSize.height + (extraMargin<<1));
	CGRect subFrame = CGRectMake(extraMargin, extraMargin, originalImageSize.width, originalImageSize.height);
	
	UIGraphicsBeginImageContext(newImageSize);
	CGContextRef c = UIGraphicsGetCurrentContext();	
	
	/* Create a white oval as the image mask */
	CGContextSetRGBFillColor(c, 1, 1, 1, 1);
	CGContextAddRoundedRectToPath(c, subFrame, cornerRadius);
	CGContextFillPath(c);
	
	/* Now draw the image with the mask */
	[img drawInRect:subFrame blendMode:kCGBlendModeSourceIn alpha:1];
	
	/* Setup shadows */
	CGContextSetShadow(c, shadowOffset, shadowBlur);
	
	/* We lighten, since we don't want to draw in the filled in shadow anymore (with our new black oval) */
	CGContextSetBlendMode(c, kCGBlendModeLighten);
	CGContextSetRGBFillColor(c, 0, 0, 0, 1);
	
	CGRect shadowRect = CGRectInset(subFrame, 1, 1);
	for (int i = 0; i < shadowPass; i++) {
		CGContextAddRoundedRectToPath(c, shadowRect, cornerRadius);
		CGContextFillPath(c);
	}
	
	UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return retval;
}


/* Return an image with round corners and a drop shadow */
UIImage *imageWithRoundCorners(UIImage *img, float radius) {
	CGSize originalImageSize = img.size;
	CGRect originalImageRect = CGRectMake(0, 0, originalImageSize.width, originalImageSize.height);
	
	UIGraphicsBeginImageContext(originalImageSize);
	CGContextRef c = UIGraphicsGetCurrentContext();	
	
	/* Create a white oval as the image mask */
	CGContextSetRGBFillColor(c, 1, 1, 1, 1);
	CGContextAddRoundedRectToPath(c, originalImageRect, radius);
	CGContextFillPath(c);
	
	/* Now draw the image with the mask */
	[img drawInRect:originalImageRect blendMode:kCGBlendModeSourceIn alpha:1];
	
	UIImage *retval = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return retval;
}

