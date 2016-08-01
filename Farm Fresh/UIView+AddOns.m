//
//  UIView+AddOns.m
//  School Intercom
//
//  Created by Randall Rumple on 11/28/13.
//  Copyright (c) 2013 Randall Rumple. All rights reserved.
//

#import "UIView+AddOns.h"
#import "Constants.h"

@implementation UIView (AddOns)

+ (UIImage * _Null_unspecified)captureView:(UIView * _Null_unspecified)view
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    
    [view.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UITapGestureRecognizer * _Null_unspecified)setupTapGestureWithTarget:(id _Nullable)target Action:(SEL _Nullable)selector cancelsTouchesInview:(BOOL)cancelTouches setDelegate:(BOOL)hasDelegate
{
    
    UITapGestureRecognizer *gestureRecgnizer = [[UITapGestureRecognizer alloc]initWithTarget:target action:selector];
    gestureRecgnizer.cancelsTouchesInView = cancelTouches;
    if(hasDelegate)
        gestureRecgnizer.delegate = target;
    
    return gestureRecgnizer;
    
}

+ (UIAlertController * _Null_unspecified)createSimpleAlertWithMessage:(NSString * _Nullable)message andTitle:(NSString * _Nullable)title withOkButton:(BOOL)useOkButton
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle: title
                                                                        message: message
                                                                 preferredStyle: UIAlertControllerStyleAlert];
    
    
    UIAlertAction *alertAction;
    
    if(useOkButton)
        alertAction =[UIAlertAction actionWithTitle: @"Ok"
                                              style: UIAlertActionStyleDefault
                                            handler: ^(UIAlertAction *action) {
                                                
                                            }];
    else
        alertAction = [UIAlertAction actionWithTitle: @"Dismiss"
                                               style: UIAlertActionStyleDestructive
                                             handler: ^(UIAlertAction *action) {
                                                 
                                             }];
    
    [controller addAction: alertAction];
    
    return controller;
}

+ (float)moveScreenUp:(UIView * _Null_unspecified)textField andView:(UIView * _Null_unspecified)view
{
    float animatedDistance = 0.0;
    
    CGRect textFieldRect = [view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [view.window convertRect:view.bounds fromView:view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        
        heightFraction = 0.0;
        
    }else if(heightFraction > 1.0){
        
        heightFraction = 1.0;
    }
    
    animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    
    
    CGRect viewFrame = view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    return animatedDistance;
    
}

+ (void)moveScreenDownWithView:(UIView * _Null_unspecified)view andDistance:(float)animatedDistance
{
    CGRect viewFrame = view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [view setFrame:viewFrame];
    [UIView commitAnimations];
}

@end
