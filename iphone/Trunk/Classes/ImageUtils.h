/*
 *  ImageUtils.h
 *  AugmentedRealitySample
 *
 *  Created by Chris Greening on 01/01/2010.
 *  Modified by Keewon Seo on 2010-05-23
 *
 */

#import <UIKit/UIKit.h>

typedef struct {
	uint8_t *rawImage;
	//uint8_t **pixels;
	int width;
	int height;
} Image;

Image *createImage(int width, int height);
Image *fromCGImage(CGImageRef srcImage, CGRect srcRect);  // alloc every time
Image *fromCGImage2(CGImageRef srcImage, CGRect srcRect); // don't alloc every time, dealloc with destroyGlobalImage 
CGImageRef toCGImage(Image *srcImage);
void destroyImage(Image *image);
void destroyGlobalImage(void);