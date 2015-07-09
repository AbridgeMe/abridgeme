//
//  BaseViewController.h
//  VoucherCloud
//
//  Created by Mackintosh on 04/03/14.
//  Copyright (c) 2014 Panacea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
-(NSDictionary *)WebParsingMethod:(NSString *)strCompleteURL : (NSString *)jsonRequest;
@end
