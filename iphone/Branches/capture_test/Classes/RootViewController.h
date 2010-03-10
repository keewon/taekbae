//
//  RootViewController.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditViewController, WebViewController;

@interface RootViewController : UITableViewController {
	
	UIToolbar *toolbar;
	UIBarButtonItem *addButtonItem;
	UIBarButtonItem *infoButtonItem;
	
	EditViewController *editViewController;
	WebViewController *webViewController;
}


@property (nonatomic, retain) EditViewController *editViewController;
@property (nonatomic, retain) WebViewController *webViewController;
@end
