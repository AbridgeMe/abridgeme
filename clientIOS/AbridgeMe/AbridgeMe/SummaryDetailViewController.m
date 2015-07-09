//
//  SummaryDetailViewController.m
//  AbridgeMe
//
//  Created by Lion on 12/11/14.
//  Copyright (c) 2014 AbridgeMe. All rights reserved.
//

#import "SummaryDetailViewController.h"
#import "NewsViewController.h"
#import "BaseViewController.h"
#import "HashTagsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "Reachability.h"

@interface SummaryDetailViewController (){
    NSString *strSummary;
    NSMutableAttributedString *attributedStringSummary, *attributedStringTopic;
    NSString *strSummayDescription, *stringTopicTitle;
    NSMutableArray *allButtonsMutableArray;
    float btnHeight,btnWidth,btnX,btnY,nTagBtnHeight,fontSize,maxWidth,btn_diff_Height;
    UIFont * font;
    CGSize stringSize;
    float tagViewY_height,tbleHeight;
    
    NSArray *newsArray;
    UIButton *btnRandom,*btnShare;
    uint32_t rnd;
    NSString *strTopicTitle;
    
    UIButton *btnfirstNews;
    UILabel *lblfirstPublish;
    UILabel *lblTopicDescription;
    UIButton *btnSecondNews;
    UILabel *lblsecondPublish;
    UILabel *lblTopicTitle;
    UILabel *lblthirdPublish;
    UIButton *btnthirdNews;
    UIButton *poweredByYahoo;
    UIButton *btnAuthorName;
    UILabel *mainTitle;
    UILabel *lblTop;
    UILabel *lblfirstNews;
    UILabel *lblbtnSecond;
    UILabel *lblbtnthird;
    UILabel *lblbottom;
    UIImageView *imgViewSummary;
    dispatch_queue_t myQueue;
}

@end

@implementation SummaryDetailViewController
@synthesize myPopover,currIndex,strRandomFlag;
@synthesize allDataArray,custScrollView,tagView,arrAllData;

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
    
    self.title = @"AbridgeMe";
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    
    
    UISwipeGestureRecognizer *recognizerRight;
    recognizerRight.delegate=self;
    
    recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:recognizerRight];
    
    
    UISwipeGestureRecognizer *recognizerLeft;
    recognizerLeft.delegate=self;
    recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeleft:)];
    [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:recognizerLeft];
    
    
    
    [self customnavBarbuttons];
 
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.delegate = self;
    HUD.labelText = NSLocalizedString(@"Loading..",nil);
    
   // [HUD show:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    myQueue = nil;
   // [HUD show:YES];
    for (UIView *layer in self.custScrollView.subviews)
    {
        [layer removeFromSuperview];
    }

    [tagView removeFromSuperview];
    
    [imgViewSummary removeFromSuperview];
    
    [btnAuthorName removeFromSuperview];
    
    [mainTitle removeFromSuperview];
    
    [lblTopicDescription removeFromSuperview];
    
    [lblTopicTitle removeFromSuperview];
    
    [btnfirstNews removeFromSuperview];
    
    [lblfirstPublish removeFromSuperview];
    
    [btnSecondNews removeFromSuperview];
    
    [lblsecondPublish  removeFromSuperview];
    
    [btnthirdNews removeFromSuperview];
    
    [lblthirdPublish removeFromSuperview];
    
    [poweredByYahoo removeFromSuperview];

    [lblTop removeFromSuperview];
    [lblbtnSecond removeFromSuperview];
    [lblfirstNews removeFromSuperview];
    [lblbtnthird removeFromSuperview];
    [lblbottom removeFromSuperview];
    
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        nTagBtnHeight=30.0f;
        fontSize=24;
        maxWidth=620.00001f;
        btn_diff_Height=35;
        tbleHeight=90;
        tagViewY_height=81;
        
    }
    else
    {
        nTagBtnHeight=27.0f;
        fontSize=17;
        maxWidth=200.00001f;
        btn_diff_Height=35;
        tbleHeight=50;
        tagViewY_height=81;
    }
    
    
   
    // ImageView of summary
    NSString *strImage = [NSString stringWithFormat:@"%@",[allDataArray valueForKey:@"topic_image"]];
   
    if([strImage isEqualToString:@""]){
        
        imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        imgViewSummary.contentMode = UIViewContentModeScaleAspectFit;
        [imgViewSummary setBackgroundColor:[UIColor whiteColor]];
        [custScrollView addSubview:imgViewSummary];
        
    }else{
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            
            NSString *filePath = [self documentsPathForFileName:strImage];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400)];
            }else{
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 205)];
            }
            
            if(pngData == NULL)
            {
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    imgViewSummary.image = [UIImage imageNamed:@"place_big_ipad.png"];
                }else{
                    imgViewSummary.image = [UIImage imageNamed:@"place_big_iphone.png"];
                }
                
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
                imgViewSummary.contentMode = UIViewContentModeScaleAspectFit;
                [imgViewSummary setBackgroundColor:[UIColor whiteColor]];
                [custScrollView addSubview:imgViewSummary];
                
            }
            else
            {
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    imgViewSummary.image = [UIImage imageNamed:@"place_big_ipad.png"];
                }else{
                    imgViewSummary.image = [UIImage imageNamed:@"place_big_iphone.png"];
                }

                
                UIImage *image = [UIImage imageWithData:pngData];
                imgViewSummary.image = image;
               // [imgViewSummary setBackgroundColor:[UIColor whiteColor]];
                imgViewSummary.contentMode = UIViewContentModeScaleAspectFit;
                [custScrollView addSubview:imgViewSummary];
            }

           
        
        } else {
            NSString *img=[NSString stringWithFormat:@"%@%@",str_global_summary_image,strImage] ;
            
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400)];
            }else{
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 205)];
            }
            
            NSString *filePath = [self documentsPathForFileName:strImage];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            if(pngData == NULL)
            {
                 NSURL *url = [NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
               
                

                
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    [imgViewSummary setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_ipad.png"]];
                }else{
                    [imgViewSummary setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_iphone.png"]];
                }
            }
            else
            {
                UIImage *image = [UIImage imageWithData:pngData];
                imgViewSummary.image = image;

            }
            
            [imgViewSummary setBackgroundColor:[UIColor whiteColor]];
            imgViewSummary.contentMode = UIViewContentModeScaleAspectFit;
            [custScrollView addSubview:imgViewSummary];
            
        }
        
    }
    
    
    // Topic
    strTopicTitle = [allDataArray valueForKey:@"topic_title"];
    attributedStringTopic = [[NSMutableAttributedString alloc] initWithString:strTopicTitle];
    NSMutableParagraphStyle *paragraphStyleTopic = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleTopic setLineSpacing:5];
    [attributedStringTopic addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTopic range:NSMakeRange(0, [strTopicTitle length])];
    
    stringTopicTitle = [NSString stringWithFormat:@"%@",attributedStringTopic];
    
    
    lblTopicTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, imgViewSummary.frame.size.height+20, [UIScreen mainScreen].bounds.size.width-12, 60)];
    lblTopicTitle.attributedText = attributedStringTopic;
    lblTopicTitle.textAlignment = NSTextAlignmentLeft;
    lblTopicTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [lblTopicTitle setTextColor:[UIColor blackColor]];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [lblTopicTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:25]];
    }else{
        [lblTopicTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:19]];
    }
    
    
    
    
    CGSize expectedTitleSize = [stringTopicTitle sizeWithFont:lblTopicTitle.font
                                            constrainedToSize:lblTopicTitle.frame.size
                                                lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect newFrameTitle = lblTopicTitle.frame;
    newFrameTitle.size.height = expectedTitleSize.height;
    lblTopicTitle.frame = newFrameTitle;
    lblTopicTitle.numberOfLines = 0;
    [lblTopicTitle sizeToFit];
    [custScrollView addSubview:lblTopicTitle];
    

    
    
    // Summary
    NSArray *summaryArray;
   
    summaryArray=[allDataArray valueForKey:@"summary"];
    summaryArray =[summaryArray objectAtIndex:0];
    strSummary=[summaryArray valueForKey:@"summary_desc"];

   
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"  " withString:@""];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];

    attributedStringSummary = [[NSMutableAttributedString alloc]initWithString:strSummary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:5];
    [attributedStringSummary addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [strSummary length])];
    
    strSummayDescription = [NSString stringWithFormat:@"%@",attributedStringSummary];
    lblTopicDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, imgViewSummary.frame.size.height+lblTopicTitle.frame.size.height+40, [UIScreen mainScreen].bounds.size.width-15, 180)];
    lblTopicDescription.attributedText = attributedStringSummary;
    lblTopicDescription.textAlignment = NSTextAlignmentLeft;
    lblTopicDescription.lineBreakMode = NSLineBreakByWordWrapping;
    [lblTopicDescription setTextColor:[UIColor blackColor]];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [lblTopicDescription setFont:[UIFont fontWithName:@"Helvetica" size:22]];
    }else{
        [lblTopicDescription setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    }

    CGSize expectedLabelSize = [strSummayDescription sizeWithFont:lblTopicDescription.font
                                                constrainedToSize:lblTopicDescription.frame.size
                                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect newFrame = lblTopicDescription.frame;
    newFrame.size.height = expectedLabelSize.height;
    lblTopicDescription.frame = newFrame;
    lblTopicDescription.numberOfLines = 0;
    [lblTopicDescription sizeToFit];
    [custScrollView addSubview:lblTopicDescription];
    
    
    NSArray *maintagArray=[allDataArray valueForKey:@"tags"];
    if([maintagArray valueForKey:@"hashtags"])
    {
        
        NSString *hashString;
        allButtonsMutableArray=[[NSMutableArray alloc]init];
        
        for (int i=0; i<[maintagArray count]; i++) {
            NSDictionary *dict=[maintagArray objectAtIndex:i];
            
            UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                tagButton.titleLabel.font = [UIFont systemFontOfSize:22.0];
            }else{
                tagButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
            }
            
            
            [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  
            [tagButton setBackgroundColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0]];
            
            tagButton.tag=i;
            [tagButton addTarget:self
                          action:@selector(hashTagAction:)
                forControlEvents:UIControlEventTouchUpInside];
            tagButton.layer.cornerRadius=5.0f;
            
            
            if(i==0)
            {
                btnX=4.2;
                btnY=0.10f;
                hashString=[NSString stringWithFormat:@"%@%@%@",@" ",[dict valueForKey:@"name"],@" "];
                //Calculate width
                font =[UIFont systemFontOfSize:fontSize];
                stringSize = [hashString sizeWithFont:font];
                btnWidth= stringSize.width;
                
                
                [tagButton setTitle:hashString forState:UIControlStateNormal];
                tagButton.frame = CGRectMake(btnX, btnY, btnWidth, nTagBtnHeight);
                
                btnX=btnWidth+07;
                
                
            }else
            {
                
                if(btnX>=maxWidth)
                {
                    hashString=[NSString stringWithFormat:@"%@%@%@",@" ",[dict valueForKey:@"name"],@" "];
                    //Calculate width
                    font =[UIFont systemFontOfSize:fontSize];
                    stringSize = [hashString sizeWithFont:font];
                    btnWidth= stringSize.width;
                    [tagButton setTitle:hashString forState:UIControlStateNormal];
                    btnY=btnY+btn_diff_Height;
                    btnX=4.2;
                    tagButton.frame = CGRectMake(btnX, btnY, btnWidth, nTagBtnHeight);
                    btnX=btnWidth+07;
                }else
                {
                    hashString=[NSString stringWithFormat:@"%@%@%@",@" ",[dict valueForKey:@"name"],@" "];
                    //Calculate width
                    font =[UIFont systemFontOfSize:fontSize];
                    stringSize = [hashString sizeWithFont:font];
                    btnWidth= stringSize.width;
                    [tagButton setTitle:hashString forState:UIControlStateNormal];
                    tagButton.frame = CGRectMake(btnX, btnY, btnWidth, nTagBtnHeight);
                    btnX+=btnWidth+07;
                }
            }

            [allButtonsMutableArray addObject:tagButton];

        }
        
        
        tagView =[[UIView alloc]initWithFrame:CGRectMake(7, imgViewSummary.frame.size.height+lblTopicTitle.frame.size.height+ lblTopicDescription.frame.size.height+60,[UIScreen mainScreen].bounds.size.width-15,btnY+nTagBtnHeight)];
        
        for(int j=0;j<[allButtonsMutableArray count];j++)
        {
            UIButton *btn=(UIButton *)[allButtonsMutableArray objectAtIndex:j];
            [tagView addSubview:btn];
        }
        tagView.backgroundColor=[UIColor whiteColor];
        [custScrollView addSubview:tagView];

    }
    
    
    // Author Name
    btnAuthorName = [[UIButton alloc]initWithFrame:CGRectMake(10, imgViewSummary.frame.size.height+lblTopicTitle.frame.size.height+ lblTopicDescription.frame.size.height+60+tagView.frame.size.height, 310, 60)];
    btnAuthorName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    
    NSArray *summArray=[allDataArray valueForKey:@"summary"];
    summArray =[summArray objectAtIndex:0];
    NSString *strFirstName=[summArray valueForKey:@"first_name"];
    NSString *strLastName=[summArray valueForKey:@"last_name"];
    
    [btnAuthorName addTarget:self action:@selector(btnAuthorNameClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [btnAuthorName setTitle:[NSString stringWithFormat:@"%@%@%@%@",@"Author: ",strFirstName,@" ",strLastName] forState:UIControlStateNormal];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        btnAuthorName.titleLabel.font = [UIFont systemFontOfSize:22];
    }else{
        btnAuthorName.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    
    
    [btnAuthorName setTitleColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];


    [custScrollView addSubview:btnAuthorName];
    
    float heightoftitle = 50;
    
    // NEWS
    heightoftitle = imgViewSummary.frame.size.height+lblTopicTitle.frame.size.height+ lblTopicDescription.frame.size.height+60+tagView.frame.size.height+50;
    newsArray = [[NSArray alloc]init];
    if([allDataArray count]>0)
    {
        myQueue = dispatch_queue_create("My Queue888",NULL);
        dispatch_async(myQueue, ^{
        NSString * jsonRequest = [NSString stringWithFormat:@"topic_id=%@",[allDataArray valueForKey:@"topic_id"]];
        NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@%@",str_global_domain,@"ws-in-the-news?",jsonRequest] ;
        BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
        NSDictionary *dict12=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
       dispatch_async(dispatch_get_main_queue(), ^{
            if([[[dict12 valueForKeyPath:@"result"]valueForKeyPath:@"msg"]isEqualToString:@"success"])
        {
            
            newsArray=[[dict12 valueForKeyPath:@"result"]valueForKeyPath:@"result"];
            if([newsArray count]>0){
               [lblTop removeFromSuperview];
                [mainTitle removeFromSuperview];
                lblTop=[[UILabel alloc]initWithFrame:CGRectMake(0, heightoftitle, [UIScreen mainScreen].bounds.size.width, 1)];
                lblTop.backgroundColor=[UIColor lightGrayColor] ;
                [custScrollView addSubview:lblTop];
                
                mainTitle=[[UILabel alloc]initWithFrame:CGRectMake(10,heightoftitle+10, [UIScreen mainScreen].bounds.size.width-10, 30)];
                mainTitle.text=@"In the News";
                mainTitle.textColor=[UIColor blackColor];
                
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    mainTitle.font=[UIFont fontWithName:@"Helvetica-Bold" size:25];
                }else{
                    mainTitle.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
                }
                
                
                [custScrollView addSubview:mainTitle];
                
                [lblfirstNews removeFromSuperview];
                [btnfirstNews removeFromSuperview];
                [lblfirstPublish removeFromSuperview];
                [lblbtnSecond removeFromSuperview];
                [lblbtnSecond removeFromSuperview];
                [btnSecondNews removeFromSuperview];
                [lblsecondPublish removeFromSuperview];
                [lblbtnthird removeFromSuperview];
                [btnthirdNews removeFromSuperview];
                [lblthirdPublish removeFromSuperview];
                [lblbottom removeFromSuperview];
                [poweredByYahoo removeFromSuperview];
                lblfirstNews=[[UILabel alloc]initWithFrame:CGRectMake(1,  heightoftitle+mainTitle.frame.size.height+20, [UIScreen mainScreen].bounds.size.width, 0.5)];
                lblfirstNews.backgroundColor=[UIColor grayColor] ;
                [custScrollView addSubview:lblfirstNews];
                
                
                btnfirstNews=[[UIButton alloc]initWithFrame:CGRectMake(10, heightoftitle+mainTitle.frame.size.height+30, [UIScreen mainScreen].bounds.size.width-15, 30)];
                
                lblfirstPublish=[[UILabel alloc]initWithFrame:CGRectMake(10, heightoftitle+btnfirstNews.frame.size.height+60, [UIScreen mainScreen].bounds.size.width-15, 30)];
                
                
                
                lblbtnSecond=[[UILabel alloc]initWithFrame:CGRectMake(1, heightoftitle+lblfirstPublish.frame.size.height+90, [UIScreen mainScreen].bounds.size.width, 0.5)];
                lblbtnSecond.backgroundColor=[UIColor grayColor] ;
                [custScrollView addSubview:lblbtnSecond];
                
                
                btnSecondNews=[[UIButton alloc]initWithFrame:CGRectMake(10, heightoftitle+lblfirstPublish.frame.size.height+100,[UIScreen mainScreen].bounds.size.width-15, 30)];
                
                lblsecondPublish=[[UILabel alloc]initWithFrame:CGRectMake(10, heightoftitle+btnSecondNews.frame.size.height+130, [UIScreen mainScreen].bounds.size.width-15, 30)];
                
                lblbtnthird=[[UILabel alloc]initWithFrame:CGRectMake(1, heightoftitle+lblsecondPublish.frame.size.height+160, [UIScreen mainScreen].bounds.size.width, 0.5)];
                lblbtnthird.backgroundColor=[UIColor grayColor] ;
                [custScrollView addSubview:lblbtnthird];
                
                btnthirdNews=[[UIButton alloc]initWithFrame:CGRectMake(10, heightoftitle+lblsecondPublish.frame.size.height+170, [UIScreen mainScreen].bounds.size.width-15, 30)];
                
                lblthirdPublish=[[UILabel alloc]initWithFrame:CGRectMake(10, heightoftitle+btnthirdNews.frame.size.height+200, [UIScreen mainScreen].bounds.size.width-15, 30)];
                
                lblbottom=[[UILabel alloc]initWithFrame:CGRectMake(1, heightoftitle+lblthirdPublish.frame.size.height+230, [UIScreen mainScreen].bounds.size.width, 0.5)];
                lblbottom.backgroundColor=[UIColor grayColor] ;
                [custScrollView addSubview:lblbottom];
                
                
                
                poweredByYahoo=[[UIButton alloc]initWithFrame:CGRectMake(120, heightoftitle+lblthirdPublish.frame.size.height+215, [UIScreen mainScreen].bounds.size.width-40, 60)];
                
                for(int i=0 ;i<[newsArray count];i++)
                {
                    NSArray *titleArray=[newsArray objectAtIndex:i];
                    
                    NSString* urlString = [NSString stringWithFormat:@"%@",[titleArray valueForKeyPath:@"title"]];
                    urlString = [urlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
                    urlString = [urlString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                    urlString = [urlString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                    urlString = [urlString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                    urlString = [urlString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                    urlString = [urlString stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
                    
                    if(i==0)
                    {
                        //Button
                        [btnfirstNews setTitle:urlString forState:UIControlStateNormal];
                        btnfirstNews.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                        [btnfirstNews.titleLabel setTextAlignment: NSTextAlignmentLeft];
                        [btnfirstNews.titleLabel setNumberOfLines:2];
                        
                        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                        {
                            btnfirstNews.titleLabel.font = [UIFont systemFontOfSize:20];
                        }else{
                            btnfirstNews.titleLabel.font = [UIFont systemFontOfSize:14];
                        }
                        
                        [btnfirstNews setTitleColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
                        
                        btnfirstNews.tag=i;
                        [btnfirstNews addTarget:self action:@selector(openWebview:) forControlEvents:UIControlEventTouchUpInside];
                        [custScrollView addSubview:btnfirstNews];
                        
                        //Label
                        NSArray *tempArray = [[titleArray valueForKeyPath:@"pubDate"] componentsSeparatedByString:@" "];
                        NSMutableString *strDate;
                        strDate = [[NSMutableString alloc]init];
                        for(int i=0;i<4;i++){
                            
                            [strDate appendString:[tempArray objectAtIndex:i]];
                            [strDate appendString:@" "];
                        }
                        
                        lblfirstPublish.text=strDate;
                        
                        
                        lblfirstPublish.textColor=[UIColor lightGrayColor];
                        
                        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                        {
                            lblfirstPublish.font=[UIFont systemFontOfSize:15];
                        }else{
                            lblfirstPublish.font=[UIFont systemFontOfSize:13];
                        }
                        
                        
                        [custScrollView addSubview:lblfirstPublish];
                        
                    }else if(i==1)
                    {
                        //button
                        [btnSecondNews setTitle:urlString forState:UIControlStateNormal];
                        btnSecondNews.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                        [btnSecondNews.titleLabel setTextAlignment: NSTextAlignmentLeft];
                        [btnSecondNews.titleLabel setNumberOfLines:2];
                        
                        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                        {
                            btnSecondNews.titleLabel.font = [UIFont systemFontOfSize:20];
                        }else{
                            btnSecondNews.titleLabel.font = [UIFont systemFontOfSize:14];
                        }
                        
                        
                        [btnSecondNews setTitleColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
                        
                        [btnSecondNews addTarget:self action:@selector(openWebview:) forControlEvents:UIControlEventTouchUpInside];
                        [custScrollView addSubview:btnSecondNews];
                        btnSecondNews.tag=i;
                        
                        NSArray *tempArray = [[titleArray valueForKeyPath:@"pubDate"] componentsSeparatedByString:@" "];
                        NSMutableString *strDate;
                        strDate = [[NSMutableString alloc]init];
                        for(int i=0;i<4;i++){
                            
                            [strDate appendString:[tempArray objectAtIndex:i]];
                            [strDate appendString:@" "];
                        }
                        
                        lblsecondPublish.text=strDate;
                        
                        
                        lblsecondPublish.textColor=[UIColor lightGrayColor];
                        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                        {
                            lblsecondPublish.font=[UIFont systemFontOfSize:15];
                        }else{
                            lblsecondPublish.font=[UIFont systemFontOfSize:13];
                        }
                        
                        
                        [custScrollView addSubview:lblsecondPublish];
                        
                    }
                    else if(i==2)
                    {
                        
                        //button
                        [btnthirdNews setTitle:urlString forState:UIControlStateNormal];
                        btnthirdNews.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                        [btnthirdNews.titleLabel setTextAlignment: NSTextAlignmentLeft];
                        [btnthirdNews.titleLabel setNumberOfLines:2];
                        
                        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                        {
                            btnthirdNews.titleLabel.font = [UIFont systemFontOfSize:20];
                        }else{
                            btnthirdNews.titleLabel.font = [UIFont systemFontOfSize:14];
                        }
                        
                        
                        [btnthirdNews setTitleColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
                        
                        [custScrollView addSubview:btnthirdNews];
                        [btnthirdNews addTarget:self action:@selector(openWebview:) forControlEvents:UIControlEventTouchUpInside];
                        btnthirdNews.tag=i;
                        
                        //Label
                        NSArray *tempArray = [[titleArray valueForKeyPath:@"pubDate"] componentsSeparatedByString:@" "];
                        NSMutableString *strDate;
                        strDate = [[NSMutableString alloc]init];
                        for(int i=0;i<4;i++){
                            
                            [strDate appendString:[tempArray objectAtIndex:i]];
                            [strDate appendString:@" "];
                        }
                        
                        lblthirdPublish.text=strDate;
                        lblthirdPublish.textColor=[UIColor lightGrayColor];
                        
                        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                        {
                            lblthirdPublish.font=[UIFont systemFontOfSize:15];
                        }else{
                            lblthirdPublish.font=[UIFont systemFontOfSize:13];
                        }
                        
                        
                        [custScrollView addSubview:lblthirdPublish];
                        
                        
                        //News provide
                        [poweredByYahoo setImage:[UIImage imageNamed:@"purple.png"] forState:UIControlStateNormal];
                        [poweredByYahoo addTarget:self action:@selector(openYahoo:) forControlEvents:UIControlEventTouchUpInside];
                        
                        [custScrollView addSubview:poweredByYahoo];
                        
                    }
                }
                
            }
       
        }
      }); });
       }


    
    //[HUD hide:YES];

    float scrollheight = heightoftitle+lblthirdPublish.frame.size.height+320;

    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        custScrollView.contentSize= CGSizeMake([UIScreen mainScreen].bounds.size.width,scrollheight);
    }else{
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
           
            custScrollView.contentSize= CGSizeMake([UIScreen mainScreen].bounds.size.width,scrollheight+95);
            
        }else{
            custScrollView.contentSize= CGSizeMake([UIScreen mainScreen].bounds.size.width,scrollheight);
        }
       
    }
    [self.custScrollView setContentOffset:CGPointZero animated:YES];
}



- (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
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
    
    btnRandom = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRandom setBackgroundImage:[UIImage imageNamed:@"shuffle_icon.png"] forState:UIControlStateNormal];
    btnRandom.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [btnRandom setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btnRandom addTarget:self action:@selector(RandomArticleCalled) forControlEvents:UIControlEventTouchUpInside];
    btnRandom.frame = CGRectMake(0, 0,30, 30);
    
    
    UIBarButtonItem *RandomBtn = [[UIBarButtonItem alloc]initWithCustomView:btnRandom];
    
    btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShare setBackgroundImage:[UIImage imageNamed:@"01_icon.png"] forState:UIControlStateNormal];
    btnShare.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    [btnShare setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btnShare addTarget:self action:@selector(twitterShareAction:) forControlEvents:UIControlEventTouchUpInside];
    btnShare.frame = CGRectMake(0, 0,30, 30);
    UIBarButtonItem *RandomBtn1 = [[UIBarButtonItem alloc]initWithCustomView:btnShare];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: RandomBtn1,RandomBtn, nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)btnAuthorNameClicked{
    
            NSArray *summArray=[allDataArray valueForKey:@"summary"];
            summArray =[summArray objectAtIndex:0];
            NSString *strFirstName=[summArray valueForKey:@"first_name"];
            NSString *strLastName=[summArray valueForKey:@"last_name"];
    
    
            NSString *articleAuthorName=[NSString stringWithFormat:@"%@%@%@%@%@",strFirstName,@"-",strLastName,@"-",[summArray valueForKey:@"user_id"]] ;
    
            NSString *newLink=[NSString stringWithFormat:@"%@%@",@"http://www.abridgeme.com/public-profile/",articleAuthorName];
            NewsViewController *obj=[[NewsViewController alloc]initWithNibName:@"NewsViewController" bundle:nil];

            obj.webLink=newLink;
            obj.flag=@"YES";
            [self.navigationController pushViewController:obj animated:YES];
    
}



-(void)openWebview:(id)sender
{
    
    UIButton *tappedButton = sender;
    NSInteger tag = tappedButton.tag;
    for (int i=0; i<[newsArray count]; i++)
    {
        NSArray *Array=[newsArray objectAtIndex:i];
        
        if(i==tag)
        {
            NSString *newLink=[NSString stringWithFormat:@"%@",[Array valueForKeyPath:@"link"]];
            
            NSArray *array = [newLink componentsSeparatedByString:@"url="];
            
            newLink=[array objectAtIndex:0];
            
            NewsViewController *obj=[[NewsViewController alloc]initWithNibName:@"NewsViewController" bundle:nil];
            
            obj.webLink=newLink;
            
            [self.navigationController pushViewController:obj animated:YES];
            break;
        }
        
    }
}

#pragma mark HashTag Tapped.

-(void)hashTagAction:(id)sender
{
    
    UIButton *tappedButton = sender;
    
    HashTagsViewController *vc;
    [tappedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            //iPhone 4
            vc=[[HashTagsViewController alloc]initWithNibName:@"HashTagsViewController_iPhone4" bundle:nil];
            
        }
        else {
            //iPhone 5
            vc=[[HashTagsViewController alloc]initWithNibName:@"HashTagsViewController" bundle:nil];
        }
    }else {
        //"iPad”
        vc=[[HashTagsViewController alloc]initWithNibName:@"HashTagViewController_iPad" bundle:nil];
    }
    
    vc.searchTagString = tappedButton.titleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}


-(void)openYahoo:sender
{
    NSString *urlString= @"http://www.yahoo.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}


// Back button method
-(void)BackBtnClicked{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)RandomArticleCalled
{
     strRandomFlag=@"YES";
    [self RandomArticlesMethod];
 // [HUD showWhileExecuting:@selector(RandomArticlesMethod) onTarget:self withObject:nil animated:YES];
}

#pragma mark Random Article

-(void)RandomArticlesMethod
{
    
    NSArray *userData;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getSummaryData;
    
    getSummaryData = [documentsDirectory stringByAppendingPathComponent:@"summary.json"];
    
    NSData *data = [NSData dataWithContentsOfFile:getSummaryData];
    
    if(data == Nil){
        userData = [[NSArray alloc]init];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Nil message:@"Opps! It looks like you're not connected to the internet. Check your connection and try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil , nil];
        [alert show];
    }else{
     //   userData = [[NSArray alloc]init];
        userData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

    rnd = arc4random_uniform((int)[userData count]);
    allDataArray=[[NSArray alloc]init];
    allDataArray = [userData objectAtIndex:rnd];
    [self viewDidAppear:YES];
    
    }
    
    
    
}


#pragma mark shareOn Default.
-(void)twitterShareAction:(id)sender
{
    
    NSString *summaryDescription;
    NSString *autherName;
    NSString *title;

            
            NSArray *summArray=[allDataArray valueForKey:@"summary"];
            summArray =[summArray objectAtIndex:0];
            NSString *strFirstName=[summArray valueForKey:@"first_name"];
            NSString *strLastName=[summArray valueForKey:@"last_name"];

            title=[NSString stringWithFormat:@"%@",[allDataArray valueForKey:@"topic_title"]];
            
            summaryDescription=[NSString stringWithFormat:@"%@%@",str_global_share,[summArray valueForKeyPath:@"seo_url"]];
            
            autherName=[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",title,@"\n\n",summaryDescription,@"\n\n",@"Author: ",strFirstName,@" ",strLastName];

            
            NSArray *objectsToShare = @[autherName];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
            
            NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                           UIActivityTypePrint,
                                           UIActivityTypeAssignToContact,
                                           UIActivityTypeSaveToCameraRoll,
                                           UIActivityTypeAddToReadingList,
                                           UIActivityTypePostToFlickr,
                                           UIActivityTypeMessage,
                                           UIActivityTypePostToVimeo];
            
            activityVC.excludedActivityTypes = excludeActivities;
            
            //if iPhone
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                [self presentViewController:activityVC animated:YES completion:nil];
            }
            //if iPad
            else
            {
                myPopover = [[UIPopoverController alloc] initWithContentViewController:activityVC];
                myPopover.delegate = self;
                [myPopover presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
    
            
            
            [activityVC setCompletionHandler:^(NSString *act, BOOL done)
             {
                 NSString *ServiceMsg = nil;
                 if ( [act isEqualToString:UIActivityTypeMail] )           ServiceMsg = @"Sent";
                 if ( [act isEqualToString:UIActivityTypePostToTwitter] )  ServiceMsg = @"Posted";
                 if ( [act isEqualToString:UIActivityTypePostToFacebook] ) ServiceMsg = @"Tweeted";
                 if ( [act isEqualToString:UIActivityTypePostToFlickr] ) ServiceMsg = @"Posted";
                 if ( [act isEqualToString:UIActivityTypeMessage] )        ServiceMsg = @"Success";
                 if ( done )
                 {
                     //UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:ServiceMsg message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
                     // [Alert show];
                     
                 }
             }];
    
    
}




#pragma mark changes Sachin Daingade ----


-(void)swipeleft:(UISwipeGestureRecognizer *)swipeGesture
{
   
    if([strRandomFlag isEqualToString:@"YES"])
    {
        [self RandomArticleCalled];
    }else
    {
    NSLog(@"%i",currIndex);
    
    if(currIndex ==[arrAllData count]-1)
    {
    }else
    {
        currIndex++;
        
        
       // allDataArray=[[NSArray alloc]init];
    allDataArray=[arrAllData objectAtIndex:currIndex];
        
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.50];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.layer addAnimation:animation forKey:kCATransition];
        
       //[self viewDidAppear:YES];
     //  [HUD showWhileExecuting:@selector(customViewDidAppear) onTarget:self withObject:nil animated:YES];
      [self customViewDidAppear];
    }
    
 }
}
-(void)swipeRight:(UISwipeGestureRecognizer *)swipeGesture
{
    if([strRandomFlag isEqualToString:@"YES"])
{
    [self RandomArticleCalled];
  
}else
{
    
       NSLog(@"%i",currIndex);
    if(currIndex <=0)
    {
        
    }else
    {
    
    currIndex--;
    allDataArray=[[NSArray alloc]init];
    allDataArray=[arrAllData objectAtIndex:currIndex];
        
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.40];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.layer addAnimation:animation forKey:kCATransition];
   
        
     //   [HUD showWhileExecuting:@selector(customViewDidAppear) onTarget:self withObject:nil animated:YES];
        [self customViewDidAppear];
        
    }
 }
    
}






-(void)customViewDidAppear
{
    myQueue = nil;
        dispatch_async(dispatch_get_main_queue(), ^{

       
    for (UIView *layer in self.custScrollView.subviews)
    {
        [layer removeFromSuperview];
    }
    [tagView removeFromSuperview];
    
    [imgViewSummary removeFromSuperview];
    
    [btnAuthorName removeFromSuperview];
    
    [mainTitle removeFromSuperview];
    
    [lblTopicDescription removeFromSuperview];
    
    [lblTopicTitle removeFromSuperview];
    
    [btnfirstNews removeFromSuperview];
    
    [lblfirstPublish removeFromSuperview];
    
    [btnSecondNews removeFromSuperview];
    
    [lblsecondPublish  removeFromSuperview];
    
    [btnthirdNews removeFromSuperview];
    
    [lblthirdPublish removeFromSuperview];
    
    [poweredByYahoo removeFromSuperview];
    
    [lblTop removeFromSuperview];
    [lblbtnSecond removeFromSuperview];
    [lblfirstNews removeFromSuperview];
    [lblbtnthird removeFromSuperview];
    [lblbottom removeFromSuperview];
    
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        nTagBtnHeight=30.0f;
        fontSize=24;
        maxWidth=620.00001f;
        btn_diff_Height=35;
        tbleHeight=90;
        tagViewY_height=81;
        
    }
    else
    {
        nTagBtnHeight=27.0f;
        fontSize=17;
        maxWidth=200.00001f;
        btn_diff_Height=35;
        tbleHeight=50;
        tagViewY_height=81;
    }
    
    
        
    // ImageView of summary
    NSString *strImage = [NSString stringWithFormat:@"%@",[allDataArray valueForKey:@"topic_image"]];
    
    if([strImage isEqualToString:@""]){
        
        imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
        imgViewSummary.contentMode = UIViewContentModeScaleAspectFit;
        [imgViewSummary setBackgroundColor:[UIColor whiteColor]];
        [custScrollView addSubview:imgViewSummary];
        
    }else{
        
        Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if (networkStatus == NotReachable) {
            
            NSString *filePath = [self documentsPathForFileName:strImage];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400)];
            }else{
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 205)];
            }
            
            if(pngData == NULL)
            {
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    imgViewSummary.image = [UIImage imageNamed:@"place_big_ipad.png"];
                }else{
                    imgViewSummary.image = [UIImage imageNamed:@"place_big_iphone.png"];
                }
                
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0)];
                imgViewSummary.contentMode = UIViewContentModeScaleAspectFit;
                [imgViewSummary setBackgroundColor:[UIColor whiteColor]];
                [custScrollView addSubview:imgViewSummary];
                
            }
            else
            {
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    imgViewSummary.image = [UIImage imageNamed:@"place_big_ipad.png"];
                }else{
                    imgViewSummary.image = [UIImage imageNamed:@"place_big_iphone.png"];
                }

                UIImage *image = [UIImage imageWithData:pngData];
                imgViewSummary.image = image;
                [imgViewSummary setBackgroundColor:[UIColor whiteColor]];
                imgViewSummary.contentMode = UIViewContentModeScaleAspectFit;
                [custScrollView addSubview:imgViewSummary];
            }
            
            
            
        } else {
            NSString *img=[NSString stringWithFormat:@"%@%@",str_global_summary_image,strImage] ;
            
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 400)];
            }else{
                imgViewSummary = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 205)];
            }
            
            NSString *filePath = [self documentsPathForFileName:strImage];
            NSData *pngData = [NSData dataWithContentsOfFile:filePath];
            if(pngData == NULL)
            {
                NSURL *url = [NSURL URLWithString:[img stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
               
                
                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                {
                    [imgViewSummary setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_ipad.png"]];
                }else{
                    [imgViewSummary setImageWithURL:url placeholderImage:[UIImage imageNamed:@"place_big_iphone.png"]];
                }
            }
            else
            {
                UIImage *image = [UIImage imageWithData:pngData];
                imgViewSummary.image = image;
                
            }
            
            [imgViewSummary setBackgroundColor:[UIColor whiteColor]];
            imgViewSummary.contentMode = UIViewContentModeScaleAspectFit;
            [custScrollView addSubview:imgViewSummary];
            
        }
        
    }
    
    
    // Topic
    strTopicTitle = [allDataArray valueForKey:@"topic_title"];
    attributedStringTopic = [[NSMutableAttributedString alloc] initWithString:strTopicTitle];
    NSMutableParagraphStyle *paragraphStyleTopic = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyleTopic setLineSpacing:5];
    [attributedStringTopic addAttribute:NSParagraphStyleAttributeName value:paragraphStyleTopic range:NSMakeRange(0, [strTopicTitle length])];
    
    stringTopicTitle = [NSString stringWithFormat:@"%@",attributedStringTopic];
    
    
    lblTopicTitle = [[UILabel alloc]initWithFrame:CGRectMake(10, imgViewSummary.frame.size.height+20, [UIScreen mainScreen].bounds.size.width-12, 60)];
    lblTopicTitle.attributedText = attributedStringTopic;
    lblTopicTitle.textAlignment = NSTextAlignmentLeft;
    lblTopicTitle.lineBreakMode = NSLineBreakByWordWrapping;
    [lblTopicTitle setTextColor:[UIColor blackColor]];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [lblTopicTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:25]];
    }else{
        [lblTopicTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:19]];
    }
    
    
    
    
    CGSize expectedTitleSize = [stringTopicTitle sizeWithFont:lblTopicTitle.font
                                            constrainedToSize:lblTopicTitle.frame.size
                                                lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect newFrameTitle = lblTopicTitle.frame;
    newFrameTitle.size.height = expectedTitleSize.height;
    lblTopicTitle.frame = newFrameTitle;
    lblTopicTitle.numberOfLines = 0;
    [lblTopicTitle sizeToFit];
    [custScrollView addSubview:lblTopicTitle];
    
    
    
    
    // Summary
    NSArray *summaryArray;
    
    summaryArray=[allDataArray valueForKey:@"summary"];
    summaryArray =[summaryArray objectAtIndex:0];
    strSummary=[summaryArray valueForKey:@"summary_desc"];
    
    
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"  " withString:@""];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    strSummary = [strSummary stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    
    attributedStringSummary = [[NSMutableAttributedString alloc]initWithString:strSummary];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:5];
    [attributedStringSummary addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [strSummary length])];
    
    strSummayDescription = [NSString stringWithFormat:@"%@",attributedStringSummary];
    lblTopicDescription = [[UILabel alloc]initWithFrame:CGRectMake(10, imgViewSummary.frame.size.height+lblTopicTitle.frame.size.height+40, [UIScreen mainScreen].bounds.size.width-15, 180)];
    lblTopicDescription.attributedText = attributedStringSummary;
    lblTopicDescription.textAlignment = NSTextAlignmentLeft;
    lblTopicDescription.lineBreakMode = NSLineBreakByWordWrapping;
    [lblTopicDescription setTextColor:[UIColor blackColor]];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        [lblTopicDescription setFont:[UIFont fontWithName:@"Helvetica" size:22]];
    }else{
        [lblTopicDescription setFont:[UIFont fontWithName:@"Helvetica" size:15]];
    }
    
    CGSize expectedLabelSize = [strSummayDescription sizeWithFont:lblTopicDescription.font
                                                constrainedToSize:lblTopicDescription.frame.size
                                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    CGRect newFrame = lblTopicDescription.frame;
    newFrame.size.height = expectedLabelSize.height;
    lblTopicDescription.frame = newFrame;
    lblTopicDescription.numberOfLines = 0;
    [lblTopicDescription sizeToFit];
    [custScrollView addSubview:lblTopicDescription];
    
    
    NSArray *maintagArray=[allDataArray valueForKey:@"tags"];
    if([maintagArray valueForKey:@"hashtags"])
    {
        
        NSString *hashString;
        allButtonsMutableArray=[[NSMutableArray alloc]init];
        
        for (int i=0; i<[maintagArray count]; i++) {
            NSDictionary *dict=[maintagArray objectAtIndex:i];
            
            UIButton *tagButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
            {
                tagButton.titleLabel.font = [UIFont systemFontOfSize:22.0];
            }else{
                tagButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
            }
            
            
            [tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [tagButton setBackgroundColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0]];
            
            tagButton.tag=i;
            [tagButton addTarget:self
                          action:@selector(hashTagAction:)
                forControlEvents:UIControlEventTouchUpInside];
            tagButton.layer.cornerRadius=5.0f;
            
            
            if(i==0)
            {
                btnX=4.2;
                btnY=0.10f;
                hashString=[NSString stringWithFormat:@"%@%@%@",@" ",[dict valueForKey:@"name"],@" "];
                //Calculate width
                font =[UIFont systemFontOfSize:fontSize];
                stringSize = [hashString sizeWithFont:font];
                btnWidth= stringSize.width;
                
                
                [tagButton setTitle:hashString forState:UIControlStateNormal];
                tagButton.frame = CGRectMake(btnX, btnY, btnWidth, nTagBtnHeight);
                
                btnX=btnWidth+07;
                
                
            }else
            {
                
                if(btnX>=maxWidth)
                {
                    hashString=[NSString stringWithFormat:@"%@%@%@",@" ",[dict valueForKey:@"name"],@" "];
                    //Calculate width
                    font =[UIFont systemFontOfSize:fontSize];
                    stringSize = [hashString sizeWithFont:font];
                    btnWidth= stringSize.width;
                    [tagButton setTitle:hashString forState:UIControlStateNormal];
                    btnY=btnY+btn_diff_Height;
                    btnX=4.2;
                    tagButton.frame = CGRectMake(btnX, btnY, btnWidth, nTagBtnHeight);
                    btnX=btnWidth+07;
                }else
                {
                    hashString=[NSString stringWithFormat:@"%@%@%@",@" ",[dict valueForKey:@"name"],@" "];
                    //Calculate width
                    font =[UIFont systemFontOfSize:fontSize];
                    stringSize = [hashString sizeWithFont:font];
                    btnWidth= stringSize.width;
                    [tagButton setTitle:hashString forState:UIControlStateNormal];
                    tagButton.frame = CGRectMake(btnX, btnY, btnWidth, nTagBtnHeight);
                    btnX+=btnWidth+07;
                }
            }
            
            [allButtonsMutableArray addObject:tagButton];
            
        }
        
        
        tagView =[[UIView alloc]initWithFrame:CGRectMake(7, imgViewSummary.frame.size.height+lblTopicTitle.frame.size.height+ lblTopicDescription.frame.size.height+60,[UIScreen mainScreen].bounds.size.width-15,btnY+nTagBtnHeight)];
        
        for(int j=0;j<[allButtonsMutableArray count];j++)
        {
            UIButton *btn=(UIButton *)[allButtonsMutableArray objectAtIndex:j];
            [tagView addSubview:btn];
        }
        tagView.backgroundColor=[UIColor whiteColor];
        [custScrollView addSubview:tagView];
        
    }
    
    
    // Author Name
    btnAuthorName = [[UIButton alloc]initWithFrame:CGRectMake(10, imgViewSummary.frame.size.height+lblTopicTitle.frame.size.height+ lblTopicDescription.frame.size.height+60+tagView.frame.size.height, 310, 60)];
    btnAuthorName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    
    NSArray *summArray=[allDataArray valueForKey:@"summary"];
    summArray =[summArray objectAtIndex:0];
    NSString *strFirstName=[summArray valueForKey:@"first_name"];
    NSString *strLastName=[summArray valueForKey:@"last_name"];
    
    [btnAuthorName addTarget:self action:@selector(btnAuthorNameClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [btnAuthorName setTitle:[NSString stringWithFormat:@"%@%@%@%@",@"Author: ",strFirstName,@" ",strLastName] forState:UIControlStateNormal];
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        btnAuthorName.titleLabel.font = [UIFont systemFontOfSize:22];
    }else{
        btnAuthorName.titleLabel.font = [UIFont systemFontOfSize:15];
    }
    
    
    [btnAuthorName setTitleColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
    
    
    [custScrollView addSubview:btnAuthorName];
    
    float heightoftitle = 50;
    
    // NEWS
    heightoftitle = imgViewSummary.frame.size.height+lblTopicTitle.frame.size.height+ lblTopicDescription.frame.size.height+60+tagView.frame.size.height+50;
    
   
        newsArray = [[NSArray alloc]init];
        if([allDataArray count]>0)
        {
           
             myQueue = dispatch_queue_create("My Queue888",NULL);
            dispatch_async(myQueue, ^{
                NSString * jsonRequest = [NSString stringWithFormat:@"topic_id=%@",[allDataArray valueForKey:@"topic_id"]];
                NSString *str_ComplrteUrl = [NSString stringWithFormat:@"%@%@%@",str_global_domain,@"ws-in-the-news?",jsonRequest] ;
                BaseViewController *baseviewcontroller = [[BaseViewController alloc]init];
                NSDictionary *dict12=[baseviewcontroller WebParsingMethod:str_ComplrteUrl :@""];
                 dispatch_async(dispatch_get_main_queue(), ^{
                if([[[dict12 valueForKeyPath:@"result"]valueForKeyPath:@"msg"]isEqualToString:@"success"])
                {
                    
                    newsArray=[[dict12 valueForKeyPath:@"result"]valueForKeyPath:@"result"];
                    if([newsArray count]>0){
                        [lblTop removeFromSuperview];
                        lblTop=[[UILabel alloc]initWithFrame:CGRectMake(0, heightoftitle, [UIScreen mainScreen].bounds.size.width, 1)];
                        lblTop.backgroundColor=[UIColor lightGrayColor] ;
                        [custScrollView addSubview:lblTop];
                        [mainTitle removeFromSuperview];
                        mainTitle=[[UILabel alloc]initWithFrame:CGRectMake(10,heightoftitle+10, [UIScreen mainScreen].bounds.size.width-10, 30)];
                        mainTitle.text=@"In the News";
                        mainTitle.textColor=[UIColor blackColor];
                        
                        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                        {
                            mainTitle.font=[UIFont fontWithName:@"Helvetica-Bold" size:25];
                        }else{
                            mainTitle.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
                        }
                        
                        
                        [custScrollView addSubview:mainTitle];
                        
                        [lblfirstNews removeFromSuperview];
                        [btnfirstNews removeFromSuperview];
                        [lblfirstPublish removeFromSuperview];
                        [lblbtnSecond removeFromSuperview];
                        [lblbtnSecond removeFromSuperview];
                        [btnSecondNews removeFromSuperview];
                        [lblsecondPublish removeFromSuperview];
                        [lblbtnthird removeFromSuperview];
                        [btnthirdNews removeFromSuperview];
                        [lblthirdPublish removeFromSuperview];
                        [lblbottom removeFromSuperview];
                        [poweredByYahoo removeFromSuperview];
                        
                        
                        lblfirstNews=[[UILabel alloc]initWithFrame:CGRectMake(1,  heightoftitle+mainTitle.frame.size.height+20, [UIScreen mainScreen].bounds.size.width, 0.5)];
                        lblfirstNews.backgroundColor=[UIColor grayColor] ;
                        [custScrollView addSubview:lblfirstNews];
                        
                        
                        btnfirstNews=[[UIButton alloc]initWithFrame:CGRectMake(10, heightoftitle+mainTitle.frame.size.height+30, [UIScreen mainScreen].bounds.size.width-15, 30)];
                        
                        lblfirstPublish=[[UILabel alloc]initWithFrame:CGRectMake(10, heightoftitle+btnfirstNews.frame.size.height+60, [UIScreen mainScreen].bounds.size.width-15, 30)];
                        
                        
                        
                        lblbtnSecond=[[UILabel alloc]initWithFrame:CGRectMake(1, heightoftitle+lblfirstPublish.frame.size.height+90, [UIScreen mainScreen].bounds.size.width, 0.5)];
                        lblbtnSecond.backgroundColor=[UIColor grayColor] ;
                        [custScrollView addSubview:lblbtnSecond];
                        
                        
                        btnSecondNews=[[UIButton alloc]initWithFrame:CGRectMake(10, heightoftitle+lblfirstPublish.frame.size.height+100,[UIScreen mainScreen].bounds.size.width-15, 30)];
                        
                        lblsecondPublish=[[UILabel alloc]initWithFrame:CGRectMake(10, heightoftitle+btnSecondNews.frame.size.height+130, [UIScreen mainScreen].bounds.size.width-15, 30)];
                        
                        lblbtnthird=[[UILabel alloc]initWithFrame:CGRectMake(1, heightoftitle+lblsecondPublish.frame.size.height+160, [UIScreen mainScreen].bounds.size.width, 0.5)];
                        lblbtnthird.backgroundColor=[UIColor grayColor] ;
                        [custScrollView addSubview:lblbtnthird];
                        
                        
                      
                        
                        btnthirdNews=[[UIButton alloc]initWithFrame:CGRectMake(10, heightoftitle+lblsecondPublish.frame.size.height+170, [UIScreen mainScreen].bounds.size.width-15, 30)];
                        
                        lblthirdPublish=[[UILabel alloc]initWithFrame:CGRectMake(10, heightoftitle+btnthirdNews.frame.size.height+200, [UIScreen mainScreen].bounds.size.width-15, 30)];
                        
                        lblbottom=[[UILabel alloc]initWithFrame:CGRectMake(1, heightoftitle+lblthirdPublish.frame.size.height+230, [UIScreen mainScreen].bounds.size.width, 0.5)];
                        lblbottom.backgroundColor=[UIColor grayColor] ;
                        [custScrollView addSubview:lblbottom];
                        
                        
                        
                        poweredByYahoo=[[UIButton alloc]initWithFrame:CGRectMake(120, heightoftitle+lblthirdPublish.frame.size.height+215, [UIScreen mainScreen].bounds.size.width-40, 60)];
                        
                        for(int i=0 ;i<[newsArray count];i++)
                        {
                            NSArray *titleArray=[newsArray objectAtIndex:i];
                            
                            NSString* urlString = [NSString stringWithFormat:@"%@",[titleArray valueForKeyPath:@"title"]];
                            urlString = [urlString stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
                            urlString = [urlString stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
                            urlString = [urlString stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                            urlString = [urlString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
                            urlString = [urlString stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
                            urlString = [urlString stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
                            
                            if(i==0)
                            {
                                //Button
                                [btnfirstNews setTitle:urlString forState:UIControlStateNormal];
                                btnfirstNews.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                                [btnfirstNews.titleLabel setTextAlignment: NSTextAlignmentLeft];
                                [btnfirstNews.titleLabel setNumberOfLines:2];
                                
                                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                                {
                                    btnfirstNews.titleLabel.font = [UIFont systemFontOfSize:20];
                                }else{
                                    btnfirstNews.titleLabel.font = [UIFont systemFontOfSize:14];
                                }
                                
                                [btnfirstNews setTitleColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
                                
                                btnfirstNews.tag=i;
                                [btnfirstNews addTarget:self action:@selector(openWebview:) forControlEvents:UIControlEventTouchUpInside];
                                [custScrollView addSubview:btnfirstNews];
                                
                                //Label
                                NSArray *tempArray = [[titleArray valueForKeyPath:@"pubDate"] componentsSeparatedByString:@" "];
                                NSMutableString *strDate;
                                strDate = [[NSMutableString alloc]init];
                                for(int i=0;i<4;i++){
                                    
                                    [strDate appendString:[tempArray objectAtIndex:i]];
                                    [strDate appendString:@" "];
                                }
                                
                                lblfirstPublish.text=strDate;
                                
                                
                                lblfirstPublish.textColor=[UIColor lightGrayColor];
                                
                                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                                {
                                    lblfirstPublish.font=[UIFont systemFontOfSize:15];
                                }else{
                                    lblfirstPublish.font=[UIFont systemFontOfSize:13];
                                }
                                
                                
                                [custScrollView addSubview:lblfirstPublish];
                                
                            }else if(i==1)
                            {
                                //button
                                [btnSecondNews setTitle:urlString forState:UIControlStateNormal];
                                btnSecondNews.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                                [btnSecondNews.titleLabel setTextAlignment: NSTextAlignmentLeft];
                                [btnSecondNews.titleLabel setNumberOfLines:2];
                                
                                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                                {
                                    btnSecondNews.titleLabel.font = [UIFont systemFontOfSize:20];
                                }else{
                                    btnSecondNews.titleLabel.font = [UIFont systemFontOfSize:14];
                                }
                                
                                
                                [btnSecondNews setTitleColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
                                
                                [btnSecondNews addTarget:self action:@selector(openWebview:) forControlEvents:UIControlEventTouchUpInside];
                                [custScrollView addSubview:btnSecondNews];
                                btnSecondNews.tag=i;
                                
                                NSArray *tempArray = [[titleArray valueForKeyPath:@"pubDate"] componentsSeparatedByString:@" "];
                                NSMutableString *strDate;
                                strDate = [[NSMutableString alloc]init];
                                for(int i=0;i<4;i++){
                                    
                                    [strDate appendString:[tempArray objectAtIndex:i]];
                                    [strDate appendString:@" "];
                                }
                                
                                lblsecondPublish.text=strDate;
                                
                                
                                lblsecondPublish.textColor=[UIColor lightGrayColor];
                                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                                {
                                    lblsecondPublish.font=[UIFont systemFontOfSize:15];
                                }else{
                                    lblsecondPublish.font=[UIFont systemFontOfSize:13];
                                }
                                
                                
                                [custScrollView addSubview:lblsecondPublish];
                                
                            }
                            else if(i==2)
                            {
                                
                                //button
                                [btnthirdNews setTitle:urlString forState:UIControlStateNormal];
                                btnthirdNews.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                                [btnthirdNews.titleLabel setTextAlignment: NSTextAlignmentLeft];
                                [btnthirdNews.titleLabel setNumberOfLines:2];
                                
                                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                                {
                                    btnthirdNews.titleLabel.font = [UIFont systemFontOfSize:20];
                                }else{
                                    btnthirdNews.titleLabel.font = [UIFont systemFontOfSize:14];
                                }
                                
                                
                                [btnthirdNews setTitleColor:[UIColor colorWithRed:117/255.0f green:214/255.f blue:255/255.0f alpha:1.0] forState:UIControlStateNormal];
                                
                                [custScrollView addSubview:btnthirdNews];
                                [btnthirdNews addTarget:self action:@selector(openWebview:) forControlEvents:UIControlEventTouchUpInside];
                                btnthirdNews.tag=i;
                                
                                //Label
                                NSArray *tempArray = [[titleArray valueForKeyPath:@"pubDate"] componentsSeparatedByString:@" "];
                                NSMutableString *strDate;
                                strDate = [[NSMutableString alloc]init];
                                for(int i=0;i<4;i++){
                                    
                                    [strDate appendString:[tempArray objectAtIndex:i]];
                                    [strDate appendString:@" "];
                                }
                                
                                lblthirdPublish.text=strDate;
                                lblthirdPublish.textColor=[UIColor lightGrayColor];
                                
                                if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
                                {
                                    lblthirdPublish.font=[UIFont systemFontOfSize:15];
                                }else{
                                    lblthirdPublish.font=[UIFont systemFontOfSize:13];
                                }
                                
                                
                                [custScrollView addSubview:lblthirdPublish];
                                
                                
                                //News provide
                                [poweredByYahoo setImage:[UIImage imageNamed:@"purple.png"] forState:UIControlStateNormal];
                                [poweredByYahoo addTarget:self action:@selector(openYahoo:) forControlEvents:UIControlEventTouchUpInside];
                                
                                [custScrollView addSubview:poweredByYahoo];
                                
                            }
                        }
                        
                    }
                }
                
            }); });
        }

        

    
   // [HUD hide:YES];
    
    float scrollheight = heightoftitle+lblthirdPublish.frame.size.height+320;
    
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
        custScrollView.contentSize= CGSizeMake([UIScreen mainScreen].bounds.size.width,scrollheight);
    }else{
        CGSize iOSDeviceScreenSize = [[UIScreen mainScreen] bounds].size;
        if(iOSDeviceScreenSize.height == 480){
            
            custScrollView.contentSize= CGSizeMake([UIScreen mainScreen].bounds.size.width,scrollheight+95);
            
        }else{
            custScrollView.contentSize= CGSizeMake([UIScreen mainScreen].bounds.size.width,scrollheight);
        }
        
    }
    });
   [self.custScrollView setContentOffset:CGPointZero animated:YES];
}





@end
