//
//  Item.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface Item : NSObject {
	sqlite3 *database;
	NSInteger primaryKey;
	NSString* title;
	NSString* number;
	NSInteger companyID;

	BOOL dirty;
}

@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *number;
@property (assign, nonatomic) NSInteger companyID;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements;

- (id)init;
- (id)initWithItem:(Item*)item;
- (id)initWithPrimaryKey:(NSInteger) pk database:(sqlite3*)db;
- (void)insertIntoDatabase:(sqlite3*)db;
- (void)saveIfDirty;
- (void)deleteFromDatabase;

@end
