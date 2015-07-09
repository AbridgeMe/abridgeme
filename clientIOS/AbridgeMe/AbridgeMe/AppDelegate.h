//
//  AppDelegate.h
//  AbridgeME
//
//  Created by Lion on 14/04/14.
//  Copyright (c) 2014 AbridgeMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatingViewController.h"

#define str_global_domain @"http://www.abridgeme.com/"
#define str_global_share @"http://www.abridgeme.com/article-details/"
#define str_global_image_domain @"http://www.abridgeme.com/media/front/img/users/"
#define str_global_summary_image @"http://www.abridgeme.com/media/front/img/topic-images/"


@class ViewController;

@class ISColumnsController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSArray *arrSummaryData;
    NSString *strValue;
}
extern NSString *const FBSessionStateChangedNotification;
@property (strong, nonatomic) NSString *strFlagFetchRecord;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property(nonatomic,strong)UILabel *lblName ;
@property(nonatomic,strong) UIImageView* imgProfile;
@property(nonatomic,strong)  UIImageView *subview1;

@property (strong, nonatomic) ISColumnsController *columnsController;
@property (strong, nonatomic) NSMutableArray *SummaryDataDictArray;

-(void)getNewArticlesFromServer;
@end
