//
//  EditProfileImageViewController.h
//  Farm Fresh
//
//  Created by Randall Rumple on 5/15/16.
//  Copyright © 2016 Farm Fresh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
#import "Constants.h"

@interface EditProfileImageViewController : UIViewController

@property (nonatomic, strong) UserModel *userData;
@property (nonatomic) NSInteger mode;

@end
