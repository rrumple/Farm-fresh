//
//  FarmEditViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 3/17/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import "Constants.h"

@interface FarmEditViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic) BOOL isFirstTimeSetup;
@property (nonatomic, strong) UIImage *menuImage;

@end
