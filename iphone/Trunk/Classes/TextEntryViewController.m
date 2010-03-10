//
//  TextEntryViewController.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TextEntryViewController.h"
#import "EditViewController.h"
#import "TaekBaeAppDelegate.h"

#define kSupportedType @"public.plain-text"

@interface TextEntryViewController(Private)
- (void) parsePasteBoard;
@end

@implementation TextEntryViewController

@synthesize text1, buttonSave, buttonPasteNumbers, textValue;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		[self setTitle: myTitle];
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (buttonSave == nil)
	{
		buttonSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
	}
	
	UIBarButtonItem* buttonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
	
	self.navigationItem.leftBarButtonItem = buttonCancel;
	[buttonCancel release];

	
	self.navigationItem.rightBarButtonItem = buttonSave;
	text1.delegate = self;
	text1.clearButtonMode = YES;
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];

}

- (void)viewWillAppear:(BOOL)animated {

	buttonSave.enabled = enableSaveButton;
	text1.enabled = YES;
	[text1 setText: textValue];
	[text1 becomeFirstResponder];
	if (returnType == 0)
	{
		[text1 setKeyboardType:UIKeyboardTypeDefault];
	}
	else if (returnType == 2)
	{
		[text1 setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
	}
	else if (returnType == 3)
	{
		[text1 setKeyboardType:UIKeyboardTypeNumberPad];
	}
	//NSLog(@"text1: %@\n", [text1 text]);
	
	
	Class pasteBoardClass = (NSClassFromString(@"UIPasteboard"));
	if (pasteBoardClass == nil || returnType == 0)
	{
		[self.buttonPasteNumbers setHidden:YES];
	}
	else
	{
		[self.buttonPasteNumbers setHidden:NO];
		[self.buttonPasteNumbers setTitle:NSLocalizedString(@"Paste No.", @"") forState:UIControlStateNormal];
		[self parsePasteBoard];
		
		if ([numbers count] <= 0)
		{
			[self.buttonPasteNumbers setEnabled:NO];
		}
		else
		{
			[self.buttonPasteNumbers setEnabled:YES];
		}
	}	
}

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
	self.buttonSave = nil;
	self.buttonPasteNumbers = nil;
	self.textValue = nil;
	[numbers release];
    [super dealloc];
}

- (IBAction)textViewDidChange:(id)sender
{
	[buttonSave setEnabled:YES];
//	buttonSave.enabled = YES;
}

- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
	if (parent)
	{
		[parent setTextResult: [self.text1 text] privateData:returnType];
	}
    // Dismiss the modal view to return to the main list
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setParent: (EditViewController*)aParent title:(NSString*)aTitle prevValue: (NSString*)aValue returnType:(NSInteger)aType
{
	self.title = aTitle;
	parent = aParent;
	self.textValue = aValue;
	enableSaveButton = NO;
	returnType = aType;
}

- (void) parsePasteBoard
{
	Class pasteBoardClass = (NSClassFromString(@"UIPasteboard"));
	if (pasteBoardClass == nil)
	{
		return;
	}
	
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	if (!gpBoard.string)
		return;
	
	NSString* text = [NSString stringWithString:gpBoard.string];
	
	if (!text) {
		return;
	}
	
	[numbers release];
	numbers = nil;
	
	numbers = [[NSMutableArray alloc] init];
	
	NSInteger length = [text length];
	NSMutableString* str = [NSMutableString string];
	BOOL invalidChar = NO;
	for (NSInteger i=0; i<length; ++i)
	{
		unichar ch = [text characterAtIndex:i];
		if ('0' <= ch && ch <= '9')
		{
			[str appendFormat:@"%C", ch];
			invalidChar = NO;
		}
		else if (('-' == ch || ' ' == ch) && invalidChar == NO)
		{
			invalidChar = YES;
		}
		else
		{
			if ([str length] > 0)
			{
				[numbers addObject: [NSString stringWithString: str]];
			}
			str = [NSMutableString string];
		}
	}
	if ([str length] > 0)
	{
		[numbers addObject: [NSString stringWithString: str]];
	}
	
	if ([numbers count] <= 0)
	{
		[numbers release];
		numbers = nil;
	}
	
}

- (IBAction)pasteNumbers:(id)sender
{
	if ([numbers count] <= 0)
	{
		[numbers release];
		numbers = nil;
		return;
	}
	
	PasteNumberViewController* vc = [[PasteNumberViewController alloc] initWithStyle:UITableViewStylePlain];
	[vc setTitle: NSLocalizedString(@"Select Numbers", @"")];
	[vc setCandidates: numbers];
	[vc setDelegate: self];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

- (void) selectCell: (NSInteger)index
{
	if (index < 0 || index >= [numbers count])
		return;
	
	NSString* number = [numbers objectAtIndex:index];
	
	self.textValue = number;
	enableSaveButton = YES;
}

@end
