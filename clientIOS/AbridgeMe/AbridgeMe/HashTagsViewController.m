//
//  HashTagsViewController.m
//  AbridgeMe
//
//  Created by Mackintosh on 21/07/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//
#import "HashTagsViewController.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "Global.h"
#import "CustomArticleCell.h"
#import "SummaryDetailViewController.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"
@interface HashTagsViewController ()
{
    NSArray* userData;
    NSMutableArray *arr_SearchData;
}
@end

@implementation HashTagsViewController

@synthesize hashTableView,searchTagString;

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
    self.title=searchTagString;
   
    [self customnavBarbuttons];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading..",nil);
    [HUD show:YES];
    
    [self getAllHashTags];
}
-(void)viewWillAppear:(BOOL)animated
{
   
}

-(void)viewDidAppear:(BOOL)animated{
    
  
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark TableView DataSource Methods.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int height;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            height = 95;
        }
        else {
            //iPhone 5
            height = 95;
        }
    }else {
        //"iPad”
        height = 143;
    }
    
    return height;
    
}

- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arr_SearchData count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView
cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // NSArray *allData=[userData objectAtIndex:indexPath.row];
    
    NSArray *allData=[arr_SearchData objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"CustomArticleCell";
    CustomArticleCell *cell = (CustomArticleCell *)[hashTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
            if(iOSDeviceScreenSize.height == 480){
                //iPhone 4
                nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell" owner:self options:nil];
            }
            else {
                //iPhone 5
                nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell" owner:self options:nil];
            }
        }else {
            //"iPad”
            nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell_iPad" owner:self options:nil];
        }
        
        
        cell = [nib objectAtIndex:0];
    }
    
    
    cell.titleLabel.text=[allData valueForKey:@"topic_title"];
    
    NSArray *summaryArray=[allData valueForKey:@"summary"];
    summaryArray =[summaryArray objectAtIndex:0];
    NSString *strSummary=[summaryArray valueForKey:@"summary_desc"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"  " withString:@""];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
     strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    
    NSString *strImage=[NSString stringWithFormat:@"%@",[allData valueForKey:@"topic_image"]];
    if([strImage isEqualToString:@""])
    {
        
        
    }
    else
    {
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable)
        {
            
            NSString *filePath = [self documentsPathForFileName:strImage];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            if(pngData == NULL)
            {
                
            }
            else
            {
                UIImage *image = [UIImage imageWithData:pngData];
                cell.imgviewArticle.image=image;
            }
        } else {
            
            NSString *img=[NSString stringWithFormat:@"%@%@",str_global_summary_image,strImage] ;
            
            NSString *filePath = [self documentsPathForFileName:strImage];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            if(pngData == NULL)
            {
                NSURL *url = [NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_ipad.png"]];
                }else{
                    [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_iphone.png"]];
                }
                
                
            }
            else
            {
                UIImage *image = [UIImage imageWithData:pngData];
                
                cell.imgviewArticle.image=image;
            }
        }
    }

    
    
    
    NSMutableAttributedString *attributedStringTopic = [[NSMutableAttributedString alloc] initWithString:strSummary];
    NSMutableParagraphStyle *paragraphStyleTopic = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleTopic setLineSpacing:5];
    [attributedStringTopic addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTopic range:NSMakeRange(0, [strSummary length])];
    
    cell.subtitleLabel.attributedText= attributedStringTopic;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
}


  
    
    
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSArray *allData;
    
    allData=[arr_SearchData objectAtIndex:indexPath.row];
    
    SummaryDetailViewController *obj;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController" bundle:nil];
        }
        else {
            //iPhone 5
            obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController" bundle:nil];
        }
    }else {
        //"iPad”
        obj = [[SummaryDetailViewController alloc]initWithNibName:@"SummaryDetailViewController_iPad" bundle:nil];
        
    }
    
    obj.allDataArray=allData;
    obj.currIndex=(int)indexPath.row;
    obj.arrAllData = arr_SearchData;
    [self.navigationController pushViewController:obj animated:YES];
    
}

#pragma mark GetAllHashTags
-(void)getAllHashTags
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getSummaryData;
    
    getSummaryData = [documentsDirectory stringByAppendingPathComponent:@"summary.json"];
    NSData *data = [NSData dataWithContentsOfFile:getSummaryData];
    if(data == Nil){
        userData = [[NSArray alloc]init];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
        [alert show];
    }else{
        userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        userData= [[userData reverseObjectEnumerator]allObjects];
    }

    
    //**********************************************************************************//
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        
       
        arr_SearchData = [[NSMutableArray alloc] init];
        
        for(int j=0;j<[userData count];j++)
        {
            NSDictionary *temp= [userData objectAtIndex:j];
            
            NSArray *tempTag= [temp valueForKey:@"tags"];
            
            NSString *strSearchText;
            
            strSearchText = searchTagString;
            
            strSearchText = [strSearchText stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if([tempTag count]>0)
            {
                for(int num=0;num<[tempTag count];num++)
                {
                    
                    NSDictionary *temp=[tempTag objectAtIndex:num];
                    
                    NSString *stringArray= [temp valueForKey:@"name"];
                    stringArray = [stringArray lowercaseString];
                    strSearchText = [strSearchText lowercaseString];
                
                    
                    if ([stringArray isEqualToString:strSearchText]) {
                            [arr_SearchData addObject:[userData objectAtIndex:j]];
                    }
                    
                    
                 }
              }
            
            NSMutableArray *uniqueArray = [NSMutableArray array];
            
            [uniqueArray addObjectsFromArray:[[NSSet setWithArray:arr_SearchData] allObjects]];
            
            arr_SearchData = [uniqueArray mutableCopy];
           
            
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray* reversed = [[arr_SearchData reverseObjectEnumerator] allObjects];
            arr_SearchData = [reversed mutableCopy];
            
            if([arr_SearchData count]>0){
                [self.hashTableView reloadData];
             }else{
                
            }
        });
    });
    
    [HUD hide:YES];
}


@end
