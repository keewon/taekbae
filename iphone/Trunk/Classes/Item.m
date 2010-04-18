//
//  Item.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *init_statement = nil;
static sqlite3_stmt *delete_statement = nil;
static sqlite3_stmt *update_statement = nil;

@implementation Item

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
	if (update_statement) {
        sqlite3_finalize(update_statement);
        update_statement = nil;
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

- (NSString *)title {
    return title;
}

- (void)setTitle:(NSString *)aString {
    if ((!title && !aString) || (title && aString && [title isEqualToString:aString])) return;
    dirty = YES;
    [title release];
    title = [aString copy];
}

- (NSString *)number {
    return number;
}

- (void)setNumber:(NSString *)aString {
    if ((!number && !aString) || (number && aString && [number isEqualToString:aString])) return;
    dirty = YES;
    [number release];
    number = [aString copy];
}

- (NSInteger)companyID {
	return companyID;
}

- (void)setCompanyID:(NSInteger)aInteger {
	if (companyID == aInteger) return;
	
	dirty = YES;
	companyID = aInteger;
}

-(id)init
{
	primaryKey = 0;
	[self setNumber:@""];
	[self setCompanyID:0];
	[self setTitle:@""];
	
	return self;
}
- (id)initWithItem:(Item*)item
{
	primaryKey = [item primaryKey];
	[self setNumber: [item number]];
	[self setCompanyID: [item companyID]];
	[self setTitle: [item title]];
	
	return self;
}

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
            const char *sql = "SELECT title,company,number FROM item WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK) {
                NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
				return nil;
            }
        }
        // For this query, we bind the primary key to the first (and only) placeholder in the statement.
        // Note that the parameters are numbered from 1, not from 0.
        sqlite3_bind_int(init_statement, 1, primaryKey);
        if (sqlite3_step(init_statement) == SQLITE_ROW) {
            [self setTitle: [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)]];
			[self setCompanyID: sqlite3_column_int(init_statement, 1)];
			[self setNumber:[NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)]];
			
		} 
		else {
            self.title = @"No title";
        }
        // Reset the statement for future reuse.
        sqlite3_reset(init_statement);
        dirty = NO;
    }
	
	return self;
}

- (void)insertIntoDatabase:(sqlite3*)db
{
    database = db;
    // This query may be performed many times during the run of the application. As an optimization, a static
    // variable is used to store the SQLite compiled byte-code for the query, which is generated one time - the first
    // time the method is executed by any Book object.
    if (insert_statement == nil) {
        static char *sql = "INSERT INTO item (title,company,number) VALUES(?,?,?)";
        if (sqlite3_prepare_v2(database, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return;
        }
    }
    sqlite3_bind_text(insert_statement, 1, [title UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insert_statement, 2, companyID);
	sqlite3_bind_text(insert_statement, 3, [number UTF8String], -1, SQLITE_TRANSIENT);
    int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
        NSLog(@"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(database));
		return;
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        primaryKey = sqlite3_last_insert_rowid(database);
    }
	dirty = NO;
}

- (void)saveIfDirty 
{
    if (dirty) {
        // Write any changes to the database.
        // First, if needed, compile the dehydrate query.
        if (update_statement == nil) {
            const char *sql = "UPDATE item SET title=?, company=?, number=? WHERE pk=?";
            if (sqlite3_prepare_v2(database, sql, -1, &update_statement, NULL) != SQLITE_OK) {
                NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
				return;
            }
        }
        // Bind the query variables.
        sqlite3_bind_text(update_statement, 1, [title UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(update_statement, 2, companyID);
        sqlite3_bind_text(update_statement, 3, [number UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(update_statement, 4, primaryKey);
        // Execute the query.
        int success = sqlite3_step(update_statement);
        // Reset the query for the next use.
        sqlite3_reset(update_statement);
        // Handle errors.
        if (success != SQLITE_DONE) {
            NSLog(@"Error: failed to dehydrate with message '%s'.", sqlite3_errmsg(database));
			return;
        }
        // Update the object state with respect to unwritten changes.
        dirty = NO;
    }
}

- (void)deleteFromDatabase
{
    // Compile the delete statement if needed.
    if (delete_statement == nil) {
        const char *sql = "DELETE FROM item WHERE pk=?";
        if (sqlite3_prepare_v2(database, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
            NSLog(@"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			return;
        }
    }
    // Bind the primary key variable.
    sqlite3_bind_int(delete_statement, 1, primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSLog(@"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(database));
		return;
    }
}

@end
