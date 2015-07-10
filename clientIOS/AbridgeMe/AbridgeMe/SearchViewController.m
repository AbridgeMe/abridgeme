 //
//  SearchViewController.m
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import "SearchViewController.h"
#import "CustomArticleCell.h"
#import "DemoTableHeaderView.h"
#import "DemoTableFooterView.h"
#import "AppDelegate.h"
#import "BaseViewController.h"
#import "Global.h"
#import "SummaryDetailViewController.h"
#import "GHPushedViewController.h"
#import "Reachability.h"
#import "UIImageView+AFNetworking.h"


#define DEFAULT_HEIGHT_OFFSET 52.0f

@interface SearchViewController (){
    NSArray *arrayArticleImages;
    NSMutableArray *items;
    NSString *str_Flag;
    NSArray *userData;
    NSString *strFlagLoad;
     NSMutableArray *arr_SearchData;
    NSString *strFlagHashKeySearch;
    int i;
    int count;
    NSMutableArray *arrayitems;
    NSString *strFlagFirst;
    
    uint32_t rnd;
    int countvalue;
    UIRefreshControl *refreshControl;
    
}
@end

@implementation SearchViewController{
@private
    RevealBlock _revealBlock;
}


@synthesize tblviewArticle,allTopic;

@synthesize allDataArray,allHashArray;


@synthesize headerView1;
@synthesize footerView1;

@synthesize isDragging;
@synthesize isRefreshing;
@synthesize isLoadingMore;

@synthesize canLoadMore;

@synthesize pullToRefreshEnabled;

@synthesize clearsSelectionOnViewWillAppear;
@synthesize strNavigationFlag,searchBar;

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            if (self = [super initWithNibName:@"SearchViewController_iPhone4" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }

        }
        else {
            //iPhone 5
            if (self = [super initWithNibName:@"SearchViewController" bundle:nil]) {
                self.title = title;
                _revealBlock = [revealBlock copy];
                
            }
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        if (self = [super initWithNibName:@"SearchViewController_iPad" bundle:nil]) {
            self.title = title;
            _revealBlock = [revealBlock copy];
            
        }
    }

    
        UIButton * btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnBack setImage:[UIImage imageNamed:@"details.png"] forState:UIControlStateNormal];
        [btnBack setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [btnBack addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        btnBack.frame = CGRectMake(0, 0, 30, 25);
        UIBarButtonItem *BackBtn = [[UIBarButtonItem alloc]initWithCustomView:btnBack];
        self.navigationItem.leftBarButtonItem = BackBtn;
        

        
    
	return self;
}

- (void)revealSidebar {
	_revealBlock();
}




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

    countvalue = 10;
    strFlagFirst = @"true";
    strFlagLoad = @"true";
    self.searchBar.showsCancelButton = NO;

    isRefreshing = NO;
    
    //refreshControl = [[UIRefreshControl alloc] init];
    
    //NSAttributedString *title = [[NSAttributedString alloc] initWithString:@""
                                                                //attributes: @{NSForegroundColorAttributeName:[UIColor blackColor]}];
    //refreshControl.attributedTitle = [[NSAttributedString alloc]initWithAttributedString:title];
    
    //[refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    //[self.tblviewArticle addSubview:refreshControl];
    
    
    
    NSString *version = [[UIDevice currentDevice] systemVersion];
    int ver = [version intValue];
    if (ver >= 7){
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        self.navigationController.navigationBar.translucent = NO;
    } else{
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:117.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }

    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.title = @"AbridgeMe";
    
    pullToRefreshEnabled = YES;
    
    canLoadMore = YES;
    
    clearsSelectionOnViewWillAppear = YES;
    autoCompleteString=[[NSMutableString alloc]init];
    autoCompleteArray=[[NSMutableArray alloc]init];
    
    // set the custom view for "pull to refresh". See DemoTableHeaderView.xib.
   // NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView" owner:self options:nil];
    //DemoTableHeaderView *headerView = (DemoTableHeaderView *)[nib objectAtIndex:0];
   // headerView1 = headerView;
    
    // set the custom view for "load more". See DemoTableFooterView.xib.
    //NSArray *nibfooter= [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView" owner:self options:nil];
    //DemoTableFooterView *footerView = (DemoTableFooterView *)[nibfooter objectAtIndex:0];
   // footerView1 = footerView;
    
    
    
    NSArray *nib;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            nib= [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView" owner:self options:nil];
        }
        else {
            //iPhone 5
            nib= [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView" owner:self options:nil];
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        nib= [[NSBundle mainBundle] loadNibNamed:@"DemoTableHeaderView_iPad" owner:self options:nil];
    }
    
    
    DemoTableHeaderView *headerView = (DemoTableHeaderView *)[nib objectAtIndex:0];
    headerView1 = headerView;
    
    // set the custom view for "load more". See DemoTableFooterView.xib.
    NSArray *nibheader;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            nibheader = [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView" owner:self options:nil];
            
        }
        else {
            //iPhone 5
            nibheader = [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView" owner:self options:nil];
            
            
        }
    }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //"iPad”
        nibheader = [[NSBundle mainBundle] loadNibNamed:@"DemoTableFooterView_iPad" owner:self options:nil];
        
    }
    
    DemoTableFooterView *footerView = (DemoTableFooterView *)[nibheader objectAtIndex:0];
    footerView1 = footerView;
    
    
    
    
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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


    allDataArray = [[NSMutableArray alloc]init];
    allTopic = [userData mutableCopy];
    
    if([userData count]>0){
        arrayitems = [[NSMutableArray alloc]init];
        
        if([allTopic count] > 10){
            
            for(int n=0; n<10; n++){
                rnd = arc4random_uniform((int)[userData count]);
                [allDataArray addObject:[allTopic objectAtIndex:rnd]];
            }
            [self.tblviewArticle reloadData];
            
        }else{
            allDataArray = [allTopic mutableCopy];
            
            [self.tblviewArticle reloadData];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tblviewArticle scrollToRowAtIndexPath:indexPath
                                       atScrollPosition:UITableViewScrollPositionTop
                                               animated:YES];
        }
    }
    }
    
    
    /*UIButton * btnRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRefresh setBackgroundImage:[UIImage imageNamed:@"refresh1.png"] forState:UIControlStateNormal];
    btnRefresh.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [btnRefresh setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btnRefresh addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    btnRefresh.frame = CGRectMake(0, 0, 24, 24);
    UIBarButtonItem *NavRefresh = [[UIBarButtonItem alloc]initWithCustomView:btnRefresh];
    self.navigationItem.rightBarButtonItem = NavRefresh;*/
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading..",nil);

    [HUD show:YES];
    
    if([strNavigationFlag isEqualToString:@"true"]){
        [self customnavBarbuttons];
    }
    
    
    if (clearsSelectionOnViewWillAppear) {
        NSIndexPath *selected = [self.tblviewArticle indexPathForSelectedRow];
        if (selected)
            [self.tblviewArticle deselectRowAtIndexPath:selected animated:YES];
   
    }
  
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self scrollViewDidScroll:nil];
    
    [HUD hide:YES];
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


- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self refreshAction];

}


-(void)refreshAction{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getSummaryData;
    
    getSummaryData = [documentsDirectory stringByAppendingPathComponent:@"summary.json"];
    
    NSData *data = [NSData dataWithContentsOfFile:getSummaryData];
    // [refreshControl endRefreshing];
    
   
    
   
    
    
    if(data == Nil){
        dispatch_async(dispatch_get_main_queue(), ^{
        userData = [[NSArray alloc]init];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
        [alert show];
        [self unpinHeaderView];
        });
        
    }else{
        userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
             isRefreshing = NO;
            
          [self unpinHeaderView];
            
         allDataArray = [[NSMutableArray alloc]init];
         allTopic = [userData mutableCopy];
        
        if([userData count]>0){
            arrayitems = [[NSMutableArray alloc]init];
            
            if([allTopic count] > 10){
                
                for(int n=0; n<10; n++){
                    rnd = arc4random_uniform((int)[userData count]);
                    [allDataArray addObject:[allTopic objectAtIndex:rnd]];
                }
                [self.tblviewArticle reloadData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tblviewArticle scrollToRowAtIndexPath:indexPath
                                           atScrollPosition:UITableViewScrollPositionTop
                                                   animated:YES];
                
            }else{
                allDataArray = [allTopic mutableCopy];
                
                [self.tblviewArticle reloadData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tblviewArticle scrollToRowAtIndexPath:indexPath
                                           atScrollPosition:UITableViewScrollPositionTop
                                                   animated:YES];
            }
        }
        });
    }
}

#pragma mark Private Methods
- (void)pushViewController {
	NSString *vcTitle = [self.title stringByAppendingString:@" - Pushed"];
	UIViewController *vc = [[GHPushedViewController alloc] initWithTitle:vcTitle];
	[self.navigationController pushViewController:vc animated:YES];
}



// Custom Back button method
-(void)EditFriendProfileClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) addItemsOnBottom
{

    
    int oldvalue = countvalue;
    if (oldvalue < [allTopic count]){
        countvalue = countvalue +10;
        
        if(countvalue>[allTopic count])
            countvalue = (int)[allTopic count];

        for (int index=oldvalue; index<countvalue; index++) {
            [allDataArray addObject:[allTopic objectAtIndex:index]];
        }
        [self.tblviewArticle reloadData];
        self.canLoadMore = YES;
    }else{
        self.canLoadMore = NO;
    }
    
    
    [self loadMoreCompleted];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Search Delegates


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBarr
{
    self.searchDisplayController.searchBar.hidden = YES;
    [searchBarr resignFirstResponder];
    searchBarr.text = @"";
    [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:self.searchBar afterDelay:0];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if ([searchText length] == 0) {
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:self.searchBar afterDelay:0];
    }
    else
    {
        
       str_Flag=@"SEARCH";
        
        if([userData count]>0){
             NSString *searchtext= [NSString stringWithFormat:@"%@",searchText];
        
        
        if([searchtext length]>0)
        {
            strFlagHashKeySearch = @"false";
            
            dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
            dispatch_async(myQueue, ^{
                // Perform long running process
                
                
                arr_SearchData = [[NSMutableArray alloc] init];
                for(int j=0;j<[userData count];j++)
                {
                    NSDictionary *temp= [userData objectAtIndex:j];

                    NSArray *temp1= [temp valueForKey:@"summary"];
                    
                    if([temp1 count]>0)
                    {
                        temp1=[temp1 objectAtIndex:0];
                        
                        
                        NSString *stringArray= [temp1 valueForKey:@"topic_title"];
                        
                        NSRange r = [stringArray rangeOfString:searchtext options:NSCaseInsensitiveSearch];
                        
                        if(r.location != NSNotFound)
                        {
                            [arr_SearchData addObject:[userData objectAtIndex:j]];
                        }
                        
                    }
                    
                    
                    NSArray *tempTag= [temp valueForKey:@"tags"];
                    
                    NSString *strSearchText;
                    strSearchText = searchText;
                    
                    strSearchText = [strSearchText stringByReplacingOccurrencesOfString:@"#" withString:@""];
                    
                    if([tempTag count]>0)
                    {
                        for(int num=0;num<[tempTag count];num++){
            
                         NSDictionary *temp=[tempTag objectAtIndex:num];
                        
                        NSString *stringArray= [temp valueForKey:@"name"];
                        stringArray = [stringArray lowercaseString];
                        strSearchText = [strSearchText lowercaseString];
                            
                            if ([stringArray isEqualToString:[strSearchText lowercaseString]]) {
                                
                                [arr_SearchData addObject:[userData objectAtIndex:j]];
                            }
                      }
                    }
                    
                }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if([arr_SearchData count]>0){
                            
                            NSMutableArray *uniqueArray = [NSMutableArray array];
                            
                            [uniqueArray addObjectsFromArray:[[NSSet setWithArray:arr_SearchData] allObjects]];
                            
                            arr_SearchData = [uniqueArray mutableCopy];
                            
                            [self.tblviewArticle reloadData];
                            NSIndexPath *indexPathrow= [NSIndexPath indexPathForItem:0 inSection:0];
                            [self.tblviewArticle scrollToRowAtIndexPath:indexPathrow atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        }else{
                            
                            [self.tblviewArticle reloadData];
                            
                        }
                    
                    });
                });
            }
        }
    }
}



-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{

}


- (void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    str_Flag=nil;
    [tblviewArticle reloadData];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    str_Flag=@"SEARCH";
    [self.searchBar resignFirstResponder];
   
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)stext
{
        if([stext length]>0)
        {
            return YES;
        }
    
    return YES;
}





#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if([str_Flag isEqualToString:@"SEARCH"])
        return [arr_SearchData count];
    else
        return [allDataArray count];
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    NSArray *allData;
    if([str_Flag isEqualToString:@"SEARCH"]){
      allData= [arr_SearchData objectAtIndex:indexPath.row];
    }else{
        allData=[allDataArray objectAtIndex:indexPath.row];
    }

   
    NSArray *temp=[allData valueForKey:@"summary"];


    static NSString *CellIdentifier = @"CustomArticleCell";
    CustomArticleCell *cell = (CustomArticleCell *)[tblviewArticle dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
     
        NSArray *nib ;
        
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
            if(iOSDeviceScreenSize.height == 480){
                //iPhone 4
                nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                 }
            else {
                //iPhone 5
                nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                }
        }else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            nib = [[NSBundle mainBundle] loadNibNamed:@"CustomArticleCell_iPad" owner:self options:nil];
            cell = [nib objectAtIndex:0];

        }
    }
    

        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        cell.titleLabel.text=[allData valueForKey:@"topic_title"];
        temp = [[temp reverseObjectEnumerator] allObjects];
      
        NSString *strDescription;
        
        if([str_Flag isEqualToString:@"SEARCH"])
        {
            
            NSArray *allData=[arr_SearchData objectAtIndex:indexPath.row];
            NSString *strDescription;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.titleLabel.text=[allData valueForKey:@"topic_title"];
            strDescription= [allData valueForKey:@"summary_desc"];
            if ([strDescription length]>1) {
                
            }else
                strDescription = [NSString stringWithFormat:@"%@",[[allData valueForKey:@"summary"]valueForKey:@"summary_desc"]];
            
            if([strDescription hasPrefix:@"("])
            {
                NSArray *tmp123=[[allData valueForKey:@"summary"]valueForKey:@"summary_desc"];
                
                strDescription=[NSString stringWithFormat:@"%@",[tmp123 objectAtIndex:0]];
            }
            
            NSMutableAttributedString *attributedStringTopic = [[NSMutableAttributedString alloc] initWithString:strDescription];
            NSMutableParagraphStyle *paragraphStyleTopic = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyleTopic setLineSpacing:5];
            [attributedStringTopic addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTopic range:NSMakeRange(0, [strDescription length])];
        
            cell.subtitleLabel.attributedText= attributedStringTopic;
            
            NSString *strImage=[NSString stringWithFormat:@"%@",[allData valueForKey:@"topic_image"]];
            if(strImage.length)
            {
                NSString *img=[NSString stringWithFormat:@"%@%@",str_global_summary_image,strImage];
                NSURL *url = [NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_ipad.png"]];
                }else{
                    [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_iphone.png"]];
                }
            }
            
        }else{
            strDescription = [NSString stringWithFormat:@"%@",[[allData valueForKey:@"summary"]valueForKey:@"summary_desc"]];
            
            if([strDescription hasPrefix:@"("])
            {
                NSArray *tmp123=[[allData valueForKey:@"summary"]valueForKey:@"summary_desc"];
                
                strDescription=[NSString stringWithFormat:@"%@",[tmp123 objectAtIndex:0]];
            }
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
            strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
             strDescription = [strDescription stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
            
            NSMutableAttributedString *attributedStringTopic = [[NSMutableAttributedString alloc] initWithString:strDescription];
            NSMutableParagraphStyle *paragraphStyleTopic = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyleTopic setLineSpacing:5];
            [attributedStringTopic addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTopic range:NSMakeRange(0, [strDescription length])];
            
            //NSString *strDesc = [NSString stringWithFormat:@"%@",strDescription];
            
            
            
            cell.subtitleLabel.attributedText= attributedStringTopic;
            
            
            NSString *strImage=[NSString stringWithFormat:@"%@",[allData valueForKey:@"topic_image"]];
            if(strImage.length)
            {
                NSString *img=[NSString stringWithFormat:@"%@%@",str_global_summary_image,strImage];
                NSURL *url = [NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_ipad.png"]];
                }else{
                    [cell.imgviewArticle setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_iphone.png"]];
                }
            }
        }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    return [documentsPath stringByAppendingPathComponent:name];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *allData;
    
    SummaryDetailViewController* obj;
    
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

    if([str_Flag isEqualToString:@"SEARCH"]){
        allData= [arr_SearchData objectAtIndex:indexPath.row];
        obj.allDataArray=allData;
        obj.currIndex=(int)indexPath.row;
        obj.arrAllData = arr_SearchData;
    }else{
        allData=[allDataArray objectAtIndex:indexPath.row];
        obj.allDataArray=allData;
        obj.arrAllData = allDataArray;
        obj.currIndex=(int)indexPath.row;
    }
    

    
    [self.navigationController pushViewController:obj animated:YES];
    
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   
    
    if (!isRefreshing && isDragging && scrollView.contentOffset.y < 0) {
        [self headerViewDidScroll:scrollView.contentOffset.y < 0 - [self headerRefreshHeight]
                       scrollView:scrollView];
    } else if (!isLoadingMore && canLoadMore) {
        CGFloat scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
        if (scrollPosition < [self footerLoadMoreHeight]) {
           [self loadMore];
        }
    }
    
    // Get visible cells on table view.
    NSArray *visibleCells = [self.tblviewArticle visibleCells];
    
    for (CustomArticleCell *cell in visibleCells) {
        [cell cellOnTableView:self.tblviewArticle didScrollOnView:self.view];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //if (isRefreshing)
        //return;
    
    isDragging = NO;
    if (scrollView.contentOffset.y <= 0 - [self headerRefreshHeight]) {

        [self refresh];
    }
}

- (void) setHeaderView:(UIView *)aView
{
   /* if (!tblviewArticle)
        return;
    
    if (headerView1 && [headerView1 isDescendantOfView:tblviewArticle])
        [headerView1 removeFromSuperview];
         headerView1 = nil;
    
    if (aView) {
        CGRect f = headerView1.frame;
        headerView1.frame = CGRectMake(f.origin.x, 0 - f.size.height, f.size.width, f.size.height);
        headerViewFrame = headerView1.frame;
        
        [tblviewArticle addSubview:headerView1];
    }*/
    
    if (!tblviewArticle)
        return;
    
    tblviewArticle.tableHeaderView = nil;
    headerView1 = nil;
    
    
    if (aView) {
        
        headerView1 = aView;
        DemoTableFooterView *fv = (DemoTableFooterView *)headerView1;
        [fv.activityIndicator startAnimating];
        tblviewArticle.tableHeaderView = headerView1;
        
        
    }
    
    
}

/*
- (CGFloat) headerRefreshHeight
{
    if (!CGRectIsEmpty(headerViewFrame))
        return 0;
    else
        return 0;
}*/

- (CGFloat) headerRefreshHeight
{
    if (!CGRectIsEmpty(headerViewFrame))
        return headerViewFrame.size.height;
    else
        return DEFAULT_HEIGHT_OFFSET;
}



- (void) pinHeaderView
{
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.tblviewArticle.contentInset = UIEdgeInsetsMake([self headerRefreshHeight], 0, 0, 0);
    }];
}

- (void) unpinHeaderView
{
    /*[UIView animateWithDuration:0.3 animations:^(void) {
        self.tblviewArticle.contentInset = UIEdgeInsetsZero;
    }];*/
    
    isRefreshing = NO;
    
    self.tblviewArticle.tableHeaderView = nil;
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.tblviewArticle.contentInset = UIEdgeInsetsZero;
        NSIndexPath *indexPathrow= [NSIndexPath indexPathForItem:0 inSection:0];
        
        [self.tblviewArticle scrollToRowAtIndexPath:indexPathrow atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        
    }];

}

- (void) willBeginRefresh
{
    // if (pullToRefreshEnabled)
    //[self pinHeaderView];
}






////////////////////////////////////////////////////////////////////////////////////////////////////

/*
- (BOOL) refresh
{
    if (isRefreshing)
        return NO;
    
    [self willBeginRefresh];
    isRefreshing = YES;
    return YES;
}*/


- (BOOL) refresh
{
    //if (isRefreshing)
        //return NO;

    //[self willBeginRefresh];
    [self setHeaderView:headerView1];

    [self refreshAction];

    isRefreshing = YES;
    return YES;

    if (![self loadMore1])
        return NO;
}





////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) refreshCompleted
{
    isRefreshing = NO;
    
    if (pullToRefreshEnabled)
        [self unpinHeaderView];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Load More

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setFooterView:(UIView *)aView
{
    if (!tblviewArticle)
        return;
    
    tblviewArticle.tableFooterView = nil;
    footerView1 = nil;
    
    if (aView) {
        
        footerView1 = aView;
        
        tblviewArticle.tableFooterView = footerView1;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) willBeginLoadingMore
{
    DemoTableFooterView *fv = (DemoTableFooterView *)self.footerView1;
    [fv.activityIndicator startAnimating];
}

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadMoreCompleted
{
    [self loadMoreCompleted1];
    
    DemoTableFooterView *fv = (DemoTableFooterView *)self.footerView1;
    [fv.activityIndicator stopAnimating];
    self.tblviewArticle.tableFooterView = nil;
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by:
        [self setFooterViewVisibility:NO];
        
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) loadMoreCompleted1
{
    isLoadingMore = NO;
}


////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) loadMore
{
    if (![self loadMore1])
        return NO;
    
    [self setFooterView:footerView1];
    
    // Do your async loading here
    [self performSelector:@selector(addItemsOnBottom) withObject:nil afterDelay:1];
    // See -addItemsOnBottom for more info on what to do after loading more items
    
    
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL) loadMore1
{
    if (isLoadingMore)
        return NO;
    
    [self willBeginLoadingMore];
    isLoadingMore = YES;
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat) footerLoadMoreHeight
{
    if (footerView1)
        return footerView1.frame.size.height;
    else
        return DEFAULT_HEIGHT_OFFSET;
}
////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) setFooterViewVisibility:(BOOL)visible
{
    if (visible && self.tblviewArticle.tableFooterView != footerView1)
        self.tblviewArticle.tableFooterView = footerView1;
    else if (!visible)
        self.tblviewArticle.tableFooterView = nil;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) allLoadingCompleted
{
    if (isRefreshing){
       
        
        [self refreshCompleted];
       
    }
    if (isLoadingMore){
        
        [self loadMoreCompleted];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate

////////////////////////////////////////////////////////////////////////////////////////////////////
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //if (isRefreshing)
        //return;
    isDragging = YES;
    isRefreshing = YES;
   // [self refreshAction];
    
    
}


- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    DemoTableHeaderView *DemoView;
    
    DemoView = (DemoTableHeaderView *)self.headerView1;
    
}

-(void)willShowHeaderView:(UIScrollView *)scrollView{
    
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBarr {
    searchBarr.showsCancelButton = YES;
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBarr {
    searchBarr.showsCancelButton = NO;
    return YES;
}




@end
