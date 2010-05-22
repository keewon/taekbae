//
//  Pair.h
//  TaekBae
//
//  Created by Keewon Seo on 10. 5. 23..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Pair : NSObject {
	NSString* first;
	NSInteger second;
}

@property(nonatomic, retain) NSString  *first;
@property(nonatomic, assign) NSInteger second;

- (id) initWithFirst: (NSString*) aFirst second:(NSInteger) aSecond;
- (NSComparisonResult) compare: (Pair*) theOther;

@end
