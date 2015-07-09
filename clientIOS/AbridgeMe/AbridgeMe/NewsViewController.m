//
//  NewsViewController.m
//  AbridgeMe
//
//  Created by Mackintosh on 24/06/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()

@end

@implementation NewsViewController
@synthesize webLink,flag;

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
    
    if([flag isEqualToString:@"YES"])
        self.title=@"Profile";
    else
        self.title=@"In the News";
   
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width  , [UIScreen mainScreen].bounds.size.height)];
   
    NSURL *nsurl=[NSURL URLWithString:webLink];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    webview.contentMode = UIViewContentModeScaleAspectFit;
    
    [webview loadRequest:nsrequest];
    
    [self customnavBarbuttons];
    
    [self.view addSubview:webview];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
