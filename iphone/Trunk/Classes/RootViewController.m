//
//  RootViewController.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "RootViewController.h"
#import "EditViewController.h"
#import "WebViewController.h"
#import "TaekBaeAppDelegate.h"
#import "Company.h"
#import "Item.h"
#import "ItemCell.h"
#import "UpdateManager.h"

#define NEWS_IN_TABLE 0

@interface RootViewController (Private)
- (void)editItem: (Item*)item;
- (void)showInfo;
@end


@implementation RootViewController

@synthesize tableView;
@synthesize editViewController;
@synthesize webViewController;
@synthesize updateManager;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.allowsSelectionDuringEditing = YES;
	
#if 1
	if (addButtonItem == nil)
	{
		addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
	}
	/*
	if (infoButtonItem == nil)
	{
		infoButtonItem = [[UIBarButtonItem alloc]
						  initWithTitle: NSLocalizedString(@"Info", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showInfo)];
	}
	 */

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
	self.navigationItem.rightBarButtonItem = addButtonItem;
#endif
#if 0
	// "Segmented" control to the right
	UISegmentedControl *segmentedControl = [[[UISegmentedControl alloc] initWithItems:
											 [NSArray arrayWithObjects:
											  NSLocalizedString(@"Add", @""),
											  NSLocalizedString(@"Edit", @""),
											  nil]] autorelease];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.frame = CGRectMake(0, 0, 90, 30.0);
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	
	//defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
	
	UIBarButtonItem *segmentBarItem = [[[UIBarButtonItem alloc] initWithCustomView:segmentedControl] autorelease];
	self.navigationItem.rightBarButtonItem = segmentBarItem;	
#endif
	
/*	
#if 1
	//[ add toolbar and info button
	
	toolbar = [[UIToolbar alloc] init];
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];
	
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect rootViewBounds = self.parentViewController.view.bounds;
	CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
	CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
	CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight,
								 rootViewWidth, toolbarHeight);
	
	[toolbar setFrame:rectArea];
	
	UIBarButtonItem *infoButton = [[UIBarButtonItem alloc]
								   initWithTitle: NSLocalizedString(@"Info", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(showInfo)];
	[toolbar setItems:[NSArray arrayWithObjects:infoButton, nil]];
	
	
	[self.navigationController.view addSubview:toolbar];

#endif
 */
	self.title = NSLocalizedString(@"TaekBae", @"");
}

- (void)viewDidUnload {
	self.tableView = nil;
	[super viewDidUnload];	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[toolbar setHidden: NO];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[toolbar setHidden: YES];
}

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
	self.webViewController = nil;
	self.editViewController = nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];

#if NEWS_IN_TABLE
    return [appDelegate.items count] + 1;
#else
	return [appDelegate.items count];
#endif
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return CELL_HEIGHT;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

#if NEWS_IN_TABLE
	static NSString *CellIdentifier1 = @"Cell";
#endif
	static NSString *CellIdentifier2 = @"ItemCell";
	
    // Set up the cell...
	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
	
#if NEWS_IN_TABLE
	if ([appDelegate.items count] <= indexPath.row)
	{
		UITableViewCell *cell = (ItemCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier1] autorelease];

		[cell setText: NSLocalizedString(@"About TaekBae", @"")];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		return cell;
	}
	else
#endif
	{
		ItemCell *cell = (ItemCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier2];
		if (cell == nil) {			
			cell = [[[ItemCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier2] autorelease];
		}
		

		Item* item = [appDelegate.items objectAtIndex:indexPath.row];
		
		//[cell setText: text];
		[cell setItem: item];
		//cell.hidesAccessoryWhenEditing = NO;
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
		return cell;
	}
}

- (void) openItem: (NSInteger) index
{
	NSString* url;
	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];

	Item* item = [appDelegate.items objectAtIndex:index];
	NSString* companyURL = [appDelegate getCompanyURL: [item companyID]];
	
	if (companyURL == nil)
	{
		// open an alert with just an OK button
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
														message:NSLocalizedString(@"Please select delivery company.", @"")
													   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
		[alert show];	
		[alert release];
		return;
	}
	
	if ( [appDelegate getCompanyFlagDaesin: [item companyID]] )
	{
		// Daesin taekbae: 4 - 3 - 6
		NSRange range;
		NSString *n1=@"", *n2=@"", *n3=@"";
		NSString *number = [item number];
		if ( [number length] >= 4 )
		{
			range.location = 0; range.length = 4;
			n1 = [number substringWithRange:range];
		}
		if ( [number length] >= 7 )
		{
			range.location = 4; range.length = 3;
			n2 = [number substringWithRange:range];
		}
		if ( [number length] >= 13 )
		{
			range.location = 7; range.length = 6;
			n3 = [number substringWithRange:range];
		}
		
		url = [NSString stringWithFormat:@"%@billno1=%@&billno2=%@&billno3=%@",
			   companyURL, n1, n2, n3];
		
	}
	else
	{
		url = [NSString stringWithFormat:@"%@%@",
			   companyURL, [item number]];
	}
	
	NSLog(@"url=%@\n", url);
	
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	NSString* companyPageEncoding = [appDelegate getCompanyPageEncoding: [item companyID]];
	
	if (self.webViewController == nil) {
		WebViewController* wvc = [[WebViewController alloc] initWithNibName:@"WebView" bundle: [NSBundle mainBundle]];
		self.webViewController = wvc;
		[wvc release];
	}
	
	[self.webViewController setURL: url title: [item title] encoding:companyPageEncoding];
	[self.navigationController pushViewController:webViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	
	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
#if NEWS_IN_TABLE
	if ([appDelegate.items count] <= indexPath.row)
	{
		[self showInfo];
		self.editing = NO;
	}
	else
#endif
	{
		if (self.editing)
		{
			if ([appDelegate.items count] > indexPath.row)
			{
				Item* item = [appDelegate.items objectAtIndex:indexPath.row];
				[self editItem: item];
			}
		}
		else
		{
			[self openItem: indexPath.row];
		}
		
	}	
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.

	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if ([appDelegate.items count] <= indexPath.row)
		return NO;
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		 TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
		 Item* item = [[appDelegate items] objectAtIndex: indexPath.row];
		 if (item)
		 {
			 [appDelegate removeItem: item];
		 }
		
        // Delete the row from the data source
        [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


// Override to support rearranging the table view.
#if 0 // not now 
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];

	NSMutableArray* items = [appDelegate items];
	Item* item = [[items objectAtIndex: fromIndexPath.row] retain];

	[items removeObjectAtIndex: fromIndexPath.row];
	[items insertObject:item atIndex:toIndexPath.row];
	
	[item release];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (indexPath.row < [appDelegate.items count]) {
		return YES;
	}
    return NO;
}
#endif

/*
- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDetailDisclosureButton;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	TaekBaeAppDelegate *appDelegate = (TaekBaeAppDelegate *)[[UIApplication sharedApplication] delegate];
	Item* item = [appDelegate.items objectAtIndex:indexPath.row];
	
	[self editItem: item];
}
 */

/*
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath;
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}
 */

- (void)dealloc {
	self.webViewController = nil;
	self.editViewController = nil;
	self.updateManager = nil;
	[toolbar release];
	[addButtonItem release];
	[infoButtonItem release];
    [super dealloc];	
}

- (void)editItem: (Item*)item {
	// Navigation logic -- create and push a new view controller
	if (self.editViewController == nil) {
		EditViewController* evc = [[EditViewController alloc] init];
		self.editViewController = evc;
		[evc release];
	}
	
	[self.editViewController setItem: item];
	[self.navigationController pushViewController:editViewController animated:YES];
	
	self.editing = NO;
}

- (void)addItem {
	[self editItem: nil];
}   

- (IBAction) showInfo {
	if (self.webViewController == nil) {
		WebViewController* wvc = [[WebViewController alloc] initWithNibName:@"WebView" bundle: [NSBundle mainBundle]];
		self.webViewController = wvc;
		[wvc release];
	}
	
	[self.webViewController setURL: NSLocalizedString(@"homepage url", @"") 
							 title: NSLocalizedString(@"About TaekBae", @"") encoding:nil];
	[self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction) checkUpdate {
	if (!self.updateManager)
	{
		self.updateManager = [[UpdateManager alloc] init];
	}
	[self.updateManager check];
}


@end

