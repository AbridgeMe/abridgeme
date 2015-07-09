//
//  FeedbackViewController.h
//  AbridgeMe
//
//  Created by Lion on 18/09/14.
//  Copyright (c) 2014 Panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "BSKeyboardControls.h"
@class TPKeyboardAvoidingScrollView;

typedef void (^RevealBlock)();

@interface FeedbackViewController : UIViewController<UIScrollViewDelegate,UITextFieldDelegate,BSKeyboardControlsDelegate,UITextViewDelegate>{
    
}

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;


@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtSubject;
@property (strong, nonatomic) IBOutlet UITextView *txtViewMessage;

-(IBAction)btnSendMessage:(id)sender;

@end
