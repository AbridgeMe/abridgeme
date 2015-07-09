//
//  SummaryDetailViewController.h
//  AbridgeMe
//
//  Created by Lion on 12/11/14.
//  Copyright (c) 2014 AbridgeMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SummaryDetailViewController : UIViewController<MBProgressHUDDelegate,UIPopoverControllerDelegate,UIGestureRecognizerDelegate>{
    UIView *tagView;
    MBProgressHUD *HUD;
    
    
}
@property (nonatomic, retain) UIPopoverController *myPopover;
@property (strong,nonatomic) NSArray *allDataArray;
@property (strong,nonatomic)IBOutlet UIScrollView *custScrollView;
@property (nonatomic,strong) UIView *tagView;

@property (nonatomic,strong)NSArray *arrAllData;
@property(nonatomic, assign) int currIndex;
@property(nonatomic,strong)NSString *strRandomFlag;


@end
