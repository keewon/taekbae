//
//  RootViewController.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditViewController, WebViewController, UpdateManager;

@interface RootViewController : UIViewController {

	UIBarButtonItem *addButtonItem;
	UIBarButtonItem *infoButtonItem;
	IBOutlet UITableView *tableView;
	UIToolbar *toolbar;
	
	EditViewController *editViewController;
	WebViewController *webViewController;
	UpdateManager *updateManager;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) EditViewController *editViewController;
@property (nonatomic, retain) WebViewController *webViewController;
@property (nonatomic, retain) UpdateManager *updateManager;

- (IBAction) showInfo;
- (IBAction) checkUpdate;
@end
