//
//  EditViewController.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CompanyListViewController, TextEntryViewController;
@class Item;

@interface EditViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	UITableView				*myTableView;
	UIBarButtonItem *saveButtonItem;
	UIBarButtonItem *deleteButtonItem;
	CompanyListViewController *companyListViewController;
	TextEntryViewController *textEntryViewController;
	Item *myItem;
	Item *newItem;
	BOOL isNewItem;
}

@property (nonatomic, retain) CompanyListViewController *companyListViewController;
@property (nonatomic, retain) TextEntryViewController *textEntryViewController;

- (void)setItem: (Item*)item;
- (void)setTextResult:(NSString*)text privateData:(NSInteger)aType;
- (void)setIntegerResult:(NSInteger)value privateData:(NSInteger)aType;

@end
