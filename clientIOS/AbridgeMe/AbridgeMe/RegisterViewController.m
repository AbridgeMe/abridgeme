//
//  RegisterViewController.m
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import "RegisterViewController.h"
#import "BSKeyboardControls.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "BaseViewController.h"
#import "AppDelegate.h"
#import "Global.h"
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
#import "LoginViewController.h"

@interface RegisterViewController()<GHSidebarSearchViewControllerDelegate>

@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHSidebarSearchViewController *searchController;
@property (nonatomic, strong) GHMenuViewController *menuController;

@end

@implementation RegisterViewController{
    
    @private
    RevealBlock _revealBlock;
    NSArray *arrAlldata;
}
@synthesize txtConfirmPassword,txtEmail,txtFirstName,txtLastName,txtPassword;
@synthesize scrollView;
@synthesize lblName,imgProfile,subview1;

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
   
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [self customnavBarbuttons];
    self.navigationItem.title = @"Sign Up";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
    
    
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    if([strTwitterUserName length]>0){
        txtFirstName.text = strTwitterUserName;
    }

    // Textfields array for keyboards
    NSArray *fields = @[self.txtFirstName,self.txtLastName,self.txtEmail,self.txtPassword,self.txtConfirmPassword];
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


- (IBAction)signUpAction:(id)sender
{
    
          if([txtFirstName.text length]<=0)
        {
            
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter your first name" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [msg show];
            
        }else if([txtLastName.text length]<=0)
        {
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter your last name" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [msg show];
            
            
        }else if([txtEmail.text length]<=0)
        {
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter your email" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [msg show];
            
        }else if([txtPassword.text length]<=0)
        {UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter a password" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [msg show];
            
        }else
        {
            NSString *emailid = txtEmail.text;
            NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
            NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
            BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:emailid];
            
            
            if(!myStringMatchesRegEx)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Please enter a valid email address.",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }else if([txtPassword.text length]<6)
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Your password must be more than 6 characters",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
            }else
            {
                
                if([txtPassword.text  isEqualToString:txtConfirmPassword.text])
                {
                //register method.
                    NSString *strLoginURL = @"ws-signup?";
                    NSString *jsonRequest = [NSString stringWithFormat:@"user_first_name=%@&user_last_name=%@&user_email=%@&user_password=%@",txtFirstName.text,txtLastName.text,txtEmail.text,txtPassword.text];
  
                    NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@%@",str_global_domain,strLoginURL,jsonRequest] ;
    
                    BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
                    
                   NSDictionary *dict=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
     
                    arrAlldata=[[dict valueForKey:@"result"]valueForKey:@"result"];

                    if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"register_success"])
                    {

                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Welcome! Your account has been created.",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
      
                    }
                    else if([[[dict valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"already_exists"])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"This email already exists",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        regFlag=@"YES";
                 
                    }
                }
                
                
                else
                {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Opps! Your passwords do not match",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                
                    }
                }
      
        }
  
}






- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
   
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 0)
    {
        
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];

        
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
       
        [Global_defaults setObject:GlobalUserEmailId forKey:@"user_email"];
        [Global_defaults synchronize];
        
        
        GlobalUserName=[Global_defaults valueForKey:@"first_name"];
   
        appDelegate.lblName.text=GlobalUserName;
        
        
        regFlag=@"YES";
       // [self dismissViewControllerAnimated:YES completion:nil];
        
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
