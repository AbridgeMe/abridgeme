#import <UIKit/UIKit.h>

typedef void (^RevealBlock)();


@protocol ISColumnsControllerChild <NSObject>
@optional
- (void)didBecomeActive;
- (void)didResignActive;
@end

@interface ISColumnsController : UIViewController <UIScrollViewDelegate>

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;


@property (retain, nonatomic) NSArray       *viewControllers;
@property (retain, nonatomic) UIScrollView  *scrollView;
@property (retain, nonatomic) UILabel       *titleLabel;
@property (retain, nonatomic) UIPageControl *pageControl;

@end
