//
//  CompanyListViewController.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditViewController;

@interface CompanyListViewController : UITableViewController {
	EditViewController* parent;
	NSInteger returnType;
	NSInteger prevValue;

	NSMutableArray *clipBoardCompanies;
	//UIBarButtonItem *addButtonItem;
}

- (void)setParent: (EditViewController*)aParent prevValue:(NSInteger)aValue returnType:(NSInteger)aType;

@end
