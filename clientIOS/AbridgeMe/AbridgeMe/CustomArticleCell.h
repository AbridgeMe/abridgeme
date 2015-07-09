//
//  CustomArticleCell.h
//  AbridgeMe
//
//  Created by Lion on 14/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomArticleCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UIImageView *imgviewArticle;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;




- (void)cellOnTableView:(UITableView *)tableView didScrollOnView:(UIView *)view;

@end
