//
//  TessWrapper.h
//  TaekBae
//
//  Created by Keewon Seo on 10. 03. 08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TessWrapper : NSObject {

}

+ (void) init;
+ (void) end;
+ (NSString*) getNumber:(const unsigned char*)data rect: (CGRect)rect;

@end
