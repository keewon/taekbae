//
//  WebViewController.m
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController(Private)
- (void)setToolbarRefresh:(BOOL)isRefresh;
@end


@implementation WebViewController

@synthesize webView, activityIndicator, toolbar;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
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
//	self.navigationController.toolbar = toolbar;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	/*
	CGPoint c1 = [[self view]center];
	CGPoint c2;
	c2.x = c1.y;
	c2.y = c1.x;
	
	[activityIndicator setCenter: c2];
	 */
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[activityIndicator setCenter: [[self view]center]];	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)newRequest {
	
	NSURLRequest* request = [NSURLRequest requestWithURL: [NSURL URLWithString: myUrl]];
	
	[currentURL release];
	currentURL = [[NSURL URLWithString:myUrl] retain];
	
	if (myConnection)
	{
		[myConnection release];
		myConnection = nil;
	}
	
	if (myEncoding)
	{
		myConnection = [[NSURLConnection alloc] initWithRequest: request delegate:self];
		if (myConnection)
		{
			receivedData = [[NSMutableData data] retain];
			//[self.navigationController setNavigationBarHidden:YES animated: NO];
			[activityIndicator startAnimating];
			[self setToolbarRefresh:NO];
		}
		else
		{
			// download failed
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
															message:@"Can't make a connection"
														   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") 
												  otherButtonTitles: nil];
			alert.tag = 0;
			[alert show];	
			[alert release];
		}
	}
	else
	{
		myConnection = nil;
		//[self.navigationController setNavigationBarHidden:YES animated: NO];
		[activityIndicator startAnimating];
		[webView loadRequest: request];
		[self setToolbarRefresh:NO];
	}
	//	[webView loadData: nil MIMEType:@"text/html" textEncodingName:@"euc-kr" baseURL:[NSURL URLWithString: myUrl]];
	
}

- (void)viewDidAppear:(BOOL)animated 
{
	[self setTitle:myTitle];
	[activityIndicator setCenter: [[self view]center]];	
	
	[self newRequest];
}


- (void)viewWillDisappear:(BOOL)animated
{
	NSLog(@"viewWillDisapper+\n");
	[activityIndicator stopAnimating];
	if (myConnection)
	{
		[myConnection cancel];
		[myConnection release];
		myConnection = nil;
		NSLog(@"Cancel connection\n");
	}
	[webView stopLoading];
	NSLog(@"Stop loading\n");
	[webView loadHTMLString:@"<html></html>" baseURL: nil];
//	webView.delegate = nil;
	[super viewDidDisappear:animated];
	NSLog(@"viewWillDisappear-\n");
}

- (void)dealloc {
	[myUrl release];
	[myTitle release];
	[myEncoding release];
	[receivedData release];
	[buttonsStop release];
	[buttonsRefresh release];
	[currentURL release];
    [super dealloc];	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	NSLog(@"didFailLoadWithError\n");
	[self setToolbarRefresh:YES];
	
	if (error.code == NSURLErrorUnsupportedURL)
	{
		return; // ignore
	}
	
	if ([activityIndicator isAnimating])
	{
		[activityIndicator stopAnimating];
		//[self.navigationController setNavigationBarHidden:NO animated: YES];	
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
												message:[error localizedDescription]
												delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") 
											  otherButtonTitles: nil];
		alert.tag = 0;
		[alert show];	
		[alert release];
	}
	else
	{
		NSLog(@" - webView is not active now: error=%@\n", [error localizedDescription]);
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	NSLog(@"webViewDidFinishLoad\n");
	[self setToolbarRefresh:YES];
	[activityIndicator stopAnimating];
	//[self.navigationController setNavigationBarHidden:NO animated: YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 0)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else if (alertView.tag == 1)
	{
		if (buttonIndex == 1)
		{
			[[UIApplication sharedApplication] openURL: [NSURL URLWithString:alertView.message]];
		}
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[[UIApplication sharedApplication] openURL: currentURL];
	}
}

- (void)setURL:(NSString*) aUrl title:(NSString*)aTitle encoding:(NSString*)aEncoding
{
	[myTitle release];
	[myUrl release];
	[myEncoding release];
	
	myTitle = [[NSString stringWithString:aTitle] retain];
	[self setTitle:myTitle];
	myUrl = [[NSString stringWithString: aUrl] retain];
	
	if (aEncoding == nil || [aEncoding isEqualToString:@""])
		myEncoding = nil;
	else
		myEncoding = [aEncoding copy];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{   
	// append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere                    
    [receivedData appendData:data];
	
	NSLog(@"received\n");
}       

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{               
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
	myConnection = nil;
	
    // inform the user
    //NSLog(@"Connection failed! Error - %@ %@",
    //      [error localizedDescription],
    //      [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	NSLog(@"Connection failed! Error - %@",
          [error localizedDescription]);
	
	[activityIndicator stopAnimating];
	//[self.navigationController setNavigationBarHidden:NO animated: YES];	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") 
													message:[error localizedDescription]
												   delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") 
										  otherButtonTitles: nil];
	alert.tag = 0;
	[alert show];	
	[alert release];
	
	[self setToolbarRefresh:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
//	NSString *a = [[NSString alloc] initWithData: receivedData encoding:NSUTF8StringEncoding];

	//[webView loadData: nil MIMEType:@"text/html" textEncodingName baseURL:[NSURL URLWithString: myUrl]];
	[webView loadData:receivedData MIMEType:@"text/html" textEncodingName:myEncoding baseURL:nil];
	
	
	[receivedData release]; receivedData = nil;
	
//	[a release];
	[myConnection release]; myConnection = nil;
//	[connection release];
	
	[self setToolbarRefresh:YES];
	
	NSLog(@"connectionDidFinishLoading-\n");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
	navigationType:(UIWebViewNavigationType)navigationType
{
	NSString* url = [[request URL] absoluteString];
	NSLog(@"shouldStart: %@\n", url);
	if ((navigationType == UIWebViewNavigationTypeBackForward ||
		navigationType == UIWebViewNavigationTypeLinkClicked) &&
		![url isEqualToString:@"about:blank"])
	{
		[currentURL release];
		currentURL = [[request URL] copy];
	}
	
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		static NSString* itunesLink = @"http://itunes.apple.com";
		NSInteger itunesLinkLen = [itunesLink length];
										  
		// This app is not a general web browser. So open it in Safari
		if ([[url substringToIndex:itunesLinkLen] isEqualToString: itunesLink]) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Open App Store", @"") 
															message: url
														   delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
												  otherButtonTitles: NSLocalizedString(@"Open", @""), nil];
			alert.tag = 1;
			[alert show];	
			[alert release];
			
			
			return NO;
		}
	}
	
	return YES;
}

- (void)actionBack {
	[webView goBack];
}

- (void)actionForward {
	[webView goForward];
}

- (void)actionRefresh {
	if (myEncoding) {
		[self newRequest];
	}
	else {
		[webView reload];
	}
}

- (void)actionStop {
	[webView stopLoading];
}

- (void)actionAction {
	UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: [currentURL absoluteString]
													   delegate:self 
							cancelButtonTitle:NSLocalizedString(@"Cancel", @"") 
										 destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open in Safari", @""), nil];
	[sheet showFromToolbar:toolbar];
	[sheet release];
}

- (void)setToolbarRefresh:(BOOL)isRefresh {
	
	if (isRefresh) {
		if (buttonsRefresh == nil) {
			buttonsRefresh = [[NSArray alloc] initWithObjects:
							  [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon.png"] 
																style:UIBarButtonItemStylePlain 
															   target:self action:@selector(actionBack)] autorelease],
							  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			 target:nil action:nil] autorelease],
							  [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon.png"]
																style:UIBarButtonItemStylePlain
															   target:self action:@selector(actionForward)] autorelease],
							  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			 target:nil action:nil] autorelease],
							  
							  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																			 target:self action:@selector(actionRefresh)] autorelease],
							  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																			 target:nil action:nil] autorelease],
							  
							  [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																			 target:self action:@selector(actionAction)] autorelease],
							  nil];
		}
		
		[toolbar setItems: buttonsRefresh];
	}
	else {
		if (buttonsStop == nil) {
			buttonsStop = [[NSArray alloc] initWithObjects:
						   [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"backIcon.png"] 
															 style:UIBarButtonItemStylePlain 
															target:self action:@selector(actionBack)] autorelease],
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																		  target:nil action:nil] autorelease],
						   [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon.png"]
															 style:UIBarButtonItemStylePlain
															target:self action:@selector(actionForward)] autorelease],
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																		  target:nil action:nil] autorelease],
						   
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
																		  target:self action:@selector(actionStop)] autorelease],
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																		  target:nil action:nil] autorelease],
						   
						   [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																		  target:self action:@selector(actionAction)] autorelease],  
						   nil];
			
		}
		
		[toolbar setItems: buttonsStop];
	}

	UIBarButtonItem* button;
	
	if (myEncoding) {
		button = [toolbar.items objectAtIndex:0];
		[button setEnabled:NO];
		
		button = [toolbar.items objectAtIndex:2];
		[button setEnabled:NO];
	}
	else {
		button = [toolbar.items objectAtIndex:0];
		if (webView.canGoBack) {
			[button setEnabled:YES];
		}
		else {
			[button setEnabled:NO];
		}
		
		button = [toolbar.items objectAtIndex:2];
		if (webView.canGoForward){
			[button setEnabled:YES];
		}
		else {
			[button setEnabled:NO];
		}
	}
}

@end
