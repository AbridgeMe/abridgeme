//
//  ForgotPassViewController.h
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"

@class TPKeyboardAvoidingScrollView;

@interface ForgotPassViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,BSKeyboardControlsDelegate>

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property(nonatomic,retain) IBOutlet UITextField *txtEmail;

- (IBAction)sendAction:(id)sender;

@end
