//
//  UpdateManager.h
//  TaekBae
//
//  Created by Keewon Seo on 10. 4. 18..
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	STATE_NONE = 0,
	STATE_VERSION,
	STATE_DB,
	STATE_UPDATE_INFO,
} UpdateManagerState;

@interface UpdateManager : NSObject <UIAlertViewDelegate> {
	NSURLConnection *connection;
	NSMutableData *receivedData;
	UpdateManagerState state;
	
	NSInteger newVersion;
	UIAlertView *alertViewDownloading;
}

- (void)check;
+ (BOOL)isNewVersion;

@end
