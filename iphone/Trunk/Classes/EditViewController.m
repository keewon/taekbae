//
//  EditViewController.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "CompanyListViewController.h"
#import "TextEntryViewController.h"
#import "TaekBaeAppDelegate.h"
#import "Item.h"

@implementation EditViewController

@synthesize companyListViewController;
@synthesize textEntryViewController;

- (id)init
{
	self = [super init];
	newItem = [[Item alloc] init];

	return self;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// create and configure the table view
	myTableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];	
	myTableView.delegate = self;
	myTableView.dataSource = self;
	myTableView.autoresizesSubviews = YES;
	self.view = myTableView;

	
	//[saveButtonItem setEnabled:NO];		
	//self.navigationItem.rightBarButtonItem = saveButtonItem;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[myTableView setDelegate:nil];
	[myTableView release];
	
	[companyListViewController release];
	[textEntryViewController release];
	[newItem release];
	
	[saveButtonItem release];
	[deleteButtonItem release];
	
    [super dealloc];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title;

	if (section == 0)
	{
		title = NSLocalizedString(@"Name", @"");
	}
	else if (section == 1)
	{
		title = NSLocalizedString(@"Company", @"");
	}
	else if (section == 2)
	{
		title = NSLocalizedString(@"Item No.", @"");
	}
	
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	if (myItem == nil)
	{
		[cell setText: @""];
	}
	else
	{
		switch (indexPath.section)
		{
			case 0:
				[cell setText: [myItem title]];
				break;
			case 1:
			{
				TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
				NSString* companyName = [appDelegate getCompanyName: [myItem companyID]];
				[cell setText: companyName];
			}
				break;
			case 2:
				[cell setText: [myItem number]];
				break;
		}
	}
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	[cell setSelected:NO];
	 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (indexPath.section == 1)
	{
		if (companyListViewController == nil)
		{
			CompanyListViewController* clvc = [[CompanyListViewController alloc] initWithStyle:UITableViewStyleGrouped];
			self.companyListViewController = clvc;
			[clvc release];
		}
		
		TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		NSInteger companyIndex = [appDelegate getCompanyIndexByID: [myItem companyID]];
		[self.companyListViewController setParent:self prevValue: companyIndex returnType:1 ];
		[self.navigationController pushViewController: companyListViewController animated:YES];
	}
	else
	{
		NSString* textViewTitle = nil;
		if (textEntryViewController == nil)
		{
			TextEntryViewController* tevc = [[TextEntryViewController alloc] 
											 initWithNibName:@"TextEntryViewController" bundle: [NSBundle mainBundle]];
			self.textEntryViewController = tevc;
			[tevc release];
		}
		if (indexPath.section == 0)
		{
			textViewTitle = NSLocalizedString(@"Name", @"");
			[self.textEntryViewController setParent:self title:textViewTitle prevValue:[myItem title] returnType:0];
		}
		else if (indexPath.section == 2)
		{
			textViewTitle = NSLocalizedString(@"Item No.", @"");
			
			TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
			BOOL useNumPad = [appDelegate getCompanyUseNumPad: [myItem companyID]];
			
			if (useNumPad)
			{
				[self.textEntryViewController setParent:self title:textViewTitle prevValue:[myItem number] returnType:3];
			}
			else
			{
				[self.textEntryViewController setParent:self title:textViewTitle prevValue:[myItem number] returnType:2];
			}
		}
		
		//[self.textEntryViewController setTitle:textViewTitle];
		
		[self.navigationController pushViewController: textEntryViewController animated:YES];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[myTableView deselectRowAtIndexPath: [myTableView indexPathForSelectedRow] animated: YES];
}

- (void)setItem: (Item*)item
{
	myItem = item;
	
	if (item == nil)
	{
		isNewItem = YES;
		[self setTitle: NSLocalizedString(@"New Item", @"")];
		[newItem init];
		myItem = newItem;
		
		if (nil == saveButtonItem)
		{
			saveButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveItem)];
		}
		
		self.navigationItem.rightBarButtonItem = saveButtonItem;
		[saveButtonItem setEnabled:NO];
	}
	else
	{
		/*
		if (nil == deleteButtonItem)
		{
			deleteButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteItem)];
		}
		 */
		isNewItem = NO;
		[self setTitle: NSLocalizedString(@"Edit Item", @"")];
		//self.navigationItem.rightBarButtonItem = deleteButtonItem;
		self.navigationItem.rightBarButtonItem = nil;
	}
	[myTableView reloadData];
}

- (void)setTextResult:(NSString*)text privateData:(NSInteger)aType
{
	if (aType == 0)
	{
		[myItem setTitle: text];
	}
	else if (aType == 2 || aType == 3)
	{
		[myItem setNumber: text];
	}
	
	if ([[myItem number] isEqualToString:@""] || [myItem companyID] <= 0)
	{
		[saveButtonItem setEnabled:NO];
	}
	else
	{
		[saveButtonItem setEnabled:YES];
	}
	[myTableView reloadData];
}

- (void)setIntegerResult:(NSInteger)value privateData:(NSInteger)aType
{
	if (aType == 1)
	{
//		TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSInteger companyID = value; //[[appDelegate.companys objectAtIndex: value] primaryKey];
		[myItem setCompanyID: companyID];
	}
	
	if ([[myItem number] isEqualToString:@""] || [myItem companyID] <= 0)
	{
		[saveButtonItem setEnabled:NO];
	}
	else
	{
		[saveButtonItem setEnabled:YES];
	}

	[myTableView reloadData];
}

- (void)saveItem
{
	if (isNewItem)
	{
		TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
		Item* item = [[Item alloc] initWithItem: newItem];
		[appDelegate addItem: item];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
	}
}

- (void)deleteItem
{
	if (!isNewItem)
	{
		// open a dialog with an OK and cancel button
		UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
												delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
												destructiveButtonTitle:NSLocalizedString(@"Delete", @"") otherButtonTitles:nil];
		actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
		[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
		[actionSheet release];
		
	}	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
		TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
		
		[appDelegate removeItem: myItem];
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		//NSLog(@"cancel");
	}
	
	//[myTableView deselectRowAtIndexPath:[myTableView indexPathForSelectedRow] animated:NO];
}

@end
