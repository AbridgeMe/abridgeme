//
//  RotatingViewController.m
//  iResume
//
//  Created by Panacea on 02/04/2013.
//  Copyright (c) 2013 panaceatek. All rights reserved.

#import "RotatingViewController.h"

@interface RotatingViewController() {
@private
    BOOL hasTwoNibs;
    BOOL inTransition;
    NSString* currentNibName;
}
@property (nonatomic, strong) NSString* currentNibName;
- (void) switchViews: (BOOL)toPortrait;
- (CGRect) targetFrameForPortrait: (BOOL)isPortrait;

@end

@implementation RotatingViewController

@synthesize currentNibName;

#pragma mark - Initialization

- (void)customInit {
    // Custom initialization
    NSString* className = NSStringFromClass([self class]);
    NSString* landscapeNibName = [NSString stringWithFormat: @"%@-landscape", className];
    // bundle resource file will be ViewControllerClassName-landscape.nib (not .xib!)
    hasTwoNibs = ([[NSBundle mainBundle] pathForResource: landscapeNibName ofType:@"nib"] != nil); 
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self customInit];
        self.currentNibName = nibNameOrNil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder: decoder];
    if (self) {
        [self customInit];
    }
    return self;
}

#pragma mark - View lifecycle




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // default autoresizing behaviour ... subclasses may override
    self.view.autoresizesSubviews = YES;
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | 
                                  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | 
                                  UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin);
    
    if (self.currentNibName == nil) {
        self.currentNibName = self.nibName;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    // check to see whether we're switching to this view controller in the "wrong" orientation
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(self.interfaceOrientation);
    if (hasTwoNibs) {
        if (([currentNibName rangeOfString: @"-landscape" 
                                   options: NSCaseInsensitiveSearch].location == NSNotFound) != isPortrait) {
            // orientation mismatch!
            [self switchViews: isPortrait];
        }
    } else {
        CGRect frame = [self targetFrameForPortrait: isPortrait];
        [self adjustLayoutForPortrait: isPortrait insideFrame: frame];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void) saveUiState {
    // default implementation does nothing
}

#pragma mark - Orientation Handling

-(void) adjustLayoutForPortrait:(BOOL)isPortrait insideFrame: (CGRect) parentFrame {
    // default implementation does nothing
}

- (UIImage*) imageNamed: (NSString*) baseName {
    
    NSString* imgName;
    BOOL fetchPortraitVersion = (inTransition ? UIInterfaceOrientationIsLandscape(self.interfaceOrientation) :
                                 UIInterfaceOrientationIsPortrait(self.interfaceOrientation));
    
    if (fetchPortraitVersion) {
        imgName = baseName;
    } else {
        // WARNING: this assumes one, and only one period ('.') in the basename!!
        imgName = [baseName stringByReplacingOccurrencesOfString: @"."
                                                      withString: @"-landscape."];
    }
    return [[UIImage alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: imgName
                                                                                    ofType: nil]];
}

- (void)switchViews: (BOOL)isPortrait {
    // must (re)load this view
    NSString* nibName = isPortrait ? NSStringFromClass([self class]) : 
    [NSString stringWithFormat:@"%@-landscape", NSStringFromClass([self class])];
    
    NSArray* results = [[NSBundle mainBundle] loadNibNamed: nibName  
                                                     owner: self
                                                   options: nil];
    
    for (id v in results) {
        if ([[v class] isSubclassOfClass: [UIView class]]) {
            self.view = (UIView*)v;
            break;
        }
    }
    // this must be called manually to re-establish IBOutlets, and other initialization
    [self viewDidLoad]; 
    
    self.currentNibName = nibName;
}

- (CGRect) targetFrameForPortrait: (BOOL)isPortrait {
    // for convenience, pass the subclass what the frame WILL BE, which usually
    //   helps in adjustLayoutForPortrait:
    CGRect frame = self.view.frame;
    CGRect screen = [[UIScreen mainScreen] bounds];
    // use MIN and MAX just because I don't trust these results :(
    int smallerBound = MIN(screen.size.height, screen.size.width);
    int largerBound = MAX(screen.size.height, screen.size.width);
    int verticalSpaceLost = isPortrait ? smallerBound - frame.size.height : largerBound - frame.size.height;
    
    int temp = frame.size.height;
    frame.size.height = frame.size.width - verticalSpaceLost;
    frame.size.width = temp + verticalSpaceLost;
    
    return frame;
}

- (void)animateToPortrait: (BOOL)toPortrait duration: (NSTimeInterval) duration {
    CGRect frame = [self targetFrameForPortrait: toPortrait];
    
    [UIView animateWithDuration: duration
                          delay: 0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^(void) {
                        [self adjustLayoutForPortrait: toPortrait insideFrame: frame];
                     }
                     completion: ^(BOOL finished) {
                         // code to run after animation completes can go here
                     }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation: toInterfaceOrientation duration: duration];
    
    inTransition = YES;
    BOOL toPortrait = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
    if (hasTwoNibs) {
        [self saveUiState];
        [self switchViews: toPortrait];
    } else {
        if (toPortrait) {
            [self animateToPortrait:YES duration: duration];
        } else { 
            [self animateToPortrait:NO duration: duration];
        }
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation: fromInterfaceOrientation];
    
    inTransition = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
