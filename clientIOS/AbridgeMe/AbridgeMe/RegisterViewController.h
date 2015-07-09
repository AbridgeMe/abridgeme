//
//  RegisterViewController.h
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
@class TPKeyboardAvoidingScrollView;

@interface RegisterViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,BSKeyboardControlsDelegate>


    
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
    
@property(nonatomic,retain) IBOutlet UITextField *txtFirstName;
@property(nonatomic,retain) IBOutlet UITextField *txtLastName;
@property(nonatomic,retain) IBOutlet UITextField *txtEmail;
@property(nonatomic,retain) IBOutlet UITextField *txtPassword;
@property(nonatomic,retain) IBOutlet UITextField *txtConfirmPassword;
@property (strong, nonatomic) IBOutlet UIButton *signUp;

@property(nonatomic,strong) UIImageView *subview1;
@property(nonatomic,strong) UILabel *lblName ;
@property(nonatomic,strong) UIImageView* imgProfile;

- (IBAction)signUpAction:(id)sender;

@end
