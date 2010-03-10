//
//  CompanyListViewController.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CompanyListViewController.h"
#import "TaekBaeAppDelegate.h"
#import "Company.h"
#import "EditViewController.h"

@implementation CompanyListViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

/*
- (void)viewDidLoad {
    [super viewDidLoad];

	
	if (addButtonItem == nil)
	{
		addButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self action:@selector(companyMenu)];
	}
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = addButtonItem;
}
*/

- (void)viewWillAppear:(BOOL)animated {
	[clipBoardCompanies release];
	clipBoardCompanies = nil;
	
	if (prevValue < 0) {
		Class pasteBoardClass = (NSClassFromString(@"UIPasteboard"));
		if (pasteBoardClass != nil)
		{
			UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
			if (gpBoard.string)
			{
				NSString* text = [NSString stringWithString:gpBoard.string];
				
				if (text) {
					TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
					
					for (Company* company in [appDelegate  companys]) {
						for (NSString* key in company.keywords) {
							NSRange range = [text rangeOfString:key options:NSCaseInsensitiveSearch];
							if (range.location != NSNotFound) {
								if (clipBoardCompanies == nil) {
									clipBoardCompanies = [[NSMutableArray alloc] init];
								}
								[clipBoardCompanies addObject: company];
								break;
							}
						}
					}
				}
			}
		}
	}
	[self.tableView reloadData];
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([clipBoardCompanies count] > 0)
		return 2;
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if ([clipBoardCompanies count] > 0)
	{
		if (section == 0) {
			return NSLocalizedString(@"Companies from Clip Board", @"");
		}
		else {
			return NSLocalizedString(@"Other companies", @"");
		}
	}
	else {
		return @"";
	}
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([clipBoardCompanies count] > 0 && section == 0)
	{
		return [clipBoardCompanies count];
	}
	else
	{
		TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
		return [appDelegate.companys count];
	}
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if ([clipBoardCompanies count] > 0 && indexPath.section == 0) {
		Company* company = [clipBoardCompanies objectAtIndex: indexPath.row];
		[cell setText: [company korean]];
		[cell setAccessoryType: UITableViewCellAccessoryNone];
	}
	else {
		TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
		NSInteger count = [appDelegate.companys count];
		
		if (indexPath.row < count)
		{
			Company* company = [appDelegate.companys objectAtIndex: indexPath.row];
			[cell setText: [company korean]];
		}
		if (prevValue == indexPath.row)
		{
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		}
		else
		{
			[cell setAccessoryType:UITableViewCellAccessoryNone];
		}
	}
	
	[cell setSelected:NO];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	if (parent)
	{
		Company* company;
		if ([clipBoardCompanies count] > 0 && indexPath.section == 0) {
			company = [clipBoardCompanies objectAtIndex: indexPath.row];
		}
		else {
			TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
			company = [[appDelegate companys] objectAtIndex: indexPath.row];
		}
		
		[parent setIntegerResult: company.primaryKey privateData: returnType];

	}
	[self.navigationController popViewControllerAnimated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)dealloc {
	//[addButtonItem release];
	[clipBoardCompanies release];
    [super dealloc];
}

- (void)setParent: (EditViewController*)aParent prevValue:(NSInteger)aValue returnType:(NSInteger)aType
{
	[self setTitle:NSLocalizedString(@"Company", @"")];
	parent = aParent;
	prevValue = aValue;
	returnType = aType;
	[self.tableView reloadData];
}

/*
- (void) companyMenu
{
	NSLog(@"companyMenu\n");
}*/

@end

