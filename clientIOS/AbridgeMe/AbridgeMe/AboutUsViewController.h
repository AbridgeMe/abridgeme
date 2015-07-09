//
//  AboutUsViewController.h
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatingViewController.h"

typedef void (^RevealBlock)();

@class ISColumnsController;

@interface AboutUsViewController : UIViewController

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;

@property (strong, nonatomic) ISColumnsController *columnsController;

@end
