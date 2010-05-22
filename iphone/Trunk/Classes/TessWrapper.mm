//
//  TessWrapper.mm
//  TaekBae
//
//  Created by Keewon Seo on 10. 03. 08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TessWrapper.h"
#include "baseapi.h"
#include <stdlib.h>

@implementation TessWrapper
+ (void) init {
	setenv("TESSDATA_PREFIX", 
		   [[[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/"] UTF8String], 1);
	TessBaseAPI::SetVariable("tessedit_char_whitelist", "0123456789- ");
	TessBaseAPI::Init(NULL, NULL, NULL, false, 0, NULL);
	
}

+ (void) end {
	TessBaseAPI::End();
}


+ (NSString*) getNumber:(const unsigned char*)data rect: (CGRect)rect {
	char* result = TessBaseAPI::TesseractRect(data, 1, rect.size.width,
											  rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
	
	if (result) {
		NSString* ret = [[NSString stringWithUTF8String: result] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
		delete [] result;
		return ret;
	}
	return nil;
}
@end
