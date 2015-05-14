//
//  TPKeyboardAvoidingScrollView.h
//  iResume
//
//  Created by Panacea on 02/04/2013.
//  Copyright (c) 2013 panaceatek. All rights reserved.

#import <UIKit/UIKit.h>

@interface TPKeyboardAvoidingScrollView : UIScrollView {
    UIEdgeInsets    _priorInset;
    BOOL            _priorInsetSaved;
    BOOL            _keyboardVisible;
    CGRect          _keyboardRect;
    CGSize          _originalContentSize;
}

- (void)adjustOffsetToIdealIfNeeded;
@end
