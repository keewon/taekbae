//
//  TextEntryViewController.h
//  TaekBae
//
//  Created by Keewon Seo on 09. 01. 02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PasteNumberViewController.h"

@class EditViewController;

@interface TextEntryViewController : UIViewController<UITextFieldDelegate, PasteNumberDelegate> {
	IBOutlet UITextField* text1;
	UIBarButtonItem* buttonSave;
	NSInteger returnType;
	EditViewController* parent;
	NSString* textValue;
	IBOutlet UIButton* buttonPasteNumbers;
	IBOutlet UIButton* buttonCapture;
	NSMutableArray* numbers;
	NSTimer *processingTimer;
	BOOL enableSaveButton;
}

//- (BOOL)textFieldShouldReturn:(UITextField *)textField;

//- (IBAction)cancel:(id)sender;
//- (IBAction)save:(id)sender;
- (IBAction)textViewDidChange:(id)sender;
- (IBAction)pasteNumbers:(id)sender;
- (IBAction)capture:(id)sender;

- (void)setParent: (EditViewController*)aParent title:(NSString*)aTitle prevValue: (NSString*)aValue returnType:(NSInteger)aType;

@property(nonatomic, retain) IBOutlet UITextField *text1;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *buttonSave;
@property(nonatomic, retain) IBOutlet UIButton *buttonPasteNumbers;
@property(nonatomic, retain) IBOutlet UIButton *buttonCapture;
@property(nonatomic, copy) NSString* textValue;
@end
