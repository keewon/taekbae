//
//  ItemCell.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 12.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemCell.h"
#import "Item.h"
#import "TaekBaeAppDelegate.h"

@implementation ItemCell

@synthesize nameLabel;
@synthesize explainLabel;

#define LEFT_COLUMN_OFFSET		10
#define LEFT_COLUMN_WIDTH		220

#define UPPER_ROW_TOP			0


- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialization code
		// you can do this here specifically or at the table level for all cells
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		// Create label views to contain the various pieces of text that make up the cell.
		// Add these as subviews.
		nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];	// layoutSubViews will decide the final frame
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.opaque = NO;
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.font = [UIFont boldSystemFontOfSize:18];
		[self.contentView addSubview:nameLabel];
		
		explainLabel = [[UILabel alloc] initWithFrame:CGRectZero];	// layoutSubViews will decide the final frame
		explainLabel.backgroundColor = [UIColor clearColor];
		explainLabel.opaque = NO;
		explainLabel.textColor = [UIColor grayColor];
		explainLabel.highlightedTextColor = [UIColor whiteColor];
		explainLabel.font = [UIFont systemFontOfSize:14];
		[self.contentView addSubview:explainLabel];		
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	
	// In this example we will never be editing, but this illustrates the appropriate pattern
    CGRect frame = CGRectMake(contentRect.origin.x + LEFT_COLUMN_OFFSET, UPPER_ROW_TOP, LEFT_COLUMN_WIDTH, CELL_HEIGHT * 3 / 5);
	nameLabel.frame = frame;
	
	frame = CGRectMake(contentRect.origin.x + LEFT_COLUMN_OFFSET, UPPER_ROW_TOP + CELL_HEIGHT * 3 / 5, LEFT_COLUMN_WIDTH, CELL_HEIGHT * 2/ 5);
	explainLabel.frame = frame;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
	//nameLabel.highlighted = selected;
}


- (void)dealloc {
	[nameLabel release];
	[explainLabel release];
	[explanation release];
    [super dealloc];	
}

- (void)setItem: (Item*)aItem
{
	item = aItem;
	if ([[item title] isEqualToString:@""])
	{
		nameLabel.text = NSLocalizedString(@"Untitled", @"");
	}
	else
	{
		nameLabel.text = [item title];
	}

	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString* companyName = [appDelegate getCompanyName: [item companyID]];
	
	[explanation release];
	explanation = [[NSString stringWithFormat:@"%@ - %@", companyName, [item number]] retain];
	explainLabel.text = explanation;
	
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

@end
