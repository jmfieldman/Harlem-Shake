//
//  ImageHelpers.h
//  ExperimentF
//
//  Created by Jason Fieldman on 5/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


UIImage *scaleAndRotateImage(UIImage *image, int maxDimension);
UIImage *imageWithRoundCornersAndShadow(UIImage *img);
UIImage *imageWithRoundCorners(UIImage *img, float radius);
void CGContextAddRoundedRectToPath(CGContextRef context, CGRect rect, float radius);

UIImage *squareImageCutout(UIImage *image, int squareSize, float xCentering, float yCentering);
UIImage *sizedImageCutout(UIImage *image, CGSize finalSize, float xCentering, float yCentering);

UIImage *rotateImage90(UIImage *image);