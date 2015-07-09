//
//  AppDelegate.m
//  AbridgeMe
//
//  Created by Lion on 14/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Global.h"
#import "ISColumnsController.h"
#import "SlideViewController.h"
#import "BaseViewController.h"
#import "GHRootViewController.h"
#import "GHMenuCell.h"
#import "GHMenuViewController.h"
#import "GHRevealViewController.h"
#import "GHSidebarSearchViewController.h"
#import "GHSidebarSearchViewControllerDelegate.h"
#import "ProfileViewController.h"
#import "SearchViewController.h"
#import "LoginViewController.h"
#import "AboutUsViewController.h"
#import "FeedbackViewController.h"
#import <FacebookSDK/FacebookSDK.h>

//#import "DemoTableViewController.h"

#pragma mark Private Interface
@interface AppDelegate () <GHSidebarSearchViewControllerDelegate>

@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHSidebarSearchViewController *searchController;
@property (nonatomic, strong) GHMenuViewController *menuController;
@property (nonatomic, strong) UIAlertView *alertView;

@end


@implementation AppDelegate

NSString *const FBSessionStateChangedNotification = @"com.abridgeme.AbridgeMe:FBSessionStateChangedNotification";

@synthesize columnsController;
@synthesize lblName,imgProfile,subview1,SummaryDataDictArray;
@synthesize strFlagFetchRecord;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //sleep(2.0);
    
    SummaryDataDictArray = [[NSMutableArray alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    Global_defaults=[NSUserDefaults standardUserDefaults];
    Global_loginStatus=[Global_defaults objectForKey:@"status"];
    
    if([Global_loginStatus isEqualToString:@"login"])
    {
        GlobalUserID=[Global_defaults valueForKey:@"user_id"];
        GlobalUserName=[Global_defaults valueForKey:@"first_name"];
        GlobalUserImage=[Global_defaults  valueForKey:@"profile_picture"];
        GlobalTwitterUsername=[Global_defaults  valueForKey:@"user_name"];
        GlobalUserEmailId=[Global_defaults  valueForKey:@"user_email"];
        GlobalUserLastName=[Global_defaults valueForKeyPath:@"last_name"];
        
       if(GlobalUserImage ==nil  || [GlobalUserImage isEqualToString:str_global_image_domain]||[GlobalUserImage isEqual:[NSNull null]]){
          imgProfile.image = [UIImage imageNamed:@"setting_profile_bg.png"];
       }
       else
       {
            NSURL *url = [NSURL URLWithString:GlobalUserImage];
            NSData *data = [NSData dataWithContentsOfURL:url];
            imgProfile.image=[UIImage imageWithData:data];
            
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
        
        
        
        lblName.text=GlobalUserName;
        
        if(GlobalUserImage ==nil  || [GlobalUserImage isEqualToString:str_global_image_domain]||[GlobalUserImage isEqual:[NSNull null]])
        {
            imgProfile.image = [UIImage imageNamed:@"setting_profile_bg.png"];
        }else
        {
            
            NSURL *url = [NSURL URLWithString:GlobalUserImage];
            NSData *data = [NSData dataWithContentsOfURL:url];
            imgProfile.image=[UIImage imageWithData:data];
        }
        
        self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
                                                                            withSearchBar:subview1
                                                                              withHeaders:headers
                                                                          withControllers:controllers
                                                                            withCellInfos:cellInfos];
        
    }else{
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
        
        
        
        lblName.text=GlobalUserName;
        
        if(GlobalUserImage ==nil  || [GlobalUserImage isEqualToString:str_global_image_domain]||[GlobalUserImage isEqual:[NSNull null]])
        {
            imgProfile.image = [UIImage imageNamed:@"setting_profile_bg.png"];
        }else
        {
            
            NSURL *url = [NSURL URLWithString:GlobalUserImage];
            NSData *data = [NSData dataWithContentsOfURL:url];
            imgProfile.image=[UIImage imageWithData:data];
        }
        
        self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController:self.revealController
                                                                            withSearchBar:subview1
                                                                              withHeaders:headers
                                                                          withControllers:controllers
                                                                            withCellInfos:cellInfos];
    }
    

    
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int ver = [version intValue];
    if (ver >= 7){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    } else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }

    
    //value fetch from plist
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"AbridgeMeDetail.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"AbridgeMeDetail" ofType:@"plist"];
    }
    
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
    if (!temp)
    {
       // NSLog(@"Error reading plist: %@, format%lu%u", errorDesc, format);
    }
    
    strValue=[NSString stringWithFormat:@"%@",[temp objectForKey:@"Global_value"]];
    
    
    if([strValue isEqualToString:@"1"])
    {
        strFlagFetchRecord = @"TRUE";
        [self getAllArticals];
        
    }else{
        strFlagFetchRecord = @"TRUE";
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
             [self getAllArticals];
             //strFlagFetchRecord = @"TRUE";
            dispatch_async(dispatch_get_main_queue(), ^{
              
                
            });
        });
    }
    

    
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.rootViewController = self.revealController;
    
        [self.window makeKeyAndVisible];
        
        return YES;
}


-(void)getNewArticlesFromServer{

        NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@",str_global_domain,@"ws-get-all-article"] ;
        BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
        
        NSDictionary *dict=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
        
        if ([str_ServerUnderMaintainess isEqualToString:@"NO"]) {
            
            NSLog(@"Internet is not available");
        }
        else if([[[dict valueForKey:@"result"]valueForKey:@"msg"] isEqualToString:@"get_all_article_success"])
        {
            NSString *filePath;
            NSData *allData;
            
            filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"summary.json"]];
            allData = [NSData dataWithContentsOfFile:filePath];
            
            [self writeJsonToFile:[[dict valueForKey:@"result"]valueForKey:@"result"] index:0];
            
            [SummaryDataDictArray addObject:dict];
            
            ViewController *obj = [[ViewController alloc]init];
            [obj FetchRecordAppMinimizeReopen];
        
            dispatch_queue_t myQueue = dispatch_queue_create("MyQueue1234567",NULL);
            dispatch_async(myQueue, ^{
                // Perform long running process
                NSArray *arrayImagesData = [[dict valueForKey:@"result"]valueForKey:@"result"];
            
                for(int i=0 ; i< [arrayImagesData count];i++)
                {
                    NSString *filename =[NSString stringWithFormat:@"%@",[[arrayImagesData objectAtIndex:i]valueForKey:@"topic_image"]];
                    
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



#pragma mark GetAllArticles...
-(void)getAllArticals
{
    NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@",str_global_domain,@"ws-get-all-article"] ;
    BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
    
    NSDictionary *dict=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
 
    if ([str_ServerUnderMaintainess isEqualToString:@"NO"]) {

        NSLog(@"Internet is not available");
    }
    else if([[[dict valueForKey:@"result"]valueForKey:@"msg"] isEqualToString:@"get_all_article_success"])
    {
        NSString *filePath;
        NSData *allData;
        NSError *error;

        filePath = [self documentsPathForFileName:[NSString stringWithFormat:@"summary.json"]];
        allData = [NSData dataWithContentsOfFile:filePath];
        
                [self writeJsonToFile:[[dict valueForKey:@"result"]valueForKey:@"result"] index:0];

            [SummaryDataDictArray addObject:dict];
        
        
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue123444",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            NSArray *arrayImagesData = [[dict valueForKey:@"result"]valueForKey:@"result"];
            for(int i=0 ; i< [arrayImagesData count];i++)
            {
                NSString *filename =[NSString stringWithFormat:@"%@",[[arrayImagesData objectAtIndex:i]valueForKey:@"topic_image"]];
                
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
        
       
 
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"AbridgeMeDetail.plist"];
        strValue=@"0";
        NSDictionary *plistDict = [NSDictionary dictionaryWithObject:strValue forKey:@"Global_value"];
        
        NSString *error1 = nil;
        NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error1];
        if(plistData)
        {
            [plistData writeToFile:plistPath atomically:YES];
        }
        else
        {
            NSLog(@"Error in saveData: %@", error);
            
        }
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



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    strFlagFetchRecord = @"FALSE";
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(![strFlagFetchRecord isEqualToString:@"TRUE"]){
        NSLog(@"Active");
        
        ViewController *obj = [[ViewController alloc]init];
        [obj HUDShow];

    }
    
   
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBSession.activeSession handleOpenURL:url];
}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}


-(void)searchResult:(id)result selectedAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)searchResultsForText:(NSString *)text withScope:(NSString *)scope callback:(SearchResultsBlock)callback{
    
}

-(UITableViewCell *)searchResultCellForEntry:(id)entry atIndexPath:(NSIndexPath *)indexPath inTableView:tableView
{
    return tableView;
}


@end
