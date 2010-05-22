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
#import "TessWrapper.h"
#import "ImageUtils.h"
#import "Pair.h"

#define kSupportedType @"public.plain-text"

//#define TEST_CAPTURE 1
#define CAPTURE_Y 120
#define CAPTURE_HEIGHT 60

@interface TextEntryViewController(Private)
- (void) parsePasteBoard;
- (void) cancelCapture;
- (void) captureThis;
@end

@implementation TextEntryViewController

@synthesize text1, buttonSave, buttonPasteNumbers, textValue, buttonCapture;

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
	if (pasteBoardClass == nil || returnType != 3)
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
	
	if (returnType == 3 &&
		[UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] &&
		[UIImagePickerController instancesRespondToSelector: @selector(setCameraOverlayView:)]
		) {
		[self.buttonCapture setHidden: NO];
	}
	else {
#ifdef TEST_CAPTURE
		[self.buttonCapture setHidden:NO];
#else
		[self.buttonCapture setHidden:YES];
#endif
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
	[clipBoardText release];
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
	
	[clipBoardText release]; clipBoardText = nil;
	
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	if (!gpBoard.string)
		return;
	
	NSString* text = [NSString stringWithString:gpBoard.string];
	
	if (!text) {
		return;
	}
	
	clipBoardText = [text retain];
	
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
			if ([str length] > 2) // 0 -> 2 (reasonable length)
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

- (void) selectCell: (NSInteger)index
{
	if (index < 0 || index >= [numbers count])
		return;
	
	NSString* number = [numbers objectAtIndex:index];
	
	self.textValue = number;
	enableSaveButton = YES;
}


- (IBAction)pasteNumbers:(id)sender
{
	if ([numbers count] <= 0)
	{
		[numbers release];
		numbers = nil;
		return;
	}
	
	PasteNumberViewController* vc = [[PasteNumberViewController alloc] initWithStyle:UITableViewStyleGrouped];
	[vc setTitle: NSLocalizedString(@"Select Numbers", @"")];
	[vc setCandidates: numbers];
	[vc setClipBoardText: clipBoardText];
	[vc setDelegate: self];
	[self.navigationController pushViewController:vc animated:YES];
	[vc release];
}

#ifdef TEST_CAPTURE
- (IBAction)capture:(id)sender
{
	UIImage* image = [UIImage imageNamed: @"sample4.jpg"];
	CGRect rect = CGRectMake(0, CAPTURE_Y, 320, CAPTURE_HEIGHT);
	Image *screenImage = fromCGImage([image CGImage], rect);
	CGImageRef c1 = toCGImage(screenImage);
	UIImage* u1 = [UIImage imageWithCGImage: c1];
	CGImageRelease(c1);
	
	UIImageWriteToSavedPhotosAlbum(u1, nil, nil, nil);
	
	for (int y=0; y<CAPTURE_HEIGHT; ++y) {
		for (int x=0; x<320; ++x) {
			//unsigned char* p = &(screenImage->pixels[y][x]);
			unsigned char* p = &(screenImage->rawImage[y * width + x]);
			
			if (*p > 90)
				*p = 255;
			else
				*p = 0;
			
			if (x > 160) {
			if (*p == 0)
				printf("0");
			else
				printf(" ");
			}
		}
		printf("\n");
	}
	printf("\n");
	
	rect = CGRectMake(0, 0, 320, CAPTURE_HEIGHT);

	NSString* result = [TessWrapper getNumber: screenImage->rawImage rect: rect];
	NSLog(@"result = %@\n", result);
	
	CGImageRef c2 = toCGImage(screenImage);
	UIImage* u2 = [UIImage imageWithCGImage: c2];
	
	UIImageWriteToSavedPhotosAlbum(u2, nil, nil, nil);
	
	CGImageRelease(c2);
	destroyImage(screenImage);
}

#else

#define MARGIN_X 20
#define MARGIN_Y 20

#define BORDER_GREEN_WINDOW 1
#define BORDER_WHITE_CORNER 2

#define BORDER_TYPE BORDER_GREEN_WINDOW

#if BORDER_TYPE == BORDER_GREEN_WINDOW

#define TAG_BORDER_TOP 1001
#define TAG_BORDER_BOTTOM 1002
#define TAG_BORDER_LEFT 1003
#define TAG_BORDER_RIGHT 1004

- (IBAction)changeWindowSize: (id)sender
{
	UISlider* senderView = (UISlider*)sender;
	UIView* parentView = senderView.superview;
	
	UIView* topView = [parentView viewWithTag: TAG_BORDER_TOP];
	UIView* bottomView = [parentView viewWithTag: TAG_BORDER_BOTTOM];
	UIView* leftView = [parentView viewWithTag: TAG_BORDER_LEFT];
	UIView* rightView = [parentView viewWithTag: TAG_BORDER_RIGHT];
	
	CGFloat value = senderView.value;
	
	captureRect = CGRectMake(142 - value*140, CAPTURE_Y, 36 + value*2*140, CAPTURE_HEIGHT);
	
	CGRect rect;
	
	
	rect = leftView.frame;
	rect.origin.x = 140 - value*140;
	leftView.frame = rect;
	
	rect = rightView.frame;
	rect.origin.x = 178 + value*140;
	rightView.frame = rect;
	
	rect = topView.frame;
	rect.size.width = captureRect.size.width + 4;
	rect.origin.x = 140 - value*140;
	topView.frame = rect;
	
	rect = bottomView.frame;
	rect.size.width = captureRect.size.width + 4;
	rect.origin.x = 140 - value*140;
	bottomView.frame = rect;
}
#elif BORDER_TYPE == BORDER_WHITE_CORNER
#define TAG_VIEW_LEFT 1001
#define TAG_VIEW_RIGHT 1002

- (IBAction)changeWindowSize: (id)sender
{
	UISlider* senderView = (UISlider*)sender;
	UIView* parentView = senderView.superview;
	
	UIView* leftView = [parentView viewWithTag: TAG_VIEW_LEFT];
	UIView* rightView = [parentView viewWithTag: TAG_VIEW_RIGHT];
	
	CGFloat value = senderView.value;
	
	captureRect = CGRectMake(142 - value*140, CAPTURE_Y, 36 + value*2*140, CAPTURE_HEIGHT);
	
	CGRect rect;
	
	
	rect = leftView.frame;
	rect.origin.x = 140 - value*140 - rect.size.width;
	leftView.frame = rect;
	
	rect = rightView.frame;
	rect.origin.x = 180 + value*140;
	rightView.frame = rect;
}

#endif

- (IBAction)capture:(id)sender
{
	UIButton *buttonCancel = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	[buttonCancel setFrame: CGRectMake(MARGIN_X, CAPTURE_Y+CAPTURE_HEIGHT+MARGIN_Y*2+33, 72, 33)];
	[buttonCancel setTitle: NSLocalizedString(@"Cancel", "") forState:UIControlStateNormal];
	[buttonCancel addTarget:self action:@selector(finishCapture) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *buttonOK = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	[buttonOK setFrame: CGRectMake(MARGIN_X, CAPTURE_Y+CAPTURE_HEIGHT + MARGIN_Y, 72, 33)];
	[buttonOK setTitle: NSLocalizedString(@"OK", "") forState:UIControlStateNormal];
	[buttonOK addTarget:self action:@selector(captureThis) forControlEvents:UIControlEventTouchUpInside];
						  
	UIView* parentView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
	
	[parentView addSubview: buttonOK];
	[parentView addSubview: buttonCancel];
	
	UISlider* slider = [[[UISlider alloc] initWithFrame: CGRectMake(160, CAPTURE_Y+CAPTURE_HEIGHT+MARGIN_Y, 160-MARGIN_X, 40)] autorelease];
	[slider setMinimumValue: 0];
	[slider setMaximumValue: 1];
	[slider setValue:1];
	[slider addTarget:self action:@selector(changeWindowSize:) forControlEvents:UIControlEventValueChanged];

	[parentView addSubview: slider];
	
	[labelCaptureResult release];
	labelCaptureResult = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320, 44)];
	[labelCaptureResult setText:@""];
	[labelCaptureResult setBackgroundColor: [UIColor blackColor]];
	[labelCaptureResult setTextColor: [UIColor whiteColor]];
	[labelCaptureResult setAlpha: 0.5];
	[labelCaptureResult setNumberOfLines: 2];
	[parentView addSubview: labelCaptureResult];
	
	UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 480-88, 320, 88)];
	[desc setText: NSLocalizedString(@"Camera Usage", @"")];
	[desc setBackgroundColor: [UIColor blackColor]];
	[desc setTextColor: [UIColor whiteColor]];
	[desc setAlpha: 0.5];
	[desc setNumberOfLines: 4];
	[parentView addSubview: desc];

#if BORDER_TYPE == BORDER_GREEN_WINDOW
	UIView *borderView1 = [[[UIView alloc] initWithFrame: CGRectMake(0, CAPTURE_Y-2, 320, 2)] autorelease];
	UIView *borderView2 = [[[UIView alloc] initWithFrame: CGRectMake(0, CAPTURE_Y+CAPTURE_HEIGHT, 320, 2)] autorelease];
	UIView *borderView3 = [[[UIView alloc] initWithFrame: CGRectMake(0, CAPTURE_Y, 2, CAPTURE_HEIGHT)] autorelease];
	UIView *borderView4 = [[[UIView alloc] initWithFrame: CGRectMake(320-2, CAPTURE_Y, 2, CAPTURE_HEIGHT)] autorelease];

	[borderView1 setBackgroundColor: [UIColor whiteColor]];
	[borderView2 setBackgroundColor: [UIColor whiteColor]];
	[borderView3 setBackgroundColor: [UIColor whiteColor]];
	[borderView4 setBackgroundColor: [UIColor whiteColor]];
	
	[borderView1 setTag: TAG_BORDER_TOP];
	[borderView2 setTag: TAG_BORDER_BOTTOM];
	[borderView3 setTag: TAG_BORDER_LEFT];
	[borderView4 setTag: TAG_BORDER_RIGHT];

	[parentView addSubview: borderView1];
	[parentView addSubview: borderView2];
	[parentView addSubview: borderView3];
	[parentView addSubview: borderView4];
#elif BORDER_TYPE == BORDER_WHITE_CORNER
	UIView *borderView1 = [[[UIView alloc] initWithFrame: CGRectMake(-140, CAPTURE_Y, 140, CAPTURE_HEIGHT)] autorelease];
	UIView *borderView2 = [[[UIView alloc] initWithFrame: CGRectMake(320, CAPTURE_Y, 140, CAPTURE_HEIGHT)] autorelease];
	
	[borderView1 setBackgroundColor: [UIColor blackColor]];
	[borderView2 setBackgroundColor: [UIColor blackColor]];
	[borderView1 setAlpha: 0.5];
	[borderView2 setAlpha: 0.5];
	
	[borderView1 setTag: TAG_VIEW_LEFT];
	[borderView2 setTag: TAG_VIEW_RIGHT];
	
	[parentView addSubview: borderView1];
	[parentView addSubview: borderView2];
	
#endif
	captureRect = CGRectMake(2, CAPTURE_Y, 320-4, CAPTURE_HEIGHT);
	
	[capturedNumbersDict release];
	capturedNumbersDict = [[NSMutableDictionary alloc] init];
	bestCapturedNumber = @"";
	
	UIImagePickerController *picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;
	picker.showsCameraControls = NO;
	picker.delegate = nil;
	picker.allowsImageEditing = NO;
	[picker setCameraOverlayView: parentView];
	[self presentModalViewController:picker animated:YES];
	[picker release];

	[TessWrapper init];
	
	processingTimer = [NSTimer scheduledTimerWithTimeInterval:1/2.0f target: self selector:@selector(processImage) userInfo:nil repeats:YES];
}
#endif

- (void) finishCapture {

	[labelCaptureResult release];
	labelCaptureResult = nil;

	[processingTimer invalidate];
	processingTimer = nil;

	[TessWrapper end];
	destroyGlobalImage();
	
	[capturedNumbersDict release];
	capturedNumbersDict = nil;

	[self dismissModalViewControllerAnimated:YES];
}

- (void) cancelCapture {
	[self finishCapture];
}

- (void) captureThis {
	NSString* str = bestCapturedNumber;
	NSMutableString* result = [NSMutableString string];

	for (int i=0; i<[str length]; ++i) {
		unichar ch = [str characterAtIndex:i];

		if ('0' <= ch && ch <= '9') {
			[result appendFormat:@"%C", ch];
		}
	}
	self.textValue = [NSString stringWithString: result];
	enableSaveButton = YES;
	[self finishCapture];
}

/*
   - (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   [self finishCapture];
   }
 */



CGImageRef UIGetScreenImage();

- (void) processImage {
	CGImageRef screenCGImage = UIGetScreenImage();
	Image *screenImage = fromCGImage2(screenCGImage, captureRect);
	CGImageRelease(screenCGImage);
	
#if 0 // for debug
	CGImageRef c1 = toCGImage(screenImage);
	UIImage* u1 = [UIImage imageWithCGImage: c1];
	UIImageWriteToSavedPhotosAlbum(u1, nil, nil, nil);
	CGImageRelease(c1);
#endif

	int height = captureRect.size.height;
	int width = captureRect.size.width;
	

	for (int y=0; y<height; ++y) {
		for (int x=0; x<width; ++x) {
			unsigned char* p = &(screenImage->rawImage[y * width + x]);

			if (*p > 90)
				*p = 255;
			else
				*p = 0;

			/*
			   if (x > 160) {
			   if (*p == 0)
			   printf("0");
			   else
			   printf(" ");
			   }
			 */
		}
		//printf("\n");
	}
	//printf("\n");

	CGRect rect = CGRectMake(0, 0, captureRect.size.width, captureRect.size.height);

	NSString* result = [TessWrapper getNumber: screenImage->rawImage rect: rect];
	//NSLog(@"result = %@\n", result);
	
	result = [result stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	// Downsizing dictionary
	//NSLog(@"count: %d\n", [capturedNumbersDict count]);
	if ([capturedNumbersDict count] > 60) {
		NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity: 60];
		
		NSEnumerator *enumerator = [capturedNumbersDict keyEnumerator];
		NSString* key;
		
		while ((key = [enumerator nextObject])) {
			/* code that uses the returned key */
			NSNumber* value = [capturedNumbersDict objectForKey: key];
			
			[tempArray addObject: [[[Pair alloc] initWithFirst:key second: [value intValue]] autorelease]];
		}
		
		[tempArray sortUsingSelector: @selector(compare:)];
		
		[capturedNumbersDict release];
		capturedNumbersDict = [[NSMutableDictionary alloc] init];
		
		for (int i=0; i<6; ++i) {
			Pair *a = [tempArray objectAtIndex: i];
			//NSLog(@"%@ - %d\n", a.first ,a.second);
			[capturedNumbersDict setObject: [NSNumber numberWithInt: a.second] forKey: a.first];
		}
	}
	
	// insert
	if ([result length] > 2) {
		NSNumber *value = [capturedNumbersDict objectForKey: result];
		
		if (value) {
			value = [NSNumber numberWithInt: [value intValue] + 1];
		}
		else {
			value = [NSNumber numberWithInt: 1];
		}
		
		[capturedNumbersDict setObject: value forKey: result];
	}
	
	// choose best
	{
		NSEnumerator *enumerator = [capturedNumbersDict keyEnumerator];
		NSString* key;
		NSInteger bestCount = 0;
		
		while ((key = [enumerator nextObject])) {
			/* code that uses the returned key */
			NSNumber* value = [capturedNumbersDict objectForKey: key];
			
			if ([value intValue] > bestCount) {
				bestCapturedNumber = key;
				bestCount = [value intValue];
			}
		}
		
		NSString *resultShort;
		if ([result length] > 20) {
			resultShort = [[result substringToIndex: 20] stringByAppendingString: @".."];
		}
		else {
			resultShort = result;
		}
				
		[labelCaptureResult setText: [NSString stringWithFormat: NSLocalizedString(@"Input: %@\nBest: %@", @""), 
									  resultShort, bestCapturedNumber]];
	}
	

#if 0 // for debug
	     CGImageRef c2 = toCGImage(screenImage);
	     UIImage* u2 = [UIImage imageWithCGImage: c2];

	     UIImageWriteToSavedPhotosAlbum(u2, nil, nil, nil);

	     CGImageRelease(c2);
#endif
	// destroyImage(screenImage); // call this only if we use fromCGImage, not fromCGImage2

}


@end
