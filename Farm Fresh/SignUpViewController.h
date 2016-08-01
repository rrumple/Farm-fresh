//
//  SignUpViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/11/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface SignUpViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic) BOOL isLogin;

@end
