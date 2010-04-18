//
//  TaekBaeAppDelegate.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@class Item, Company;

@interface TaekBaeAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
	NSMutableArray *items;
	NSMutableArray *companys;
	sqlite3 *db_items;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *companys;

- (IBAction)removeItem:(Item*)item;
- (void)addItem:(Item*)item;

- (NSString*)getCompanyURL:(NSInteger)id;
- (NSString*)getCompanyName:(NSInteger)id;
- (NSInteger)getCompanyIndexByID:(NSInteger)id;
- (NSString*)getCompanyPageEncoding:(NSInteger)id;
- (BOOL) getCompanyUseNumPad:(NSInteger)id;
- (BOOL) getCompanyFlagDaesin:(NSInteger)id;

- (void) reloadCompanyDatabase;
@end

