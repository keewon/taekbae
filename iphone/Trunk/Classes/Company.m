//
//  Company.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Company.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;

@implementation Company

@synthesize useNumPad, flagDaesin, keywords;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements {
    if (insert_statement) {
        sqlite3_finalize(insert_statement);
        insert_statement = nil;
    }
    if (init_statement) {
        sqlite3_finalize(init_statement);
        init_statement = nil;
    }
    if (delete_statement) {
        sqlite3_finalize(delete_statement);
        delete_statement = nil;
    }
	
}

#pragma mark Properties
// Accessors implemented below. All the "get" accessors simply return the value directly, with no additional
// logic or steps for synchronization. The "set" accessors attempt to verify that the new value is definitely
// different from the old value, to minimize the amount of work done. Any "set" which actually results in changing
// data will mark the object as "dirty" - i.e., possessing data that has not been written to the database.
// All the "set" accessors copy data, rather than retain it. This is common for value objects - strings, numbers, 
// dates, data buffers, etc. This ensures that subsequent changes to either the original or the copy don't violate 
// the encapsulation of the owning object.

- (NSInteger)primaryKey {
    return primaryKey;
}

- (NSString *)english {
    return english;
}

- (void)setEnglish:(NSString *)aString {
    if ((!english && !aString) || (english && aString && [english isEqualToString:aString])) return;
    [english release];
    english = [aString copy];
}

- (NSString *)korean {
    return korean;
}

- (void)setKorean:(NSString *)aString {
    if ((!korean && !aString) || (korean && aString && [korean isEqualToString:aString])) return;
    [korean release];
    korean = [aString copy];
}

- (NSString *)url {
    return url;
}

- (void)setUrl:(NSString *)aString {
    if ((!url && !aString) || (url && aString && [url isEqualToString:aString])) return;
    [url release];
    url = [aString copy];
}

- (NSString *)pageEncoding {
	return pageEncoding;
};

- (void)setPageEncoding:(NSString *)aString {
	if ((!pageEncoding && !aString) || (pageEncoding && aString && [pageEncoding isEqualToString:aString])) return;
	[pageEncoding release];
	pageEncoding = [aString copy];
}

/*
- (int)useNumPad {
	return useNumPad;
}

- (void)setUseNumPad:(int)aValue {
	useNumPad = aValue;
}
 */

- (id)initWithPrimaryKey:(NSInteger) pk database:(sqlite3*)db
{
    if (self = [super init]) {
        primaryKey = pk;
        database = db;
        // Compile the query for retrieving book data. See insertNewBookIntoDatabase: for more detail.
        if (init_statement == nil) {
            // Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
            // This is a great way to optimize because frequently used queries can be compiled once, then with each
            // use new variable values can be bound to placeholders.
            const char *sql = "SELECT korean,english,url,page_encoding,flag,keywords FROM company WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
            [self setKorean: [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)]];
			[self setEnglish: [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)]];
			[self setUrl:[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)]];
			char* enc = (char *)sqlite3_column_text(init_statement, 3);
			if (enc)
				[self setPageEncoding:[NSString stringWithUTF8String:enc]];
			else
				[self setPageEncoding:nil];
			
			int flag = sqlite3_column_int(init_statement, 4);
			[self setUseNumPad: (flag & 0x01)];
			[self setFlagDaesin: (flag & 0x02)];
			
			{
				NSString* strKeywords = [NSString stringWithUTF8String:(char*)sqlite3_column_text(init_statement, 5)];
				self.keywords = [strKeywords componentsSeparatedByString:@","];
										 
			}
		} 
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
    }
	return self;
}

- (void) dealloc {
	[korean release];
	[english release];
	[url release];
	[pageEncoding release];
	self.keywords = nil;
	
	[super dealloc];
}

@end
