//
//  BaseViewController.m
//  VoucherCloud
//
//  Created by Mackintosh on 04/03/14.
//  Copyright (c) 2014 Panacea. All rights reserved.
//

#import "BaseViewController.h"
#import "Reachability.h"
#import "Global.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

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
}
-(NSDictionary *)WebParsingMethod:(NSString *)strCompleteURL :(NSString *)jsonRequest{
    NSDictionary *jsonDict;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        
        str_ServerUnderMaintainess = @"NO";

    } else {
       
        NSError *error = nil;
        NSURL *URL = [NSURL URLWithString:strCompleteURL];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long)[jsonRequest length]];
        [request setValue:length forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding]];
       
        // Response data from server
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
        if(!error) {
            jsonDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                       options:kNilOptions
                                                         error:&error];
         
        }
    }
    return jsonDict;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
