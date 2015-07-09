//
//  ProfileViewController.h
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "MBProgressHUD.h"

@class TPKeyboardAvoidingScrollView;

typedef void (^RevealBlock)();

@interface ProfileViewController : UIViewController<UITextFieldDelegate,UIScrollViewDelegate,BSKeyboardControlsDelegate,UIActionSheetDelegate,MBProgressHUDDelegate,
UIImagePickerControllerDelegate>
{
    //For Image picker:
    UIImagePickerController *imgPickerCObj;
    UIImage *image;
    NSString *savedImagePath;
    MBProgressHUD *HUD;
}
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;



@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (nonatomic, retain) IBOutlet TPKeyboardAvoidingScrollView *scrollView;


- (IBAction)uploadImageAction:(id)sender;


- (IBAction)saveChangesAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *userImageBtn;



@property(nonatomic,retain) IBOutlet UITextField *txtFirstName;
@property(nonatomic,retain) IBOutlet UITextField *txtLastName;
@property(nonatomic,retain) IBOutlet UITextField *txtEmail;
@property(nonatomic,retain) IBOutlet UITextField *txtPassword;
@property(nonatomic,retain) IBOutlet UITextField *txtConfirmPassword;
@property (strong, nonatomic) IBOutlet UIImageView *imgvw_Photo;







@end
