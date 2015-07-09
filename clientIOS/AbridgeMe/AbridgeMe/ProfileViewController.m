//
//  ProfileViewController.m
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import "ProfileViewController.h"
#import "BSKeyboardControls.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "Global.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()
{
    NSString *strFlagSave;
}
@end

@implementation ProfileViewController{
@private
    RevealBlock _revealBlock;
}


@synthesize txtConfirmPassword,txtEmail,txtFirstName,txtLastName,txtPassword,userImageBtn;
@synthesize scrollView,imgvw_Photo;

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            if (self = [super initWithNibName:@"ProfileViewController_iPhone4" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
        }
        else {
            //iPhone 5
            if (self = [super initWithNibName:@"ProfileViewController" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        if (self = [super initWithNibName:@"ProfileViewController_iPad" bundle:nil]) {
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

    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Profile";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    
    // Textfields array for keyboards
    NSArray *fields = @[self.txtFirstName,self.txtLastName,self.txtEmail,self.txtPassword,self.txtConfirmPassword];
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    
    if([imgStr_Flag isEqualToString: @"1" ])
    {
        
        userImageBtn.layer.masksToBounds = NO;
        userImageBtn.layer.borderWidth = 0;
        userImageBtn.layer.cornerRadius = userImageBtn.frame.size.width/2;
        userImageBtn.clipsToBounds=YES;

        [userImageBtn setBackgroundImage:image forState:UIControlStateNormal];
        
        
        
    }
    
    
    if(GlobalUserID.length>0)
    {
        
        if([GlobalUserName length]>0){
            txtFirstName.text=GlobalUserName;
        }else{
            txtFirstName.text=GlobalTwitterUsername;
        }
        
       // txtEmail.userInteractionEnabled = YES;
        txtFirstName.userInteractionEnabled = YES;
        txtLastName.userInteractionEnabled = YES;
        txtPassword.userInteractionEnabled = YES;
        txtConfirmPassword.userInteractionEnabled = YES;
        
        txtLastName.text=GlobalUserLastName;
        txtEmail.text=GlobalUserEmailId;
        txtFirstName.text=GlobalUserName;
        txtLastName.text=GlobalUserLastName;
        txtEmail.text=GlobalUserEmailId;
        userImageBtn.layer.masksToBounds = NO;
        userImageBtn.layer.borderWidth = 0;
        userImageBtn.layer.cornerRadius = 52.52;
        userImageBtn.clipsToBounds=YES;
        
        if(GlobalUserImage ==nil  || [GlobalUserImage isEqualToString:str_global_image_domain]||[GlobalUserImage isEqual:[NSNull null]]){
            [userImageBtn setBackgroundImage:[UIImage imageNamed:@"setting_profile_bg.png"] forState:UIControlStateNormal];
        }else{
            NSURL *url = [NSURL URLWithString:GlobalUserImage];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img =[UIImage imageWithData:data];
            [userImageBtn setBackgroundImage:img forState:UIControlStateNormal];
        }
        
        
    }else
    {
       // txtEmail.userInteractionEnabled = NO;
        txtFirstName.userInteractionEnabled = NO;
        txtLastName.userInteractionEnabled = NO;
        txtPassword.userInteractionEnabled = NO;
        txtConfirmPassword.userInteractionEnabled = NO;
        
        txtLastName.text=nil;
        txtEmail.text=nil;
        txtFirstName.text=nil;
        txtLastName.text=nil;
        txtEmail.text=nil;
        
        
        [userImageBtn setBackgroundImage:[UIImage imageNamed:@"setting_profile_bg.png"] forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading..",nil);
    [self.view addSubview:HUD];
    
    
    if([strFlagSave isEqualToString:@"true"]){
        
        strFlagSave = @"false";
            if([GlobalUserName length]>0){
                txtFirstName.text=GlobalUserName;
            }else{
                txtFirstName.text=GlobalTwitterUsername;
            }
            
           // txtEmail.userInteractionEnabled = YES;
            txtFirstName.userInteractionEnabled = YES;
            txtLastName.userInteractionEnabled = YES;
            txtPassword.userInteractionEnabled = YES;
            txtConfirmPassword.userInteractionEnabled = YES;
            
            txtLastName.text=GlobalUserLastName;
            txtEmail.text=GlobalUserEmailId;
            txtFirstName.text=GlobalUserName;
            txtLastName.text=GlobalUserLastName;
            txtEmail.text=GlobalUserEmailId;
            userImageBtn.layer.cornerRadius = 35;
            userImageBtn.clipsToBounds=YES;
            
            if(GlobalUserImage ==nil  || [GlobalUserImage isEqualToString:str_global_image_domain]||[GlobalUserImage isEqual:[NSNull null]]){
                [userImageBtn setBackgroundImage:[UIImage imageNamed:@"setting_profile_bg.png"] forState:UIControlStateNormal];
            }else{
                NSURL *url = [NSURL URLWithString:GlobalUserImage];
                NSData *data = [NSData dataWithContentsOfURL:url];
                UIImage *img =[UIImage imageWithData:data];
                [userImageBtn setBackgroundImage:img forState:UIControlStateNormal];
            }
            
            
    
    }
    
    
    
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    txtPassword.text = @"";
    txtConfirmPassword.text = @"";
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
    [txtFirstName resignFirstResponder];
    [txtLastName resignFirstResponder];
    [txtEmail resignFirstResponder];
    [txtPassword resignFirstResponder];
    [txtConfirmPassword resignFirstResponder];
    
}

// UITextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)uploadImageAction:(id)sender {
   
    if(GlobalUserID.length>0)
    {
        UIActionSheet   *callactionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:(id)self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Take photo",nil), NSLocalizedString(@"Choose from gallery",nil), nil];
        [callactionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }else
    {
        UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"You have to login first for view profile!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [msg show];
    }
    
   
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex== 0)
    {
       // NSLog(@"take photo button");
        
        imgPickerCObj = [[UIImagePickerController alloc] init];
        imgPickerCObj.sourceType = UIImagePickerControllerSourceTypeCamera;
        [imgPickerCObj setDelegate:(id)self];
        [self presentViewController:imgPickerCObj animated:YES completion:nil];
        
    }
    else if (buttonIndex== 1)
    {

        imgPickerCObj = [[UIImagePickerController alloc] init];
        imgPickerCObj.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [imgPickerCObj setDelegate:(id)self];
        [self presentViewController:imgPickerCObj animated:YES completion:nil];
        imgPickerCObj.allowsEditing = NO;
        imgPickerCObj.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypePhotoLibrary];
        
        
    }
    else if (buttonIndex== 2)
    {
       // NSLog(@"cancel button");
    }
    
    
}

#pragma IMAGE PICKER DELEGATES:
// image picker delegates:

-(void) imagePickerController:(UIImagePickerController *) picker didFinishPickingMediaWithInfo:(NSDictionary *) info {
    
    
    
    imgStr_Flag=@"1";
    image = [info objectForKey:UIImagePickerControllerOriginalImage];

    
    [userImageBtn setBackgroundImage:image forState:UIControlStateNormal];
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
   
}



- (IBAction)saveChangesAction:(id)sender
{
     // [HUD show:YES];
    if(GlobalUserID.length>0)
    {
      
        
        if([txtFirstName.text length]<=0)
        {
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter your first name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [msg show];
        }else if ([txtLastName.text length]<=0)
        {
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter your last name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [msg show];
        }else if ([txtEmail.text length]<=0)
        {
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Please enter your email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [msg show];
        }
        else
        {
            [HUD showWhileExecuting:@selector(EditProfileMethod) onTarget:self withObject:nil animated:YES];
           // [self EditProfileMethod];
            
        }
       // [HUD hide:YES];
        
    }else
    {
        UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"You have to login first for view profile!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [msg show];
        //[HUD hide:YES];
    }
    
}



- (void)EditProfileMethod
{
   
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];

    if (networkStatus == NotReachable)
    {
        //[HUD hide:YES];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:Nil message:NSLocalizedString(@"Opps! It looks like you're not connected to the internet. Check your connection and try again.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alert show];
           [HUD hide:YES];
    }
    else
    {
        
         NSString *strUploadtURL = [NSString stringWithFormat:@"%@%@",str_global_domain,@"ws-edit-profile?"] ;
    
        NSString            *stringBoundary, *contentType, *baseURLString, *urlString;
        NSURL               *url;
        NSMutableURLRequest *urlRequest;
        NSMutableData       *postBody;
        baseURLString   = [NSString stringWithFormat:@"%@",strUploadtURL];
        urlString       = [NSString stringWithFormat:@"%@", baseURLString];
        url             = [NSURL URLWithString:urlString];
        urlRequest      = [[NSMutableURLRequest alloc] initWithURL:url];
        [urlRequest setHTTPMethod:@"POST"];
        // Setup POST body
       
        contentType    = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary];
        [urlRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
        // Setting up the POST request's multipart/form-data body
        
        postBody = [NSMutableData data];
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"user_first_name\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:txtFirstName.text] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"user_last_name\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:txtLastName.text] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
       
        float h= image.size.height;
        
        if(h>0.000)
        {
            
            imgvw_Photo=[[UIImageView alloc]init];
             imgvw_Photo.image=image;
            
            NSData* pictureData = [NSData dataWithData:UIImageJPEGRepresentation(imgvw_Photo.image,0.5)];
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"profile_picture\"; filename=\"image.JPG\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postBody appendData:pictureData];
            [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"user_id\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithString:GlobalUserID] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [urlRequest setHTTPBody:postBody];
        
        // Response data from server
        NSData *responseData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];

        
        NSError *myError = nil;
        NSDictionary *res = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];

        
        if([[[res valueForKey:@"result"] valueForKey:@"msg"] isEqualToString:@"profile_update_success"])
        {
            
            strFlagSave = @"true";
            
            NSArray  *arrAlldata = [[res valueForKey:@"result"]valueForKey:@"result"];

            AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];

            NSString  *uImage=[arrAlldata valueForKey:@"profile_picture"];
            GlobalUserImage=[NSString stringWithFormat:@"%@",uImage];
            
            GlobalUserLastName = [arrAlldata valueForKey:@"last_name"];
            GlobalUserName = [arrAlldata valueForKey:@"first_name"];

            if(GlobalUserImage.length>0)
            {
                NSURL *url = [NSURL URLWithString:GlobalUserImage];
                NSData *data = [NSData dataWithContentsOfURL:url];
                appDelegate.imgProfile.image=[UIImage imageWithData:data];
            }else
            {
                appDelegate.imgProfile.image = [UIImage imageNamed:@"setting_profile_bg.png"];
            }
            
            Global_defaults=[NSUserDefaults standardUserDefaults];
            [Global_defaults setObject:GlobalUserName forKey:@"first_name"];
            [Global_defaults setObject:GlobalUserLastName forKey:@"last_name"];
            [Global_defaults setObject:GlobalUserImage forKey:@"profile_picture"];
            [Global_defaults synchronize];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            [HUD hide:YES];
            UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Your profile has been updated" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [msg show];
            
            
        }
  
    }
    
    [HUD hide:YES];
}


@end
