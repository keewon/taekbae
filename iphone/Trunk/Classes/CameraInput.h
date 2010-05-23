//
//  CameraInput.h
//  TaekBae
//
//  Created by Keewon Seo on 10. 5. 23..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextEntryViewController;

@interface CameraInput : NSObject<UIImagePickerControllerDelegate> {
	NSMutableDictionary* capturedNumbersDict;
	NSString* bestCapturedNumber;
	NSLock *ocrLock;
	BOOL ocrQuit;
	NSTimer *processingTimer;
	
	UILabel *labelCaptureResult;
	CGRect captureRect;	
	
	TextEntryViewController* parentViewController;
}

- (void) capture: (TextEntryViewController*) aParentViewController;

@end
