//
//  RotatingViewController.h
//  iResume
//
//  Created by Panacea on 02/04/2013.
//  Copyright (c) 2013 panaceatek. All rights reserved.

@interface RotatingViewController : UIViewController

- (void) saveUiState;

- (void) adjustLayoutForPortrait: (BOOL)isPortrait insideFrame: (CGRect) parentFrame;

- (UIImage*) imageNamed: (NSString*) baseName;

@end
