//
//  ItemCell.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CELL_HEIGHT				60.0

@class Item;

@interface ItemCell : UITableViewCell {
	Item* item;
	NSString* explanation;
	
	UILabel			*nameLabel;
	UILabel			*explainLabel;	
}

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *explainLabel;

- (void)setItem: (Item*)aItem;

@end
