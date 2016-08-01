//
//  ChatLabel.m
//  School Intercom
//
//  Created by Randall Rumple on 10/29/15.
//  Copyright © 2015 Randall Rumple. All rights reserved.
//

#import "ChatLabel.h"

@implementation ChatLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
