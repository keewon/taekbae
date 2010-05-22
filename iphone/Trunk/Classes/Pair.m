//
//  Pair.m
//  TaekBae
//
//  Created by Keewon Seo on 10. 5. 23..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Pair.h"


@implementation Pair
@synthesize first, second;

- (id) initWithFirst: (NSString*) aFirst second:(NSInteger) aSecond
{
	self = [super init];
	self.first = aFirst;
	self.second = aSecond;
	
	return self;
}

- (void) dealloc
{
	self.first = nil;
	[super dealloc];
}

- (NSComparisonResult) compare: (Pair*) theOther {
	if (second > theOther.second) {
		return NSOrderedAscending;
	}
	else if (second < theOther.second) {
		return NSOrderedDescending;
	}
	return NSOrderedSame;
}
@end
