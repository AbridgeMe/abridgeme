//
//  ViewController.m
//  AbridgeMe
//
//  Created by Lion on 14/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.


#import "ViewController.h"
#import "CustomArticleCell.h"
#import "DemoTableHeaderView.h"
#import "DemoTableFooterView.h"
#import "GHPushedViewController.h"
#import "SearchViewController.h"
#import "LoginViewController.h"
#import "Global.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "SummaryDetailViewController.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"

#define DEFAULT_HEIGHT_OFFSET 52.0f


@interface ViewController (){
    NSArray *arrayArticleImages;
    NSMutableArray *items;
    int i;
    int count;
    
    NSArray *userSeachData;
    UIButton * btnEditProfile;
    NSString *str_Flag;
    NSString *strFlagLoad;
    NSMutableArray *arr_SearchData;
    
    NSString *strFlagHashKeySearch;
    uint32_t rnd;
    NSString *strFlagAdded;
    int countvalue;
    UIRefreshControl *refreshControl;
}



// Private helper methods
- (void) addItemsOnBottom;
- (void) addItemsOnTop;

@end

@implementation ViewController{
@private
RevealBlock _revealBlock;
    
}

@synthesize tblviewArticle;
@synthesize allDataArray,allTopic;
@synthesize searchBar;
@synthesize headerView1;
@synthesize footerView1;
@synthesize isDragging;
@synthesize isRefreshing;
@synthesize isLoadingMore;
@synthesize canLoadMore;
@synthesize pullToRefreshEnabled;
@synthesize clearsSelectionOnViewWillAppear;
@synthesize NewSummaryDataDictArray;



#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            if (self = [super initWithNibName:@"ViewController_iPhone4" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
            
        }
        else {
            //iPhone 5
            if (self = [super initWithNibName:@"ViewController_iPhone5" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
           
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        if (self = [super initWithNibName:@"ViewController_iPad" bundle:nil]) {
            self.title = title;
            _revealBlock = [revealBlock copy];
            
        }
    }
    
    
    UIButton * btnSetting = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSetting setImage:[UIImage imageNamed:@"details.png"] forState:UIControlStateNormal];
    [btnSetting addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
    btnSetting.frame = CGRectMake(0, 0, 30, 25);
    UIBarButtonItem *SettingBtn = [[UIBarButtonItem alloc]initWithCustomView:btnSetting];
    
    
    
    UIButton * btnRandom = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRandom setBackgroundImage:[UIImage imageNamed:@"shuffle_icon.png"] forState:UIControlStateNormal];
    btnRandom.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [btnRandom setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btnRandom addTarget:self action:@selector(RandomClicked) forControlEvents:UIControlEventTouchUpInside];
    btnRandom.frame = CGRectMake(0, 0, 30, 30);
    UIBarButtonItem *RandomBtn = [[UIBarButtonItem alloc]initWithCustomView:btnRandom];

    
    self.navigationItem.leftBarButtonItems = @[SettingBtn];
    
    self.navigationItem.rightBarButtonItems= @[RandomBtn];
    
    btnEditProfile = [UIButton buttonWithType:UIButtonTypeCustom];
  
    if([GlobalUserID length]>0 )
    {
        [btnEditProfile setTitle:@"Sign Out" forState:UIControlStateNormal];
        
    }else
    {
        [btnEditProfile setTitle:@"Sign In" forState:UIControlStateNormal];
    }
    [btnEditProfile setBackgroundImage:[UIImage imageNamed:@"btn_bg.png"] forState:UIControlStateNormal];
    [btnEditProfile setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnEditProfile setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    btnEditProfile.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [btnEditProfile addTarget:self action:@selector(EditFriendProfileClicked) forControlEvents:UIControlEventTouchUpInside];
    btnEditProfile.frame = CGRectMake(0, 0, 75, 30);
    
    searchBar.delegate=self;
    
	return self;
}

- (void)revealSidebar {
	_revealBlock();
}

-(void)refreshAction
{
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue12345888",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        
        [self getAllArticals];
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
    
}
-(void)RandomClicked{
 
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getSummaryData;
    
    getSummaryData = [documentsDirectory stringByAppendingPathComponent:@"summary.json"];
    
    NSData *data = [NSData dataWithContentsOfFile:getSummaryData];
    
    if(data == Nil){
        userData = [[NSArray alloc]init];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
        [alert show];
    }else{
        
    userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    rnd = arc4random_uniform((int)[userData count]);

    SummaryDetailViewController *obj;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
          obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController" bundle:nil];
           
            
        }
        else {
            //iPhone 5
            obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController" bundle:nil];


        }
    }else {
        //"iPad”
    obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController_iPad" bundle:nil];
       
    }
        obj.strRandomFlag=@"YES";
     obj.allDataArray = [userData objectAtIndex:rnd];
    [self.navigationController pushViewController:obj animated:YES];
   
    }

}


#pragma ViewDidLoad method
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    countvalue = 100;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    strFlagHashKeySearch = @"false";
    
    strFlagLoad = @"true";
    
    for (UITextView *view in self.view.subviews) {
        if ([view isKindOfClass:[UITextView class]]) {
            view.scrollsToTop = NO;
        }
    }
       self.tblviewArticle.scrollsToTop = YES;

    
    
    // Navigation bar background image
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int ver = [version intValue];
    if (ver >= 7){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    } else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    Global_loginStatus = [prefs stringForKey:@"status"];
    
    if([Global_loginStatus isEqualToString:@"login"])
    {
        GlobalUserID=[Global_defaults valueForKey:@"user_id"];
        GlobalUserName=[Global_defaults valueForKey:@"first_name"];
        GlobalUserImage=[Global_defaults  valueForKey:@"profile_picture"];
        GlobalTwitterUsername=[Global_defaults  valueForKey:@"user_name"];
        GlobalUserEmailId=[Global_defaults  valueForKey:@"user_email"];
        GlobalUserLastName=[Global_defaults valueForKeyPath:@"last_name"];
    }
    
    appDelegate.lblName.text=GlobalUserName;
    if(GlobalUserImage ==nil || [GlobalUserImage isEqualToString:str_global_image_domain]||[GlobalUserImage isEqual:[NSNull null]])
    {
        appDelegate.imgProfile.image = [UIImage imageNamed:@"setting_profile_bg.png"];
        
    }else
    {
        
        NSURL *url = [NSURL URLWithString:GlobalUserImage];
        NSData *data = [NSData dataWithContentsOfURL:url];
        appDelegate.imgProfile.image=[UIImage imageWithData:data];
    }
   
    if(GlobalUserName.length>0)
    {
         appDelegate.lblName.text=GlobalUserName;
    }else
    {
         appDelegate.lblName.text=@"";
    }

    
    
    pullToRefreshEnabled = YES;
    canLoadMore = YES;
    clearsSelectionOnViewWillAppear = YES;
  
    autoCompleteArray=[[NSMutableArray alloc]init];
    autoCompleteString=[[NSMutableString alloc]init];
    
    Global_defaults=[NSUserDefaults standardUserDefaults];
    Global_loginStatus=[Global_defaults objectForKey:@"status"];

    NSArray *nib;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            nib= [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView" owner:self options:nil];
        }
        else {
            //iPhone 5
           nib= [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView" owner:self options:nil];
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
       nib= [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView_iPad" owner:self options:nil];
    }
    
    
    DemoTableHeaderView *headerView = (DemoTableHeaderView *)[nib objectAtIndex:0];
    headerView1 = headerView;
    
    // set the custom view for "load more". See DemoTableFooterView.xib.
    NSArray *nibheader;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            nibheader = [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView" owner:self options:nil];
         
        }
        else {
            //iPhone 5
            nibheader = [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView" owner:self options:nil];
           
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        nibheader = [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView_iPad" owner:self options:nil];
       
    }
    
    DemoTableFooterView *footerView = (DemoTableFooterView *)[nibheader objectAtIndex:0];
    footerView1 = footerView;
    
    
    
}


    
-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y == 0)
        NSLog(@"At the top");
}
#pragma mark ViewWillAppear

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading..",nil);
    
    [HUD show:YES];
    
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue123456789",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
        [self FetchRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tblviewArticle reloadData];
        });
    });
    
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (clearsSelectionOnViewWillAppear) {
        NSIndexPath *selected = [self.tblviewArticle indexPathForSelectedRow];
        if (selected)
            [self.tblviewArticle deselectRowAtIndexPath:selected animated:YES];
    }
    
     [self scrollViewDidScroll:nil];
    
    [tblviewArticle setScrollsToTop:YES];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getSummaryData;
    
    getSummaryData = [documentsDirectory stringByAppendingPathComponent:@"summary.json"];
    NSData *data = [NSData dataWithContentsOfFile:getSummaryData];
    if(data == Nil){
        userData = [[NSArray alloc]init];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
        [alert show];
    }else{
     
        userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        allDataArray = [[NSMutableArray alloc]init];
        allTopic = [userData mutableCopy];
        
        if([userData count]>0){
            //arrayitems = [[NSMutableArray alloc]init];
            
            if([allTopic count] > 100){
                
                for(int n=0; n<100; n++){
                    rnd = arc4random_uniform((int)[userData count]);
                    [allDataArray addObject:[allTopic objectAtIndex:rnd]];
                }
                [self.tblviewArticle reloadData];
                
            }else{
                allDataArray = [allTopic mutableCopy];
                
                [self.tblviewArticle reloadData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tblviewArticle scrollToRowAtIndexPath:indexPath
                                           atScrollPosition:UITableViewScrollPositionTop
                                                   animated:YES];
            }
        }
    }
    
    
    if([GlobalUserID length]>0 )
    {
        [btnEditProfile setTitle:@"Sign Out" forState:UIControlStateNormal];

    }else
    {
        [btnEditProfile setTitle:@"Sign In" forState:UIControlStateNormal];
    }
    
    if( [regFlag isEqualToString:@"VOTE_SUCCESS"])
    {
        [HUD show:YES];

    }
    
}

-(void)HUDShow{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading..",nil);
    
    //[HUD show:YES];
    [HUD showWhileExecuting:@selector(FetchRecord) onTarget:self withObject:nil animated:YES];
    
}


-(void)FetchRecord{
   // AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
   // [appDelegate getNewArticlesFromServer];
    
   // [self FetchRecordAppMinimizeReopen];
}


-(void)FetchRecordAppMinimizeReopen{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getSummaryData;
    
    getSummaryData = [documentsDirectory stringByAppendingPathComponent:@"summary.json"];
    NSData *data = [NSData dataWithContentsOfFile:getSummaryData];
    if(data == Nil){
        userData = [[NSArray alloc]init];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
        [alert show];
    }else{
        userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        allDataArray = [[NSMutableArray alloc]init];
        allTopic = [userData mutableCopy];
        
        if([userData count]>0){
            //arrayitems = [[NSMutableArray alloc]init];
            if([allTopic count] > 100){
                
                for(int n=0; n<100; n++){
                    rnd = arc4random_uniform((int)[userData count]);
                    [allDataArray addObject:[allTopic objectAtIndex:rnd]];
                }
                [HUD hide:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblviewArticle reloadData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tblviewArticle scrollToRowAtIndexPath:indexPath
                                               atScrollPosition:UITableViewScrollPositionTop
                                                       animated:YES];
                    
                });
                
            }else{
                allDataArray = [allTopic mutableCopy];
                
                [HUD hide:YES];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tblviewArticle reloadData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tblviewArticle scrollToRowAtIndexPath:indexPath
                                               atScrollPosition:UITableViewScrollPositionTop
                                                       animated:YES];
                    
                });
            }
        }
    }
}



- (void)refresh:(UIRefreshControl *)refreshControl
{
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue12345888",NULL);
    dispatch_async(myQueue, ^{
        // Perform long running process
       
          [self getAllArticals];
        dispatch_async(dispatch_get_main_queue(), ^{
           
        });
    });
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    if([strFlagLoad isEqualToString:@"true"])
    {
        strFlagLoad = @"false";
       // [self getAllArticals];
    }

    [HUD hide:YES];
}


#pragma mark Private Methods
- (void)pushViewController {
	NSString *vcTitle = [self.title stringByAppendingString:@" - Pushed"];
	UIViewController *vc = [[GHPushedViewController alloc] initWithTitle:vcTitle];
	[self.navigationController pushViewController:vc animated:YES];
}



// Custom Back button method
-(void)EditFriendProfileClicked{
    
    regFlag=@"NO";
    
    if([GlobalUserID length]>0 )
    {
        
        UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Are you sure to leave?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        [msg show];
        
    }else
    {
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            LoginViewController *obj = [[LoginViewController alloc]initWithNibName:@"LoginViewController_iPhone4" bundle:nil];
            obj.strNavgSearchFlag = @"true";
            [self.navigationController pushViewController:obj animated:YES];
        }
        else {
            //iPhone 5
            LoginViewController *obj = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
            obj.strNavgSearchFlag = @"true";
            [self.navigationController pushViewController:obj animated:YES];
        }
    }else
    {
        //"iPad”
        LoginViewController *obj = [[LoginViewController alloc]initWithNibName:@"LoginViewController_iPad" bundle:nil];
        obj.strNavgSearchFlag = @"true";
     [self.navigationController pushViewController:obj animated:YES];
 
     }
    
    
    }
}


#pragma mark AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
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
            appDelegate.imgProfile.image = [UIImage imageNamed:@"setting_profile_bg.png"];
        }else{
            NSURL *url = [NSURL URLWithString:GlobalUserImage];
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img =[UIImage imageWithData:data];
            appDelegate.imgProfile.image = img;
            
        }
        [btnEditProfile setTitle:@"Sign In" forState:UIControlStateNormal];
        
        
        UIAlertView *msg=[[UIAlertView alloc]initWithTitle:nil message:@"Logout successfully." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        [msg show];

    }
    else
    {
        //Do something else
        
    }
}

- (void)addItemsOnBottom
{
    int oldvalue = countvalue;
    if (oldvalue < [userData count]){
        countvalue = countvalue +100;
        
        if(countvalue>[userData count])
            countvalue = (int)[userData count];
        

        for (int index=oldvalue; index<countvalue; index++) {
            [allDataArray addObject:[allTopic objectAtIndex:index]];
        }
        [self.tblviewArticle reloadData];
        self.canLoadMore = YES;
    }else{
        self.canLoadMore = NO;
    }
    
    
    [self loadMoreCompleted];
    
    
}


- (void) addItemsOnTop
{
    /*for (int i = 0; i < 3; i++)
        [items insertObject:[self createRandomValue] atIndex:0];
    [self.tableView reloadData];
    
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    [self refreshCompleted];*/
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    if([str_Flag isEqualToString:@"SEARCH"])
        return [arr_SearchData count];
    else
          return [allDataArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            height = 95;
        }
        else {
            //iPhone 5
            height = 95;
        }
    }else {
        //"iPad”
        height = 143;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomArticleCell";
    CustomArticleCell *cell = (CustomArticleCell *)[tblviewArticle dequeueReusableCellWithIdentifier:CellIdentifier];
    
   
    if (cell == nil) {
        NSArray *nib;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
            if(iOSDeviceScreenSize.height == 480){
                //iPhone 4
               nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell" owner:self options:nil];
            }
            else {
                //iPhone 5
                nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell" owner:self options:nil];
            }
        }else {
            //"iPad”ƒ
            nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell_iPad" owner:self options:nil];
        }
        
        
        cell = [nib objectAtIndex:0];
    }
    
    
    if([str_Flag isEqualToString:@"SEARCH"])
    {
       
        if([arr_SearchData count]>0){
        NSArray *allData=[arr_SearchData objectAtIndex:indexPath.row];
        NSString *strDescription;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.titleLabel.text=[allData valueForKey:@"topic_title"];
        strDescription= [allData valueForKey:@"summary_desc"];
            
        if ([strDescription length]>1) {
            
        }else
            strDescription = [NSString stringWithFormat:@"%@",[[allData valueForKey:@"summary"]valueForKey:@"summary_desc"]];
           
        if([strDescription hasPrefix:@"("])
        {
            NSArray *tmp123=[[allData valueForKey:@"summary"]valueForKey:@"summary_desc"];
            
            strDescription=[NSString stringWithFormat:@"%@",[tmp123 objectAtIndex:0]];
        }
            
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
        
        
        NSMutableAttributedString *attributedStringTopic = [[NSMutableAttributedString alloc] initWithString:strDescription];
        NSMutableParagraphStyle *paragraphStyleTopic = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyleTopic setLineSpacing:5];
        [attributedStringTopic addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTopic range:NSMakeRange(0, [strDescription length])];
        

        
        cell.subtitleLabel.attributedText= attributedStringTopic;
            
            
            NSString *strImage=[NSString stringWithFormat:@"%@",[allData valueForKey:@"topic_image"]];
            if([strImage isEqualToString:@""])
            {
                
                
            }
            else
            {
                Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                if (networkStatus == NotReachable)
                {
                    
                    NSString *filePath = [self documentsPathForFileName:strImage];
                    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                    if(pngData == NULL)
                    {
                        
                    }
                    else
                    {
                        UIImage *image = [UIImage imageWithData:pngData];
                        cell.imgviewArticle.image=image;
                    }
                } else {
                    
                    NSString *img=[NSString stringWithFormat:@"%@%@",str_global_summary_image,strImage] ;
                    
                    NSString *filePath = [self documentsPathForFileName:strImage];
                    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                    if(pngData == NULL)
                    {
                        NSURL *url = [NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        
                        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                        {
                            [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_ipad.png"]];
                        }else{
                            [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_iphone.png"]];
                        }
                        
                        
                    }
                    else
                    {
                        UIImage *image = [UIImage imageWithData:pngData];
                        
                        cell.imgviewArticle.image=image;
                    }
                }
                
                
            }

    
        }
    
    }
    else
    {
        
                NSArray *allData=[userData objectAtIndex:indexPath.row];
                NSArray *temp=[allData valueForKey:@"summary"];
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                 cell.titleLabel.text=[allData valueForKey:@"topic_title"];
                temp = [[temp reverseObjectEnumerator] allObjects];
                if([temp count]>0)
                {
                    temp=[temp objectAtIndex:0];
                    NSString *strDescription = [temp valueForKey:@"summary_desc"];
                    strDescription = [strDescription stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                    strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
                    strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                    strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                    strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                    strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                     strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
                    strDescription = [strDescription stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
                    
                    
                    NSMutableAttributedString *attributedStringTopic = [[NSMutableAttributedString alloc] initWithString:strDescription];
                    NSMutableParagraphStyle *paragraphStyleTopic = [[NSMutableParagraphStyle alloc] init];
                    [paragraphStyleTopic setLineSpacing:5];
                    [attributedStringTopic addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTopic range:NSMakeRange(0, [strDescription length])];
                    
                    //NSString *strDesc = [NSString stringWithFormat:@"%@",strDescription];
                    
                     cell.subtitleLabel.attributedText= attributedStringTopic;
                    
                    
                    
                    
                    NSString *strImage=[NSString stringWithFormat:@"%@",[allData valueForKey:@"topic_image"]];
                    if([strImage isEqualToString:@""])
                    {
                        
                        
                    }
                    else
                    {
                        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                        if (networkStatus == NotReachable)
                        {
                            
                            NSString *filePath = [self documentsPathForFileName:strImage];
                            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                            if(pngData == NULL)
                            {
                                
                            }
                            else
                            {
                                UIImage *image = [UIImage imageWithData:pngData];
                                cell.imgviewArticle.image=image;
                            }
                        } else {
            
                            NSString *img=[NSString stringWithFormat:@"%@%@",str_global_summary_image,strImage] ;
                            
                            NSString *filePath = [self documentsPathForFileName:strImage];
                            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                            if(pngData == NULL)
                            {
                                NSURL *url = [NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                  
                                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                                {
                                    [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_ipad.png"]];
                                }else{
                                    [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_iphone.png"]];
                                }
                                
                                
                            }
                            else
                            {
                                UIImage *image = [UIImage imageWithData:pngData];
                                
                                cell.imgviewArticle.image=image;
                            }
                        }
                        
                        
                    }
                    
                    
                }else
                {
                    //search
                    if([str_Flag isEqualToString:@"SEARCH"])
                    {
                        NSString *strDescription = [allData valueForKey:@"summary_desc"];
                        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
                        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                        strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
                          strDescription = [strDescription stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
                        
                        NSMutableAttributedString *attributedStringTopic = [[NSMutableAttributedString alloc] initWithString:strDescription];
                        NSMutableParagraphStyle *paragraphStyleTopic = [[NSMutableParagraphStyle alloc] init];
                        [paragraphStyleTopic setLineSpacing:5];
                        [attributedStringTopic addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTopic range:NSMakeRange(0, [strDescription length])];
                        
                        cell.subtitleLabel.attributedText= attributedStringTopic;
                
                        
                        NSString *strImage=[NSString stringWithFormat:@"%@",[allData valueForKey:@"topic_image"]];
                        if([strImage isEqualToString:@""])
                        {
                            
                            
                        }
                        else
                        {
                            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                            if (networkStatus == NotReachable)
                            {
                                
                                NSString *filePath = [self documentsPathForFileName:strImage];
                                NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                                if(pngData == NULL)
                                {
                                   
                                }
                                else
                                {
                                    UIImage *image = [UIImage imageWithData:pngData];
                                    cell.imgviewArticle.image=image;
                                }
                            } else {
                                NSString *img=[NSString stringWithFormat:@"%@%@",str_global_summary_image,strImage] ;
                                NSString *filePath = [self documentsPathForFileName:strImage];
                                NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                                if(pngData == NULL)
                                {
                                    NSURL *url = [NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                    
                                    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                                    {
                                        [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_ipad.png"]];
                                    }else{
                                        [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_iphone.png"]];
                                    }
                                }
                                else
                                {
                                    UIImage *image = [UIImage imageWithData:pngData];
                                    
                                    cell.imgviewArticle.image=image;
                                }
                            }
                            
                            
                        }
                        
                
                    }else
                        {
                        temp = [[temp reverseObjectEnumerator] allObjects];
                        
                        }
                }
        
    }
        

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}


#pragma mark TableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [HUD show:YES];
    
    NSArray *allData;

    if([str_Flag isEqualToString:@"SEARCH"])
    {
        allData=[arr_SearchData objectAtIndex:indexPath.row];
        
        SummaryDetailViewController *obj;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
            if(iOSDeviceScreenSize.height == 480){
                //iPhone 4
                obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController" bundle:nil];
            }
            else {
                //iPhone 5
                obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController" bundle:nil];
            }
        }else {
            //"iPad”
            obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController_iPad" bundle:nil];
            
        }
        obj.allDataArray=allData;
        obj.currIndex=(int)indexPath.row;
        obj.arrAllData = arr_SearchData;
        [HUD hide:YES];
        
        [self.navigationController pushViewController:obj animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
    }
    else
    {
    
 
        
        allData=[userData objectAtIndex:indexPath.row];
        
        SummaryDetailViewController *obj;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
            if(iOSDeviceScreenSize.height == 480){
                //iPhone 4
                obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController" bundle:nil];
            }
            else {
                //iPhone 5
                obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController" bundle:nil];
            }
        }else {
            //"iPad”
            obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController_iPad" bundle:nil];
            
        }
        obj.allDataArray=allData;
        obj.arrAllData = userData;
        obj.currIndex=(int)indexPath.row;
        
        [HUD hide:YES];
        
        [self.navigationController pushViewController:obj animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
 
    
    if (!isRefreshing && isDragging && scrollView.contentOffset.y < 0) {
        // Krishna
        [self headerViewDidScroll:scrollView.contentOffset.y < 0 - [self headerRefreshHeight]
                       scrollView:scrollView];
    }
    else if (!isLoadingMore && canLoadMore)
    {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < [self footerLoadMoreHeight])
        {
            [self loadMore];
            
            
            if([str_Flag isEqualToString:@"SEARCH"])
            {
                
            }
            else
            {
                
               // [self getAllArticals];
            }
        }
    }
    
    // Get visible cells on table view.
    NSArray *visibleCells = [self.tblviewArticle visibleCells];
    
    for (CustomArticleCell *cell in visibleCells) {
        [cell cellOnTableView:self.tblviewArticle didScrollOnView:self.view];
    }
}

#pragma mark GetAllArticles...
-(void)getAllArticals
{

    NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@",str_global_domain,@"ws-get-all-article"] ;
    BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
    
    NSDictionary *dict=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
    

    if ([str_ServerUnderMaintainess isEqualToString:@"NO"]) {
        [HUD hide:YES];
        str_ServerUnderMaintainess = @"Yes";
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
        [alert show];
        // [refreshControl endRefreshing];
    }
    else if([[[dict valueForKey:@"result"]valueForKey:@"msg"] isEqualToString:@"get_all_article_success"])
    {
        NSString *filePath;
        NSData *allData;

        filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"summary.json"]];
        allData = [NSData dataWithContentsOfFile:filePath];

        [self writeJsonToFile:[[dict valueForKey:@"result"]valueForKey:@"result"] index:0];

        
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *getSummaryData;
        
        getSummaryData = [documentsDirectory stringByAppendingPathComponent:@"summary.json"];
   
        NSData *data = [NSData dataWithContentsOfFile:getSummaryData];
        
        
        if(data == Nil){
            [HUD hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
            userData = [[NSArray alloc]init];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
            [alert show];
            //[refreshControl endRefreshing];
            
            isRefreshing = NO;
            
            [self unpinHeaderView];
        });
            
        }else{
            //[refreshControl endRefreshing];
            [HUD hide:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                isRefreshing = NO;
                
                [self unpinHeaderView];
                userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                [self.tblviewArticle reloadData];
                NSIndexPath *indexPathrow= [NSIndexPath indexPathForItem:0 inSection:0];
                
                [self.tblviewArticle scrollToRowAtIndexPath:indexPathrow atScrollPosition:UITableViewScrollPositionTop animated:YES];

            });
        }

        dispatch_queue_t myQueue = dispatch_queue_create("My Queue12345",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            NSArray *arrayImagesData = [[dict valueForKey:@"result"]valueForKey:@"result"];
      
            for(int num=0 ; num< [arrayImagesData count];num++)
            {
                NSString *filename =[NSString stringWithFormat:@"%@",[[arrayImagesData objectAtIndex:num]valueForKey:@"topic_image"]];
                
                if([filename isEqualToString:@""]){
                    NSLog(@"No image found");
                }else{
                    NSString *filePath = [self documentsPathForFileName:filename];
                    NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                    if(pngData == NULL)
                    {
                        NSString *str_url=[NSString stringWithFormat:@"%@%@",str_global_summary_image,filename];
                        
                        NSData *pngData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_url]];
                        
                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
                        NSString *filePath = [documentsPath stringByAppendingPathComponent:filename]; //Add the file name
                        [pngData writeToFile:filePath atomically:YES]; //Write the file
                    }
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
                
            });
        });
    }
}

- (void)writeJsonToFile:(NSDictionary*)dataDict index:(NSInteger)index
{
    NSError *error;
    NSData *dataFromDict = [NSJSONSerialization dataWithJSONObject:dataDict
                                                           options:kNilOptions
                                                             error:&error];
    
    NSString *filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"summary.json"]];
    [dataFromDict writeToFile:filePath atomically:YES];
}


- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
    
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBarr
{
    self.searchDisplayController.searchBar.hidden = YES;
    [searchBarr resignFirstResponder];
    searchBarr.text = @"";
    [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:self.searchBar afterDelay:0];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (isRefreshing)
        return;
    
    isDragging = NO;
    if (scrollView.contentOffset.y <= 0 - [self headerRefreshHeight]) {
        //if (pullToRefreshEnabled)
            [self refresh];
    }
}

- (void) setHeaderView:(UIView *)aView
{

    
    if (!tblviewArticle)
        return;
    
    tblviewArticle.tableHeaderView = nil;
    headerView1 = nil;
    
    
    if (aView) {
        
        headerView1 = aView;
        DemoTableFooterView *fv = (DemoTableFooterView *)headerView1;
        [fv.activityIndicator startAnimating];
        tblviewArticle.tableHeaderView = headerView1;
       

    }
    
}



- (CGFloat) headerRefreshHeight
{
    if (!CGRectIsEmpty(headerViewFrame))
        return headerViewFrame.size.height;
    else
        return DEFAULT_HEIGHT_OFFSET;
}

- (void) pinHeaderView
{
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.tblviewArticle.contentInset = UIEdgeInsetsMake([self headerRefreshHeight], 0, 0, 0);
    }];
}

- (void) unpinHeaderView
{
    
    self.tblviewArticle.tableHeaderView = nil;
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.tblviewArticle.contentInset = UIEdgeInsetsZero;
        NSIndexPath *indexPathrow= [NSIndexPath indexPathForItem:0 inSection:0];
        
        [self.tblviewArticle scrollToRowAtIndexPath:indexPathrow atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        
    }];
}

- (void) willBeginRefresh
{
    //if (pullToRefreshEnabled)
       // [self pinHeaderView];
}


- (BOOL) refresh
{
    if (isRefreshing)
        return NO;
    
    //[self willBeginRefresh];
    [self setHeaderView:headerView1];
    
    [self refreshAction];
    
    isRefreshing = YES;
    return YES;
    
    if (![self loadMore1])
        return NO;

}


- (void) refreshCompleted
{
    isRefreshing = NO;
    
    //if (pullToRefreshEnabled)
        [self unpinHeaderView];
}

#pragma mark - Load More
- (void) setFooterView:(UIView *)aView
{
    if (!tblviewArticle)
        return;
    
    tblviewArticle.tableFooterView = nil;
    footerView1 = nil;
    
    if (aView) {
        
        footerView1 = aView;
        
        tblviewArticle.tableFooterView = footerView1;
    }
}


- (void) willBeginLoadingMore
{
    DemoTableFooterView *fv = (DemoTableFooterView *)self.footerView1;
    [fv.activityIndicator startAnimating];
}

- (void) loadMoreCompleted
{
    [self loadMoreCompleted1];
    
    DemoTableFooterView *fv = (DemoTableFooterView *)self.footerView1;
    [fv.activityIndicator stopAnimating];
    self.tblviewArticle.tableFooterView = nil;
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by:
        [self setFooterViewVisibility:NO];
    
        // Just show a textual info that there are no more items to load
       // fv.infoLabel.hidden = NO;
    }
}

- (void) loadMoreCompleted1
{
    isLoadingMore = NO;
}

- (BOOL) loadMore
{
    if (![self loadMore1])
        return NO;

    [self setFooterView:footerView1];
   
    // Do your async loading here
    [self performSelector:@selector(addItemsOnBottom) withObject:nil afterDelay:1];
    return YES;
}



- (BOOL) loadMore1
{
    if (isLoadingMore)
        return NO;
    
    [self willBeginLoadingMore];
    isLoadingMore = YES;
    return YES;
}



- (CGFloat) footerLoadMoreHeight
{
    if (footerView1)
        return footerView1.frame.size.height;
    else
        return DEFAULT_HEIGHT_OFFSET;
}


- (void) setFooterViewVisibility:(BOOL)visible
{
    if (visible && self.tblviewArticle.tableFooterView != footerView1)
        self.tblviewArticle.tableFooterView = footerView1;
    else if (!visible)
        self.tblviewArticle.tableFooterView = nil;
}


#pragma mark -
- (void) allLoadingCompleted
{
    if (isRefreshing)
        [self refreshCompleted];
    if (isLoadingMore)
        [self loadMoreCompleted];
}

#pragma mark - UIScrollViewDelegate
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (isRefreshing)
        return;
    isDragging = YES;
    
    
}

- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    DemoTableHeaderView *DemoView;

    DemoView = (DemoTableHeaderView *)self.headerView1;

}


#pragma mark - SearchBar Delegates.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   
    if ([searchText length] == 0) {
        
      [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:self.searchBar afterDelay:0];
        
    }
    else
    {
        str_Flag=@"SEARCH";
        
        NSString *searchtext= [NSString stringWithFormat:@"%@",searchText];
        if([userData count]>0){
        if([searchtext length]>0)
        {
            strFlagHashKeySearch = @"false";
            
            dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
            dispatch_async(myQueue, ^{
               
            strFlagAdded = @"false";
                
            // Perform long running process
            arr_SearchData = [[NSMutableArray alloc] init];
           
            for(int j=0;j<[userData count];j++)
            {
                NSDictionary *temp= [userData objectAtIndex:j];
                
                NSArray *temp1= [temp valueForKey:@"summary"];
                
                if([temp1 count]>0)
                {
                    NSDictionary *objtemp=[temp1 objectAtIndex:0];
                    
                    
                    NSString *stringArray= [objtemp valueForKey:@"topic_title"];
                    stringArray = [stringArray lowercaseString];
                    NSRange r = [stringArray rangeOfString:searchtext options:NSCaseInsensitiveSearch];
            
                    if(r.location != NSNotFound)
                    {
                        strFlagAdded = @"true";
                        [arr_SearchData addObject:[userData objectAtIndex:j]];
                    }
                }
                
                
                NSArray *tempTag= [temp valueForKey:@"tags"];
                
                NSString *strSearchText;
                
                strSearchText = searchText;
                
                strSearchText = [strSearchText stringByReplacingOccurrencesOfString:@"#" withString:@""];
        
                if([tempTag count]>0)
                {
                    for(int num=0;num<[tempTag count];num++){
                        
                        NSDictionary *temp=[tempTag objectAtIndex:num];
                        
                        NSString *stringArray= [temp valueForKey:@"name"];
                        stringArray = [stringArray lowercaseString];
                        strSearchText = [strSearchText lowercaseString];
                        
                        if ([stringArray isEqualToString:strSearchText]) {
                                if([strFlagAdded isEqualToString:@"true"]){
                                   strFlagAdded = @"false";
                                }else{
                                    [arr_SearchData addObject:[userData objectAtIndex:j]];
                                }
                        }
                    }
                }
            }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([arr_SearchData count]>0){
                        
                        NSMutableArray *uniqueArray = [NSMutableArray array];
                        
                        [uniqueArray addObjectsFromArray:[[NSSet setWithArray:arr_SearchData] allObjects]];
                        
                        arr_SearchData = [uniqueArray mutableCopy];
                        
                    [self.tblviewArticle reloadData];
                    NSIndexPath *indexPathrow= [NSIndexPath indexPathForItem:0 inSection:0];
                    [self.tblviewArticle scrollToRowAtIndexPath:indexPathrow atScrollPosition:UITableViewScrollPositionTop animated:YES];
                    }else{
    
                        [self.tblviewArticle reloadData];

                    }
                    
                });
            });
        }
    }
    }
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBarr {
    searchBarr.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBarr {
    searchBarr.showsCancelButton = NO;
    return YES;
}


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchDisplayController.searchBar.hidden = NO;
}


- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [self.searchBar resignFirstResponder];
        return NO;
    }
    return YES;
}


- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
     str_Flag=@"ALLARTICLE";
    [self.tblviewArticle reloadData];
}


@end
