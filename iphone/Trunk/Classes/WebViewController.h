//
//  WebViewController.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 11.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	IBOutlet UIWebView* webView;
	IBOutlet UIActivityIndicatorView* activityIndicator;
	IBOutlet UIToolbar* toolbar;
	NSString *myTitle;
	NSString *myEncoding;	
	NSString *myUrl;
	NSArray *buttonsStop;
	NSArray *buttonsRefresh;
	
	NSURL *currentURL;
	NSURLConnection *myConnection;
	NSMutableData *receivedData;
}

@property(nonatomic, retain) IBOutlet UIWebView* webView;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView* activityIndicator;
@property(nonatomic, retain) IBOutlet UIToolbar* toolbar;

- (void)setURL:(NSString*) aUrl title:(NSString*)aTitle encoding:(NSString*)aEncoding;

@end
