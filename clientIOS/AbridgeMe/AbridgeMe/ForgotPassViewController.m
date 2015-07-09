//
//  ForgotPassViewController.m
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import "ForgotPassViewController.h"
#import "BSKeyboardControls.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "Global.h"
#import "BaseViewController.h"
#import "AppDelegate.h"


@interface ForgotPassViewController ()

@end

@implementation ForgotPassViewController
@synthesize scrollView,txtEmail;

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
    [self customnavBarbuttons];
    self.navigationItem.title = @"Forgot Password";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    // Textfields array for keyboards
    NSArray *fields = @[self.txtEmail];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
}

#pragma mark Methods
// Custom Navigation bar methods
-(void)customnavBarbuttons
{
    UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnBack setImage:[UIImage imageNamed:@"back_btn.png"] forState:UIControlStateNormal];
    [btnBack setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btnBack addTarget:self action:@selector(BackBtnClicked) forControlEvents:UIControlEventTouchUpInside];
     btnBack.frame = CGRectMake(0, 0, 25, 30);
    UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc]initWithCustomView:btnBack];
    self.navigationItem.leftBarButtonItem = BackBtn;
}

// Back button method
-(void)BackBtnClicked{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TextField Delegate Methods
// Text field delegate method
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView adjustOffsetToIdealIfNeeded];
    [self.keyboardControls setActiveField:textField];
}

// keyboard control direction
- (void)keyboardControls:(BSKeyboardControls *)keyboardControls directionPressed:(BSKeyboardControlsDirection)direction
{
    UIView *view = keyboardControls.activeField.superview.superview;
    [self.scrollView scrollRectToVisible:view.frame animated:YES];
}

// keyboard control done button
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [keyboardControls.activeField resignFirstResponder];
}

// UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)sendAction:(id)sender
{

    if([txtEmail.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Please enter email text field." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
    }else{
        
    
    NSString *strLoginURL = @"ws-forgot-password?";
    NSString *jsonRequest = [NSString stringWithFormat:@"user_emailId=%@",txtEmail.text];
    
    
    NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@%@",str_global_domain,strLoginURL,jsonRequest] ;
    
    
    BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
    
    NSDictionary *dict=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
    if ([str_ServerUnderMaintainess isEqualToString:@"NO"]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
    }else if([[[dict valueForKey:@"result"]valueForKey:@"msg"]isEqualToString:@"This_email_address_does_not_exists"])
        {
                UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Entered email address does not exists." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [msg show];
                [self.navigationController popViewControllerAnimated:YES];
        }else if([[[dict valueForKey:@"result"]valueForKey:@"msg"]isEqualToString:@"success"])
        {
                UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Your password has been sent to your email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [msg show];
                [self.navigationController popViewControllerAnimated:YES];
        }else if([[[dict valueForKey:@"result"]valueForKey:@"msg"] isEqualToString:@"This_email_address_does_not_exists."])
        {
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Unknown email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [msg show];
        }
            
    }

}
@end
