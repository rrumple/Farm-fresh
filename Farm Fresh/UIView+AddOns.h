//
//  UIView+AddOns.h
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AddOns)

+ (UIImage * _Null_unspecified)captureView:(UIView * _Null_unspecified)view;

+ (UITapGestureRecognizer * _Null_unspecified)setupTapGestureWithTarget:(id _Nullable)target Action:(SEL _Nullable)selector cancelsTouchesInview:(BOOL)cancelTouches setDelegate:(BOOL)hasDelegate;

+ (UIAlertController * _Null_unspecified)createSimpleAlertWithMessage:(NSString * _Nullable)message andTitle:(NSString * _Nullable)title withOkButton:(BOOL)useOkButton;

+ (float)moveScreenUp:(UIView * _Null_unspecified)textField andView:(UIView * _Null_unspecified)view;

+ (void)moveScreenDownWithView:(UIView * _Null_unspecified)view andDistance:(float)animatedDistance;
@end
