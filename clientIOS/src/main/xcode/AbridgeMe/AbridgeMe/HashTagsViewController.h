//
//  HashTagsViewController.h
//  AbridgeMe
//
//  Created by Mackintosh on 21/07/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface HashTagsViewController : UIViewController<MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;
}
@property(nonatomic,strong)NSString *searchTagString;
@property (strong, nonatomic) IBOutlet UITableView *hashTableView;




@end
