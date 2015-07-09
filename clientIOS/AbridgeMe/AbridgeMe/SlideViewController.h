//
//  SlideViewController.h
//  SlideViewDemo
//
//  Created by Panacea on 25/07/2013.
//  Copyright (c) 2013 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RotatingViewController.h"

@interface SlideViewController : RotatingViewController

@property(nonatomic,strong)IBOutlet UIImageView *imgvFisrt;
@property(nonatomic,strong)IBOutlet UIImageView *imgvSecond;
@property(nonatomic,strong)IBOutlet UIImageView *imgvThird;
@property(nonatomic,strong)IBOutlet UIImageView *imgvFour;
@property(nonatomic,strong)IBOutlet UIImageView *imgvFive;

@end
