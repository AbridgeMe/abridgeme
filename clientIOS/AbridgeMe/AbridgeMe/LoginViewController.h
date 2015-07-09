//
//  LoginViewController.h
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "SA_OAuthTwitterController.h"
#import "MBProgressHUD.h"

@class TPKeyboardAvoidingScrollView;

typedef void (^RevealBlock)();

@interface LoginViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,BSKeyboardControlsDelegate,SA_OAuthTwitterControllerDelegate,MBProgressHUDDelegate>{
       SA_OAuthTwitterEngine *_engine;
    MBProgressHUD *HUD;

}
    
@property(strong,nonatomic) NSString *strNavgSearchFlag;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property(nonatomic,retain) IBOutlet UITextField *txtEmail;
@property(nonatomic,retain) IBOutlet UITextField *txtPassword;
@property(nonatomic,strong)  UIImageView *subview1;
@property(nonatomic,strong)UILabel *lblName ;
@property(nonatomic,strong) UIImageView* imgProfile;


- (IBAction)signInAction:(id)sender;

- (IBAction)loginwithFBAction:(id)sender;

- (IBAction)loginWithTwitter:(id)sender;

-(IBAction)btnCreateAccount:(id)sender;

-(IBAction)btnForgotPassword:(id)sender;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;


@end
