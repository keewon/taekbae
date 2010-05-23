//
//  CameraInput.m
//  TaekBae
//
//  Created by Keewon Seo on 10. 5. 23..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CameraInput.h"
#import "TextEntryViewController.h"
#import "TessWrapper.h"
#import "ImageUtils.h"
#import "Pair.h"
#include <sys/time.h>


//#define TEST_CAPTURE 1
#define CAPTURE_Y 120
#define CAPTURE_HEIGHT 60

@interface CameraInput(Private)
- (void) cancelCapture;
- (void) captureThis;
@end

@implementation CameraInput

@synthesize bestCapturedNumber, capturedNumber;

#ifdef TEST_CAPTURE
- (void)capture: (UIViewController*)aParentViewController
{
	UIImage* image = [UIImage imageNamed: @"sample4.jpg"];
	CGRect rect = CGRectMake(0, CAPTURE_Y, 320, CAPTURE_HEIGHT);
	Image *screenImage = fromCGImage([image CGImage], rect);
	CGImageRef c1 = toCGImage(screenImage);
	UIImage* u1 = [UIImage imageWithCGImage: c1];
	CGImageRelease(c1);
	
	UIImageWriteToSavedPhotosAlbum(u1, nil, nil, nil);
	
	for (int y=0; y<CAPTURE_HEIGHT; ++y) {
		for (int x=0; x<320; ++x) {
			//unsigned char* p = &(screenImage->pixels[y][x]);
			unsigned char* p = &(screenImage->rawImage[y * width + x]);
			
			if (*p > 90)
				*p = 255;
			else
				*p = 0;
			
			if (x > 160) {
				if (*p == 0)
					printf("0");
				else
					printf(" ");
			}
		}
		printf("\n");
	}
	printf("\n");
	
	rect = CGRectMake(0, 0, 320, CAPTURE_HEIGHT);
	
	NSString* result = [TessWrapper getNumber: screenImage->rawImage rect: rect];
	NSLog(@"result = %@\n", result);
	
	CGImageRef c2 = toCGImage(screenImage);
	UIImage* u2 = [UIImage imageWithCGImage: c2];
	
	UIImageWriteToSavedPhotosAlbum(u2, nil, nil, nil);
	
	CGImageRelease(c2);
	destroyImage(screenImage);
}

#else

#define MARGIN_X 20
#define MARGIN_Y 20

#define TAG_BORDER_TOP 1001
#define TAG_BORDER_BOTTOM 1002
#define TAG_BORDER_LEFT 1003
#define TAG_BORDER_RIGHT 1004

- (IBAction)changeWindowSize: (id)sender
{
	UISlider* senderView = (UISlider*)sender;
	UIView* parentView = senderView.superview;
	
	UIView* topView = [parentView viewWithTag: TAG_BORDER_TOP];
	UIView* bottomView = [parentView viewWithTag: TAG_BORDER_BOTTOM];
	UIView* leftView = [parentView viewWithTag: TAG_BORDER_LEFT];
	UIView* rightView = [parentView viewWithTag: TAG_BORDER_RIGHT];
	
	CGFloat value = senderView.value;
	
	captureRect = CGRectMake(142 - value*140, CAPTURE_Y, 36 + value*2*140, CAPTURE_HEIGHT);
	
	CGRect rect;
	
	
	rect = leftView.frame;
	rect.origin.x = 140 - value*140;
	leftView.frame = rect;
	
	rect = rightView.frame;
	rect.origin.x = 178 + value*140;
	rightView.frame = rect;
	
	rect = topView.frame;
	rect.size.width = captureRect.size.width + 4;
	rect.origin.x = 140 - value*140;
	topView.frame = rect;
	
	rect = bottomView.frame;
	rect.size.width = captureRect.size.width + 4;
	rect.origin.x = 140 - value*140;
	bottomView.frame = rect;
}

- (void)capture: (TextEntryViewController*)aParentViewController
{
	parentViewController = aParentViewController;
	
	UIButton *buttonCancel = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	[buttonCancel setFrame: CGRectMake(MARGIN_X, CAPTURE_Y+CAPTURE_HEIGHT+MARGIN_Y*2+33, 72, 33)];
	[buttonCancel setTitle: NSLocalizedString(@"Cancel", "") forState:UIControlStateNormal];
	[buttonCancel addTarget:self action:@selector(finishCapture) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *buttonOK = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	[buttonOK setFrame: CGRectMake(MARGIN_X, CAPTURE_Y+CAPTURE_HEIGHT + MARGIN_Y, 72, 33)];
	[buttonOK setTitle: NSLocalizedString(@"OK", "") forState:UIControlStateNormal];
	[buttonOK addTarget:self action:@selector(captureThis) forControlEvents:UIControlEventTouchUpInside];
	
	UIView* parentView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
	
	[parentView addSubview: buttonOK];
	[parentView addSubview: buttonCancel];
	
	UISlider* slider = [[[UISlider alloc] initWithFrame: CGRectMake(160, CAPTURE_Y+CAPTURE_HEIGHT+MARGIN_Y, 160-MARGIN_X, 40)] autorelease];
	[slider setMinimumValue: 0];
	[slider setMaximumValue: 1];
	[slider setValue:1];
	[slider addTarget:self action:@selector(changeWindowSize:) forControlEvents:UIControlEventValueChanged];
	
	[parentView addSubview: slider];
	
	[labelCaptureResult release];
	labelCaptureResult = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,320, 44)] autorelease];
	[labelCaptureResult setText:@""];
	[labelCaptureResult setBackgroundColor: [UIColor blackColor]];
	[labelCaptureResult setTextColor: [UIColor whiteColor]];
	[labelCaptureResult setAlpha: 0.5];
	[labelCaptureResult setNumberOfLines: 2];
	[parentView addSubview: labelCaptureResult];
	
	UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 480-22*5, 320, 22*5)];
	[desc setText: NSLocalizedString(@"Camera Usage", @"")];
	[desc setBackgroundColor: [UIColor blackColor]];
	[desc setTextColor: [UIColor whiteColor]];
	[desc setAlpha: 0.5];
	[desc setNumberOfLines: 5];
	[parentView addSubview: desc];
	
	UIView *borderView1 = [[[UIView alloc] initWithFrame: CGRectMake(0, CAPTURE_Y-2, 320, 2)] autorelease];
	UIView *borderView2 = [[[UIView alloc] initWithFrame: CGRectMake(0, CAPTURE_Y+CAPTURE_HEIGHT, 320, 2)] autorelease];
	UIView *borderView3 = [[[UIView alloc] initWithFrame: CGRectMake(0, CAPTURE_Y, 2, CAPTURE_HEIGHT)] autorelease];
	UIView *borderView4 = [[[UIView alloc] initWithFrame: CGRectMake(320-2, CAPTURE_Y, 2, CAPTURE_HEIGHT)] autorelease];
	
	[borderView1 setBackgroundColor: [UIColor whiteColor]];
	[borderView2 setBackgroundColor: [UIColor whiteColor]];
	[borderView3 setBackgroundColor: [UIColor whiteColor]];
	[borderView4 setBackgroundColor: [UIColor whiteColor]];
	
	[borderView1 setTag: TAG_BORDER_TOP];
	[borderView2 setTag: TAG_BORDER_BOTTOM];
	[borderView3 setTag: TAG_BORDER_LEFT];
	[borderView4 setTag: TAG_BORDER_RIGHT];
	
	[parentView addSubview: borderView1];
	[parentView addSubview: borderView2];
	[parentView addSubview: borderView3];
	[parentView addSubview: borderView4];
	
	captureRect = CGRectMake(2, CAPTURE_Y, 320-4, CAPTURE_HEIGHT);
	
	[capturedNumbersDict release];
	capturedNumbersDict = [[NSMutableDictionary alloc] init];
	self.bestCapturedNumber = @"";
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	picker.showsCameraControls = NO;
	picker.delegate = nil;
	picker.allowsImageEditing = NO;
	[picker setCameraOverlayView: parentView];
	[parentViewController presentModalViewController:picker animated:YES];
	[picker release];
	
	[TessWrapper init];
	
	ocrQuit = NO;
	ocrLock = [[NSLock alloc] init];
	
	processingTimer = [NSTimer scheduledTimerWithTimeInterval:1/2.0f target: self selector:@selector(processImage) userInfo:nil repeats:YES];
}
#endif

- (void) finishCapture {
	
	[labelCaptureResult removeFromSuperview];
	labelCaptureResult = nil;
	
	[processingTimer invalidate];
	
	ocrQuit = YES;
	[ocrLock lock];
	[ocrLock unlock];
	[ocrLock release];
	ocrLock = nil;
	
	[TessWrapper end];
	destroyGlobalImage();
	
	[capturedNumbersDict release];
	capturedNumbersDict = nil;
	self.capturedNumber = nil;
	self.bestCapturedNumber = nil;
	
	[parentViewController dismissModalViewControllerAnimated:YES];
}

- (void) cancelCapture {
	[self finishCapture];
}

- (void) captureThis {
	NSString* str = self.bestCapturedNumber;
	NSMutableString* result = [NSMutableString string];
	
	for (int i=0; i<[str length]; ++i) {
		unichar ch = [str characterAtIndex:i];
		
		if ('0' <= ch && ch <= '9') {
			[result appendFormat:@"%C", ch];
		}
	}
	[parentViewController setNumber: result];
	[self finishCapture];
}

/*
 - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
 [self finishCapture];
 }
 */



CGImageRef UIGetScreenImage();

- (void) processImage {
//	NSLog(@"processImage\n");
	if (ocrQuit)
		return;
	
	if ([ocrLock tryLock]) {
		[ocrLock unlock];
	}
	else {
		//NSLog(@"do later\n");
		return;
	}

	//[ set result
	NSString *result = [[self.capturedNumber copy] autorelease];
	NSString *resultShort;
	
	if ([result length] > 20) {
		resultShort = [[result substringToIndex: 20] stringByAppendingString: @".."];
	}
	else {
		resultShort = result;
		if (!resultShort) {
			resultShort = @"";
		}
	}
	
	[labelCaptureResult setText: [NSString stringWithFormat: NSLocalizedString(@"Input: %@\nBest: %@", @""), 
								  resultShort, self.bestCapturedNumber]];
	
	//]
	
	CGImageRef screenCGImage = UIGetScreenImage();
	Image *screenImage = fromCGImage2(screenCGImage, captureRect);
	CGImageRelease(screenCGImage);
	
#if 0 // for debug
	CGImageRef c1 = toCGImage(screenImage);
	UIImage* u1 = [UIImage imageWithCGImage: c1];
	UIImageWriteToSavedPhotosAlbum(u1, nil, nil, nil);
	CGImageRelease(c1);
#endif
	
	int height = captureRect.size.height;
	int width = captureRect.size.width;
	
	
	for (int y=0; y<height; ++y) {
		for (int x=0; x<width; ++x) {
			unsigned char* p = &(screenImage->rawImage[y * width + x]);
			
			if (*p > 90)
				*p = 255;
			else
				*p = 0;
			
			/*
			 if (x > 160) {
			 if (*p == 0)
			 printf("0");
			 else
			 printf(" ");
			 }
			 */
		}
		//printf("\n");
	}
	//printf("\n");
	
	[self performSelectorInBackground:@selector(doOCR:) withObject:nil];
	
#if 0 // for debug
	CGImageRef c2 = toCGImage(screenImage);
	UIImage* u2 = [UIImage imageWithCGImage: c2];
	
	UIImageWriteToSavedPhotosAlbum(u2, nil, nil, nil);
	
	CGImageRelease(c2);
#endif
	// destroyImage(screenImage); // call this only if we use fromCGImage, not fromCGImage2	

}

- (void) doOCR: (id)data
{
	NSAutoreleasePool*  pool = [[NSAutoreleasePool alloc] init];
	if (ocrQuit) {
		[pool release];
		return;
	}
	[ocrLock lock];	
//	struct timeval tv1, tv2;
//	gettimeofday(&tv1, NULL);
	
	CGRect rect = CGRectMake(0, 0, captureRect.size.width, captureRect.size.height);
	Image* screenImage = getGlobalImage();
	NSString* result = [TessWrapper getNumber: screenImage->rawImage rect: rect];
	//NSLog(@"result = %@\n", result);
	
	result = [result stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// Downsizing dictionary
	//NSLog(@"count: %d\n", [capturedNumbersDict count]);
	if ([capturedNumbersDict count] > 60) {
		NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity: 60];
		
		NSEnumerator *enumerator = [capturedNumbersDict keyEnumerator];
		NSString* key;
		
		while ((key = [enumerator nextObject])) {
			/* code that uses the returned key */
			NSNumber* value = [capturedNumbersDict objectForKey: key];
			
			[tempArray addObject: [[[Pair alloc] initWithFirst:key second: [value intValue]] autorelease]];
		}
		
		[tempArray sortUsingSelector: @selector(compare:)];
		
		[capturedNumbersDict release];
		capturedNumbersDict = [[NSMutableDictionary alloc] init];
		
		for (int i=0; i<6; ++i) {
			Pair *a = [tempArray objectAtIndex: i];
			//NSLog(@"%@ - %d\n", a.first ,a.second);
			[capturedNumbersDict setObject: [NSNumber numberWithInt: a.second] forKey: a.first];
		}
	}
	
	// insert
	if ([result length] > 2) {
		NSNumber *value = [capturedNumbersDict objectForKey: result];
		
		if (value) {
			value = [NSNumber numberWithInt: [value intValue] + 1];
		}
		else {
			value = [NSNumber numberWithInt: 1];
		}
		
		[capturedNumbersDict setObject: value forKey: result];
	}
	
	// choose best
	{
		NSEnumerator *enumerator = [capturedNumbersDict keyEnumerator];
		NSString* key;
		NSInteger bestCount = 0;
		
		while ((key = [enumerator nextObject])) {
			/* code that uses the returned key */
			NSNumber* value = [capturedNumbersDict objectForKey: key];
			
			if ([value intValue] > bestCount) {
				self.bestCapturedNumber = key;
				bestCount = [value intValue];
			}
		}
		self.capturedNumber = result;
	}
	
//	gettimeofday(&tv2, NULL);
	
//	NSLog(@"tv1 : %ld, %ld | tv2: %ld, %ld\n", tv1.tv_sec, tv1.tv_usec, tv2.tv_sec, tv2.tv_usec);
	
	[ocrLock unlock];
	
	[pool release];
}


@end
