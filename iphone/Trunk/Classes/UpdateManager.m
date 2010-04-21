//
//  UpdateManager.m
//  TaekBae
//
//  Created by Keewon Seo on 10. 4. 18..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UpdateManager.h"
#import "TaekBaeAppDelegate.h"

#if 1
NSString * UPDATE_URL[] = {
	nil,
	@"http://kldp.net/scm/viewvc.php/*checkout*/common/version.txt?root=taekbae",
	@"http://kldp.net/scm/viewvc.php/*checkout*/common/taekbae2_db.sql?root=taekbae",
	@"http://kldp.net/scm/viewvc.php/*checkout*/common/update.txt?root=taekbae"
};
#elif 0
NSString * UPDATE_URL[] = {
	nil,
	@"http://news.naver.com/scm/viewvc.php/*checkout*/common/version.txt?root=taekbae",
	@"http://news.naver.com/scm/viewvc.php/*checkout*/common/taekbae2_db.sql?root=taekbae",
	@"http://news.naver.com/scm/viewvc.php/*checkout*/common/update.txt?root=taekbae"
};
#else
NSString * UPDATE_URL[] = {
	nil,
	@"http://kldp.net/scm/viewvc.php/*checkout*/common/update_test/version.txt?root=taekbae",
	@"http://kldp.net/scm/viewvc.php/*checkout*/common/update_test/taekbae2_db.sql?root=taekbae",
	@"http://kldp.net/scm/viewvc.php/*checkout*/common/update_test/update.txt?root=taekbae"
};
#endif

#define CURRENT_COMPANY_DB_VERSION @"CURRENT_COMPANY_DB_VERSION"
#define ALERT_VIEW_DOWNLOADING 1001

@implementation UpdateManager

+ (NSInteger) currentVersion {
	NSString* currentVersionString = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_COMPANY_DB_VERSION];
	NSInteger currentVersion = 0;
	if (currentVersionString)
		currentVersion = [currentVersionString intValue];
	
	return currentVersion;
}

+ (NSInteger) defaultVersion {
	NSString* defaultVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"DEFAULT_COMPANY_DB_VERSION"];
	NSInteger defaultVersion = 0;
	if (defaultVersionString)
		defaultVersion = [defaultVersionString intValue];
	
	return defaultVersion;
}

+ (BOOL)isNewVersion {
	NSInteger currentVersion = [UpdateManager currentVersion];
	NSInteger defaultVersion = [UpdateManager defaultVersion];
	
	return defaultVersion > currentVersion;
}

+ (void)setNewVersion: (NSInteger)v {
	[[NSUserDefaults standardUserDefaults] setObject: [NSString stringWithFormat:@"%d", v] forKey: CURRENT_COMPANY_DB_VERSION];	
}

+ (void)setVersionToDefaultVersion {
	[UpdateManager setNewVersion: [UpdateManager defaultVersion]];
}

- (id) init {
	self = [super init];
	
	state = STATE_NONE;
	
	return self;
}

- (void) dealloc {
	[alertViewDownloading release]; alertViewDownloading = nil;
	[connection release]; connection = nil;
	[receivedData release]; receivedData = nil;
	[super dealloc];
}

- (void) check {
	[connection release];
	connection = nil;

	[receivedData release];
	receivedData = nil;
	
	state = STATE_VERSION;
	NSURL *url = [NSURL URLWithString: UPDATE_URL[state] ];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:10];
	
	connection = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: YES];
	
	if (connection) {
		receivedData = [[NSMutableData data] retain];
	}
	
	alertViewDownloading = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TaekBae", @"") 
													  message:NSLocalizedString(@"Checking update now", @"")
													 delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
											otherButtonTitles:nil];
	alertViewDownloading.tag = ALERT_VIEW_DOWNLOADING;
	[alertViewDownloading show];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[receivedData setLength: 0];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data
{   
	// append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere                    
    [receivedData appendData:data];
	
	NSLog(@"received\n");
}       

- (void)connection:(NSURLConnection *)aConnection  didFailWithError:(NSError *)error
{               
    // release the connection, and the data object
    [aConnection release];
	connection = nil;
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	receivedData = nil;
	
    // inform the user
    //NSLog(@"Connection failed! Error - %@ %@",
    //      [error localizedDescription],
    //      [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	NSLog(@"Connection failed! Error - %@",
          [error localizedDescription]);

	
	NSString *errorString;
	if (state == STATE_VERSION) {
		errorString = NSLocalizedString(@"Checking version failed", @"");
	} else if (state == STATE_UPDATE_INFO) {
		errorString = NSLocalizedString(@"Retrieving update information failed", @"");
	} else if (state == STATE_DB) {
		errorString = NSLocalizedString(@"Retrieving DB failed", @""); 
	} else {
		errorString = NSLocalizedString(@"System Error", @"");
	}

	if (alertViewDownloading) {
		[alertViewDownloading dismissWithClickedButtonIndex:0 animated:NO];
		[alertViewDownloading release];
		alertViewDownloading = nil;
	}
	
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
													message: [NSString stringWithFormat: @"%@ - %@", errorString, [error localizedDescription]]
												   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") 
										  otherButtonTitles: nil] autorelease];
	alert.tag = 0;
	[alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	if (alertViewDownloading) {
		[alertViewDownloading dismissWithClickedButtonIndex:0 animated:NO];
		[alertViewDownloading release];
		alertViewDownloading = nil;
	}
	
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	BOOL requestAgain = YES;
	
	if (state == STATE_VERSION) {
		
		NSInteger currentVersion = [UpdateManager currentVersion];
		
		NSString* newVersionString = [NSString stringWithCString:[receivedData bytes] encoding: NSUTF8StringEncoding];
		newVersion = 0;
		if (newVersionString)
			newVersion = [newVersionString intValue];
		
		NSLog(@"current version = %d, new version = %@\n", currentVersion, newVersionString);
		
		if (newVersion <= 0) {
			requestAgain = NO;
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
															 message: NSLocalizedString(@"Retrieving version information failed.", @"") 
															delegate:self 
												   cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles:nil] autorelease];
			[alert show];
		}
		else if (currentVersion >= newVersion) {
			requestAgain = NO;
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TaekBae", @"")
															 message: [NSString stringWithFormat: @"%@ (v.%d)",
																	   NSLocalizedString(@"You are using latest version.", @""),
																	   currentVersion]
															delegate:self 
												   cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles:nil] autorelease];
			[alert show];
		} else {
			[alertViewDownloading dismissWithClickedButtonIndex:0 animated:NO];
			[alertViewDownloading release];
			
			alertViewDownloading = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TaekBae", @"")
															 message: NSLocalizedString(@"Updating now", @"") 
															delegate:self 
												   cancelButtonTitle: nil otherButtonTitles:nil];
			alertViewDownloading.tag = ALERT_VIEW_DOWNLOADING;
			[alertViewDownloading show];
		}


		
	} else if (state == STATE_UPDATE_INFO) {
		size_t len = [receivedData length];
		char *buffer = malloc(len + 1);
		memcpy(buffer, [receivedData bytes], len);
		buffer[len] = 0;

		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TaekBae", @"")
														message: [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding] 
													   delegate:self 
											  cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles:nil] autorelease];
		[alert show];
		free(buffer);
	} else if (state == STATE_DB) {
		
		// First, test for existence.
		BOOL success;
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"taekbae2_db.sql"];
		NSString *tempDBPath = [documentsDirectory stringByAppendingPathComponent: @"taekbae2_db_temp.sql"];
		
		success = NO;
		{
			FILE* fp = fopen([tempDBPath cStringUsingEncoding: NSUTF8StringEncoding], "wb");
			if (fp) {
				size_t written = fwrite([receivedData bytes], 1, [receivedData length], fp);
				
				if (written == [receivedData length]) {
					success = YES;
				}
				fclose(fp);
			}
		}
		
		if (success) {
			success = [fileManager removeItemAtPath: writableDBPath error:&error];
			if (success) {
				success = [fileManager moveItemAtPath: tempDBPath toPath: writableDBPath error: &error];
				if (success) {
					[UpdateManager setNewVersion: newVersion];
					
					TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
					[appDelegate reloadCompanyDatabase];
				}
				else {
					NSLog(@"Failed to create writable database file with message '%@'.", [error localizedDescription]);
				}
			}
			else {
				NSLog(@"Failed to remove prev database '%@'.", [error localizedDescription]);
			}

		}
		
		if (!success) {
			requestAgain = NO;
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
															 message: NSLocalizedString(@"Writing DB to file system failed.", @"")
															delegate:self 
												   cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles:nil] autorelease];
			[alert show];
		}
	} else {
		NSLog(@"connectionDidFinishLoading - invalid state\n");
	}
	
	[receivedData release]; receivedData = nil;
	[aConnection release]; connection = nil;

	
	if (requestAgain && (state == STATE_VERSION || state == STATE_DB)) {
		if (state == STATE_VERSION) {
			state = STATE_DB;
		}
		else if (state == STATE_DB) {
			state = STATE_UPDATE_INFO;
		}
		
		NSURL *url = [NSURL URLWithString: UPDATE_URL[state] ];
		NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowedInMemoryOnly timeoutInterval:10];
		
		connection = [[NSURLConnection alloc] initWithRequest: request delegate: self startImmediately: YES];
		
		if (connection) {
			receivedData = [[NSMutableData data] retain];
		}
	}
	
	NSLog(@"connectionDidFinishLoading-\n");
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == ALERT_VIEW_DOWNLOADING) {
		[connection cancel];
		[connection release];
		connection = nil;
		[receivedData release];
		receivedData = nil;
		[alertViewDownloading release];
		alertViewDownloading = nil;
	}
}

@end
