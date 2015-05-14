//
//  FeedbackViewController.m
//  AbridgeMe
//
//  Created by Lion on 18/09/14.
//  Copyright (c) 2014 Panaceatek. All rights reserved.
//

#import "FeedbackViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"

@interface FeedbackViewController ()<MFMailComposeViewControllerDelegate>

@end

@implementation FeedbackViewController{
@private
    RevealBlock _revealBlock;
}


@synthesize scrollView;
@synthesize txtEmail,txtName,txtSubject,txtViewMessage;



#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            if (self = [super initWithNibName:@"FeedbackViewController" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
        }
        else {
            //iPhone 5
            if (self = [super initWithNibName:@"FeedbackViewController" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        if (self = [super initWithNibName:@"FeedbackViewController_iPad" bundle:nil]) {
            self.title = title;
            _revealBlock = [revealBlock copy];
            
        }
    }
    
    
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:[UIImage imageNamed:@"details.png"] forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
    btnBack.frame = CGRectMake(0, 0, 30, 25);
    UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = BackBtn;
    
    
	
	return self;
}

- (void)revealSidebar {
	_revealBlock();
}




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int ver = [version intValue];
    if (ver >= 7){
        // [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.5f]];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    } else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }
  
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    

    NSArray *fields = @[ self.txtName,self.txtEmail,self.txtSubject,self.txtViewMessage];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    //self.navigationController.navigationBarHidden = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// keyboard control direction
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls directionPressed:(BSKeyboardControlsDirection)direction
{
    UIView *view = keyboardControls.activeField.superview.superview;
    [self.scrollView scrollRectToVisible:view.frame animated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView adjustOffsetToIdealIfNeeded];
    [self.keyboardControls setActiveField:textField];
}

#pragma mark Text View Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    [self.keyboardControls setActiveField:textView];
}


// keyboard control done button
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}




-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    
    [textView resignFirstResponder];
    return YES;
    
}

-(IBAction)btnSendMessage:(id)sender{
    
    NSString *emailid = txtEmail.text;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:emailid];

    
    if(![txtName.text length]>0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter your name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [txtName becomeFirstResponder];
        
    }else if(![txtEmail.text length]>0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter your email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [txtEmail becomeFirstResponder];
    }else if (!myStringMatchesRegEx) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter a valid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [txtEmail becomeFirstResponder];
        
    }else if(![txtSubject.text length]>0){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter a subject" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [txtSubject becomeFirstResponder];
    }else if([txtViewMessage.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"Please enter a message" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [txtViewMessage becomeFirstResponder];
    }else{
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailComposer =
            [[MFMailComposeViewController alloc] init];
            
            [mailComposer setSubject:txtSubject.text];
        
            NSString* message = [NSString stringWithFormat:
                                 @"<html><head></head><body style='font-weight:bold;'>"
                                 @"<p>Hello,</p></br>"
                                 @"<p>%@</p></br>"
                                 @"<p>Regards</p>"
                                 @"<p>%@</p>"
                                 @"<p>%@</p>"
                                 @"</body></html>",txtViewMessage.text,txtName.text,txtEmail.text];
            
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
                if(iOSDeviceScreenSize.height == 480){
                    [[mailComposer navigationBar] setTintColor:[UIColor blackColor]];
                    
                }else{
                   [[mailComposer navigationBar] setTintColor:[UIColor whiteColor]];
                }
            }else{
                 [[mailComposer navigationBar] setTintColor:[UIColor whiteColor]];
            }
            
            
            NSArray * recipients = [NSArray arrayWithObjects:@"Eric@AbridgeMe.com",nil];
            [mailComposer setToRecipients:recipients];
            [mailComposer setMessageBody:message
                                  isHTML:YES];
            mailComposer.mailComposeDelegate = self;
            [self presentViewController:mailComposer animated:YES completion:nil];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"We're unable to access your email account. Please be sure that your account is set up on your device and you have an internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate methods
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
          //  NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
          //  NSLog(@"Mail saved"); break;
            txtEmail.text = @"";
            txtName.text = @"";
            txtSubject.text = @"";
            txtViewMessage.text = @"";
        case MFMailComposeResultSent:
          //  NSLog(@"Mail sent"); break;
            txtEmail.text = @"";
            txtName.text = @"";
            txtSubject.text = @"";
            txtViewMessage.text = @"";
        case MFMailComposeResultFailed:
           // NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            txtEmail.text = @"";
            txtName.text = @"";
            txtSubject.text = @"";
            txtViewMessage.text = @"";break;
        default:
            break;
    }
    
    // close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}




@end
