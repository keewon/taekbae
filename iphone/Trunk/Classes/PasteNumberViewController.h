//
//  PasteNumberViewController.h
//  TaekBae
//
//  Created by Keewon Seo on 10. 01. 08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PasteNumberDelegate<NSObject>
- (void) setNumber: (NSString*)number;
@end

@interface PasteNumberViewController : UITableViewController {
	id<PasteNumberDelegate> delegate;
	NSArray* candidates;
	NSString* clipBoardText;
}

@property(readwrite, assign) id<PasteNumberDelegate> delegate;
@property(nonatomic, assign) NSArray* candidates;
@property(nonatomic, assign) NSString* clipBoardText;

@end
