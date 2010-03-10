//
//  Company.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Company : NSObject {
	sqlite3 *database;
	NSInteger primaryKey;
	NSString* korean;
	NSString* english;
	NSString* url;
	NSString* pageEncoding;
	NSArray* keywords;
	int useNumPad;
	int flagDaesin;
}

@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (copy, nonatomic) NSString *korean;
@property (copy, nonatomic) NSString *english;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *pageEncoding;
@property (retain, nonatomic) NSArray *keywords;
@property (assign, nonatomic) int useNumPad;
@property (assign, nonatomic) int flagDaesin;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

- (id)initWithPrimaryKey:(NSInteger) pk database:(sqlite3*)db;

@end
