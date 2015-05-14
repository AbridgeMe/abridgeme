//
//  AboutUsViewController.m
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import "AboutUsViewController.h"

#import "ISColumnsController.h"
#import "SlideViewController.h"


@interface AboutUsViewController ()

@end

@implementation AboutUsViewController{
@private
    RevealBlock _revealBlock;
}

@synthesize columnsController;

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            if (self = [super initWithNibName:@"AboutUsViewController_iPhone4" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
        }
        else {
            //iPhone 5
            if (self = [super initWithNibName:@"AboutUsViewController" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        if (self = [super initWithNibName:@"AboutUsViewController_iPad" bundle:nil]) {
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
        
        UIButton * btnRightBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnRightBack setImage:[UIImage imageNamed:@"aboutus.png"] forState:UIControlStateNormal];
        [btnRightBack setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [btnRightBack addTarget:self action:@selector(revealSidebarRight) forControlEvents:UIControlEventTouchUpInside];
        btnRightBack.frame = CGRectMake(0, 0, 30, 30);
        UIBarButtonItem *RightBackBtn = [[UIBarButtonItem alloc]initWithCustomView:btnRightBack];
        self.navigationItem.rightBarButtonItem = RightBackBtn;

	return self;
}

- (void)revealSidebar {
	_revealBlock();
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"About Us";
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // Do any additional setup after loading the view from its nib.
    self.columnsController = [[ISColumnsController alloc] init];
    
    self.columnsController.navigationItem.hidesBackButton=NO;
    
    [self infoPage];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
   
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int ver = [version intValue];
    if (ver >= 7){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    } else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }

}
    
    
-(void)revealSidebarRight{
    self.columnsController = [[ISColumnsController alloc] init];
    
    self.columnsController.navigationItem.hidesBackButton=NO;
    
    [self infoPage];
}
    
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
}


#pragma mark - --- Custom method ---
-(void)infoPage
{
    [self reloadViewControllers];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    [self.navigationController pushViewController:columnsController animated:YES];
}


- (void)reloadViewControllers
{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
        // For iphone portrait view
        if([UIScreen mainScreen].bounds.size.height==480)
        {
            SlideViewController *viewController1 = [[SlideViewController alloc] initWithNibName:@"SlideViewController0_iPhone4" bundle:Nil];
            viewController1.navigationItem.title = @"AbridgeMe";
            
            SlideViewController *viewController2 = [[SlideViewController alloc] initWithNibName:@"SlideViewController1_iPhone4" bundle:Nil];
            viewController2.navigationItem.title = @"AbridgeMe";
            
            SlideViewController *viewController3 = [[SlideViewController alloc] initWithNibName:@"SlideViewController2_iPhone4" bundle:Nil] ;
            viewController3.navigationItem.title = @"AbridgeMe";
            
            
            
            
            
            
            
            self.columnsController.viewControllers = [NSArray arrayWithObjects:
                                                      viewController1,
                                                      viewController2,
                                                      viewController3,
                                                      
                                                      nil];
            
        }else{
            SlideViewController *viewController1 = [[SlideViewController alloc] initWithNibName:@"SlideViewController0" bundle:Nil];
            viewController1.navigationItem.title = @"AbridgeMe";
            
            SlideViewController *viewController2 = [[SlideViewController alloc] initWithNibName:@"SlideViewController1" bundle:Nil];
            viewController2.navigationItem.title = @"AbridgeMe";
            
            SlideViewController *viewController3 = [[SlideViewController alloc] initWithNibName:@"SlideViewController2" bundle:Nil] ;
            viewController3.navigationItem.title = @"AbridgeME";
            
            
            
            
            
            
            
            self.columnsController.viewControllers = [NSArray arrayWithObjects:
                                                      viewController1,
                                                      viewController2,
                                                      viewController3,
                                                      
                                                      nil];
        }
        
   
        
    }else{
        
        SlideViewController *viewController1 = [[SlideViewController alloc] initWithNibName:@"SlideViewControlleriPad0" bundle:Nil];
        viewController1.navigationItem.title = @"AbridgeMe";
        
        SlideViewController *viewController2 = [[SlideViewController alloc] initWithNibName:@"SlideViewControlleriPad1" bundle:Nil];
        viewController2.navigationItem.title = @"AbridgeMe";
        
        SlideViewController *viewController3 = [[SlideViewController alloc] initWithNibName:@"SlideViewControlleriPad2" bundle:Nil] ;
        viewController3.navigationItem.title = @"AbridgeMe";

        self.columnsController.viewControllers = [NSArray arrayWithObjects:
                                                  viewController1,
                                                  viewController2,
                                                  viewController3,
                                                 
                                                  nil];
        
    }
    
}

-(void)btn_Done
{
    [self.columnsController.navigationController popViewControllerAnimated:YES];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
