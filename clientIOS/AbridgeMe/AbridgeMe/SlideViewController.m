//
//  SlideViewController.m
//  SlideViewDemo
//
//  Created by Panacea on 25/07/2013.
//  Copyright (c) 2013 panaceatek. All rights reserved.
//

#import "SlideViewController.h"

@interface SlideViewController ()

@end

@implementation SlideViewController

@synthesize imgvFisrt,imgvFour,imgvSecond,imgvThird;

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
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int ver = [version intValue];
    if (ver >= 7){
        // [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.5f]];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    } else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }
    
    // Do any additional setup after loading the view from its nib.
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Autoresizing of view controller
#pragma mark - RotatingViewController
- (void) adjustLayoutForPortrait:(BOOL)portrait insideFrame: (CGRect) parentFrame {
    // autoresizing doesn't work for this subview, so we adjust its position manually.
    //  the superclass takes care of making this animated

    /* if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
         
         if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
             
             // For Iphone view
             
             if (portrait) {
                 // For iphone portrait view
                 if([UIScreen mainScreen].bounds.size.height==480)
                 {
                     
                     [imgvFisrt setImage:[UIImage imageNamed:@"tut03.png"]];
                     [imgvSecond setImage:[UIImage imageNamed:@"tut02.png"]];
                     [imgvThird setImage:[UIImage imageNamed:@"tut04.png"]];
                     
                 }
                 else
                 {
                     [imgvFisrt setImage:[UIImage imageNamed:@"tut03.png"]];
                     [imgvSecond setImage:[UIImage imageNamed:@"tut02.png"]];
                     [imgvThird setImage:[UIImage imageNamed:@"tut04.png"]];
                   
                     
                 }
                 
             }
             
         }
         
     }else{
         
         [imgvFisrt setImage:[UIImage imageNamed:@"tutiPad3.png"]];
         [imgvSecond setImage:[UIImage imageNamed:@"tutiPad2.png"]];
         [imgvThird setImage:[UIImage imageNamed:@"tutiPad4.png"]];
        
     
     }*/
    
   
}


-(IBAction)btnWebsiteURL:(id)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.abridgeme.com/"]];
}


@end
