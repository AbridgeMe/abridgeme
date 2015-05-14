//
//  TPKeyboardAvoidingTableView.h
//  iResume
//
//  Created by Panacea on 02/04/2013.
//  Copyright (c) 2013 panaceatek. All rights reserved.

#import <UIKit/UIKit.h>

@interface TPKeyboardAvoidingTableView : UITableView {
    UIEdgeInsets    _priorInset;
    BOOL            _priorInsetSaved;
    BOOL            _keyboardVisible;
    CGRect          _keyboardRect;
}

- (void)adjustOffsetToIdealIfNeeded;
@end
