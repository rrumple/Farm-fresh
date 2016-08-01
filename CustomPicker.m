//
//  CustomPicker.m
//  Farm Fresh
//
//  Created by Randall Rumple on 3/17/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import "CustomPicker.h"

@implementation CustomPicker

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (UIView * _Null_unspecified)createPickerWithTag :(NSInteger)tag withDelegate:(id<UIPickerViewDelegate> _Nullable)delegate andDataSource:(id<UIPickerViewDataSource> _Nullable)dataSource target:(id _Nullable)target action:(SEL _Nullable)selector andWidth:(float)width
{
    
    UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, width, 216)];
    pickerView.tag = tag;
   
    pickerView.dataSource = dataSource;
    pickerView.delegate = delegate;
  
    
    [pickerView setShowsSelectionIndicator:YES];
    
   
    
    return pickerView;
}

+(UIView * _Null_unspecified)createAccessoryViewWithTitle:(NSString * _Null_unspecified)title target:(id _Nullable)target action:(SEL _Nullable)selector
{
    UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:title
                                                                   style:UIBarButtonItemStylePlain target:target
                                                                  action:selector];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    
    return keyboardDoneButtonView;
}

@end
