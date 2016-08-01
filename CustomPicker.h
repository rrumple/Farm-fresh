//
//  CustomPicker.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/17/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPicker : UIView

+ (UIView * _Null_unspecified)createPickerWithTag :(NSInteger)tag withDelegate:(id<UIPickerViewDelegate> _Nullable)delegate andDataSource:(id<UIPickerViewDataSource> _Nullable)dataSource target:(id _Nullable)target action:(SEL _Nullable)selector andWidth:(float)width;
+(UIView * _Null_unspecified)createAccessoryViewWithTitle:(NSString * _Null_unspecified)title target:(id _Nullable)target action:(SEL _Nullable)selector;
@end
