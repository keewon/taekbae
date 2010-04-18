//
//  TaekBaeAppDelegate.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "TaekBaeAppDelegate.h"
#import "RootViewController.h"
#import "Item.h"
#import "Company.h"
#import "UpdateManager.h"

@interface TaekBaeAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
@end

@implementation TaekBaeAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize items, companys;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users, 
    // so we need to create a copy of it in the application's Documents directory.     
    [self createEditableCopyOfDatabaseIfNeeded];
    // Call internal method to initialize database connection
    [self initializeDatabase];
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	[items makeObjectsPerformSelector:@selector(saveIfDirty)];
	[Item finalizeStatements];
	[Company finalizeStatements];
	
	if (sqlite3_close(db_items) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(db_items));
    }
}

- (void)removeItem:(Item *)item {
	//NSLog(@"removeItem: %@ ", [item title]);
    [item deleteFromDatabase];
    [items removeObject:item];
}

- (void)addItem:(Item *)item {
	//NSLog(@"addItem: %@ ", [item title]);
    [item insertIntoDatabase:db_items];
	[items insertObject:item atIndex:0];
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[items release];
	[companys release];
	[super dealloc];
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"taekbae_db.sql"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
	
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"taekbae_db.sql"];
	//[fileManager removeItemAtPath:writableDBPath error:&error];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSLog(@"Failed to create writable taekbae_db file with message '%@'.", [error localizedDescription]);
		
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
															message: [NSString stringWithFormat:@"%@ (1) - %@",
																	  NSLocalizedString(@"Writing DB failed", @""),
																	  [error localizedDescription]]
														   delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"")
												   otherButtonTitles:nil] autorelease];
		[alertView show];
		return;
    }
	
	if ([UpdateManager isNewVersion]) {
		writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"taekbae2_db.sql"];
		defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"taekbae2_db.sql"];
		//[fileManager removeItemAtPath:writableDBPath error:&error];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) {
			NSLog(@"Failed to create writable taekbae2_db file with message '%@'.", [error localizedDescription]);
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
																 message: [NSString stringWithFormat:@"%@ (2) - %@",
																		   NSLocalizedString(@"Writing DB failed", @""),
																		   [error localizedDescription]]
																delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"")
													   otherButtonTitles:nil] autorelease];
			[alertView show];
		}
	}
}


- (void) reloadCompanyDatabase {
	self.companys = nil;
	[Company finalizeStatements];
	
	NSMutableArray *companyArray = [[NSMutableArray alloc] init];
	self.companys = companyArray;
	[companyArray release];
	
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//NSString *companyDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"taekbae2_db.sql"];
	NSString *companyDBPath = [documentsDirectory stringByAppendingPathComponent:@"taekbae2_db.sql"];
	sqlite3* db_companys=NULL;
	//sqlite3* db_companys = db_items;
	if (sqlite3_open([companyDBPath UTF8String], &db_companys) == SQLITE_OK)
	{
		// Get the primary key for all companys.
		const char *sql = "SELECT pk FROM company ORDER BY korean";
		sqlite3_stmt *statement=NULL;
		// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
		// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
		if (sqlite3_prepare_v2(db_companys, sql, -1, &statement, NULL) == SQLITE_OK) {
			// We "step" through the results - once for each row.
			while (sqlite3_step(statement) == SQLITE_ROW) {
				// The second parameter indicates the column index into the result set.
				int primaryKey = sqlite3_column_int(statement, 0);
				// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
				// autorelease is slightly more expensive than release. This design choice has nothing to do with
				// actual memory management - at the end of this block of code, all the book objects allocated
				// here will be in memory regardless of whether we use autorelease or release, because they are
				// retained by the books array.
				Company *item = [[Company alloc] initWithPrimaryKey:primaryKey database:db_companys];
				[companys addObject:item];
				[item release];
			}
		}
		// "Finalize" the statement - releases the resources associated with the statement.
		if (statement)
			sqlite3_finalize(statement);
	}
	else {
		// Even though the open failed, call close to properly clean up resources.
		sqlite3_close(db_companys);
		NSLog(@"Failed to open db_companys with message '%s'.", sqlite3_errmsg(db_companys));
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
															 message: NSLocalizedString(@"Loading DB failed. Please use 'Update' again.", @"")
															delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"")
												   otherButtonTitles:nil] autorelease];
		[alertView show];
		// Additional error handling, as appropriate...
	}
}

// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    self.items = itemArray;
    [itemArray release];

	// The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"taekbae_db.sql"];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &db_items) == SQLITE_OK) {
		{
			// Get the primary key for all items.
			const char *sql = "SELECT pk FROM item order by pk desc";
			sqlite3_stmt *statement=NULL;
			// Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
			// The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.        
			if (sqlite3_prepare_v2(db_items, sql, -1, &statement, NULL) == SQLITE_OK) {
				// We "step" through the results - once for each row.
				while (sqlite3_step(statement) == SQLITE_ROW) {
					// The second parameter indicates the column index into the result set.
					int primaryKey = sqlite3_column_int(statement, 0);
					// We avoid the alloc-init-autorelease pattern here because we are in a tight loop and
					// autorelease is slightly more expensive than release. This design choice has nothing to do with
					// actual memory management - at the end of this block of code, all the book objects allocated
					// here will be in memory regardless of whether we use autorelease or release, because they are
					// retained by the books array.
					Item *item = [[Item alloc] initWithPrimaryKey:primaryKey database:db_items];
					[items addObject:item];
					[item release];
				}
			}
			// "Finalize" the statement - releases the resources associated with the statement.
			if (statement)
				sqlite3_finalize(statement);		
		}
	} else {
		// Even though the open failed, call close to properly clean up resources.
		sqlite3_close(db_items);
		NSLog( @"Failed to open database with message '%s'.", sqlite3_errmsg(db_items));
		// Additional error handling, as appropriate...
		
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
															 message: NSLocalizedString(@"Loading DB failed. Please reinstall this program. Sorry.", @"")
															delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"")
												   otherButtonTitles:nil] autorelease];
		[alertView show];
	}
	
	[self reloadCompanyDatabase];
}

- (NSString*)getCompanyName:(NSInteger)id
{
	int i;
	int count = [companys count];
	for (i=0; i<count; ++i)
	{
		if ( [[companys objectAtIndex:i] primaryKey] == id )
		{
			return [[companys objectAtIndex:i] korean];
		}
	}
	return NSLocalizedString(@"Undefined", @"");
}

- (NSString*)getCompanyURL:(NSInteger)id
{
	int i;
	int count = [companys count];
	for (i=0; i<count; ++i)
	{
		if ( [[companys objectAtIndex:i] primaryKey] == id )
		{
			return [[companys objectAtIndex:i] url];
		}
	}
	return nil;	
}

- (NSString*)getCompanyPageEncoding:(NSInteger)id
{
	int i;
	int count = [companys count];
	for (i=0; i<count; ++i)
	{
		if ( [[companys objectAtIndex:i] primaryKey] == id )
		{
			return [[companys objectAtIndex:i] pageEncoding];
		}
	}
	return nil;	
}

- (NSInteger)getCompanyIndexByID:(NSInteger)id
{
	int i;
	int count = [companys count];
	for (i=0; i<count; ++i)
	{
		if ( [[companys objectAtIndex:i] primaryKey] == id )
		{
			return i;
		}
	}
	return -1;	
}

- (BOOL) getCompanyUseNumPad:(NSInteger)id
{
	int i;
	int count = [companys count];
	for (i=0; i<count; ++i)
	{
		if ( [[companys objectAtIndex:i] primaryKey] == id )
		{
			return [[companys objectAtIndex:i] useNumPad] != 0;
		}
	}
	return NO;
}

- (BOOL) getCompanyFlagDaesin:(NSInteger)id
{
	int i;
	int count = [companys count];
	for (i=0; i<count; ++i)
	{
		if ( [[companys objectAtIndex:i] primaryKey] == id )
		{
			return [[companys objectAtIndex:i] flagDaesin] != 0;
		}
	}
	return NO;
}
@end
