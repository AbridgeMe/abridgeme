
//
//  LoginViewController.m
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ForgotPassViewController.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "Global.h"
#import "BSKeyboardControls.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "Reachability.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "GHRootViewController.h"
#import "GHMenuCell.h"
#import "GHMenuViewController.h"
#import "GHRevealViewController.h"
#import "GHSidebarSearchViewController.h"
#import "GHSidebarSearchViewControllerDelegate.h"
#import "ViewController.h"
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "AboutUsViewController.h"
#import "FeedbackViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SA_OAuthTwitterEngine.h"
#define kOAuthConsumerKey	@"XyFsG8FaxdPMitWdU1xbkL7zF"		//REPLACE ME
#define kOAuthConsumerSecret	@"XRi0yrmPVS96Atidz6RbK4qEPPtGI9Rn0jddJlloZLXEGWaxyl"		//REPLACE ME



@interface LoginViewController ()<GHSidebarSearchViewControllerDelegate>
@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHSidebarSearchViewController *searchController;
@property (nonatomic, strong) GHMenuViewController *menuController;

@end

@implementation LoginViewController{
    @private
    RevealBlock _revealBlock;
    NSArray *userData;
    NSArray *arrAlldata;
    NSTimer *timer;
    UIViewController *controller;
}

@synthesize txtEmail,txtPassword;
@synthesize scrollView;
@synthesize strNavgSearchFlag;
@synthesize lblName,imgProfile,subview1;

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            if (self = [super initWithNibName:@"LoginViewController_iPhone4" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
            }

        }
        else {
            //iPhone 5
            if (self = [super initWithNibName:@"LoginViewController" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        if (self = [super initWithNibName:@"LoginViewController_iPad" bundle:nil]) {
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

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int ver = [version intValue];
    if (ver >= 7){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    } else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }
    
    self.title=@"Sign in";
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];

    if([GlobalUserID length]>0 )
    {
        //Logout
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        GlobalUserID = nil;
        GlobalUserImage=nil;
        GlobalUserEmailId=nil;
        GlobalUserName=nil;
        GlobalUserLastName=nil;
        GlobalUserImage=nil;
        appDelegate.lblName.text=nil;
        appDelegate.imgProfile.image=[UIImage imageNamed:@"setting_profile_bg.png"];
        
        Global_defaults=[NSUserDefaults standardUserDefaults];
        
        [Global_defaults setObject:@"logout" forKey:@"status"];
        [Global_defaults setObject:GlobalUserID forKey:@"user_id"];
        [Global_defaults setObject:GlobalUserName forKey:@"first_name"];
        [Global_defaults setObject:GlobalUserLastName forKey:@"last_name"];
        [Global_defaults setObject:GlobalUserImage forKey:@"profile_picture"];
        [Global_defaults setObject:GlobalUserEmailId forKey:@"user_email"];
        [Global_defaults synchronize];
        
        
        if(GlobalUserImage ==nil || [GlobalUserImage isEqualToString:str_global_image_domain]||[GlobalUserImage isEqual:[NSNull null]]){
            imgProfile.image = [UIImage imageNamed:@"setting_profile_bg.png"];
        }else{
            NSURL *url = [NSURL URLWithString:GlobalUserImage];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img =[UIImage imageWithData:data];
            imgProfile.image = img;
            
        }
        
        UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
        self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
        self.revealController.view.backgroundColor = bgColor;
        
        RevealBlock revealBlock = ^(){
            [self.revealController toggleSidebar:!self.revealController.sidebarShowing
                                        duration:kGHRevealSidebarDefaultAnimationDuration];
        };
        
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        
        
        NSArray *headers = @[
                             [NSNull null],
                             [NSNull null]
                             ];
        NSArray *controllers = @[
                                 @[
                                     [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]]
                                     ],
                                 @[
                                     [[UINavigationController alloc] initWithRootViewController:[[SearchViewController alloc] initWithTitle:@"Random Feed" withRevealBlock:revealBlock]],
                                     [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] initWithTitle:@"Profile" withRevealBlock:revealBlock]],
                                     [[UINavigationController alloc] initWithRootViewController:[[AboutUsViewController alloc] initWithTitle:@"About Us" withRevealBlock:revealBlock]],
                                     [[UINavigationController alloc] initWithRootViewController:[[FeedbackViewController alloc] initWithTitle:@"Give Feedback" withRevealBlock:revealBlock]],
                                     [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]],
                                     
                                     ]
                                 ];
        NSArray *cellInfos = @[
                               @[
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"home.png"], kSidebarCellTextKey: NSLocalizedString(@"Home", @"")}
                                   ],
                               @[
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"random_feed.png"], kSidebarCellTextKey: NSLocalizedString(@"Random Feed", @"")},
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"profile_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")},
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"aboutus.png"], kSidebarCellTextKey: NSLocalizedString(@"About Us", @"")},
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"feedback_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Give Feedback", @"")},
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"login-64.png"], kSidebarCellTextKey: NSLocalizedString(@"Login", @"")},
                                   
                                   ]
                               ];
        
        // Add drag feature to each root navigation controller
        [controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            [((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
                UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                             action:@selector(dragContentView:)];
                panGesture.cancelsTouchesInView = YES;
                [((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
            }];
        }];
        
        subview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
        [subview1 setBackgroundColor:[UIColor clearColor]];
        
        
        imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 75, 75)];
        imgProfile.image = [UIImage imageNamed:@"setting_profile_bg.png"];
        imgProfile.layer.masksToBounds = NO;
        imgProfile.layer.borderWidth = 0;
        imgProfile.layer.cornerRadius = 38.52;
        imgProfile.clipsToBounds=YES;
        [subview1 addSubview:imgProfile];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(90, 15, 150, 60)];
        [lblName setBackgroundColor:[UIColor clearColor]];
        lblName.textColor = [UIColor whiteColor];
        lblName.lineBreakMode = NSLineBreakByWordWrapping;
        lblName.numberOfLines = 0;
        [subview1 addSubview:lblName];
        
        self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
                                                                            withSearchBar:subview1
                                                                              withHeaders:headers
                                                                          withControllers:controllers
                                                                            withCellInfos:cellInfos];
        
        [self presentViewController:self.revealController animated:YES completion:nil];
        
    }

}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];

    if([regFlag isEqualToString:@"YES"])
    {
        [self backMethod];
        
    }
    
    if([strNavgSearchFlag isEqualToString:@"true"]){
        [self customnavBarbuttons];
    }
    
    // Textfields array for keyboards
    NSArray *fields = @[self.txtEmail,self.txtPassword];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];

    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading..",nil);
        
}

-(void)backMethod
{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


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


- (IBAction)signInAction:(id)sender {
    if([txtEmail.text length]<=0)
    {
        UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter your email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [msg show];

    }
    else if([txtPassword.text length]<=0)
    {
        
        UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter your password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [msg show];
    }
    else
    {
    
    [HUD show:YES];
        
    NSString *strLoginURL = @"ws-signin?";
    NSString *jsonRequest = [NSString stringWithFormat:@"user_emailId=%@&user_password=%@",txtEmail.text,txtPassword.text];
    
    NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@%@",str_global_domain,strLoginURL,jsonRequest] ;
    
    
    BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
    
    NSDictionary *dict=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];

    if ([str_ServerUnderMaintainess isEqualToString:@"NO"]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
        [alert show];
         [HUD hide:YES];
    }
      else  if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"success"]){
          
          
          arrAlldata=[[dict valueForKey:@"result"]valueForKey:@"result"];
          
          NSArray *TempUser=[arrAlldata  valueForKey:@"user_id"];
          
          GlobalUserID= [NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
          
          TempUser=[arrAlldata valueForKey:@"first_name"];
          GlobalUserName=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
       

          TempUser=[arrAlldata valueForKey:@"profile_picture"];
          GlobalUserImage=[NSString stringWithFormat:@"%@%@",str_global_image_domain,[TempUser objectAtIndex:0]];
          
          TempUser=[arrAlldata valueForKey:@"user_email"];

          GlobalUserEmailId=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
          
          TempUser=[arrAlldata valueForKey:@"last_name"];
          GlobalUserLastName=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];

          
           Global_defaults=[NSUserDefaults standardUserDefaults];
          
            [Global_defaults setObject:@"login" forKey:@"status"];
            [Global_defaults setObject:GlobalUserID forKey:@"user_id"];
            [Global_defaults setObject:GlobalUserName forKey:@"first_name"];
            [Global_defaults setObject:GlobalUserLastName forKey:@"last_name"];
            [Global_defaults setObject:GlobalUserImage forKey:@"profile_picture"];
            [Global_defaults setObject:GlobalUserEmailId forKey:@"user_email"];
            [Global_defaults synchronize];
        
            GlobalUserName=[Global_defaults valueForKey:@"first_name"];
        
          [HUD hide:YES];
         
          UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
          self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
          self.revealController.view.backgroundColor = bgColor;
          
          RevealBlock revealBlock = ^(){
              [self.revealController toggleSidebar:!self.revealController.sidebarShowing
                                          duration:kGHRevealSidebarDefaultAnimationDuration];
          };
          
          [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
          
          
          
          NSArray *headers = @[
                               [NSNull null],
                               [NSNull null]
                               ];
          NSArray *controllers = @[
                                   @[
                                       [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]]
                                       ],
                                   @[
                                       [[UINavigationController alloc] initWithRootViewController:[[SearchViewController alloc] initWithTitle:@"Random Feed" withRevealBlock:revealBlock]],
                                       [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] initWithTitle:@"Profile" withRevealBlock:revealBlock]],
                                       [[UINavigationController alloc] initWithRootViewController:[[AboutUsViewController alloc] initWithTitle:@"About Us" withRevealBlock:revealBlock]],
                                       [[UINavigationController alloc] initWithRootViewController:[[FeedbackViewController alloc] initWithTitle:@"Give Feedback" withRevealBlock:revealBlock]],
                                       [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]],
                                       
                                       ]
                                   ];
          NSArray *cellInfos = @[
                                 @[
                                     @{kSidebarCellImageKey: [UIImage imageNamed:@"home.png"], kSidebarCellTextKey: NSLocalizedString(@"Home", @"")}
                                     ],
                                 @[
                                     @{kSidebarCellImageKey: [UIImage imageNamed:@"random_feed.png"], kSidebarCellTextKey: NSLocalizedString(@"Random Feed", @"")},
                                     @{kSidebarCellImageKey: [UIImage imageNamed:@"profile_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")},
                                     @{kSidebarCellImageKey: [UIImage imageNamed:@"aboutus.png"], kSidebarCellTextKey: NSLocalizedString(@"About Us", @"")},
                                     @{kSidebarCellImageKey: [UIImage imageNamed:@"feedback_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Give Feedback", @"")},
                                     @{kSidebarCellImageKey: [UIImage imageNamed:@"login-64.png"], kSidebarCellTextKey: NSLocalizedString(@"Logout", @"")},
                                     
                                     ]
                                 ];
          
          // Add drag feature to each root navigation controller
          [controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
              [((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
                  UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                               action:@selector(dragContentView:)];
                  panGesture.cancelsTouchesInView = YES;
                  [((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
              }];
          }];
          
          
          
          
          
          subview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
          [subview1 setBackgroundColor:[UIColor clearColor]];
          
          
          imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 75, 75)];
          NSURL *url = [NSURL URLWithString:GlobalUserImage];
           NSData *data = [NSData dataWithContentsOfURL:url];
          imgProfile.image = [UIImage imageWithData:data];;
          imgProfile.layer.masksToBounds = NO;
          imgProfile.layer.borderWidth = 0;
          imgProfile.layer.cornerRadius = 38.52;
          imgProfile.clipsToBounds=YES;
          [subview1 addSubview:imgProfile];
          
          lblName = [[UILabel alloc]initWithFrame:CGRectMake(90, 15, 150, 60)];
          lblName.text = GlobalUserName;
          [lblName setBackgroundColor:[UIColor clearColor]];
          lblName.textColor = [UIColor whiteColor];
          lblName.lineBreakMode = NSLineBreakByWordWrapping;
          lblName.numberOfLines = 0;
          [subview1 addSubview:lblName];
          
          self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
                                                                              withSearchBar:subview1
                                                                                withHeaders:headers
                                                                            withControllers:controllers
                                                                              withCellInfos:cellInfos];
          
          [self presentViewController:self.revealController animated:YES completion:nil];
          
    
          
          
       
         
        }else if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"login_password_error"])
        {
              UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Invalid email or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [msg show];

        }else if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"invalid_email"])
        {
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Invalid email or password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [msg show];
        }

    }
}

- (IBAction)loginwithFBAction:(id)sender
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus != NotReachable) {
    
        [self openSessionWithAllowLoginUI:YES];
    
    }
    else{
       
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Opps! It looks like you're not connected to the internet. Check your connection and try again.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        alert.tag=3;
        [alert show];
        
    }
    
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen:
            if (!error) {

                // We have a valid session
                [self populateUserDetails];
                
            }
            break;
        case FBSessionStateClosed: NSLog(@"closed ");
        case FBSessionStateClosedLoginFailed: NSLog(@"failed");
            [FBSession.activeSession closeAndClearTokenInformation];
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName:FBSessionStateChangedNotification
     object:session];
    
    
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */

- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    NSArray *permissions = [[NSArray alloc] initWithObjects:
                            @"email",
                            nil];// @"user_location",@"first_name", @"last_name", @"locale",
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

- (void) closeSession {
    [FBSession.activeSession closeAndClearTokenInformation];
    
    
}


#pragma Facebook Delegates


- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 NSString *strFirstName=[user objectForKey:@"first_name"];
                 NSString *strLastName=[user objectForKey:@"last_name"];
                 NSString *strEmail=[user objectForKey:@"email"];
                 NSString *strPassword=@"987654321";
                
                 NSString *strLoginURL = @"ws-signup?";
                 NSString *jsonRequest = [NSString stringWithFormat:@"user_first_name=%@&user_last_name=%@&user_email=%@&user_password=%@",strFirstName,strLastName,strEmail,strPassword];
                 
                 
                 NSString *fbuid=[user objectForKey:@"id"];
                 GlobalUserImage = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=212&height=179", fbuid];
                 
                NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@%@",str_global_domain,strLoginURL,jsonRequest] ;
                 
                 
                 BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
                 
                 NSDictionary *dict=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
                 
                
                 arrAlldata=[[dict valueForKey:@"result"]valueForKey:@"result"];
                 
                 if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"register_success"])
                 {
     
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Login Success",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                     
   
                     
                 }else if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"already_exists"])
                 {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Login success",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
             }
         }];
    }
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0)
    {
        NSArray *TempUser=[arrAlldata  valueForKey:@"user_id"];
        
        GlobalUserID= [NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
        
        TempUser=[arrAlldata valueForKey:@"first_name"];
        GlobalUserName=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
       
        
        TempUser=[arrAlldata valueForKey:@"user_email"];
        
        GlobalUserEmailId=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
        

        
        TempUser=[arrAlldata valueForKey:@"last_name"];
        GlobalUserLastName=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
        
        
        Global_defaults=[NSUserDefaults standardUserDefaults];
        
        [Global_defaults setObject:@"login" forKey:@"status"];
        [Global_defaults setObject:GlobalUserID forKey:@"user_id"];
        [Global_defaults setObject:GlobalUserName forKey:@"first_name"];
        [Global_defaults setObject:GlobalUserLastName forKey:@"last_name"];
        [Global_defaults setObject:GlobalUserImage forKey:@"profile_picture"];
        [Global_defaults setObject:GlobalUserEmailId forKey:@"user_email"];
        [Global_defaults synchronize];
        
        GlobalUserName=[Global_defaults valueForKey:@"first_name"];
        
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        appDelegate.lblName.text=GlobalUserName;
        
    
        UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
        self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
        self.revealController.view.backgroundColor = bgColor;
        
        RevealBlock revealBlock = ^(){
            [self.revealController toggleSidebar:!self.revealController.sidebarShowing
                                        duration:kGHRevealSidebarDefaultAnimationDuration];
        };
        
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        
        
        NSArray *headers = @[
                             [NSNull null],
                             [NSNull null]
                             ];
        NSArray *controllers = @[
                                 @[
                                     [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]]
                                     ],
                                 @[
                                     [[UINavigationController alloc] initWithRootViewController:[[SearchViewController alloc] initWithTitle:@"Random Feed" withRevealBlock:revealBlock]],
                                     [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] initWithTitle:@"Profile" withRevealBlock:revealBlock]],
                                     [[UINavigationController alloc] initWithRootViewController:[[AboutUsViewController alloc] initWithTitle:@"About Us" withRevealBlock:revealBlock]],
                                     [[UINavigationController alloc] initWithRootViewController:[[FeedbackViewController alloc] initWithTitle:@"Give Feedback" withRevealBlock:revealBlock]],
                                     [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]],
                                     
                                     ]
                                 ];
        NSArray *cellInfos = @[
                               @[
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"home.png"], kSidebarCellTextKey: NSLocalizedString(@"Home", @"")}
                                   ],
                               @[
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"random_feed.png"], kSidebarCellTextKey: NSLocalizedString(@"Random Feed", @"")},
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"profile_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")},
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"aboutus.png"], kSidebarCellTextKey: NSLocalizedString(@"About Us", @"")},
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"feedback_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Give Feedback", @"")},
                                   @{kSidebarCellImageKey: [UIImage imageNamed:@"login-64.png"], kSidebarCellTextKey: NSLocalizedString(@"Logout", @"")},
                                   
                                   ]
                               ];
        
        // Add drag feature to each root navigation controller
        [controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            [((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
                UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                             action:@selector(dragContentView:)];
                panGesture.cancelsTouchesInView = YES;
                [((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
            }];
        }];
        
        
        
        
        
        subview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
        [subview1 setBackgroundColor:[UIColor clearColor]];
        
        
        imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 75, 75)];
        NSURL *url = [NSURL URLWithString:GlobalUserImage];
        NSData *data = [NSData dataWithContentsOfURL:url];
        imgProfile.image = [UIImage imageWithData:data];;
        imgProfile.layer.masksToBounds = NO;
        imgProfile.layer.borderWidth = 0;
        imgProfile.layer.cornerRadius = 38.52;
        imgProfile.clipsToBounds=YES;
        [subview1 addSubview:imgProfile];
        
        lblName = [[UILabel alloc]initWithFrame:CGRectMake(90, 15, 150, 60)];
        lblName.text = GlobalUserName;
        [lblName setBackgroundColor:[UIColor clearColor]];
        lblName.textColor = [UIColor whiteColor];
        lblName.lineBreakMode = NSLineBreakByWordWrapping;
        lblName.numberOfLines = 0;
        [subview1 addSubview:lblName];
        
        self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
                                                                            withSearchBar:subview1
                                                                              withHeaders:headers
                                                                          withControllers:controllers
                                                                            withCellInfos:cellInfos];
        
        [self presentViewController:self.revealController animated:YES completion:nil];
    }
    else
    {
       
    }
}



- (IBAction)loginWithTwitter:(id)sender {

    
    strTwitterUserName=@"";
    
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {

        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:NSLocalizedString(@"Opps! It looks like you're not connected to the internet. Check your connection and try again.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        // alert.tag = 1;
        [alert show];
    } else {
        
        timer=[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(twitterReg) userInfo:nil repeats:YES];
        [timer fire];
      
        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate: self];
        _engine.consumerKey = kOAuthConsumerKey;
        _engine.consumerSecret = kOAuthConsumerSecret;
        
        controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine: _engine delegate: self];
        
        if (controller)
          
            [self presentViewController:controller animated:YES completion:Nil];
        else {
            [_engine sendUpdate: [NSString stringWithFormat: @"Already Updated. %@", [NSDate date]]];
        }
    }


}


-(void)twitterReg
{

    if([strTwitterUserName length]>0)
    {
        [timer invalidate];
        NSString *strLoginURL = @"ws-twitter-signup?";
        NSString *jsonRequest = [NSString stringWithFormat:@"user_name=%@&tw_id=%@",strTwitterUserName,strTwitterID];
       
        
        NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@%@",str_global_domain,strLoginURL,jsonRequest] ;
        
        
        BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
        
        NSDictionary *dict=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
       
        if ([str_ServerUnderMaintainess isEqualToString:@"NO"]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:Nil, nil];
            [alert show];
        }
        else  if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"register_success"]){
           
            arrAlldata=[[dict valueForKey:@"result"]valueForKey:@"result"];
            
            
            NSArray *TempUser=[arrAlldata  valueForKey:@"user_id"];
            
            GlobalUserID= [NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
            
            
            TempUser=[arrAlldata valueForKey:@"user_name"];
            GlobalUserName=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];

            
            TempUser=[arrAlldata valueForKey:@"user_name"];
            GlobalTwitterUsername=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
            
        
            TempUser=[arrAlldata valueForKey:@"profile_picture"];
            GlobalUserImage=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
            
            TempUser=[arrAlldata valueForKey:@"user_email"];
            
            GlobalUserEmailId=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
        
            
            TempUser=[arrAlldata valueForKey:@"last_name"];
            GlobalUserLastName=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];

            
            Global_defaults=[NSUserDefaults standardUserDefaults];
            
            [Global_defaults setObject:@"login" forKey:@"status"];
            [Global_defaults setObject:GlobalUserID forKey:@"user_id"];
            [Global_defaults setObject:GlobalUserName forKey:@"first_name"];
            [Global_defaults setObject:GlobalTwitterUsername forKey:@"user_name"];
            [Global_defaults setObject:GlobalUserLastName forKey:@"last_name"];
            [Global_defaults setObject:GlobalUserImage forKey:@"profile_picture"];
            [Global_defaults setObject:GlobalUserEmailId forKey:@"user_email"];
            [Global_defaults synchronize];
            
            
            UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
            self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
            self.revealController.view.backgroundColor = bgColor;
            
            RevealBlock revealBlock = ^(){
                [self.revealController toggleSidebar:!self.revealController.sidebarShowing
                                            duration:kGHRevealSidebarDefaultAnimationDuration];
            };
            
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
            
            
            
            NSArray *headers = @[
                                 [NSNull null],
                                 [NSNull null]
                                 ];
            NSArray *controllers = @[
                                     @[
                                         [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]]
                                         ],
                                     @[
                                         [[UINavigationController alloc] initWithRootViewController:[[SearchViewController alloc] initWithTitle:@"Random Feed" withRevealBlock:revealBlock]],
                                         [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] initWithTitle:@"Profile" withRevealBlock:revealBlock]],
                                         [[UINavigationController alloc] initWithRootViewController:[[AboutUsViewController alloc] initWithTitle:@"About Us" withRevealBlock:revealBlock]],
                                         [[UINavigationController alloc] initWithRootViewController:[[FeedbackViewController alloc] initWithTitle:@"Give Feedback" withRevealBlock:revealBlock]],
                                         [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]],
                                         
                                         ]
                                     ];
            NSArray *cellInfos = @[
                                   @[
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"home.png"], kSidebarCellTextKey: NSLocalizedString(@"Home", @"")}
                                       ],
                                   @[
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"random_feed.png"], kSidebarCellTextKey: NSLocalizedString(@"Random Feed", @"")},
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"profile_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")},
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"aboutus.png"], kSidebarCellTextKey: NSLocalizedString(@"About Us", @"")},
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"feedback_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Give Feedback", @"")},
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"login-64.png"], kSidebarCellTextKey: NSLocalizedString(@"Logout", @"")},
                                       
                                       ]
                                   ];
            
            // Add drag feature to each root navigation controller
            [controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                [((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
                    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                                 action:@selector(dragContentView:)];
                    panGesture.cancelsTouchesInView = YES;
                    [((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
                }];
            }];
            
            
            
            
            
            subview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
            [subview1 setBackgroundColor:[UIColor clearColor]];
            
            
            imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 75, 75)];
            NSURL *url = [NSURL URLWithString:GlobalUserImage];
            NSData *data = [NSData dataWithContentsOfURL:url];
            imgProfile.image = [UIImage imageWithData:data];;
            imgProfile.layer.masksToBounds = NO;
            imgProfile.layer.borderWidth = 0;
            imgProfile.layer.cornerRadius = 38.52;
            imgProfile.clipsToBounds=YES;
            [subview1 addSubview:imgProfile];
            
            lblName = [[UILabel alloc]initWithFrame:CGRectMake(90, 15, 150, 60)];
            lblName.text = GlobalUserName;
            [lblName setBackgroundColor:[UIColor clearColor]];
            lblName.textColor = [UIColor whiteColor];
            lblName.lineBreakMode = NSLineBreakByWordWrapping;
            lblName.numberOfLines = 0;
            [subview1 addSubview:lblName];
            
            self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
                                                                                withSearchBar:subview1
                                                                                  withHeaders:headers
                                                                              withControllers:controllers
                                                                                withCellInfos:cellInfos];
            
            [self presentViewController:self.revealController animated:YES completion:nil];

            
            
        }else  if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"already_exists"]){
            
            arrAlldata=[[dict valueForKey:@"result"]valueForKey:@"result"];
            
            
            NSArray *TempUser=[arrAlldata  valueForKey:@"user_id"];
            
            GlobalUserID= [NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
            
            TempUser=[arrAlldata valueForKey:@"user_name"];
            GlobalUserName=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
        
            
            TempUser=[arrAlldata valueForKey:@"user_name"];
            GlobalTwitterUsername=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
            
    
            TempUser=[arrAlldata valueForKey:@"profile_picture"];
            GlobalUserImage=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
    
            
            TempUser=[arrAlldata valueForKey:@"user_email"];
            
            GlobalUserEmailId=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
            
            TempUser=[arrAlldata valueForKey:@"last_name"];
            GlobalUserLastName=[NSString stringWithFormat:@"%@",[TempUser objectAtIndex:0]];
            
            
            Global_defaults=[NSUserDefaults standardUserDefaults];
            
            [Global_defaults setObject:@"login" forKey:@"status"];
            [Global_defaults setObject:GlobalUserID forKey:@"user_id"];
            [Global_defaults setObject:GlobalUserName forKey:@"first_name"];
            [Global_defaults setObject:GlobalTwitterUsername forKey:@"user_name"];
            [Global_defaults setObject:GlobalUserLastName forKey:@"last_name"];
            [Global_defaults setObject:GlobalUserImage forKey:@"profile_picture"];
            [Global_defaults setObject:GlobalUserEmailId forKey:@"user_email"];
            [Global_defaults synchronize];
           // [self.navigationController popToRootViewControllerAnimated:YES];
            
            UIColor *bgColor = [UIColor colorWithRed:(50.0f/255.0f) green:(57.0f/255.0f) blue:(74.0f/255.0f) alpha:1.0f];
            self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
            self.revealController.view.backgroundColor = bgColor;
            
            RevealBlock revealBlock = ^(){
                [self.revealController toggleSidebar:!self.revealController.sidebarShowing
                                            duration:kGHRevealSidebarDefaultAnimationDuration];
            };
            
            [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
            
            
            
            NSArray *headers = @[
                                 [NSNull null],
                                 [NSNull null]
                                 ];
            NSArray *controllers = @[
                                     @[
                                         [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]]
                                         ],
                                     @[
                                         [[UINavigationController alloc] initWithRootViewController:[[SearchViewController alloc] initWithTitle:@"Random Feed" withRevealBlock:revealBlock]],
                                         [[UINavigationController alloc] initWithRootViewController:[[ProfileViewController alloc] initWithTitle:@"Profile" withRevealBlock:revealBlock]],
                                         [[UINavigationController alloc] initWithRootViewController:[[AboutUsViewController alloc] initWithTitle:@"About Us" withRevealBlock:revealBlock]],
                                         [[UINavigationController alloc] initWithRootViewController:[[FeedbackViewController alloc] initWithTitle:@"Give Feedback" withRevealBlock:revealBlock]],
                                         [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] initWithTitle:@"AbridgeMe" withRevealBlock:revealBlock]],
                                         
                                         ]
                                     ];
            NSArray *cellInfos = @[
                                   @[
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"home.png"], kSidebarCellTextKey: NSLocalizedString(@"Home", @"")}
                                       ],
                                   @[
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"random_feed.png"], kSidebarCellTextKey: NSLocalizedString(@"Random Feed", @"")},
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"profile_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Profile", @"")},
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"aboutus.png"], kSidebarCellTextKey: NSLocalizedString(@"About Us", @"")},
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"feedback_icon.png"], kSidebarCellTextKey: NSLocalizedString(@"Give Feedback", @"")},
                                       @{kSidebarCellImageKey: [UIImage imageNamed:@"login-64.png"], kSidebarCellTextKey: NSLocalizedString(@"Logout", @"")},
                                       
                                       ]
                                   ];
            
            // Add drag feature to each root navigation controller
            [controllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                [((NSArray *)obj) enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2){
                    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                                 action:@selector(dragContentView:)];
                    panGesture.cancelsTouchesInView = YES;
                    [((UINavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
                }];
            }];
            
            
            
            
            
            subview1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 50)];
            [subview1 setBackgroundColor:[UIColor clearColor]];
            
            
            imgProfile = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 75, 75)];
            NSURL *url = [NSURL URLWithString:GlobalUserImage];
            NSData *data = [NSData dataWithContentsOfURL:url];
            imgProfile.image = [UIImage imageWithData:data];;
            imgProfile.layer.masksToBounds = NO;
            imgProfile.layer.borderWidth = 0;
            imgProfile.layer.cornerRadius = 38.52;
            imgProfile.clipsToBounds=YES;
            [subview1 addSubview:imgProfile];
            
            lblName = [[UILabel alloc]initWithFrame:CGRectMake(90, 15, 150, 60)];
            lblName.text = GlobalUserName;
            [lblName setBackgroundColor:[UIColor clearColor]];
            lblName.textColor = [UIColor whiteColor];
            lblName.lineBreakMode = NSLineBreakByWordWrapping;
            lblName.numberOfLines = 0;
            [subview1 addSubview:lblName];
            
            self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
                                                                                withSearchBar:subview1
                                                                                  withHeaders:headers
                                                                              withControllers:controllers
                                                                                withCellInfos:cellInfos];
            
            [self presentViewController:self.revealController animated:YES completion:nil];
        }

    }
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    appDelegate.lblName.text=GlobalTwitterUsername;
}



-(IBAction)btnCreateAccount:(id)sender{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            
            RegisterViewController *obj = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController_iPhone4" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
           // [self.navigationController presentViewController:obj animated:YES completion:nil];
            
        }
        else {
            //iPhone 5
            
            RegisterViewController *obj = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController" bundle:nil];
        
           // [self.navigationController presentViewController:obj animated:YES completion:nil];
            [self.navigationController pushViewController:obj animated:YES];

            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        //"iPad”
        
        RegisterViewController *obj = [[RegisterViewController alloc]initWithNibName:@"RegisterViewController_iPad" bundle:nil];
      
       // [self.navigationController presentViewController:obj animated:YES completion:nil];
        [self.navigationController pushViewController:obj animated:YES];
      
    }
    
    

    
  }

-(IBAction)btnForgotPassword:(id)sender{
    
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480)
        {
            //iPhone 4
            ForgotPassViewController *obj = [[ForgotPassViewController alloc]initWithNibName:@"ForgotPassViewController_iPhone4" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];

            
        }
        else
        {
            ForgotPassViewController *obj = [[ForgotPassViewController alloc]initWithNibName:@"ForgotPassViewController" bundle:nil];
            [self.navigationController pushViewController:obj animated:YES];
            
        }
        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //"iPad”
        ForgotPassViewController *obj = [[ForgotPassViewController alloc]initWithNibName:@"ForgotPassViewController_iPad" bundle:nil];
        [self.navigationController pushViewController:obj animated:YES];
        
    }

    
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
            if(iOSDeviceScreenSize.height == 480)
            {
                //iPhone 4
                
            }
            else
            {
                [self.scrollView adjustOffsetToIdealIfNeeded];
                [self.keyboardControls setActiveField:textField];
            }
                
            }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            //"iPad”
            
        }


    
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
        
        [txtEmail resignFirstResponder];
        [txtPassword resignFirstResponder];
        
    }
    
    // UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
    {
        [textField resignFirstResponder];
        return YES;
    }


#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData:(NSString *)data forUsername: (NSString *) username {
  
    strTwitterUserName=username;
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    [self twitterReg];
   
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	
    
    return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
    
    
}

#pragma mark SA_OAuthTwitterControllerDelegate
- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username {
    strTwitterUserName=username;
    
}

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Failed!");
}

- (void) OAuthTwitterControllerCanceled: (SA_OAuthTwitterController *) controller {
	NSLog(@"Authentication Canceled.");
}


#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
    
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}


-(UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:tableView
{
    
return  tableView;
}

-(void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback{
    
}

-(void)searchResult:(id)result selectedAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier{
    
}

@end

