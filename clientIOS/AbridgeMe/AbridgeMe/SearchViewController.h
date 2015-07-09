//
//  SearchViewController.h
//  AbridgeMe
//
//  Created by Lion on 15/04/14.
//  Copyright (c) 2014 panaceatek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


typedef void (^RevealBlock)();

@interface SearchViewController : UIViewController<UISearchBarDelegate,MBProgressHUDDelegate>{
    int currentMaxDisplayedCell;
    int currentMaxDisplayedSection;
    
    NSMutableString *autoCompleteString;
    NSMutableArray *autoCompleteArray;
    MBProgressHUD *HUD;
@protected
    
    BOOL isDragging;
    BOOL isRefreshing;
    BOOL isLoadingMore;
    
    CGRect headerViewFrame;
    
    IBOutlet UISearchBar *searchBar;
    
}

@property(nonatomic,strong)UISearchBar *searchBar;
@property(strong,nonatomic) NSString *strNavigationFlag;
@property(nonatomic,strong)NSMutableArray *allDataArray;
@property(nonatomic,strong)NSArray *allHashArray,*allTopic;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;








/**  @property cellZoomXScaleFactor
 *   @brief The X Zoom Factor
 *   How much to scale to x axis of the cell before it is animated back to normal size. 1 is normal size. >1 is bigger, <1 is smaller. Default if not set is 1.25 **/
@property (strong, nonatomic) NSNumber* cellZoomXScaleFactor;

/**  @property cellZoomYScaleFactor
 *   @brief The Y Zoom Factor
 *   How much to scale to y axis of the cell before it is animated back to normal size. 1 is normal size. >1 is bigger, <1 is smaller. Default if not set is 1.25 **/
@property (strong, nonatomic) NSNumber* cellZoomYScaleFactor;

/**  @property cellZoomXOffset
 *   @brief Specify an X offset (in pixels) for the animation's initial position
 *   Allows you to specify an X offset (in pixels) for the animation's initial position, so for example if you say -50 this will mean as well as the rest of the animation, the cell also comes in from 50 pixels to the left of the screen. If you say 100 it will come in from 100 pixels to the right of the screen. Combine it with the cellZoomYOffset to get the cell to come in diagonally (see TabThreeViewController in Demo examples). If not set, the default is 0.  **/
@property (strong, nonatomic) NSNumber* cellZoomXOffset;

/**  @property cellZoomYOffset
 *   @brief Specify a Y offset (in pixels). for the animations initial position
 *   Allows you to specify a Y offset (in pixels) for the animation's initial position, so for example if you say -50 this will mean as well as the rest of the animation, the cell also comes in from 50 pixels to the top of the screen. If you say 100 it will come in from 100 pixels to the bottom of the screen. Combine it with the cellZoomXOffset to get the cell to come in diagonally (see TabThreeViewController in Demo examples). If not set, the default is 0.  **/
@property (strong, nonatomic) NSNumber* cellZoomYOffset;

/**  @property cellZoomInitialAlpha
 *   @brief The inital Alpha value of the cell
 *   The initial alpha value of the cell when it starts animation. For example if you set this to be 0 then the cell will begin completely transparent, and will fade into view as well as zooming. Value between 0 and 1. Default if not set is 0.3 **/
@property (strong, nonatomic) NSNumber* cellZoomInitialAlpha;

/**  @property cellZoomAnimationDuration
 *   @brief The Animation Duration
 *   The duration of the animation effect, in seconds. Default if not set is 0.65 seconds **/
@property (strong, nonatomic) NSNumber* cellZoomAnimationDuration;

/*
 Resets the view counter. The animation effect doesnt repeat when you've already seen a cell once, for example if you scroll down past cell #5, then scroll back to the top and down again, the animation won't repeat as you scroll back down past #5. This is by design to make only "new" cells animate as they appear. Call this method to reset the count of which cells have been seen (e.g when you call reload on the table's data)
 */
-(void)resetViewedCells;


@property(nonatomic,retain) IBOutlet UITableView *tblviewArticle;










// The view used for "pull to refresh"
@property (nonatomic, retain) UIView *headerView1;

// The view used for "load more"
@property (nonatomic, retain) UIView *footerView1;

@property (readonly) BOOL isDragging;
@property (readonly) BOOL isRefreshing;
@property (readonly) BOOL isLoadingMore;
@property (nonatomic) BOOL canLoadMore;

@property (nonatomic) BOOL pullToRefreshEnabled;

// Defaults to YES
@property (nonatomic) BOOL clearsSelectionOnViewWillAppear;


#pragma mark - Pull to Refresh

// The minimum height that the user should drag down in order to trigger a "refresh" when
// dragging ends.
- (CGFloat) headerRefreshHeight;

// Will be called if the user drags down which will show the header view. Override this to
// update the header view (e.g. change the label to "Pull down to refresh").
- (void) willShowHeaderView:(UIScrollView *)scrollView;

// If the user is dragging, will be called on every scroll event that the headerView is shown.
// The value of willRefreshOnRelease will be YES if the user scrolled down enough to trigger a
// "refresh" when the user releases the drag.
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView;

// By default, will permanently show the headerView by setting the tableView's contentInset.
- (void) pinHeaderView;

// Reverse of pinHeaderView.
- (void) unpinHeaderView;

// Called when the user stops dragging and, if the conditions are met, will trigger a refresh.
- (void) willBeginRefresh;

// Override to perform fetching of data. The parent method [super refresh] should be called first.
// If the value is NO, -refresh should be aborted.
- (BOOL) refresh;

// Call to signal that refresh has completed. This will then hide the headerView.
- (void) refreshCompleted;

#pragma mark - Load More

// The value of the height starting from the bottom that the user needs to scroll down to in order
// to trigger -loadMore. By default, this will be the height of -footerView.
- (CGFloat) footerLoadMoreHeight;

// Override to perform fetching of next page of data. It's important to call and get the value of
// of [super loadMore] first. If it's NO, -loadMore should be aborted.
- (BOOL) loadMore;

// Called when all the conditions are met and -loadMore will begin.
- (void) willBeginLoadingMore;

// Call to signal that "load more" was completed. This should be called so -isLoadingMore is
// properly set to NO.
- (void) loadMoreCompleted;

// Helper to show/hide -footerView
- (void) setFooterViewVisibility:(BOOL)visible;

#pragma mark -

// A helper method that calls refreshCompleted and/or loadMoreCompleted if any are active.
- (void) allLoadingCompleted;


@end
