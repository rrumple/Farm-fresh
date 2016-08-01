//
//  ChatMessagesViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/22/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface ChatMessagesViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic, strong) NSDictionary *userSelected;
@property (nonatomic) NSInteger userType;

@end
